#!/usr/bin/env perl

package PostText::Model::Thread;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_reference) {
    bless {
        $pg              => $pg_reference,
        threads_per_page => 5,
        date_format      => 'Dy Mon FMDD HH24:MI TZ YYYY'
    }, $class
}

sub create($self, $author, $title, $body, $hidden = 0, $flagged = 0) {
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

*create_thread = \&create;

sub dump_all($self) {
    $self->pg->db->query(<<~'END_SQL', %$self{'date_format'})->hashes
        SELECT thread_id               AS id,
               TO_CHAR(thread_date, ?) AS date,
               thread_author           AS author,
               thread_title            AS title,
               thread_body             AS body
          FROM threads
         WHERE NOT hidden_status
         ORDER BY bump_date DESC;
       END_SQL
}

*get_all_threads = \&dump_all;

sub by_page($self, $this_page = 1) {
    my $date_format = %$self{'date_format'};
    my $row_count   = $self->{'threads_per_page'};
    my $offset      = ($this_page - 1) * $row_count;

    $self->pg->db
        ->query(<<~'END_SQL', $date_format, $row_count, $offset)->hashes;
            SELECT thread_id               AS id,
                   TO_CHAR(thread_date, ?) AS date,
                   thread_author           AS author,
                   thread_title            AS title,
                   thread_body             AS body
              FROM threads
             WHERE NOT hidden_status
             ORDER BY bump_date DESC
             LIMIT ? OFFSET ?;
           END_SQL
}

*get_threads_by_page = \&by_page;

sub per_page($self, $value = undef) {
    $self->{'threads_per_page'} = $value // $self->{'threads_per_page'}
}

*threads_per_page = \&per_page;

sub last_page($self) {
    my $thread_count = $self->count;
    my $last_page    = int($thread_count / $self->{'threads_per_page'});

    # Add a page for 'remainder' posts
    $last_page++ if $thread_count % $self->{'threads_per_page'};

    $last_page;
}

*get_last_page = \&last_page;

sub count($self) {
    $self->pg->db->query(<<~'END_SQL')->hash->{'count'}
        SELECT COUNT(*) AS count
          FROM threads
         WHERE NOT hidden_status;
       END_SQL
}

*get_thread_count = \&count;

sub by_id($self, $thread_id) {
    my $date_format = %$self{'date_format'};

    $self->pg->db->query(<<~'END_SQL', $date_format, $thread_id)->hash;
        SELECT thread_id               AS id,
               TO_CHAR(thread_date, ?) AS date,
               thread_author           AS author,
               thread_title            AS title,
               thread_body             AS body
          FROM threads
         WHERE thread_id = ?;
       END_SQL
}

*get_thread_by_id = \&by_id;

1;
