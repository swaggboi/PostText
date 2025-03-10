use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

my %valid_login   = (
    email    => 'swaggboi@gangstalking.agency',
    password => 'i also like to party'
    );

my %invalid_login = (
    email    => 'fuck@example.com',
    password => 'ah fuck goddamn'
    );

subtest Login => sub {
    $t->get_ok('/login')
        ->status_is(200)
        ->element_exists('form input[name="email"]'     )
        ->element_exists('form input[name="password"]'  )
        ->element_exists('form input[name="csrf_token"]')
        ->text_like(h2 => qr/Moderator Login/);

    # Bad CSRF token
    $t->post_ok('/login', form => \%valid_login)
        ->status_is(403)
        ->text_like(p => qr/Something went wrong/);

    $invalid_login{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok('/login', form => \%invalid_login)
        ->status_is(403)
        ->element_exists('form input[name="email"]')
        ->element_exists('form input[name="password"]')
        ->text_like(p => qr/Invalid login/);

    $valid_login{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok('/login', form => \%valid_login)
        ->status_is(302)
        ->header_like(Location => qr{moderator/flagged});

    $t->get_ok('/login')
        ->status_is(302)
        ->header_like(Location => qr{moderator/flagged});

    # Do these subs while logged in
    subtest Flag => sub {
        $t->get_ok('/moderator/thread/unflag/1')
            ->status_is(302)
            ->header_like(Location => qr{moderator/flagged});

        $t->get_ok('/moderator/remark/unflag/1')
            ->status_is(302)
            ->header_like(Location => qr{moderator/flagged});
    };

    subtest Hide => sub {
        $t->get_ok('/moderator/thread/hide/1')
            ->status_is(302)
            ->header_like(Location => qr{moderator/flagged});
        $t->get_ok('/moderator/thread/single/1')
            ->status_is(200)
            ->text_like(h2 => qr/Thread #/);
        $t->get_ok('/thread/single/1')
            ->status_is(404)
            ->text_like(p => qr/Thread not found/);
        $t->get_ok('/moderator/thread/unhide/1')
            ->status_is(302)
            ->header_like(Location => qr{moderator/hidden});

        $t->get_ok('/moderator/remark/hide/1')
            ->status_is(302)
            ->header_like(Location => qr{moderator/flagged});
        $t->get_ok('/moderator/remark/single/1')
            ->status_is(200)
            ->text_like(h2 => qr/Remark #/);
        $t->get_ok('/remark/single/1')
            ->status_is(404)
            ->text_like(p => qr/Remark not found/);
        $t->get_ok('/moderator/remark/unhide/1')
            ->status_is(302)
            ->header_like(Location => qr{moderator/hidden});
    };

    subtest 'Buttons for mods', sub {
        $t->get_ok('/moderator/thread/single/1')
            ->status_is(200)
            ->element_exists('a[href*="/hide/1"]'  )
            ->element_exists('a[href*="/unhide/1"]')
            ->element_exists('a[href*="/unflag/1"]');

        $t->get_ok('/moderator/remark/single/1')
            ->status_is(200)
            ->element_exists('a[href*="/hide/1"]'  )
            ->element_exists('a[href*="/unhide/1"]')
            ->element_exists('a[href*="/unflag/1"]');
    };

    subtest Flagged => sub {
        $t->get_ok('/moderator/flagged')
            ->status_is(200)
            ->text_like(h2 => qr/Flagged Posts/)
            ->element_exists('a[href*="/moderator/flagged"]')
            ->element_exists('a[href*="/moderator/hidden"]' )
            ->element_exists('a[href*="/logout"]'           )
    };

    subtest Hidden => sub {
        $t->get_ok('/moderator/hidden')
            ->status_is(200)
            ->text_like(h2 => qr/Hidden Posts/)
            ->element_exists('a[href*="/moderator/flagged"]')
            ->element_exists('a[href*="/moderator/hidden"]' )
            ->element_exists('a[href*="/logout"]'           )
    };

    subtest Reset => sub {
        $t->get_ok('/moderator/reset')
            ->status_is(200)
            ->text_like(h2 => qr/Reset Password/)
            ->element_exists('a[href*="/moderator/reset"]')
            ->element_exists('form input[name="password"]')
    };

    subtest List => sub {
        $t->get_ok('/moderator/list')
            ->status_is(200)
            ->text_like(h2 => qr/Moderator List/)
    };

    # Mod session ends
    $t->get_ok('/logout')
        ->status_is(302)
        ->header_like(Location => qr{thread/list});

    subtest 'No mod, no buttons', sub {
        $t->get_ok('/thread/single/1')
            ->status_is(200)
            ->element_exists_not('a[href*="/hide/1"]'           )
            ->element_exists_not('a[href*="/unhide/1"]'         )
            ->element_exists_not('a[href*="/unflag/1"]'         )
            ->element_exists_not('a[href*="/moderator/flagged"]')
            ->element_exists_not('a[href*="/moderator/hidden"]' )
            ->element_exists_not('a[href*="/moderator/list"]'   )
            ->element_exists_not('a[href*="/logout"]'           );

        $t->get_ok('/remark/single/1')
            ->status_is(200)
            ->element_exists_not('a[href*="/hide/1"]'           )
            ->element_exists_not('a[href*="/unhide/1"]'         )
            ->element_exists_not('a[href*="/unflag/1"]'         )
            ->element_exists_not('a[href*="/moderator/flagged"]')
            ->element_exists_not('a[href*="/moderator/hidden"]' )
            ->element_exists_not('a[href*="/moderator/list"]'   )
            ->element_exists_not('a[href*="/logout"]'           );

        $t->get_ok('/moderator/flagged')
            ->status_is(302)
            ->header_like(Location => qr/login/);

        $t->get_ok('/moderator/hidden')
            ->status_is(302)
            ->header_like(Location => qr/login/);

        $t->get_ok('/moderator/list')
            ->status_is(302)
            ->header_like(Location => qr/login/);
    };
};

done_testing;
