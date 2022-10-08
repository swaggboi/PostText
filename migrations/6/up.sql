  ALTER TABLE threads
    ADD COLUMN bump_count INTEGER
    NOT NULL
DEFAULT 0;

UPDATE threads t
   SET bump_count = r.remark_count
  FROM (SELECT COUNT(*) AS remark_count,
               thread_id
          FROM remarks
         GROUP BY thread_id) AS r
 WHERE t.thread_id = r.thread_id;
