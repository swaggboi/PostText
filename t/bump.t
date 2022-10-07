use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

subtest 'Bumping thread', sub {
    $t->get_ok('/list')->status_is(200)
        ->element_exists('a[href~="bump"]')
        ->text_like(h2 => qr/Threads List/);

    $t->get_ok('/bump/1')->status_is(302)
        ->header_like(Location => qr/list/);
};
