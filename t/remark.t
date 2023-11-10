use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

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

done_testing;
