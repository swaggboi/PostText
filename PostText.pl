#!/usr/bin/env perl

# PostText v0.1
# Jul 22

use Mojolicious::Lite -signatures;
use Mojo::Pg;
use Data::Dumper; # For your debugging pleasure

# Load the local modules too
use lib 'lib';
use PostText::Model::Thread;
use PostText::Model::Remark;

# Load Mojo plugins
plugin 'Config';
plugin 'TagHelpers::Pagination';
plugin AssetPack => {pipes => [qw{Css Combine}]};

# Helpers
helper pg => sub {
    state $pg = Mojo::Pg->new(app->config->{app->mode}{'pg_string'})
};

helper thread => sub {
    state $thread = PostText::Model::Thread->new(pg => shift->pg)
};

helper remark => sub {
    state $remark = PostText::Model::Remark->new(pg => shift->pg)
};

# Begin routing
under sub ($c) {
    $c->session(expires => time() + 31536000);

    1;
};

# Root
get '/', sub ($c) { $c->redirect_to('view') };

# View
group {
    under 'view';

    get '/:page', [page => qr/[0-9]+/], {page => 1}, sub ($c) {
        my $base_path = '/view';
        my $this_page = $c->param('page');
        my $last_page = $c->thread->get_last_page();
        my $threads   = $c->thread->get_threads_by_page($this_page);

        $c->stash(
            threads   => $threads,
            this_page => $this_page,
            last_page => $last_page,
            base_path => $base_path
            );

        $c->render();
    };
};

# Post
any [qw{GET POST}], '/post', sub ($c) {
    my $v;

    $v = $c->validation() if $c->req->method eq 'POST';

    if ($v && $v->has_data) {
        my $thread_author = $c->param('name' ) || 'Anonymous';
        my $thread_title  = $c->param('title');
        my $thread_body   = $c->param('post' );

        $v->required('name' )->size(1, 63  );
        $v->required('title')->size(1, 127 );
        $v->required('post' )->size(2, 4000);

        if ($v->has_error) {
            $c->stash(status => 400)
        }
        else {
            $c->thread->create_thread(
                $thread_author,
                $thread_title,
                $thread_body
                );

            return $c->redirect_to('view');
        }
    }

    return $c->render();
};

# Thread
group {
    under '/thread';

    get '/:thread_id', [thread_id => qr/[0-9]+/], sub ($c) {
        my $thread_id = $c->param('thread_id');
        my $thread    = $c->thread->get_thread_by_id($thread_id);
        my $remarks   = $c->remark->get_remarks_by_thread_id($thread_id);

        if (my $thread_body = %$thread{'body'}) {
            $c->stash(
                thread  => $thread,
                remarks => $remarks
                )
        }
        else {
            $c->stash(
                thread => [],
                status => 404
                )
        }

        $c->render();
    };
};

# Configure things
app->secrets(app->config->{'secrets'}) || die $@;

app->pg->migrations->from_dir('migrations')->migrate(5);

if (my $threads_per_page = app->config->{'threads_per_page'}) {
    app->thread->threads_per_page($threads_per_page);
}

app->asset->process('main.css', 'css/PostText.css');

# Send it
app->start();
