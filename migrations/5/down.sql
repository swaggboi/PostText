 ALTER TABLE remarks
RENAME TO replies;

 ALTER TABLE replies
RENAME remark_id TO reply_id;

 ALTER TABLE replies
RENAME remark_date TO reply_date;

 ALTER TABLE replies
RENAME remark_author TO reply_author;

 ALTER TABLE replies
RENAME remark_body TO reply_body;
