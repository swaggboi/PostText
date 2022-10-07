package PostText;

# Sep 22

use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Pg;
use PostText::Model::Thread;
use PostText::Model::Remark;

sub startup($self) {
    $self->plugin('Config');
    $self->plugin('TagHelpers::Pagination');
    $self->plugin(AssetPack => {pipes => [qw{Css Combine}]});

    # Helpers
    $self->helper(pg => sub ($c) {
        state $pg = Mojo::Pg->new($c->config->{$self->mode}{'pg_string'})
    });

    $self->helper(thread => sub ($c) {
        state $thread = PostText::Model::Thread->new(pg => $c->pg)
    });

    $self->helper(remark => sub ($c) {
        state $remark = PostText::Model::Remark->new(pg => $c->pg)
    });

    $self->helper(truncate_text => sub ($c, $input_text) {
        my $truncated_text = 500 < length($input_text)
            ? substr($input_text, 0, 500) . '...' : $input_text;

        return $truncated_text;
    });

    # Finish configuring some things
    $self->secrets($self->config->{'secrets'}) || die $@;

    $self->pg->migrations->from_dir('migrations')->migrate(5);

    if (my $threads_per_page = $self->config->{'threads_per_page'}) {
        $self->thread->per_page($threads_per_page)
    }

    if (my $remarks_per_page = $self->config->{'remarks_per_page'}) {
        $self->remark->per_page($remarks_per_page)
    }

    $self->asset->process('main.css', 'css/PostText.css');

    # Begin routing
    my $r = $self->routes->under(sub ($c) {
        $c->session(expires => time + 31536000);

        $c->session(author => 'Anonymous') unless $c->session('author');

        1;
    });

    # Root redirect
    $r->get('/', sub ($c) { $c->redirect_to('threads_list') });

    # Thread
    my $threads_list = $r->under('/list');
    $threads_list
        ->get('/:list_page', [list_page => qr/[0-9]+/], {list_page => 1})
        ->to('thread#by_page')
        ->name('threads_list');

    my $post_thread = $r->under;
    $post_thread->any([qw{GET POST}], '/post')
        ->to('thread#create')
        ->name('post_thread');

    my $single_thread =
        $r->under('/thread/:thread_id', [thread_id => qr/[0-9]+/]);
    $single_thread
        ->get('/:thread_page', [thread_page => qr/[0-9]+/], {thread_page => 1})
        ->to('thread#by_id')
        ->name('single_thread');

    # Remark
    my $post_remark = $r->under('/post');
    $post_remark
        ->any([qw{GET POST}], '/:thread_id', [thread_id => qr/[0-9]+/])
        ->to('remark#create')
        ->name('post_remark');

    my $single_remark = $r->under('/remark');
    $single_remark->get('/:remark_id', [remark_id => qr/[0-9]+/])
        ->to('remark#by_id')
        ->name('single_remark');

    # Bump
    my $bump_thread = $r->under('/bump');
    $bump_thread->get('/:thread_id', [thread_id => qr/[0-9]+/])
        ->to('bump#create')
        ->name('bump_thread');
}

1;
