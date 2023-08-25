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
    my $thread_id  = $self->param('thread_id');
    my $remark_id  = $self->param('remark_id');
    my $body_limit = $self->config->{'body_max_length'} || 4_000;
    my ($v, $draft);

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('author' )->size(1,          63);
        $v->required('body'   )->size(2, $body_limit);
        $v->optional('bump'   );
        $v->optional('preview');

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my $remark_author = $v->param('author' );
            my $remark_body   = $v->param('body'   );
            my $bump_thread   = $v->param('bump'   );
            my $preview       = $v->param('preview');

            $self->session(author => $remark_author);

            unless ($preview) {
                $self->remark->create(
                    $thread_id,
                    $remark_author,
                    $remark_body
                    );

                $self->thread->bump($thread_id) if $bump_thread;

                return $self->redirect_to($self->url_for(single_thread => {
                    thread_id   => $thread_id,
                    thread_page => $self->remark->last_page_for($thread_id)
                })->fragment('remarks'));
            }

            $draft = $remark_body;
        }
    }

    my $thread      = $self->thread->by_id($thread_id);
    my $last_remark = $remark_id
        ? $self->remark->by_id($remark_id)
        : $self->remark->last_for($thread_id);

    $self->stash(
        thread      => $thread,
        last_remark => $last_remark,
        draft       => $draft,
        body_limit  => $body_limit
        );

    $self->stash(status => 404, error => 'Thread not found 🤷')
        unless keys %{$thread};

    return $self->render;
}

sub flag($self) {
    my $remark_id    = $self->param('remark_id');
    my $thread_id    = $self->remark->thread_id_for($remark_id);
    my $redirect_url =
        $self->url_for('single_thread', thread_id => $thread_id)
            ->fragment('info')->to_abs;


    $self->remark->flag($remark_id);
    $self->flash(
        info => "Remark #$remark_id has been flagged for moderator. 🚩"
        );

    $self->redirect_to($redirect_url);
}

1;
