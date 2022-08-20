CREATE TABLE IF NOT EXISTS replies (
          reply_id SERIAL PRIMARY KEY,
         thread_id INT,
        reply_date TIMESTAMPTZ NOT NULL DEFAULT now(),
      reply_author VARCHAR(64),
        reply_body VARCHAR(4096),
     hidden_status BOOLEAN NOT NULL,
    flagged_status BOOLEAN NOT NULL,
           FOREIGN KEY (thread_id)
        REFERENCES threads(thread_id)
);
