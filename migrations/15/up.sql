-- Fuzzy search
-- https://hevodata.com/blog/postgresql-full-text-search-setup/#Fuzzy_Search_vs_Full_Text_Search
CREATE EXTENSION pg_trgm;

-- Create column for seearch tokens
    ALTER TABLE threads
      ADD COLUMN search_tokens TSVECTOR
GENERATED ALWAYS AS
          (TO_TSVECTOR('english', thread_author) ||
           TO_TSVECTOR('english', thread_title ) ||
           TO_TSVECTOR('english', thread_body  )) STORED;

-- Create GIN index for search tokens
CREATE INDEX threads_search_idx
    ON threads
 USING GIN(search_tokens);

-- Same for remarks
    ALTER TABLE remarks
      ADD COLUMN search_tokens TSVECTOR
GENERATED ALWAYS AS
          (TO_TSVECTOR('english', remark_author) ||
           TO_TSVECTOR('english', remark_body  )) STORED;

CREATE INDEX remarks_search_idx
    ON remarks
 USING GIN(search_tokens);
