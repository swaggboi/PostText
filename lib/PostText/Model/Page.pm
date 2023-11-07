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
           AND NOT hidden_status
         UNION ALL
        SELECT 'remark',
               remark_id,
               TO_CHAR(remark_date, $1),
               remark_author,
               remark_body,
               TS_RANK(search_tokens, PLAINTO_TSQUERY('english', $2))
          FROM remarks
         WHERE search_tokens @@ PLAINTO_TSQUERY('english', $2)
           AND NOT hidden_status
         ORDER BY search_rank DESC, post_date DESC
         LIMIT $3 OFFSET $4;
       END_SQL
}

sub count_for($self, $search_query) {
    $self->pg->db->query(<<~'END_SQL', $search_query)->hash->{'post_tally'}
         SELECT COUNT(*) AS post_tally
           FROM (SELECT thread_date AS post_date
                   FROM threads
                  WHERE search_tokens @@ PLAINTO_TSQUERY('english', $1)
                    AND NOT hidden_status
                  UNION ALL
                 SELECT remark_date
                   FROM remarks
                  WHERE search_tokens @@ PLAINTO_TSQUERY('english', $1)
                    AND NOT hidden_status)
             AS posts;
        END_SQL
}

sub last_page_for($self, $search_query) {
    my $post_count = $self->count_for($search_query);
    my $last_page  = int($post_count / $self->per_page);

    # Add a page for 'remainder' posts
    $last_page++ if $post_count % $self->per_page;

    return $last_page;
}

1;
