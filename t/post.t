use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

# For CAPTCHA
my %good_captcha    = (answer => 1, number => 'Ⅰ');
my $bump_thread_url =
    '/captcha/H4sIAImTzmQAA8soKSmw0tfPyU9OzMnILy6xMjYwMNDPKM1NzNMvyShKTUzRTyrNLdA3BAD5ek7T%0AKQAAAA==%0A';

my %valid_thread = (
    author => 'Anonymous',
    title  => 'hi',
    body   => 'ayy... lmao'
    );

my %invalid_title = (
    author => 'Anonymous',
    title  => '',
    body   => 'ayy... lmao'
    );

my %invalid_thread = (
    author => 'Anonymous',
    title  => 'hi',
    body   => 'a'
    );

my %valid_remark = (
    author => 'Anonymous',
    body   => 'hi'
    );

my %invalid_remark = (
    author => 'Anonymous',
    body   => 'a'
    );

# No CAPTCHA yet
$t->get_ok('/human/thread/post')->status_is(302)
    ->header_like(Location => qr/captcha/);
$t->get_ok('/human/remark/post/1')->status_is(302)
    ->header_like(Location => qr/captcha/);

# Do CAPTCHA
$t->post_ok($bump_thread_url, form => \%good_captcha)
    ->status_is(302)
    ->header_like(Location => qr{human/thread/bump/1});

$t->ua->max_redirects(1);

subtest 'Post new thread', sub {
    # GET
    $t->get_ok('/human/thread/post')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form input[name="title"]'  )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form button[type="submit"]' )
        ->text_like(h2 => qr/New Thread/);

    # POST
    $t->post_ok('/human/thread/post')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form input[name="title"]'  )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form button[type="submit"]' )
        ->text_like(h2 => qr/New Thread/);

    $t->post_ok('/human/thread/post', form => \%invalid_title)
        ->status_is(400)
        ->text_like(p => qr/Must be between/);

    $t->post_ok('/human/thread/post', form => \%invalid_thread)
        ->status_is(400)
        ->text_like(p => qr/Must be between/);

    $t->post_ok('/human/thread/post', form => \%valid_thread)
        ->status_is(200)
        ->text_like(h2 => qr/Thread #\d+/);
};

subtest 'Post new remark', sub {
    # GET
    $t->get_ok('/human/remark/post/1')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form button[type="submit"]' )
        ->text_like(h2 => qr/Remark on Thread #/);
    $t->get_ok('/human/remark/post/65536')->status_is(404)
        ->text_like(p => qr/Thread not found/);
    # Test the remark-to-remark thing
    $t->get_ok('/human/remark/post/1/1')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form button[type="submit"]' )
        ->element_exists('a[href$="/remark/single/1"]')
        ->text_like(h3 => qr/Last Remark/);

    # POST
    $t->post_ok('/human/remark/post/1')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form button[type="submit"]' )
        ->text_like(h2 => qr/Remark on Thread #/);

    $t->post_ok('/human/remark/post/1', form => \%valid_remark)
        ->status_is(200)
        ->text_like(h2 => qr/Thread #1/);

    $t->post_ok('/human/remark/post/1', form => \%invalid_remark)
        ->status_is(400)
        ->text_like(p => qr/Must be between/);
};

done_testing;
