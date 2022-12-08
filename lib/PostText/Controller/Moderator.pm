package PostText::Controller::Moderator;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list($self) { $self->render }

sub login($self) {
    my $v;

    #Already logged in?
    return $self->redirect_to('flagged_list') if $self->is_mod;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        my ($email, $password, $mod_id, $mod_name);

        $v->required('email'   );
        $v->required('password');

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            $email    = $self->param('email'   );
            $password = $self->param('password');

            if ($self->moderator->check($email, $password)) {
                $mod_id   = $self->moderator->get_id($email);
                $mod_name = $self->moderator->get_name($mod_id);

                $self->session(
                    mod_id => $mod_id,
                    author => $mod_name
                    );
                $self->flash(info => "Hello, $mod_name 😎");

                return $self->redirect_to('flagged_list');
            }
            else {
                $self->stash(
                    status => 403,
                    error  => 'Invalid login! 🧐'
                    );
            }
        }
    }

    return $self->render;
}

sub logout($self) {
    delete $self->session->{'mod_id'};

    $self->flash(info => 'Logged out successfully 👋');

    $self->redirect_to('threads_list');
}

sub unflag($self) {
    my $thread_id    = $self->param('thread_id');
    my $redirect_url = $self->url_for('threads_list')->fragment('info')->to_abs;

    $self->moderator->unflag($thread_id);
    $self->flash(info => "Thread #$thread_id has been unflagged. ◀️");

    $self->redirect_to($redirect_url);
}

sub hide($self) {
    my $thread_id    = $self->param('thread_id');
    my $redirect_url = $self->url_for(single_thread => thread_id => $thread_id)
        ->fragment('info')->to_abs;

    $self->moderator->hide($thread_id);
    $self->flash(info => "Thread #$thread_id has been hidden. 🫥");

    $self->redirect_to($redirect_url);
}

sub unhide($self) {
    my $thread_id    = $self->param('thread_id');
    my $redirect_url = $self->url_for('threads_list')->fragment('info')->to_abs;

    $self->moderator->unhide($thread_id);
    $self->flash(info => "Thread #$thread_id has been unhidden. ⏪");

    $self->redirect_to($redirect_url);
}

1;
