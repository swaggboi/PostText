package PostText::Command::argon2;

use Mojo::Base 'Mojolicious::Command', -signatures;

has description => 'Hash a string with Argon2';
has usage       => sub ($self) { $self->extract_usage };

sub run($self, @args) {
    die $self->usage unless $args[0];

    say $self->app->authenticator->hash_password($_) for @args
}

1;

=head1 SYNOPSIS

  Usage: APPLICATION argon2 STRING(S)

=cut
