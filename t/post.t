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
my %invalid_title  = (
    name => 'Anonymous',
    title => '',
    post => 'ayy... lmao'
    );
my %invalid_post   = (
    name => 'Anonymous',
    title => 'hi',
    post => 'a'
    );
my %valid_remark   = (
    name => 'Anonymous',
    post => 'hi'
    );
my %invalid_remark = (
    name => 'Anonymous',
    post => 'a'
    );

$t->ua->max_redirects(1);

# GET
$t->get_ok('/post'  )->status_is(200)->text_like(h2 => qr/New Thread/);
$t->get_ok('/post/1')->status_is(200)->text_like(h2 => qr/New Remark/);

# POST
$t->post_ok('/post'  )->status_is(200)->text_like(h2 => qr/New Thread/);

$t->post_ok('/post', form => \%invalid_title)->status_is(400)
    ->text_like(p => qr/Invalid title/);
$t->post_ok('/post', form => \%invalid_post)->status_is(400)
    ->text_like(p => qr/Invalid post/);
$t->post_ok('/post', form => \%valid_params)->status_is(200)
    ->text_like(h2 => qr/Threads List/);

$t->post_ok('/post/1')->status_is(200)->text_like(h2 => qr/New Remark/);

$t->post_ok('/post/1', form => \%valid_remark)->status_is(200)
    ->text_like(h2 => qr/Thread - #1/);
$t->post_ok('/post/1', form => \%invalid_remark)->status_is(400)
    ->text_like(h2 => qr/New Remark/);

done_testing();
