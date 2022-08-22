 ALTER TABLE remarks
RENAME TO replies;

 ALTER TABLE replies
RENAME remark_id
    TO reply_id;

 ALTER TABLE replies
RENAME remark_date
    TO reply_date;

 ALTER TABLE replies
RENAME remark_author
    TO reply_author;

 ALTER TABLE replies
RENAME remark_body
    TO reply_body;

 ALTER TABLE replies
RENAME CONSTRAINT remarks_thread_id_fkey
    TO replies_thread_id_fkey;

 ALTER INDEX remarks_pkey
RENAME TO replies_pkey;

 ALTER SEQUENCE remarks_remark_id_seq
RENAME TO replies_reply_id_seq;
