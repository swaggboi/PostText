-- Fuzzy search
-- https://hevodata.com/blog/postgresql-full-text-search-setup/#Fuzzy_Search_vs_Full_Text_Search
CREATE EXTENSION pg_trgm;

-- Create column for seearch tokens
    ALTER TABLE threads
      ADD COLUMN search_tokens tsvector
GENERATED ALWAYS AS
          (to_tsvector('english', thread_author) ||
           to_tsvector('english', thread_title ) ||
           to_tsvector('english', thread_body  )) STORED;

-- Create GIN index for search tokens
CREATE INDEX threads_search_idx
    ON threads
 USING GIN(search_tokens);

-- Same for remarks
    ALTER TABLE remarks
      ADD COLUMN search_tokens tsvector
GENERATED ALWAYS AS
          (to_tsvector('english', remark_author) ||
           to_tsvector('english', remark_body  )) STORED;

CREATE INDEX remarks_search_idx
    ON remarks
 USING GIN(search_tokens);
