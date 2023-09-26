use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

my %valid_remark = (
    author => 'Anonymous',
    body   => 'hi'
    );

my %invalid_remark = (
    author => 'Anonymous',
    body   => 'a'
    );

subtest 'View single remark', sub {
    $t->get_ok('/remark/single/1')->status_is(200)
        ->text_like(h2 => qr/Remark #1/)
        ->element_exists('a[href$="/remark/post/1/1"]')
        ->element_exists('h2 sup a[href$=".txt"]');
    $t->get_ok('/remark/single/65536')->status_is(404)
        ->text_like(p => qr/Remark not found/);

    $t->get_ok('/remark/single/1.txt')->status_is(200)
        ->content_type_like(qr{text/plain});
    $t->get_ok('/remark/single/65536.txt')->status_is(404)
        ->content_type_like(qr{text/plain});
};

subtest 'Remarks feed', sub {
    $t->get_ok('/remark/feed.rss')->status_is(200)
        ->content_type_is('application/rss+xml')
};

$t->ua->max_redirects(1);

subtest 'Post new remark', sub {
    # GET
    $t->get_ok('/remark/post/1')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form button[type="submit"]' )
        ->text_like(h2 => qr/Remark on Thread #/);
    $t->get_ok('/remark/post/65536')->status_is(404)
        ->text_like(p => qr/Thread not found/);
    # Test the remark-to-remark thing
    $t->get_ok('/remark/post/1/1')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form button[type="submit"]' )
        ->element_exists('a[href$="/remark/single/1"]')
        ->text_like(h3 => qr/Last Remark/);

    # POST
    $t->post_ok('/remark/post/1')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form button[type="submit"]' )
        ->text_like(h2 => qr/Remark on Thread #/);

    $t->post_ok('/remark/post/1', form => \%valid_remark)->status_is(200)
        ->text_like(h2 => qr/Thread #1/);

    $t->post_ok('/remark/post/1', form => \%invalid_remark)->status_is(400)
        ->text_like(p => qr/Must be between/);
};

done_testing;
