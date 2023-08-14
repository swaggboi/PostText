use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

#my %preview_thread = (
#    author  => 'Anonymous',
#    title   => 'hi',
#    body    => 'ayy... lmao',
#    preview => 1
#    );
my %preview_remark = (
    author  => 'Anonymous',
    body    => 'ayy... lmao',
    preview => 1
    );

subtest 'Check the form + button', sub {
    $t->get_ok('/remark/post/1')->status_is(200)
        ->element_exists('input[id="preview"]');

    #$t->get_ok('/thread/post')->status_is(200)
    #    ->element_exists('input[id="preview"]');
};

subtest 'Submit input', sub {
    $t->post_ok('/remark/post/1', form => \%preview_remark)
        ->status_is(200)
        ->text_like(p => qr/ayy\.\.\. lmao/);

    #$t->post_ok('/thread/post', form => \%preview_thread)
    #    ->status_is(200)
    #    ->text_like(p => qr/ayy\.\.\. lmao/);
};

done_testing;
