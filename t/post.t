#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script = curfile->dirname->sibling('PostText.pl');
my $t      = Test::Mojo->new($script);
my %valid_params = (
    name  => 'Anonymous',
    title => 'hi',
    body  => 'ayy... lmao'
    );

$t->ua->max_redirects(1);

$t->get_ok('/post')->status_is(200)->text_like(h2 => qr/New Thread/);;

# This should fail!! 08142022
$t->post_ok('/post')->status_is(200);

$t->post_ok('/post', form => \%valid_params)->status_is(200)
    ->text_like(h2 => qr/View Threads/);

done_testing();
