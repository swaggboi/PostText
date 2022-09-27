#!/usr/bin/env perl

# Sep 22

package PostText;

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
    $r->get('/', sub ($c) { $c->redirect_to('list') });

    my $list = $r->under('/list');
    $list->get('/:list_page', [list_page => qr/[0-9]+/], {list_page => 1}, sub ($c) {
        my $base_path = $c->match->path_for(list_page => undef)->{'path'};
        my $this_page = $c->param('list_page');
        my $last_page = $c->thread->last_page;
        my $threads   = $c->thread->by_page($this_page);

        $c->stash(status => 404) unless $threads->[0];

        $c->stash(
            threads   => $threads,
            this_page => $this_page,
            last_page => $last_page,
            base_path => $base_path
            );

        $c->render;
    });

    # Post
    my $post = $r->under;
    $post->any([qw{GET POST}], '/post', sub ($c) {
        my $v;

        $v = $c->validation if $c->req->method eq 'POST';

        if ($v && $v->has_data) {
            my $thread_author = $c->param('author');
            my $thread_title  = $c->param('title' );
            my $thread_body   = $c->param('body'  );

            $v->required('author')->size(1, 63  );
            $v->required('title' )->size(1, 127 );
            $v->required('body'  )->size(2, 4000);

            if ($v->has_error) {
                $c->stash(status => 400)
            }
            else {
                my $new_thread_id = $c->thread->create(
                    $thread_author,
                    $thread_title,
                    $thread_body
                    );

                $c->session(author => $thread_author);

                return $c->redirect_to(
                    thread_page => {thread_id => $new_thread_id}
                    );
            }
        }

        return $c->render;
    });
    $post = $post->under('/post');
    $post->any([qw{GET POST}], '/:thread_id', [thread_id => qr/[0-9]+/], sub ($c) {
        my ($thread_id, $v) = ($c->param('thread_id'), undef);

        $v = $c->validation if $c->req->method eq 'POST';

        if ($v && $v->has_data) {
            my $remark_author = $c->param('author');
            my $remark_body   = $c->param('body'  );

            $v->required('author')->size(1, 63  );
            $v->required('body'  )->size(2, 4000);

            if ($v->has_error) {
                $c->stash(status => 400)
            }
            else {
                $c->remark->create(
                    $thread_id,
                    $remark_author,
                    $remark_body
                    );

                $c->session(author => $remark_author);

                return $c->redirect_to(
                    thread_page => {thread_id => $thread_id}
                    );
            }
        }

        my $thread      = $c->thread->by_id($thread_id);
        my $last_remark = $c->remark->last_for($thread_id);

        $c->stash(
            thread      => $thread,
            last_remark => $last_remark
            );

        return $c->render;
    });

    # Thread
    my $thread = $r->under('/thread/:thread_id', [thread_id => qr/[0-9]+/]);
    $thread->get('/:thread_page', [thread_page => qr/[0-9]+/], {thread_page => 1}, sub ($c) {
        my $thread_id = $c->param('thread_id');
        my $thread    = $c->thread->by_id($thread_id);
        my $base_path = $c->match->path_for(thread_page => undef)->{'path'};
        my $this_page = $c->param('thread_page');
        my $last_page = $c->remark->last_page_for($thread_id);
        my $remarks   = $c->remark->by_page_for($thread_id, $this_page);

        if (my $thread_body = %$thread{'body'}) {
            $c->stash(
                thread    => $thread,
                base_path => $base_path,
                this_page => $this_page,
                last_page => $last_page,
                remarks   => $remarks
                )
        }
        else {
            $c->stash(
                thread => [],
                status => 404
                )
        }

        # Check for remarks or remark page number
        $c->stash(status => 404) unless $remarks->[0] || 1 >= $this_page;

        $c->render;
    });

    # Remark
    my $remark = $r->under('/remark');
    $remark->get('/:remark_id', [remark_id => qr/[0-9]+/], sub ($c) {
        my $remark_id = $c->param('remark_id');
        my $remark    = $c->remark->by_id($remark_id);

        $c->stash(status => 404) unless $remark->{'id'};

        $c->stash(remark => $remark);

        $c->render;
    });
}

1;
