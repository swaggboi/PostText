package PostText::Controller::Remark;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub by_id($self) {
    my $remark_id = $self->param('remark_id');
    my $remark    = $self->remark->by_id($remark_id);

    $self->stash(status => 404) unless $remark->{'id'};

    $self->stash(remark => $remark);

    $self->render;
}

sub create($self) {
    my ($thread_id, $v) = ($self->param('thread_id'), undef);

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        my $remark_author = $self->param('author');
        my $remark_body   = $self->param('body'  );

        $v->required('author')->size(1, 63  );
        $v->required('body'  )->size(2, 4000);

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            $self->remark->create(
                $thread_id,
                $remark_author,
                $remark_body
                );

            $self->session(author => $remark_author);

            $self->thread->bump($thread_id);

            return $self->redirect_to(single_thread => {
                thread_id   => $thread_id,
                thread_page => $self->remark->last_page_for($thread_id)
            });
        }
    }

    my $thread      = $self->thread->by_id($thread_id);
    my $last_remark = $self->remark->last_for($thread_id);

    $self->stash(
        thread      => $thread,
        last_remark => $last_remark
      );

    return $self->render;
}

1;
