package PostText::Command::promote;

use Mojo::Base 'Mojolicious::Command', -signatures;

has description => 'Promote a moderator account to admin';
has usage       => sub ($self) { $self->extract_usage };

sub run($self, @args) {
    die $self->usage unless $args[0];

    for my $email (@args) {
        say "Promoted $email." if $self->app->moderator->promote($email)
    }
}

1;

=head1 SYNOPSIS

  Usage: APPLICATION EMAIL(S)

=cut
