#!/usr/bin/env perl

package PostText::Model::Thread;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_object) {
    bless {$pg => $pg_object}
}

1;
