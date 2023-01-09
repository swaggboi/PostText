package PostText::Model::Moderator;

use Mojo::Base -base, -signatures;

has [qw{pg authenticator}];

sub create($self, $name, $email, $password) {
    my $password_hash = $self->authenticator->hash_password($password);

    $self->pg->db->query(<<~'END_SQL', $name, $email, $password_hash);
        INSERT INTO moderators
               (moderator_name,
                email_addr,
                password_hash)
        VALUES (?, ?, ?);
       END_SQL
}

sub check($self, $email, $password) {
    my $moderator =
        $self->pg->db->query(<<~'END_SQL', $email)->hash;
            SELECT moderator_id AS id,
                   password_hash
              FROM moderators
             WHERE email_addr = ?;
           END_SQL

    return undef unless $moderator->{'id'};

    return $self->authenticator
        ->verify_password($password, $moderator->{'password_hash'});
}

sub get_id($self, $email) {
    $self->pg->db->query(<<~'END_SQL', $email)->hash->{'moderator_id'}
        SELECT moderator_id
          FROM moderators
         WHERE email_addr = ?;
       END_SQL
}

sub get_name($self, $mod_id) {
    $self->pg->db->query(<<~'END_SQL', $mod_id)->hash->{'moderator_name'}
        SELECT moderator_name
          FROM moderators
         WHERE moderator_id = ?;
       END_SQL
}

sub unflag_thread($self, $thread_id) {
    $self->pg->db->query(<<~'END_SQL', $thread_id)
        UPDATE threads
           SET flagged_status = FALSE
         WHERE thread_id = ?;
       END_SQL
}

sub hide_thread($self, $thread_id) {
    $self->pg->db->query(<<~'END_SQL', $thread_id)
        UPDATE threads
           SET hidden_status = TRUE,
               flagged_status = FALSE
         WHERE thread_id = ?;
       END_SQL
}

sub unhide_thread($self, $thread_id) {
    $self->pg->db->query(<<~'END_SQL', $thread_id)
        UPDATE threads
           SET hidden_status = FALSE
         WHERE thread_id = ?;
       END_SQL
}

sub unflag_remark($self, $remark_id) {
    $self->pg->db->query(<<~'END_SQL', $remark_id)
        UPDATE remarks
           SET flagged_status = FALSE
         WHERE remark_id = ?;
       END_SQL
}

sub hide_remark($self, $remark_id) {
    $self->pg->db->query(<<~'END_SQL', $remark_id)
        UPDATE remarks
           SET hidden_status = TRUE,
               flagged_status = FALSE
         WHERE remark_id = ?;
       END_SQL
}

sub unhide_remark($self, $remark_id) {
    $self->pg->db->query(<<~'END_SQL', $remark_id)
        UPDATE remarks
           SET hidden_status = FALSE
         WHERE remark_id = ?;
       END_SQL
}

sub flagged($self) {
    $self->pg->db->query(<<~'END_SQL')->hashes
        SELECT 'thread'  AS type,
               thread_id AS id
          FROM threads
         WHERE flagged_status
         UNION
        SELECT 'remark',
               remark_id
          FROM remarks
         WHERE flagged_status;
       END_SQL
}

sub hidden($self) {
    $self->pg->db->query(<<~'END_SQL')->hashes
        SELECT 'thread'  AS type,
               thread_id AS id
          FROM threads
         WHERE hidden_status
         UNION
        SELECT 'remark',
               remark_id
          FROM remarks
         WHERE hidden_status;
       END_SQL
}

1;
