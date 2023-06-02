package PostText::Model::Remark;

use Mojo::Base -base, -signatures;

has [qw{pg hr}];

has per_page => 5;

has date_format => 'Dy, FMDD Mon YYYY HH24:MI:SS TZHTZM';

sub by_page_for($self, $thread_id, $this_page = 1) {
    my $date_format = $self->date_format;
    my $row_count   = $self->per_page;
    my $offset      = ($this_page - 1) * $row_count;
    my @data        = ($date_format, $thread_id, $row_count, $offset);

    $self->pg->db->query(<<~'END_SQL', @data)->hashes;
        SELECT remark_id               AS id,
               TO_CHAR(remark_date, ?) AS date,
               remark_author           AS author,
               remark_body             AS body
          FROM remarks
         WHERE thread_id = ?
           AND NOT hidden_status
         ORDER BY remark_date ASC
         LIMIT ? OFFSET ?;
       END_SQL
}

sub create($self, $thread_id, $author, $body, $hidden = 0, $flagged = 0) {
    my $clean_body = $self->hr->process($body);
    my @data       = ($thread_id, $author, $clean_body, $hidden, $flagged);

    $self->pg->db->query(<<~'END_SQL', @data);
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

sub count_for($self, $thread_id) {
    $self->pg->db->query(<<~'END_SQL', $thread_id)->hash->{'tally'}
        SELECT COUNT(*) AS tally
          FROM remarks
         WHERE thread_id = ?
           AND NOT hidden_status;
       END_SQL
}

sub last_page_for($self, $thread_id) {
    my $remark_count = $self->count_for($thread_id);
    my $last_page    = int($remark_count / $self->per_page);

    # Add a page for 'remainder' posts
    $last_page++ if $remark_count % $self->per_page;

    return $last_page;
}

sub last_for($self, $thread_id) {
    my $date_format = $self->date_format;

    $self->pg->db->query(<<~'END_SQL', $date_format, $thread_id)->hash;
        SELECT remark_id               AS id,
               TO_CHAR(remark_date, ?) AS date,
               remark_author           AS author,
               remark_body             AS body
          FROM remarks
         WHERE thread_id = ?
         ORDER BY remark_date
          DESC LIMIT 1;
       END_SQL
}

sub by_id($self, $remark_id) {
    my $date_format = $self->date_format;

    $self->pg->db->query(<<~'END_SQL', $date_format, $remark_id)->hash;
        SELECT remark_id               AS id,
               TO_CHAR(remark_date, ?) AS date,
               remark_author           AS author,
               remark_body             AS body,
               thread_id
          FROM remarks
         WHERE remark_id = ?
           AND NOT hidden_status;
       END_SQL
}

sub thread_id_for($self, $remark_id) {
    $self->pg->db->query(<<~'END_SQL', $remark_id)->hash->{'thread_id'}
        SELECT thread_id
          FROM remarks
         WHERE remark_id = ?;
       END_SQL
}

sub flag($self, $remark_id) {
    $self->pg->db->query(<<~'END_SQL', $remark_id)
        UPDATE remarks
           SET flagged_status = TRUE
         WHERE remark_id = ?;
       END_SQL
}

sub unflag($self, $remark_id) {
    $self->pg->db->query(<<~'END_SQL', $remark_id)
        UPDATE remarks
           SET flagged_status = FALSE
         WHERE remark_id = ?;
       END_SQL
}

1;
