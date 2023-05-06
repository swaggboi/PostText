-- Input validation may fail for body if user submits only an HTML tag

ALTER TABLE threads
ALTER COLUMN thread_body
  SET NOT NULL;

ALTER TABLE remarks
ALTER COLUMN remark_body
  SET NOT NULL;
