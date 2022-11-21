package PostText::Model::Moderator;

use Mojo::Base -base, -signatures;

has [qw{pg authenticator}];

sub check($self, $email, $password) {
    my $moderator =
        $self->pg->db->query(<<~'END_SQL', $email)->hash;
            SELECT moderator_id  AS id,
                   password_hash
              FROM moderators
             WHERE email_addr = ?;
           END_SQL

    return undef unless $moderator->{'id'};

    return $self->authenticator
        ->verify_password($password, $moderator->{'password_hash'});
}

1;
