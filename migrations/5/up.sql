 ALTER TABLE replies
RENAME TO remarks;

 ALTER TABLE remarks
RENAME reply_id
    TO remark_id;

 ALTER TABLE remarks
RENAME reply_date
    TO remark_date;

 ALTER TABLE remarks
RENAME reply_author
   TO remark_author;

 ALTER TABLE remarks
RENAME reply_body
    TO remark_body;

 ALTER TABLE remarks
RENAME CONSTRAINT replies_thread_id_fkey
    TO remarks_thread_id_fkey;

 ALTER INDEX replies_pkey
RENAME TO remarks_pkey;

 ALTER SEQUENCE replies_reply_id_seq
RENAME TO remarks_remark_id_seq;
