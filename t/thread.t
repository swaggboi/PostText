use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

my %valid_params = (
    author => 'Anonymous',
    title  => 'hi',
    body   => 'ayy... lmao'
    );

my %invalid_title = (
    author => 'Anonymous',
    title  => '',
    body   => 'ayy... lmao'
    );

my %invalid_post = (
    author => 'Anonymous',
    title  => 'hi',
    body   => 'a'
    );

subtest 'List threads by page', sub {
    $t->get_ok('/thread/list')->status_is(200)
        ->text_like(h2 => qr/Threads List/);

    $t->get_ok('/thread/list/1')->status_is(200)
        ->text_like(h2 => qr/Threads List/);
};

subtest 'View single thread', sub {
    $t->get_ok('/thread/single/1')->status_is(200)
        ->text_like(h2 => qr/Thread #1/);

    $t->get_ok('/thread/single/1/1')->status_is(200)
        ->text_like(h2 => qr/Thread #1/);

    $t->get_ok('/thread/single/65536')->status_is(404)
        ->text_like(p => qr/Thread not found/);
};

subtest 'Threads feed', sub {
    $t->get_ok('/thread/feed.rss')->status_is(200)
        ->content_type_is('application/rss+xml')
};

$t->ua->max_redirects(1);

subtest 'Post new thread', sub {
    # GET
    $t->get_ok('/thread/post')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form input[name="title"]'  )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form button[type="submit"]' )
        ->text_like(h2 => qr/New Thread/);

    # POST
    $t->post_ok('/thread/post')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form input[name="title"]'  )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form button[type="submit"]' )
        ->text_like(h2 => qr/New Thread/);

    $t->post_ok('/thread/post', form => \%invalid_title)->status_is(400)
        ->text_like(p => qr/Must be between/);

    $t->post_ok('/thread/post', form => \%invalid_post)->status_is(400)
        ->text_like(p => qr/Must be between/);

    $t->post_ok('/thread/post', form => \%valid_params)->status_is(200)
        ->text_like(h2 => qr/Thread #\d+/);
};

subtest 'Bumping thread', sub {
    $t->get_ok('/thread/list')->status_is(200)
        ->element_exists('a[href*="bump"]')
        ->text_like(h2 => qr/Threads List/);

    $t->get_ok('/thread/single/1')->status_is(200)
        ->element_exists('a[href*="bump"]')
        ->text_like(h2 => qr/Thread #1/);

    $t->get_ok('/thread/bump/1')->status_is(200)
        ->element_exists('p[class="stash-with-info"]')
        ->text_like(p => qr/Thread #1 has been bumped/);
};

subtest 'Flagging thread', sub {
    $t->get_ok('/thread/list')->status_is(200)
        ->element_exists('a[href*="flag"]')
        ->text_like(h2 => qr/Threads List/);

    $t->get_ok('/thread/single/1')->status_is(200)
        ->element_exists('a[href*="flag"]')
        ->text_like(h2 => qr/Thread #1/);

    $t->get_ok('/thread/flag/1')->status_is(200)
        ->element_exists('p[class="stash-with-info"]')
        ->text_like(p => qr/Thread #1 has been flagged/);
};

done_testing;
