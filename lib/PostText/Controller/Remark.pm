package PostText::Controller::Remark;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub by_id($self) {
    my $remark_id = $self->param('remark_id');
    my $remark    = $self->remark->by_id($remark_id);

    $self->stash(remark => $remark);

    $self->stash(status => 404, error => 'Remark not found 🤷')
        unless keys %{$remark};

    $self->render;
}

sub create($self) {
    my ($thread_id, $v) = ($self->param('thread_id'), undef);

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('author')->size(1,   63);
        $v->required('body'  )->size(2, 4000);
        $v->optional('bump'  );

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my $remark_author = $v->param('author');
            my $remark_body   = $v->param('body'  );
            my $bump_thread   = $v->param('bump'  );

            $self->remark->create(
                $thread_id,
                $remark_author,
                $remark_body
                );

            $self->session(author => $remark_author);

            $self->thread->bump($thread_id) if $bump_thread;

            return $self->redirect_to($self->url_for(single_thread => {
                thread_id   => $thread_id,
                thread_page => $self->remark->last_page_for($thread_id)
            })->fragment('remarks'));
        }
    }

    my $thread      = $self->thread->by_id($thread_id);
    my $last_remark = $self->remark->last_for($thread_id);

    $self->stash(
        thread      => $thread,
        last_remark => $last_remark
        );

    $self->stash(status => 404, error => 'Thread not found 🤷')
        unless keys %{$thread};

    return $self->render;
}

sub flag($self) {
    my $remark_id = $self->param('remark_id');
    my $valid_id  = $self->remark->by_id($remark_id) ? 1 : 0;
    my $v         = $self->validation;

    $v->optional(captcha => 'trim')->size(4, 4)->like(qr/flag/i);

    if ($v->is_valid) {
        my $thread_id    = $self->remark->thread_id_for($remark_id);
        my $redirect_url =
            $self->url_for('single_thread', thread_id => $thread_id)
                ->fragment('info')->to_abs;

        $self->remark->flag($remark_id);
        $self->flash(
            info => "Remark #$remark_id has been flagged for moderator. 🚩"
            );

        return $self->redirect_to($redirect_url);
    }
    elsif ($v->has_error) {
        $self->stash(status => 400)
    }

    $self->stash(status => 404, error => 'Remark not found 🤷')
        unless $valid_id;

    $self->stash(valid_id => $valid_id);

    return $self->render;
}

1;
