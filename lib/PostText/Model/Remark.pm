#!/usr/bin/env perl

package PostText::Model::Remark;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_reference) {
    bless {
        $pg              => $pg_reference,
        remarks_per_page => 5,
        date_format      => 'Dy Mon FMDD HH24:MI TZ YYYY'
    }, $class
}

sub get_remarks_by_thread_id($self, $thread_id) {
    my $date_format = %$self{'date_format'};

    $self->pg->db->query(<<~'END_SQL', $date_format, $thread_id)->hashes();
        SELECT remark_id               AS id,
               TO_CHAR(remark_date, ?) AS date,
               remark_author           AS author,
               remark_body             AS body
          FROM remarks
         WHERE thread_id = ?
           AND NOT hidden_status
         ORDER BY remark_date ASC;
       END_SQL
}

sub remarks_per_page($self, $value = undef) {
    $self->{'remarks_per_page'} = $value // $self->{'remarks_per_page'};
}

sub create_remark(
    $self,
    $thread_id,
    $author,
    $body,
    $hidden  = 0,
    $flagged = 0
    )
{
    $self->pg->db
        ->query(<<~'END_SQL', $thread_id, $author, $body, $hidden, $flagged)
            INSERT INTO remarks (
                thread_id,
                remark_author,
                remark_body,
                hidden_status,
                flagged_status
                )
            VALUES (?, ?, ?, ?, ?);
           END_SQL
}

1;
