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

sub by_page_for($self, $thread_id, $this_page = 1) {
    my $date_format = %$self{'date_format'};
    my $row_count   = %$self{'remarks_per_page'};
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

sub per_page($self, $value = undef) {
    $self->{'remarks_per_page'} = $value // $self->{'remarks_per_page'}
}

sub create($self, $thread_id, $author, $body, $hidden = 0, $flagged = 0) {
    my @data = ($thread_id, $author, $body, $hidden, $flagged);

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
    $self->pg->db->query(<<~'END_SQL', $thread_id)->hash->{'count'}
        SELECT COUNT(*) AS count
          FROM remarks
         WHERE thread_id = ?
           AND NOT hidden_status;
       END_SQL
}

sub last_page_for($self, $thread_id) {
    my $remark_count = $self->count_for($thread_id);
    my $last_page    = int($remark_count / $self->{'remarks_per_page'});

    # Add a page for 'remainder' posts
    $last_page++ if $remark_count % $self->{'remarks_per_page'};

    $last_page;
}

sub last_for($self, $thread_id) {
    my $date_format = $self->{'date_format'};

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
    my $date_format = $self->{'date_format'};

    $self->pg->db->query(<<~'END_SQL', $date_format, $remark_id)->hash;
        SELECT remark_id               AS id,
               TO_CHAR(remark_date, ?) AS date,
               remark_author           AS author,
               remark_body             AS body,
               thread_id
          FROM remarks
         WHERE remark_id = ?;
       END_SQL
}

sub thread_id_for($self, $remark_id) {
    $self->pg->db->query(<<~'END_SQL', $remark_id)->hash->{'thread_id'}
        SELECT thread_id
          FROM remarks
         WHERE remark_id = ?;
       END_SQL
}

1;
