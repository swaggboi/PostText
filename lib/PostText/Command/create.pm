package PostText::Command::create;

use Mojo::Base 'Mojolicious::Command', -signatures;
use Mojo::Util qw{getopt};

has description => 'Create a moderator account';
has usage       => sub ($self) { $self->extract_usage };

sub run($self, @args) {
    die $self->usage unless $args[0];

    getopt \@args,
        'n|name=s'     => \my $name,
        'e|email=s'    => \my $email,
        'p|password=s' => \my $password;

    say 'Moderator created successfully.'
        if $self->app->moderator->create($name, $email, $password);
}

1;

=head1 SYNOPSIS

  Usage: APPLICATION create OPTIONS

  Options:
    -n, --name                           Moderator's name
    -e, --email                          Moderator's email
    -p, --password                       Moderator's password
=cut
