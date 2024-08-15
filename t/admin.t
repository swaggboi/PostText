use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

my %valid_login   = (
    email    => 'swaggboi@slackware.uk',
    password => 'i like to party'
    );

subtest Login => sub {
    $t->get_ok('/login');

    $valid_login{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

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
            ->element_exists('a[href*="/moderator/admin/create"]')
            ->element_exists('a[href*="/moderator/admin/reset"]' )
    };

    subtest Create => sub {
        $t->get_ok('/moderator/admin/create')
            ->status_is(200)
            ->text_like(h2 => qr/Create Moderator/)
            ->element_exists('form input[name="name"]'      )
            ->element_exists('form input[name="email"]'     )
            ->element_exists('form input[name="password"]'  )
            ->element_exists('form input[name="csrf_token"]')
    };

    subtest Reset => sub {
        $t->get_ok('/moderator/admin/reset')
            ->status_is(200)
            ->text_like(h2 => qr/Reset Password/)
            ->element_exists('a[href*="/moderator/admin/reset"]')
            ->element_exists('form input[name="email"]'         )
            ->element_exists('form input[name="password"]'      )
            ->element_exists('form input[name="csrf_token"]'    )
    };

    subtest Lock => sub {
        $t->get_ok('/moderator/admin/lock')
            ->status_is(200)
            ->text_like(h2 => qr/Lock Account/)
            ->element_exists('a[href*="/moderator/admin/lock"]')
            ->element_exists('form input[name="email"]'        )
            ->element_exists('form input[name="csrf_token"]'   )
    };

    subtest Unlock => sub {
        $t->get_ok('/moderator/admin/unlock')
            ->status_is(200)
            ->text_like(h2 => qr/Unlock Account/)
            ->element_exists('a[href*="/moderator/admin/unlock"]')
            ->element_exists('form input[name="email"]'          )
            ->element_exists('form input[name="csrf_token"]'     )
    };

    subtest Promote => sub {
        $t->get_ok('/moderator/admin/promote')
            ->status_is(200)
            ->text_like(h2 => qr/Promote Moderator/)
            ->element_exists('a[href*="/moderator/admin/promote"]')
            ->element_exists('form input[name="email"]'           )
            ->element_exists('form input[name="csrf_token"]'      )
    };

    subtest Demote => sub {
        $t->get_ok('/moderator/admin/demote')
            ->status_is(200)
            ->text_like(h2 => qr/Demote Admin/)
            ->element_exists('a[href*="/moderator/admin/demote"]')
            ->element_exists('form input[name="email"]'          )
            ->element_exists('form input[name="csrf_token"]'     )
    };

    # Admin session ends
    $t->get_ok('/logout')
        ->status_is(302)
        ->header_like(Location => qr{thread/list});

    subtest 'No admin, no buttons', sub {
        $t->get_ok('/thread/single/1')
            ->status_is(200)
            ->element_exists_not('a[href*="/moderator/admin/create"]' )
            ->element_exists_not('a[href*="/moderator/admin/reset"]'  )
            ->element_exists_not('a[href*="/moderator/admin/lock"]'   )
            ->element_exists_not('a[href*="/moderator/admin/unlock"]' )
            ->element_exists_not('a[href*="/moderator/admin/promote"]')
            ->element_exists_not('a[href*="/moderator/admin/demote"]' );

        $t->get_ok('/remark/single/1')
            ->status_is(200)
            ->element_exists_not('a[href*="/moderator/admin/create"]' )
            ->element_exists_not('a[href*="/moderator/admin/reset"]'  )
            ->element_exists_not('a[href*="/moderator/admin/lock"]'   )
            ->element_exists_not('a[href*="/moderator/admin/unlock"]' )
            ->element_exists_not('a[href*="/moderator/admin/promote"]')
            ->element_exists_not('a[href*="/moderator/admin/demote"]' );

        $t->get_ok('/moderator/admin/create')
            ->status_is(302)
            ->header_like(Location => qr/login/);

        $t->get_ok('/moderator/admin/reset')
            ->status_is(302)
            ->header_like(Location => qr/login/);

        $t->get_ok('/moderator/admin/lock')
            ->status_is(302)
            ->header_like(Location => qr/login/);

        $t->get_ok('/moderator/admin/unlock')
            ->status_is(302)
            ->header_like(Location => qr/login/);

        $t->get_ok('/moderator/admin/promote')
            ->status_is(302)
            ->header_like(Location => qr/login/);

        $t->get_ok('/moderator/admin/demote')
            ->status_is(302)
            ->header_like(Location => qr/login/);
    };
};

done_testing;
