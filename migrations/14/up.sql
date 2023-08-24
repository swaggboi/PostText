ALTER TABLE moderators
ALTER COLUMN moderator_name TYPE TEXT,
ALTER COLUMN email_addr     TYPE TEXT;

ALTER TABLE remarks
ALTER COLUMN remark_author TYPE TEXT,
ALTER COLUMN remark_body   TYPE TEXT;

ALTER TABLE threads
ALTER COLUMN thread_author TYPE TEXT,
ALTER COLUMN thread_title  TYPE TEXT,
ALTER COLUMN thread_body   TYPE TEXT;
