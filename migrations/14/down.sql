ALTER TABLE moderators
ALTER COLUMN moderator_name TYPE VARCHAR( 64),
ALTER COLUMN email_addr     TYPE VARCHAR(320);

ALTER TABLE remarks
ALTER COLUMN remark_author TYPE VARCHAR(  64),
ALTER COLUMN remark_body   TYPE VARCHAR(4096);

ALTER TABLE threads
ALTER COLUMN thread_author TYPE VARCHAR(  64),
ALTER COLUMN thread_title  TYPE VARCHAR( 128),
ALTER COLUMN thread_body   TYPE VARCHAR(4096);
