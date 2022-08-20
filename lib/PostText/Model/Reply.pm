#!/usr/bin/env perl

package PostText::Model::Reply;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_reference) {
    bless {
        $pg              => $pg_reference,
        replies_per_page => 5
    }, $class
}

1;
