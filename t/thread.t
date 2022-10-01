#!/usr/bin/env perl

use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

$t->get_ok('/thread/1'  )->status_is(200)->text_like(h2 => qr/Thread #1/);
$t->get_ok('/thread/1/1')->status_is(200)->text_like(h2 => qr/Thread #1/);

done_testing();
