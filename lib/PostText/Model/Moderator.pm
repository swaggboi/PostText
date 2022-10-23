package PostText::Model::Moderator;

use Mojo::Base -base, -signatures;
use Authen::Passphrase::BlowfishCrypt;
use Data::Dumper;

has 'pg';

sub check_password($self, $email, $password) {
    my $moderator =
        $self->pg->db->query(<<~'END_SQL', $email)->hash;
            SELECT moderator_id  AS id,
                   password_hash
              FROM moderators
             WHERE email_addr = ?;
           END_SQL

    return undef unless $moderator->{'id'};

    return Authen::Passphrase::BlowfishCrypt
        ->from_crypt($moderator->{'password_hash'})
        ->match($password);
}

1;
