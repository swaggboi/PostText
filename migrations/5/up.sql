 ALTER TABLE replies
RENAME TO remarks;

 ALTER TABLE remarks
RENAME reply_id TO remark_id;

 ALTER TABLE remarks
RENAME reply_date TO remark_date;

 ALTER TABLE remarks
RENAME reply_author TO remark_author;

 ALTER TABLE remarks
RENAME reply_body TO remark_body;
