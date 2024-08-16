use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

# For CAPTCHA
my %good_captcha    = (answer => 1, number => 'Ⅰ');
my $bump_thread_url =
    '/captcha/H4sIAImTzmQAA8soKSmw0tfPyU9OzMnILy6xMjYwMNDPKM1NzNMvyShKTUzRTyrNLdA3BAD5ek7T%0AKQAAAA==%0A';

my %preview_thread = (
    author  => 'Anonymous',
    title   => 'hi',
    body    => 'ayy... lmao',
    preview => 1
    );

my %preview_remark = (
    author  => 'Anonymous',
    body    => 'ayy... lmao',
    preview => 1
    );

# Do CAPTCHA
$t->get_ok($bump_thread_url);

$good_captcha{'csrf_token'} =
    $t->tx->res->dom->at('input[name="csrf_token"]')->val;

$t->post_ok($bump_thread_url, form => \%good_captcha)
    ->status_is(302)
    ->header_like(Location => qr{human/thread/bump/1});

subtest 'Check the form + button', sub {
    $t->get_ok('/human/remark/post/1')->status_is(200)
        ->element_exists('input[id="preview"]');

    $t->get_ok('/human/thread/post')->status_is(200)
        ->element_exists('input[id="preview"]');
};

subtest 'Submit input', sub {
    $t->get_ok('/human/remark/post/1');

    $preview_remark{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok('/human/remark/post/1', form => \%preview_remark)
        ->status_is(200)
        ->text_like(p => qr/ayy\.\.\. lmao/);

    $t->get_ok('/human/thread/post');

    $preview_thread{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok('/human/thread/post', form => \%preview_thread)
        ->status_is(200)
        ->text_like(p => qr/ayy\.\.\. lmao/);
};

done_testing;
