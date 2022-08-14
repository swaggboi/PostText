#!/usr/bin/env perl

package PostText::Model::Thread;

use Mojo::Base -base, -signatures;

has 'pg';

sub new($class, $pg, $pg_reference) {
    bless {
        $pg              => $pg_reference,
        threads_per_page => 5
    }, $class
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

sub get_all_threads($self) {
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

sub get_threads_by_page($self, $this_page = 1) {
    my $row_count = $self->{'threads_per_page'};
    my $offset    = ($this_page - 1) * $row_count;

    $self->pg->db->query(<<~'END_SQL', $row_count, $offset)->hashes();
        SELECT thread_id                                             AS id,
               TO_CHAR(thread_date, 'Dy Mon DD HH:MI:SS AM TZ YYYY') AS date,
               thread_author                                         AS author,
               thread_title                                          AS title,
               thread_body                                           AS body
          FROM threads
         WHERE NOT hidden_status
         ORDER BY thread_date DESC
         LIMIT ? OFFSET ?;
       END_SQL
}

sub threads_per_page($self, $value = undef) {
    $self->{'threads_per_page'} = $value // $self->{'threads_per_page'}
}

sub get_last_page($self) {
    my $thread_count = $self->get_thread_count();
    my $last_page    = int($thread_count / $self->{'threads_per_page'});

    # Add a page for 'remainder' posts
    return ++$last_page if $thread_count % $self->{'threads_per_page'};

    return $last_page;
}

sub get_thread_count($self) {
    $self->pg->db->query(<<~'END_SQL')->text()
        SELECT COUNT(*)
          FROM threads
         WHERE NOT hidden_status;
       END_SQL
}

1;
