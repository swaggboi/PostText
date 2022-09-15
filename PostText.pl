#!/usr/bin/env perl

# PostText v0.1
# Jul 22

use Mojo::Base -strict;
use lib qw{lib};
use Mojolicious::Commands;

Mojolicious::Commands->start_app('PostText');
