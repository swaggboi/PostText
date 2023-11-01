DROP EXTENSION pg_trgm;

ALTER TABLE threads
 DROP COLUMN search_tokens;

ALTER TABLE remarks
 DROP COLUMN search_tokens;
