CREATE TABLE IF NOT EXISTS moderators (
       moderator_id SERIAL       PRIMARY KEY,
     moderator_name VARCHAR(64)  NOT NULL,
         email_addr VARCHAR(320) NOT NULL,
      password_hash VARCHAR(64)  NOT NULL,
      creation_date TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    last_login_date TIMESTAMPTZ  NOT NULL DEFAULT '2000-01-01',
        lock_status BOOLEAN      NOT NULL DEFAULT FALSE
);
