package PostText::Model::Moderator;

use Mojo::Base -base, -signatures;

has [qw{pg authenticator}];

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

sub unflag($self, $thread_id) {
    $self->pg->db->query(<<~'END_SQL', $thread_id)
        UPDATE threads
           SET flagged_status = FALSE
         WHERE thread_id = ?;
       END_SQL
}

sub hide($self, $thread_id) {
    $self->pg->db->query(<<~'END_SQL', $thread_id)
        UPDATE threads
           SET hidden_status = TRUE,
               flagged_status = FALSE
         WHERE thread_id = ?;
       END_SQL
}

sub unhide($self, $thread_id) {
    $self->pg->db->query(<<~'END_SQL', $thread_id)
        UPDATE threads
           SET hidden_status = FALSE
         WHERE thread_id = ?;
       END_SQL
}

1;
