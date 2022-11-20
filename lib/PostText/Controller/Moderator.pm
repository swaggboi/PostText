package PostText::Controller::Moderator;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list($self) { $self->render }

sub login($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        my ($email, $password);

        $v->required('email'   );
        $v->required('password');

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            $email    = $self->param('email'   );
            $password = $self->param('password');

            if ($self->moderator->check($email, $password)) {
                $self->session(moderator => 1);

                return $self->redirect_to('mod_list');
            }
            else {
                $self->flash(error => 'Invalid login! 🧐')
            }
        }
    }

    $self->render;
}

1;
