# Post::Text

A textboard written in Perl

## Installing locally

Install dependencies:

    cpanm --installdeps .

## Running locally

Create a config file:

    cp example_post_text.conf post_text.conf

This file right now just contains a Perl hash reference. Someday it
should be YAML or XML or something better suited.

Run it in development mode:

    morbo -w assets/css/ -w lib/ -w migrations/ -w t/ -w templates/ \
        script/post_text

Now try requesting http://localhost:3000

## Testing

Run the tests locally (against development environment):

    prove -l

## TODOs

1. Need to actually protect the admin paths with `under()`
1. Action for resetting passwords
1. Action for locking/unlocking accounts
1. CSS
1. "All new posts flagged" mode (require approval for new posts)

## Crazy future ideas

### (Lord knows there's TODOs I could be working on...)

1. RSS feed!!
1. Support at least some Markdown, specifically the code blocks
1. Implement tripcodes (moving this down in priority due to complexity...)
1. Return a text response instead of HTML if a `.txt` extension [is
   requested](https://docs.mojolicious.org/Mojolicious/Plugin/DefaultHelpers#respond_to)
   (JSON?)
1. Post thread via SMS (twil.io??)
1. Option to remark without bumping?
