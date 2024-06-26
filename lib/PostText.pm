package PostText;

# Sep 22 2022

use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Util qw{b64_encode gzip};
use Mojo::Pg;
use Crypt::Passphrase;
use Text::Markdown qw{markdown};
use HTML::Restrict;

# The local libs
use PostText::Model::Thread;
use PostText::Model::Remark;
use PostText::Model::Moderator;
use PostText::Model::Page;

sub startup($self) {
    $self->plugin('Config');
    $self->plugin('TagHelpers::Pagination');

    # Helpers
    $self->helper(pg => sub ($c) {
        state $pg = Mojo::Pg->new($c->config->{$self->mode}{'pg_string'})
    });

    $self->helper(authenticator => sub ($c) {
        state $authenticator = Crypt::Passphrase->new(encoder => 'Argon2')
    });

    $self->helper(hr => sub ($c) {
        state $hr = HTML::Restrict->new(
            filter_text            => 0,
            strip_enclosed_content => [],
            rules                  => {
                br => [],
                s  => []
            })
    });

    $self->helper(thread => sub ($c) {
        state $thread = PostText::Model::Thread->new(
            pg => $c->pg,
            hr => $c->hr
            )
    });

    $self->helper(remark => sub ($c) {
        state $remark = PostText::Model::Remark->new(
            pg => $c->pg,
            hr => $c->hr
            )
    });

    $self->helper(moderator => sub ($c) {
        state $moderator = PostText::Model::Moderator->new(
            pg            => $c->pg,
            authenticator => $c->authenticator
            )
    });

    $self->helper(page => sub ($c) {
        state $moderator = PostText::Model::Page->new(pg => $c->pg)
    });

    $self->helper(truncate_text => sub ($c, $input_text) {
        my $truncated_text = 299 < length($input_text)
            ? substr($input_text, 0, 299) . '…' : $input_text;

        return $truncated_text;
    });

    $self->helper(is_mod => sub ($c) {
        if (my $mod_id = $c->session->{'mod_id'}) {
            return 1 unless $c->moderator->lock_status($mod_id)
        }

        return undef;
    });

    $self->helper(is_admin => sub ($c) {
        $c->session->{'is_admin'} || undef
    });

    $self->helper(markdown => sub ($c, $input_text) {
        markdown($input_text, {empty_element_suffix => '>'})
    });

    # Finish configuring some things
    $self->secrets($self->config->{'secrets'}) || die $@;

    $self->pg->migrations->from_dir('migrations')->migrate(15);

    if (my $threads_per_page = $self->config->{'threads_per_page'}) {
        $self->thread->per_page($threads_per_page)
    }

    if (my $remarks_per_page = $self->config->{'remarks_per_page'}) {
        $self->remark->per_page($remarks_per_page)
    }

    if (my $results_per_page = $self->config->{'results_per_page'}) {
        $self->page->per_page($results_per_page)
    }

    if (my $max_thread_pages = $self->config->{'max_thread_pages'}) {
        $self->thread->max_pages($max_thread_pages)
    }

    push @{$self->commands->namespaces}, 'PostText::Command';

    # Begin routing
    my $r = $self->routes->under(sub ($c) {
        $c->session(expires => time + 31536000);
        $c->session(expires => time +     3600) if $c->is_mod;
        $c->session(expires => time +     1800) if $c->is_admin;

        $c->session(author => 'Anonymous') unless $c->session('author');

        1;
    });

    # For CAPTCHA protected routes
    my $human = $r->under('/human', sub ($c) {
        return 1 if $c->session('is_human');

        return $c->redirect_to(
            captcha_page => return_url =>
                b64_encode gzip $c->url_with->to_abs->to_string
          ), undef;
    });

    # Root redirect
    $r->get('/', sub ($c) { $c->redirect_to('threads_list') });

    # Shortcut to new session cookie/identity
    $r->get('/new', sub ($c) {
        $c->session(expires => 1);

        $c->redirect_to('threads_list');
    });

    # Static pages
    $r->get('/about')->to('page#about')->name('about_page');

    $r->get('/rules')->to('page#rules')->name('rules_page');

    $r->get('/feeds')->to('page#feeds')->name('feeds_page');

    $r->get('/javascript')->to('page#javascript')->name('javascript_page');

    # Not-so-static but I mean they're all 'pages' c'mon
    $human->get('/search')->to('page#search')->name('search_page');

    $r->any([qw{GET POST}], '/captcha/*return_url')
        ->to('page#captcha')
        ->name('captcha_page');

    # Thread
    my $thread       = $r    ->any('/thread');
    my $human_thread = $human->any('/thread');

    $thread->get('/list/:list_page', [list_page => qr/\d+/], {list_page => 1})
        ->to('thread#by_page')
        ->name('threads_list');

    $thread->any('/single/:thread_id', [thread_id => qr/\d+/])
        ->any('/:thread_page', [thread_page => qr/\d+/], {thread_page => 0})
        ->get('/', [format => [qw{html txt}]], {format => undef})
        ->to('thread#by_id')
        ->name('single_thread');

    $thread->get('feed', [format => [qw{rss xml}]])
        ->to('thread#feed')
        ->name('threads_feed');

    $human_thread->get('/bump/:thread_id', [thread_id => qr/\d+/])
        ->to('thread#bump')
        ->name('bump_thread');

    $human_thread->get('/flag/:thread_id', [thread_id => qr/\d+/])
        ->to('thread#flag')
        ->name('flag_thread');

    $human_thread->any([qw{GET POST}], '/post')
        ->to('thread#create')
        ->name('post_thread');

    # Remark
    my $remark       = $r    ->any('/remark');
    my $human_remark = $human->any('/remark');

    $remark->any('/single/:remark_id', [remark_id => qr/\d+/])
        ->get('/', [format => [qw{html txt}]], {format => undef})
        ->to('remark#by_id')
        ->name('single_remark');

    $remark->get('feed', [format => [qw{rss xml}]])
        ->to('remark#feed')
        ->name('remarks_feed');

    $human_remark->get('/flag/:remark_id', [remark_id => qr/\d+/])
        ->to('remark#flag')
        ->name('flag_remark');

    $human_remark
        ->any([qw{GET POST}], '/post/:thread_id', [thread_id => qr/\d+/])
        ->any('/:remark_id', [remark_id => qr/\d+/], {remark_id => 0})
        ->to('remark#create')
        ->name('post_remark');

    # Login/out
    $r->any([qw{GET POST}], '/login')
        ->to('moderator#login')
        ->name('mod_login');

    $r->get('/logout')
        ->to('moderator#logout')
        ->name('mod_logout');

    # Moderator
    my $moderator = $r->under('/moderator')->to('moderator#check');

    $moderator->get('/flagged')
        ->to('moderator#flagged')
        ->name('flagged_list');

    $moderator->get('/hidden')
        ->to('moderator#hidden')
        ->name('hidden_list');

    $moderator->any([qw{GET POST}], '/reset')
        ->to('moderator#mod_reset')
        ->name('mod_reset');

    $moderator->get('/list')
        ->to('moderator#list')
        ->name('mod_list');

    my $mod_thread = $moderator->any('/thread');

    $mod_thread->get('/unflag/:thread_id', [thread_id => qr/\d+/])
        ->to('moderator#unflag_thread')
        ->name('unflag_thread');

    $mod_thread->get('/hide/:thread_id', [thread_id => qr/\d+/])
        ->to('moderator#hide_thread')
        ->name('hide_thread');

    $mod_thread->get('/unhide/:thread_id', [thread_id => qr/\d+/])
        ->to('moderator#unhide_thread')
        ->name('unhide_thread');

    $mod_thread->get('/single/:thread_id', [thread_id => qr/\d+/])
        ->to('moderator#thread_by_id')
        ->name('hidden_thread');

    my $mod_remark = $moderator->any('/remark');

    $mod_remark->get('/unflag/:remark_id', [remark_id => qr/\d+/])
        ->to('moderator#unflag_remark')
        ->name('unflag_remark');

    $mod_remark->get('/hide/:remark_id', [remark_id => qr/\d+/])
        ->to('moderator#hide_remark')
        ->name('hide_remark');

    $mod_remark->get('/unhide/:remark_id', [remark_id => qr/\d+/])
        ->to('moderator#unhide_remark')
        ->name('unhide_remark');

    $mod_remark->get('/single/:remark_id', [remark_id => qr/\d+/])
        ->to('moderator#remark_by_id')
        ->name('hidden_remark');

    # Admin
    my $mod_admin = $moderator->under('/admin')->to('moderator#admin_check');

    $mod_admin->any([qw{GET POST}], '/create')
        ->to('moderator#create')
        ->name('create_mod');

    $mod_admin->any([qw{GET POST}], '/reset')
        ->to('moderator#admin_reset')
        ->name('admin_reset');

    # lock() is a builtin so use _acct suffix
    $mod_admin->any([qw{GET POST}], '/lock')
        ->to('moderator#lock_acct')
        ->name('lock_mod');

    $mod_admin->any([qw{GET POST}], '/unlock')
        ->to('moderator#unlock_acct')
        ->name('unlock_mod');

    $mod_admin->any([qw{GET POST}], '/promote')
        ->to('moderator#promote')
        ->name('promote_mod');

    $mod_admin->any([qw{GET POST}], '/demote')
        ->to('moderator#demote')
        ->name('demote_admin');
}

1;
