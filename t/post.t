#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script = curfile->dirname->sibling('PostText.pl');
my $t      = Test::Mojo->new($script);

$t->get_ok('/post')->status_is(200);

$t->post_ok('/post')->status_is(200);

done_testing();
