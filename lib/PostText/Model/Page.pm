package PostText::Model::Page;

use Mojo::Base -base, -signatures;

has 'pg';

has per_page => 5;

has date_format => 'Dy, FMDD Mon YYYY HH24:MI:SS TZHTZM';

sub search($self, $search_query, $this_page = 1) {
    my $date_format = $self->date_format;
    my $row_count   = $self->per_page;
    my $offset      = ($this_page - 1) * $row_count;
    my @data        = ($date_format, $search_query, $row_count, $offset);

    $self->pg->db->query(<<~'END_SQL', @data)->hashes;
        SELECT 'thread'                                               AS post_type,
               thread_id                                              AS post_id,
               TO_CHAR(thread_date, $1)                               AS post_date,
               thread_author                                          AS post_author,
               thread_body                                            AS post_body,
               TS_RANK(search_tokens, PLAINTO_TSQUERY('english', $2)) AS search_rank
          FROM threads
         WHERE search_tokens @@ PLAINTO_TSQUERY('english', $2)
         UNION ALL
        SELECT 'remark',
               remark_id,
               TO_CHAR(remark_date, $1),
               remark_author,
               remark_body,
               TS_RANK(search_tokens, PLAINTO_TSQUERY('english', $2))
          FROM remarks
         WHERE search_tokens @@ PLAINTO_TSQUERY('english', $2)
         ORDER BY search_rank DESC, post_date DESC
         LIMIT $3 OFFSET $4;
       END_SQL
}


1;
