package PostText;

# Sep 22

use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Pg;
use Crypt::Passphrase;

# The local libs
use PostText::Model::Thread;
use PostText::Model::Remark;
use PostText::Model::Moderator;

sub startup($self) {
    $self->plugin('Config');
    $self->plugin('TagHelpers::Pagination');
    $self->plugin(AssetPack => {pipes => [qw{Css Combine}]});

    # Helpers
    $self->helper(pg => sub ($c) {
        state $pg = Mojo::Pg->new($c->config->{$self->mode}{'pg_string'})
    });

    $self->helper(authenticator => sub ($c) {
        state $authenticator = Crypt::Passphrase->new(
            encoder    => 'Argon2',
            validators => ['Bcrypt'], # For old passphrases
          )
    });

    $self->helper(thread => sub ($c) {
        state $thread = PostText::Model::Thread->new(pg => $c->pg)
    });

    $self->helper(remark => sub ($c) {
        state $remark = PostText::Model::Remark->new(pg => $c->pg)
    });

    $self->helper(moderator => sub ($c) {
        state $moderator = PostText::Model::Moderator->new(
            pg            => $c->pg,
            authenticator => $c->authenticator
          )
    });

    $self->helper(truncate_text => sub ($c, $input_text) {
        my $truncated_text = 500 < length($input_text)
            ? substr($input_text, 0, 500) . '…' : $input_text;

        return $truncated_text;
    });

    $self->helper(is_mod => sub ($c) {
        if (my $mod_id = $c->session->{'mod_id'}) {
            return 1 if $mod_id =~ /\d+/
        }

        return undef;
    });

    # Finish configuring some things
    $self->secrets($self->config->{'secrets'}) || die $@;

    $self->pg->migrations->from_dir('migrations')->migrate(10);

    if (my $threads_per_page = $self->config->{'threads_per_page'}) {
        $self->thread->per_page($threads_per_page)
    }

    if (my $remarks_per_page = $self->config->{'remarks_per_page'}) {
        $self->remark->per_page($remarks_per_page)
    }

    $self->asset->process('main.css', 'css/PostText.css');

    push @{$self->commands->namespaces}, 'PostText::Command';

    # Begin routing
    my $r = $self->routes->under(sub ($c) {
        $c->session(expires => time + 31536000);

        $c->session(author => 'Anonymous') unless $c->session('author');

        1;
    });

    # Root redirect
    $r->get('/', sub ($c) { $c->redirect_to('threads_list') });

    # Thread
    my $thread = $r->under('/thread');

    $thread->get('/list/:list_page', [list_page => qr/\d+/], {list_page => 1})
        ->to('thread#by_page')
        ->name('threads_list');

    $thread->any([qw{GET POST}], '/post')
        ->to('thread#create')
        ->name('post_thread');

    $thread->under('/single/:thread_id', [thread_id => qr/\d+/])
        ->get('/:thread_page', [thread_page => qr/\d+/], {thread_page => 1})
        ->to('thread#by_id')
        ->name('single_thread');

    $thread->get('/bump/:thread_id', [thread_id => qr/\d+/])
        ->to('thread#bump')
        ->name('bump_thread');

    $thread->get('/flag/:thread_id', [thread_id => qr/\d+/])
        ->to('thread#flag')
        ->name('flag_thread');

    # Remark
    my $remark = $r->under('/remark');

    $remark->any([qw{GET POST}], '/post/:thread_id', [thread_id => qr/\d+/])
        ->to('remark#create')
        ->name('post_remark');

    $remark->get('/single/:remark_id', [remark_id => qr/\d+/])
        ->to('remark#by_id')
        ->name('single_remark');

    $remark->get('/flag/:remark_id', [remark_id => qr/\d+/])
        ->to('remark#flag')
        ->name('flag_remark');

    # Login/out
    $r->any([qw{GET POST}], '/login')
        ->to('moderator#login')
        ->name('mod_login');

    $r->get('/logout')
        ->to('moderator#logout')
        ->name('mod_logout');

    # Moderator
    my $moderator = $r->under('/moderator', sub ($c) {
        return 1 if $c->is_mod;

        # Return false otherwise a body is rendered with the redirect...
        return $c->redirect_to('mod_login'), undef;
    });

    $moderator->get('/flagged')
        ->to('moderator#flagged')
        ->name('flagged_list');

    my $mod_thread = $moderator->under('/thread');

    $mod_thread->get('/unflag/:thread_id', [thread_id => qr/\d+/])
        ->to('moderator#unflag_thread')
        ->name('unflag_thread');

    $mod_thread->get('/hide/:thread_id', [thread_id => qr/\d+/])
        ->to('moderator#hide_thread')
        ->name('hide_thread');

    $mod_thread->get('/unhide/:thread_id', [thread_id => qr/\d+/])
        ->to('moderator#unhide_thread')
        ->name('unhide_thread');
}

1;
