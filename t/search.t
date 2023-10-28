use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t             = Test::Mojo->new('PostText');
my $invalid_query = 'aaaaaaaa' x 300;

subtest Search => sub {
    $t->get_ok('/search')->status_is(200)->text_like(h2 => qr/Search/);

    $t->get_ok('/search?q=test')->status_is(200)
        ->text_like(h3 => qr/Results/);

    $t->get_ok("/search?q=$invalid_query")->status_is(400)
        ->text_like(p => qr/Must be between/);
};

done_testing;
