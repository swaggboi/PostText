use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

my %valid_login   = (
    email    => 'swaggboi@slackware.uk',
    password => 'i like to party'
    );

my %invalid_login = (
    email    => 'fuck@example.com',
    password => 'ah fuck'
    );

subtest Login => sub {
    $t->post_ok('/login', form => \%invalid_login)->status_is(403);

    $t->post_ok('/login', form => \%valid_login)
        ->status_is(302)
        ->header_like(Location => qr{moderator/list});

    $t->get_ok('/logout')
        ->status_is(302)
        ->header_like(Location => qr{thread/list});
};

done_testing();
