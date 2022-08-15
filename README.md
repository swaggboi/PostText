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

1. Display error for invalid input (call `flash()` in template)
1. Pick a date format
1. Reply model
