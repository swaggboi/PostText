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
    password => 'ah fuck goddamn'
    );

subtest Login => sub {
    $t->get_ok('/login')
        ->status_is(200)
        ->element_exists('form input[name="email"]')
        ->element_exists('form input[name="password"]')
        ->text_like(h2 => qr/Moderator Login/);

    $t->post_ok('/login', form => \%invalid_login)
        ->status_is(403)
        ->element_exists('form input[name="email"]')
        ->element_exists('form input[name="password"]')
        ->text_like(p => qr/Invalid login/);

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
        $t->get_ok('/moderator/thread/unhide/1')
            ->status_is(302)
            ->header_like(Location => qr{moderator/hidden});

        $t->get_ok('/moderator/remark/hide/1')
            ->status_is(302)
            ->header_like(Location => qr{moderator/flagged});
        $t->get_ok('/moderator/remark/unhide/1')
            ->status_is(302)
            ->header_like(Location => qr{moderator/hidden});
    };

    subtest 'Buttons for mods', sub {
        $t->get_ok('/thread/single/1')
            ->status_is(200)
            ->element_exists('a[href*="/hide/1"]'  )
            ->element_exists('a[href*="/unhide/1"]')
            ->element_exists('a[href*="/unflag/1"]');

        $t->get_ok('/remark/single/1')
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
            ->element_exists_not('a[href*="/logout"]'           );

        $t->get_ok('/remark/single/1')
            ->status_is(200)
            ->element_exists_not('a[href*="/hide/1"]'           )
            ->element_exists_not('a[href*="/unhide/1"]'         )
            ->element_exists_not('a[href*="/unflag/1"]'         )
            ->element_exists_not('a[href*="/moderator/flagged"]')
            ->element_exists_not('a[href*="/moderator/hidden"]' )
            ->element_exists_not('a[href*="/logout"]'           );

        $t->get_ok('/moderator/flagged')
            ->status_is(302)
            ->header_like(Location => qr/login/);

        $t->get_ok('/moderator/hidden')
            ->status_is(302)
            ->header_like(Location => qr/login/);
    };
};

done_testing;
