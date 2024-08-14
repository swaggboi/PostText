use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

$t->get_ok('/thread/post')->status_is(302)
    ->header_like(Location => qr{human/thread/post});

done_testing;
