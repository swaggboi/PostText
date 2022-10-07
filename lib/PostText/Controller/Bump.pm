package PostText::Controller::Bump;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub create($self) {
    my $thread_id = $self->param('thread_id');

    $self->thread->bump($thread_id);
    $self->flash(info => "Thread #$thread_id has been bumped.🔝");

    $self->redirect_to('threads_list');
}

1;
