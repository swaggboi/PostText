ALTER TABLE threads
ALTER COLUMN thread_body
  SET NOT NULL;

ALTER TABLE remarks
ALTER COLUMN remark_body
  SET NOT NULL;