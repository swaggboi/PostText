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
}

sub dump_all($self) {
    $self->pg->db->query(<<~'END_SQL', $self->{'date_format'})->hashes
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

sub by_page($self, $this_page = 1) {
    my $date_format = $self->{'date_format'};
    my $row_count   = $self->{'threads_per_page'};
    my $offset      = ($this_page - 1) * $row_count;

    $self->pg->db
        ->query(<<~'END_SQL', $date_format, $row_count, $offset)->hashes;
            SELECT t.thread_id               AS id,
                   TO_CHAR(t.thread_date, ?) AS date,
                   t.thread_author           AS author,
                   t.thread_title            AS title,
                   t.thread_body             AS body,
                   COUNT(r.*)                AS remark_count
              FROM threads t
              LEFT JOIN remarks r
                ON t.thread_id = r.thread_id
             WHERE NOT t.hidden_status
             GROUP BY t.thread_id
             ORDER BY t.bump_date DESC
             LIMIT ? OFFSET ?;
           END_SQL
}

sub per_page($self, $value = undef) {
    $self->{'threads_per_page'} = $value // $self->{'threads_per_page'}
}

sub last_page($self) {
    my $thread_count = $self->count;
    my $last_page    = int($thread_count / $self->{'threads_per_page'});

    # Add a page for 'remainder' posts
    $last_page++ if $thread_count % $self->{'threads_per_page'};

    $last_page;
}

sub count($self) {
    $self->pg->db->query(<<~'END_SQL')->hash->{'count'}
        SELECT COUNT(*) AS count
          FROM threads
         WHERE NOT hidden_status;
       END_SQL
}

sub by_id($self, $thread_id) {
    my $date_format = $self->{'date_format'};

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

sub bump($self, $thread_id) {
    $self->pg->db->query(<<~'END_SQL', $thread_id)
        UPDATE threads
           SET bump_date = NOW()
         WHERE thread_id = ?;
       END_SQL
}

1;
