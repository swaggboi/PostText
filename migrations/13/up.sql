-- Nvm this isn't how NULL works in SQL lol

ALTER TABLE threads
ALTER COLUMN thread_body
 DROP NOT NULL;

ALTER TABLE remarks
ALTER COLUMN remark_body
 DROP NOT NULL;
