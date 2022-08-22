# Post::Text

A textboard written in Perl

## Installing locally

Install dependencies

    $ cpanm --installdeps .

## Running locally

Run it in development mode

    $ morbo PostText.pl

Now try requesting http://localhost:3000

## Testing

Run the tests locally (against development environment)

    $ prove -l

## TODOs

1. Reply model needs to become Remark (to fix the error handling stuff)
1. Add hyperlink somewhere to single thread view (whoopsie)
1. Paging for replies in single thread view
1. Pick a date format
