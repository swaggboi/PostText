  ALTER TABLE threads
    ADD COLUMN bump_date TIMESTAMPTZ
    NOT NULL
DEFAULT NOW();
