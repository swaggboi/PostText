#!/usr/bin/env perl

package PostText::Model::Thread;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_reference) {
    bless {$pg => $pg_reference}
}

sub create_thread($self, $author, $title, $body, $hidden = 0, $flagged = 0) {
    my @data = ($author, $title, $body, $hidden, $flagged);

    $self->pg->db->query(<<~'END_SQL', @data);
        INSERT INTO threads (
            thread_author,
            thread_title,
            thread_body,
            hidden_status,
            flagged_status
        )
        VALUES (?, ?, ?, ?, ?);
    END_SQL
}

1;
