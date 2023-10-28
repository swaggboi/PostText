use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t             = Test::Mojo->new('PostText');
my $invalid_query = 'aaaaaaaa' x 300;
my %good_human    = (answer => 1, number => 'Ⅰ');
my $search_url    =
    '/captcha/H4sIABJ8PGUAA8soKSmw0tfPyU9OzMnILy6xMjYwMNDPKM1NzNMvTk0sSs4AAPrUR3kiAAAA%0A';

subtest 'Search before CAPTCHA', sub {
    $t->get_ok('/human/search')->status_is(302)
        ->header_like(Location => qr/captcha/);
};

subtest 'Search after CAPTCHA', sub {
    $t->post_ok($search_url, form => \%good_human)
        ->status_is(302)
        ->header_like(Location => qr{human/search});

    $t->get_ok('/human/search')->status_is(200)
        ->text_like(h2 => qr/Search Posts/);

    $t->get_ok('/human/search?q=test')->status_is(200)
        ->text_like(h3 => qr/Results/);

    $t->get_ok("/human/search?q=$invalid_query")->status_is(400)
        ->text_like(p => qr/Must be between/);
};

done_testing;
