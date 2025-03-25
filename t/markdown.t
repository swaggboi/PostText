use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

# For CAPTCHA
my %good_captcha    = (answer => 1, number => 'Ⅰ');
my $bump_thread_url =
    '/captcha/H4sIAImTzmQAA8soKSmw0tfPyU9OzMnILy6xMjYwMNDPKM1NzNMvyShKTUzRTyrNLdA3BAD5ek7T%0AKQAAAA==%0A';

my %markdown_thread = (
    author   => 'Anonymous',
    title    => 'hi',
    body     => '# ayy... lmao',
    preview  => 1,
    markdown => 1
    );

my %markdown_remark = (
    author   => 'Anonymous',
    body     => '# ayy... lmao',
    preview  => 1,
    markdown => 1
    );

my %plain_text_thread = (
    author  => 'Anonymous',
    title   => 'hi',
    body    => '# ayy... lmao',
    preview => 1
    );

my %plain_text_remark = (
    author  => 'Anonymous',
    body    => '# ayy... lmao',
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
        ->element_exists('input[id="markdown"]');

    $t->get_ok('/human/thread/post')->status_is(200)
        ->element_exists('input[id="markdown"]');
};

subtest 'Submit markdown input', sub {
    $t->get_ok('/human/remark/post/1');

    $markdown_remark{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok('/human/remark/post/1', form => \%markdown_remark)
        ->status_is(200)
        ->text_like('div.form-preview h1', qr/ayy\.\.\. lmao/);

    $t->get_ok('/human/thread/post');

    $markdown_thread{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok('/human/thread/post', form => \%markdown_thread)
        ->status_is(200)
        ->text_like('div.form-preview h1', qr/ayy\.\.\. lmao/);
};

subtest 'Submit plain text input', sub {
    $t->get_ok('/human/remark/post/1');

    $plain_text_remark{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok('/human/remark/post/1', form => \%plain_text_remark)
        ->status_is(200)
        ->text_like('span.plain-text', qr/# ayy\.\.\. lmao/);

    $t->get_ok('/human/thread/post');

    $plain_text_thread{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok('/human/thread/post', form => \%plain_text_thread)
        ->status_is(200)
        ->text_like('span.plain-text', qr/# ayy\.\.\. lmao/);
};

done_testing;
