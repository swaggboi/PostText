#!/usr/bin/env perl

package PostText::Model::Reply;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_reference) {
    bless {
        $pg              => $pg_reference,
        replies_per_page => 5,
        date_format      => 'Dy Mon FMDD HH24:MI TZ YYYY'
    }, $class
}

sub get_replies_by_thread_id($self, $thread_id) {
    my $date_format = %$self{'date_format'};

    $self->pg->db->query(<<~'END_SQL', $date_format, $thread_id)->hashes();
        SELECT reply_id               AS id,
               TO_CHAR(reply_date, ?) AS date,
               reply_author           AS author,
               reply_body             AS body
          FROM replies
         WHERE thread_id = ?
           AND NOT hidden_status
         ORDER BY reply_date ASC;
       END_SQL
}

1;
