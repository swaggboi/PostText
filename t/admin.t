use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

my %valid_login   = (
    email    => 'swaggboi@slackware.uk',
    password => 'i like to party'
    );

subtest Login => sub {
    $t->post_ok('/login', form => \%valid_login)
        ->status_is(302)
        ->header_like(Location => qr{moderator/flagged});

    $t->get_ok('/login')
        ->status_is(302)
        ->header_like(Location => qr{moderator/flagged});

    # Do these subs while logged in
    subtest 'Buttons for admins', sub {
        $t->get_ok('/moderator/flagged')
            ->status_is(200)
            ->text_like(h2 => qr/Flagged Posts/)
            ->element_exists('a[href*="/moderator/admin/create"]' );

        $t->get_ok('/moderator/hidden')
            ->status_is(200)
            ->text_like(h2 => qr/Hidden Posts/)
            ->element_exists('a[href*="/moderator/admin/create"]' );
    };

    subtest Create => sub {
        $t->get_ok('/moderator/admin/create')
            ->status_is(200)
            ->text_like(h2 => qr/Create Moderator/)
            ->element_exists('a[href*="/moderator/admin/create"]' )
    };

    # Admin session ends
    $t->get_ok('/logout')
        ->status_is(302)
        ->header_like(Location => qr{thread/list});

    subtest 'No admin, no buttons', sub {
        $t->get_ok('/thread/single/1')
            ->status_is(200)
            ->element_exists_not('a[href*="/moderator/admin/create"]' );

        $t->get_ok('/remark/single/1')
            ->status_is(200)
            ->element_exists_not('a[href*="/moderator/admin/create"]' );

        $t->get_ok('/moderator/admin/create')
            ->status_is(302)
            ->header_like(Location => qr/login/);
    };
};

done_testing();
