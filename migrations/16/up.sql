ALTER TABLE threads
  ADD COLUMN markdown_status BOOLEAN;

-- Since Markdown was default, set existing threads to true
UPDATE threads
   SET markdown_status = TRUE;

-- Now we can make it NOT NULL
ALTER TABLE threads
ALTER COLUMN markdown_status
  SET NOT NULL;

-- Do the same for remarks
ALTER TABLE remarks
  ADD COLUMN markdown_status BOOLEAN;

UPDATE remarks
   SET markdown_status = TRUE;

ALTER TABLE remarks
ALTER COLUMN markdown_status
  SET NOT NULL;
