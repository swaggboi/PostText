#!/usr/bin/env perl

package PostText::Model::Thread;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_reference) {
    bless {$pg => $pg_reference}, $class
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

sub get_threads($self) {
    $self->pg->db->query(<<~'END_SQL')->hashes()
        SELECT thread_id                                             AS id,
               TO_CHAR(thread_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY') AS date,
               thread_author                                         AS author,
               thread_title                                          AS title,
               thread_body                                           AS body
          FROM threads
         WHERE NOT hidden_status
         ORDER BY thread_date DESC;
       END_SQL
}

1;
