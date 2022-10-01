#!/usr/bin/env perl

use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

$t->get_ok('/remark/1')->status_is(200)->text_like(h2 => qr/Remark #1/);

done_testing();
