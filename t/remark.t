use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

my %valid_remark   = (
    author => 'Anonymous',
    body   => 'hi'
    );
my %invalid_remark = (
    author => 'Anonymous',
    body   => 'a'
    );

subtest 'View single remark', sub {
    $t->get_ok('/remark/1')->status_is(200)->text_like(h2 => qr/Remark #1/);
};

subtest 'Post new remark', sub {
    $t->ua->max_redirects(1);

    # GET
    $t->get_ok('/post/1')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form input[type="submit"]' )
        ->text_like(h2 => qr/New Remark/);

    # POST
    $t->post_ok('/post/1')->status_is(200)
        ->element_exists('form input[name="author"]' )
        ->element_exists('form textarea[name="body"]')
        ->element_exists('form input[type="submit"]' )
        ->text_like(h2 => qr/New Remark/);

    $t->post_ok('/post/1', form => \%valid_remark)->status_is(200)
        ->text_like(h2 => qr/Thread #1/);
    $t->post_ok('/post/1', form => \%invalid_remark)->status_is(400)
        ->text_like(p => qr/Invalid text/);
};

done_testing();
