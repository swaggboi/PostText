use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t               = Test::Mojo->new('PostText');
my %good_human      = (answer => 1,   number => 'Ⅰ');
my %bad_bot         = (answer => 2,   number => 'Ⅰ');
my %invalid_captcha = (answer => 'a', number => 'Ⅰ');
my $flag_thread_url =
    '/captcha/H4sIABSTzmQAA8soKSmw0tfPyU9OzMnILy6xMjYwMNDPKM1NzNMvyShKTUzRT8tJTNc3BABRx5B2%0AKQAAAA==%0A';
my $bump_thread_url =
    '/captcha/H4sIAImTzmQAA8soKSmw0tfPyU9OzMnILy6xMjYwMNDPKM1NzNMvyShKTUzRTyrNLdA3BAD5ek7T%0AKQAAAA==%0A';
my $flag_remark_url =
    '/captcha/H4sIAAKazmQAA8soKSmw0tfPyU9OzMnILy6xMjYwMNDPKM1NzNMvSs1NLMrWT8tJTNc3BAAN5VIw%0AKQAAAA==%0A';

subtest 'Bumping thread', sub {
    $t->get_ok('/thread/list')->status_is(200)
        ->element_exists('a[href*="bump"]')
        ->text_like(h2 => qr/Threads List/);

    $t->get_ok('/thread/single/1')->status_is(200)
        ->element_exists('a[href*="bump"]')
        ->text_like(h2 => qr/Thread #1/);

    $t->get_ok('/human/thread/bump/1')->status_is(302)
        ->header_like(Location => qr/captcha/);

    $t->get_ok($bump_thread_url)
        ->status_is(200)
        ->element_exists('input[name="answer"]'    )
        ->element_exists('input[name="number"]'    )
        ->element_exists('input[name="csrf_token"]');

    # Bad CSRF
    $t->post_ok($bump_thread_url, form => \%bad_bot)
        ->status_is(403)
        ->element_exists('p[class="stash-with-error"]')
        ->text_like(p => qr/Something went wrong/);

    # Bad CAPTCHA
    $bad_bot{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok($bump_thread_url, form => \%bad_bot)
        ->status_is(400)
        ->element_exists('p[class="stash-with-error"]')
        ->text_like(p => qr/Sounds like something a robot would say/);

    $invalid_captcha{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok($bump_thread_url, form => \%invalid_captcha)
        ->status_is(400)
        ->element_exists('p[class="field-with-error"]')
        ->text_like(p => qr/Should be a single number/);

    # Solved CAPTCHA
    $good_human{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok($bump_thread_url, form => \%good_human)
        ->status_is(302)
        ->header_like(Location => qr{human/thread/bump/1});

    $t->reset_session;
};

subtest 'Flagging thread', sub {
    $t->get_ok('/thread/list')->status_is(200)
        ->element_exists('a[href*="flag"]')
        ->text_like(h2 => qr/Threads List/);

    $t->get_ok('/thread/single/1')->status_is(200)
        ->element_exists('a[href*="flag"]')
        ->text_like(h2 => qr/Thread #1/);

    $t->get_ok('/human/thread/flag/1')->status_is(302)
        ->header_like(Location => qr/captcha/);

    # Bad CSRF
    $t->get_ok($flag_thread_url);

    $t->post_ok($flag_thread_url, form => \%bad_bot)
        ->status_is(403)
        ->element_exists('p[class="stash-with-error"]')
        ->text_like(p => qr/Something went wrong/);

    # Bad CAPTCHA
    $bad_bot{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok($flag_thread_url, form => \%bad_bot)
        ->status_is(400)
        ->element_exists('p[class="stash-with-error"]')
        ->text_like(p => qr/Sounds like something a robot would say/);

    $invalid_captcha{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok($flag_thread_url, form => \%invalid_captcha)
        ->status_is(400)
        ->element_exists('p[class="field-with-error"]')
        ->text_like(p => qr/Should be a single number/);

    # Solved CAPTCHA
    $good_human{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok($flag_thread_url, form => \%good_human)
        ->status_is(302)
        ->header_like(Location => qr{human/thread/flag/1});

    $t->reset_session;
};

subtest 'Flagging remark', sub {
    $t->get_ok('/remark/single/1')->status_is(200)
        ->element_exists('a[href*="flag"]')
        ->text_like(h2 => qr/Remark #1/);

    $t->get_ok('/human/remark/flag/1')->status_is(302)
        ->header_like(Location => qr/captcha/);

    # Bad CSRF
    $t->get_ok($flag_remark_url);

    $t->post_ok($flag_remark_url, form => \%bad_bot)
        ->status_is(403)
        ->element_exists('p[class="stash-with-error"]')
        ->text_like(p => qr/Something went wrong/);

    # Bad CAPTCHA
    $bad_bot{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok($flag_remark_url, form => \%bad_bot)
        ->status_is(400)
        ->element_exists('p[class="stash-with-error"]')
        ->text_like(p => qr/Sounds like something a robot would say/);

    $invalid_captcha{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok($flag_remark_url, form => \%invalid_captcha)
        ->status_is(400)
        ->element_exists('p[class="field-with-error"]')
        ->text_like(p => qr/Should be a single number/);

    # Solved CAPTCHA
    $good_human{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok($flag_remark_url, form => \%good_human)
        ->status_is(302)
        ->header_like(Location => qr{human/remark/flag/1});
};

done_testing;
