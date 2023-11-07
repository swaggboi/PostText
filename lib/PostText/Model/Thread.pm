package PostText::Model::Thread;

use Mojo::Base -base, -signatures;

has [qw{pg hr max_pages}];

has per_page => 5;

has date_format => 'Dy, FMDD Mon YYYY HH24:MI:SS TZHTZM';

sub create($self, $author, $title, $body, $hidden = 0, $flagged = 0) {
    my $clean_body = $self->hr->process($body);
    my @data       = ($author, $title, $clean_body, $hidden, $flagged);

    $self->pg->db->query(<<~'END_SQL', @data)->hash->{'thread_id'};
        INSERT INTO threads (
               thread_author,
               thread_title,
               thread_body,
               hidden_status,
               flagged_status
               )
        VALUES (?, ?, ?, ?, ?)
     RETURNING thread_id;
     END_SQL
    # The indented heredoc got a little confused by this one...
}

sub by_page($self, $this_page = 1) {
    my $date_format = $self->date_format;
    my $row_count   = $self->per_page;
    my $offset      = ($this_page - 1) * $row_count;

    $self->pg->db
        ->query(<<~'END_SQL', $date_format, $row_count, $offset)->hashes;
            SELECT t.thread_id               AS id,
                   TO_CHAR(t.thread_date, ?) AS date,
                   t.thread_author           AS author,
                   t.thread_title            AS title,
                   t.thread_body             AS body,
                   COUNT(r.*)                AS remark_tally,
                   t.bump_tally              AS bump_tally
              FROM threads      AS t
              LEFT JOIN remarks AS r
                ON t.thread_id = r.thread_id
             WHERE NOT (t.hidden_status OR r.hidden_status)
             GROUP BY t.thread_id
             ORDER BY t.bump_date DESC
             LIMIT ? OFFSET ?;
           END_SQL
}

sub last_page($self) {
    my $thread_count = $self->count;
    my $last_page    = int($thread_count / $self->per_page);
    my $max_pages    = $self->max_pages;

    # Add a page for 'remainder' posts
    $last_page++ if $thread_count % $self->per_page;

    if ($max_pages) {
        $last_page = $max_pages if $last_page > $max_pages
    }

    return $last_page;
}

sub count($self) {
    $self->pg->db->query(<<~'END_SQL')->hash->{'tally'}
        SELECT COUNT(*) AS tally
          FROM threads
         WHERE NOT hidden_status;
       END_SQL
}

sub by_id($self, $thread_id) {
    my $date_format = $self->date_format;

    $self->pg->db->query(<<~'END_SQL', $date_format, $thread_id)->hash;
        SELECT t.thread_id               AS id,
               TO_CHAR(t.thread_date, ?) AS date,
               t.thread_author           AS author,
               t.thread_title            AS title,
               t.thread_body             AS body,
               COUNT(r.*)                AS remark_tally,
               t.bump_tally              AS bump_tally
          FROM threads      AS t
          LEFT JOIN remarks AS r
            ON t.thread_id = r.thread_id
         WHERE t.thread_id = ?
           AND NOT t.hidden_status
         GROUP BY t.thread_id;
       END_SQL
}

sub bump($self, $thread_id) {
    $self->pg->db->query(<<~'END_SQL', $thread_id)
        UPDATE threads
           SET bump_date = NOW(),
               bump_tally = bump_tally + 1
         WHERE thread_id = ?;
       END_SQL
}

sub flag($self, $thread_id) {
    $self->pg->db->query(<<~'END_SQL', $thread_id)
        UPDATE threads
           SET flagged_status = TRUE
         WHERE thread_id = ?;
       END_SQL
}

sub feed($self) {
    my $date_format = $self->date_format;

    $self->pg->db->query(<<~'END_SQL', $date_format)->hashes;
            SELECT thread_id               AS id,
                   TO_CHAR(thread_date, ?) AS date,
                   thread_title            AS title,
                   thread_body             AS body
              FROM threads
             WHERE NOT hidden_status
             GROUP BY thread_id
             ORDER BY thread_date DESC
             LIMIT 15;
           END_SQL
}

1;
