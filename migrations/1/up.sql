CREATE TABLE IF NOT EXISTS threads (
         thread_id SERIAL PRIMARY KEY,
       thread_date TIMESTAMPTZ DEFAULT now(),
     thread_author VARCHAR(64),
      thread_title VARCHAR(256),
       thread_body VARCHAR(4096),
     hidden_status BOOLEAN NOT NULL,
    flagged_status BOOLEAN NOT NULL
);
