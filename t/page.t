use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

$t->get_ok('/about')->status_is(200)->text_like(h2 => qr/About Post::Text/);

$t->get_ok('/rules')->status_is(200)->text_like(h2 => qr/The Rules/);

$t->get_ok('/feeds')->status_is(200)->text_like(h2 => qr/Feeds/);

$t->get_ok('/javascript')->status_is(200)
    ->text_like(h2 => qr/JavaScript License Information/);

done_testing;
