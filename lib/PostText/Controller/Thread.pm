package PostText::Controller::Thread;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub create($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        my ($thread_author, $thread_title, $thread_body);

        $v->required('author')->size(1,   63);
        $v->required('title' )->size(1,  127);
        $v->required('body'  )->size(2, 4000);

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            $thread_author = $v->param('author');
            $thread_title  = $v->param('title' );
            $thread_body   = $v->param('body'  );

            my $new_thread_id = $self->thread->create(
                $thread_author,
                $thread_title,
                $thread_body
                );

            $self->session(author => $thread_author);

            return $self->redirect_to(
                single_thread => {thread_id => $new_thread_id}
                );
        }
    }

    return $self->render;
}

sub by_id($self) {
    my $thread_id = $self->param('thread_id');
    my $thread    = $self->thread->by_id($thread_id);
    my $base_path = $self->match->path_for(thread_page => undef)->{'path'};
    my $this_page = $self->param('thread_page');
    my $last_page = $self->remark->last_page_for($thread_id);
    my $remarks   = $self->remark->by_page_for($thread_id, $this_page);

    if (my $thread_body = $thread->{'body'}) {
        $self->stash(
            thread    => $thread,
            base_path => $base_path,
            this_page => $this_page,
            last_page => $last_page,
            remarks   => $remarks
            )
    }
    else {
        $self->stash(
            thread => [],
            status => 404
            )
    }

    # Check for remarks or remark page number
    $self->stash(status => 404) unless $remarks->[0] || 1 >= $this_page;

    $self->render;
}

sub by_page($self) {
    my $base_path = $self->match->path_for(list_page => undef)->{'path'};
    my $this_page = $self->param('list_page');
    my $last_page = $self->thread->last_page;
    my $threads   = $self->thread->by_page($this_page);

    $self->stash(status => 404) unless $threads->[0];

    $self->stash(
        threads   => $threads,
        this_page => $this_page,
        last_page => $last_page,
        base_path => $base_path
        );

    $self->render;
}

sub bump($self) {
    my $thread_id = $self->param('thread_id');

    $self->thread->bump($thread_id);
    $self->flash(info => "Thread #$thread_id has been bumped. 🔝");

    $self->redirect_to(
        $self->url_for('threads_list')->fragment('info')->to_abs
        );
}

sub flag($self) {
    my $thread_id    = $self->param('thread_id');
    my $redirect_url = $self->url_for('threads_list')->fragment('info')->to_abs;

    $self->thread->flag($thread_id);
    $self->flash(info => "Thread #$thread_id has been flagged. 🚩");

    $self->redirect_to($redirect_url);
}

1;
