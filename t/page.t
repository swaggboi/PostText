use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

$t->get_ok('/about')->status_is(200)->text_like(h2 => qr/About Post::Text/);

$t->get_ok('/rules')->status_is(200)->text_like(h2 => qr/The Rules/);

done_testing;
