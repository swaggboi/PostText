#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script         = curfile->dirname->sibling('PostText.pl');
my $t              = Test::Mojo->new($script);
my %valid_params   = (
    name  => 'Anonymous',
    title => 'hi',
    post  => 'ayy... lmao'
    );
my %invalid_params = (
    name => 'Anonymous',
    title => '',
    post => 'a'
    );

$t->ua->max_redirects(1);

# GET
$t->get_ok('/post')->status_is(200)->text_like(h2 => qr/New Thread/);

# POST
$t->post_ok('/post')->status_is(200)->text_like(h2 => qr/New Thread/);

$t->post_ok('/post', form => \%invalid_params)->status_is(400)
    ->text_like(h2 => qr/View Threads/);

$t->post_ok('/post', form => \%valid_params)->status_is(200)
    ->text_like(h2 => qr/View Threads/);

done_testing();
