use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t             = Test::Mojo->new('PostText');
my $invalid_query = 'aaaaaaaa' x 300;
my %good_human    = (answer => 1, number => 'Ⅰ');
my $search_url    =
    '/captcha/H4sIABJ8PGUAA8soKSmw0tfPyU9OzMnILy6xMjYwMNDPKM1NzNMvTk0sSs4AAPrUR3kiAAAA%0A';

subtest 'Search form', sub {
    $t->get_ok('/thread/list')
        ->element_exists('form input[name="q"]'      )
        ->element_exists('form button[type="submit"]');
};

subtest 'Search before CAPTCHA', sub {
    $t->get_ok('/human/search')->status_is(302)
        ->header_like(Location => qr/captcha/);
};

subtest 'Search after CAPTCHA', sub {
    $t->get_ok($search_url);

    $good_human{'csrf_token'} =
        $t->tx->res->dom->at('input[name="csrf_token"]')->val;

    $t->post_ok($search_url, form => \%good_human)
        ->status_is(302)
        ->header_like(Location => qr{human/search});

    $t->get_ok('/human/search?q=lmao')->status_is(200)
        ->text_like(h2 => qr/Search Results/);

    $t->get_ok('/human/search?q=aaaaaaaaaa')->status_is(404)
        ->text_like(p => qr/No posts found/);

    $t->get_ok("/human/search?q=$invalid_query")->status_is(400)
        ->text_like(p => qr/Must be between/);
};

done_testing;
