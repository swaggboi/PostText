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
            ? substr($input_text, 0, 500) . '...' : $input_text;

        return $truncated_text;
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

    $thread->under('/list')
        ->get('/:list_page', [list_page => qr/[0-9]+/], {list_page => 1})
        ->to('thread#by_page')
        ->name('threads_list');

    $thread->any([qw{GET POST}], '/post')
        ->to('thread#create')
        ->name('post_thread');

    $thread->under('/single/:thread_id', [thread_id => qr/[0-9]+/])
        ->get('/:thread_page', [thread_page => qr/[0-9]+/], {thread_page => 1})
        ->to('thread#by_id')
        ->name('single_thread');

    $thread->under('/bump')
        ->get('/:thread_id', [thread_id => qr/[0-9]+/])
        ->to('thread#bump')
        ->name('bump_thread');

    $thread->under('/flag')
        ->get('/:thread_id', [thread_id => qr/[0-9]+/])
        ->to('thread#flag')
        ->name('flag_thread');

    # Remark
    my $remark = $r->under('/remark');

    $remark->under('/post')
        ->any([qw{GET POST}], '/:thread_id', [thread_id => qr/[0-9]+/])
        ->to('remark#create')
        ->name('post_remark');

    $remark->under('/single')
        ->get('/:remark_id', [remark_id => qr/[0-9]+/])
        ->to('remark#by_id')
        ->name('single_remark');

    $remark->under('/flag')
        ->get('/:remark_id', [remark_id => qr/[0-9]+/])
        ->to('remark#flag')
        ->name('flag_remark');
}

1;
