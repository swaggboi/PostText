#!/usr/bin/env perl

use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PostText');

$t->get_ok('/list'  )->status_is(200)->text_like(h2 => qr/Threads List/);
$t->get_ok('/list/1')->status_is(200)->text_like(h2 => qr/Threads List/);

done_testing();
