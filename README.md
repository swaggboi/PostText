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

1. Retrieve replies in the single thread view
1. Paging for replies in single thread view
1. Default 'threads per page' is broken if config file isn't correct
   (should pick up the default value wtf)
1. Pick a date format
