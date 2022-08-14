#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Mojo::File qw{curfile};
use Test::Mojo;

my $script = curfile->dirname->sibling('PostText.pl');
my $t      = Test::Mojo->new($script);

$t->get_ok('/view')->status_is(200)->text_like(h2 => qr/View Threads/);

done_testing();
