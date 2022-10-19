package PostText::Command::bcrypt;

use Mojo::Base 'Mojolicious::Command', -signatures;

has description => 'Hash a string with brcypt';
has usage       => sub ($self) { $self->extract_usage };

sub run($self, @args) {
    say $self->app->bcrypt($_) for @args;
}

1;

=head1 SYNOPSIS

  Usage: APPLICATION bcrypt STRING(S)

=cut
