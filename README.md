# Post::Text

A textboard written in Perl

## Installing locally

Install dependencies

    cpanm --installdeps .

## Running locally

Run it in development mode

    morbo PostText.pl

Now try requesting http://localhost:3000

## Testing

Run the tests locally (against development environment)

    prove -l

## TODOs

1. Paging for remarks in single thread view
1. Form to create new remarks
1. I'm kinda hardcoding the single-thread view `link_to` in the
   templates because I cannot for the life of me figure out how to use
   `url_for` to populate the `thread_id` placeholder. Probably need to
   clean-up the HTML too, just used `<span>` cuz I didn't know what
   else to use
