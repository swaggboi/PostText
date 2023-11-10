use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

subtest 'List threads by page', sub {
    $t->get_ok('/thread/list')->status_is(200)
        ->text_like(h2 => qr/Threads List/);

    $t->get_ok('/thread/list/1')->status_is(200)
        ->text_like(h2 => qr/Threads List/);

    $t->get_ok('/thread/list/65536')->status_is(404)
        ->text_like(p => qr/Page not found/);
};

subtest 'View single thread', sub {
    $t->get_ok('/thread/single/1')->status_is(200)
        ->text_like(h2 => qr/Thread #1/)
        ->element_exists('h2 sup a[href$=".txt"]');
    $t->get_ok('/thread/single/65536')->status_is(404)
        ->text_like(p => qr/Thread not found/);

    $t->get_ok('/thread/single/1.txt')->status_is(200)
        ->content_type_like(qr{text/plain});
    $t->get_ok('/thread/single/65536.txt')->status_is(404)
        ->content_type_like(qr{text/plain});

    # Test the thread_page and remark_id params
    $t->get_ok('/thread/single/1/1')->status_is(200)
        ->element_exists('a[href$="/remark/post/1/1"]');

    $t->get_ok('/thread/single/1/65536')->status_is(404)
        ->text_like(p => qr/Page not found/);
};

subtest 'Threads feed', sub {
    $t->get_ok('/thread/feed.rss')->status_is(200)
        ->content_type_is('application/rss+xml')
};

done_testing;
