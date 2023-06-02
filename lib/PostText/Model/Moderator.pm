package PostText::Model::Moderator;

use Mojo::Base -base, -signatures;

has [qw{pg authenticator}];

has date_format => 'Dy, FMDD Mon YYYY HH24:MI:SS TZHTZM';

sub create($self, $name, $email, $password) {
    my $password_hash = $self->authenticator->hash_password($password);

    $self->pg->db->query(<<~'END_SQL', $name, $email, $password_hash);
        INSERT INTO moderators (
               moderator_name,
               email_addr,
               password_hash
               )
        VALUES (?, ?, ?);
       END_SQL
}

sub check($self, $email, $password) {
    my ($moderator, $mod_id);

    $moderator =
        $self->pg->db->query(<<~'END_SQL', $email)->hash;
            SELECT moderator_id AS id,
                   password_hash
              FROM moderators
             WHERE email_addr = ?;
           END_SQL

    $mod_id = $moderator->{'id'};

    if ($mod_id && !$self->lock_status($mod_id)) {
        return $self->authenticator
            ->verify_password($password, $moderator->{'password_hash'});
    }

    return undef;
}

sub lock_out($self, $mod_id) {
    $self->pg->db->query(<<~'END_SQL', $mod_id)
        UPDATE moderators
           SET lock_status = TRUE
         WHERE moderator_id = ?;
       END_SQL
}

sub unlock($self, $mod_id) {
    $self->pg->db->query(<<~'END_SQL', $mod_id)
        UPDATE moderators
           SET lock_status = FALSE
         WHERE moderator_id = ?;
       END_SQL
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

sub admin_status($self, $mod_id) {
    $self->pg->db->query(<<~'END_SQL', $mod_id)->hash->{'admin_status'}
        SELECT admin_status
          FROM moderators
         WHERE moderator_id = ?;
       END_SQL
}

sub lock_status($self, $mod_id) {
    $self->pg->db->query(<<~'END_SQL', $mod_id)->hash->{'lock_status'}
        SELECT lock_status
          FROM moderators
         WHERE moderator_id = ?;
       END_SQL
}

sub login_timestamp($self, $mod_id) {
    $self->pg->db->query(<<~'END_SQL', $mod_id);
        UPDATE moderators
           SET last_login_date = NOW()
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

sub admin_reset($self, $email, $password) {
    my $password_hash = $self->authenticator->hash_password($password);

    $self->pg->db->query(<<~'END_SQL', $password_hash, $email);
        UPDATE moderators
           SET password_hash = ?
         WHERE email_addr = ?;
       END_SQL
}

sub mod_reset($self, $mod_id, $password) {
    my $password_hash = $self->authenticator->hash_password($password);

    $self->pg->db->query(<<~'END_SQL', $password_hash, $mod_id);
        UPDATE moderators
           SET password_hash = ?
         WHERE moderator_id = ?;
       END_SQL
}

sub lock_acct($self, $email) {
    $self->pg->db->query(<<~'END_SQL', $email)
        UPDATE moderators
           SET lock_status = TRUE
         WHERE email_addr = ?;
       END_SQL
}

sub unlock_acct($self, $email) {
    $self->pg->db->query(<<~'END_SQL', $email)
        UPDATE moderators
           SET lock_status = FALSE
         WHERE email_addr = ?;
       END_SQL
}

sub promote($self, $email) {
    $self->pg->db->query(<<~'END_SQL', $email)
        UPDATE moderators
           SET admin_status = TRUE
         WHERE email_addr = ?;
       END_SQL
}

sub demote($self, $email) {
    $self->pg->db->query(<<~'END_SQL', $email)
        UPDATE moderators
           SET admin_status = FALSE
         WHERE email_addr = ?;
       END_SQL
}

sub thread_by_id($self, $thread_id) {
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
         GROUP BY t.thread_id;
       END_SQL
}

sub remark_by_id($self, $remark_id) {
    my $date_format = $self->date_format;

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

1;
