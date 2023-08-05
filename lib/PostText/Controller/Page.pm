package PostText::Controller::Page;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub about($self) { $self->render }

sub rules($self) { $self->render }

sub captcha($self) { $self->render }

'false';
