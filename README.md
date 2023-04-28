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

## Building/running container

### Build

    podman build -t post_text .

### Tag

    podman tag post_text git.n4vn33t.com/swag/post_text

### Push

    podman push git.n4vn33t.com/swag/post_text

### Pull

    podman pull git.n4vn33t.com/swag/post_text

### Run

    podman run -dt --rm --name post_text -p 3002:3000 post_text:latest

### Generate unit file

    podman generate systemd --files --new --name post_text

## TODOs

1. `xml_escape()` the body when rendered rather than saving XML escaped
1. Rules/about page
1. CSS
1. "All new posts flagged" mode (require approval for new posts)

## Crazy future ideas

### (Lord knows there's TODOs I could be working on...)

1. Implement tripcodes (moving this down in priority due to complexity...)
1. Return a text response instead of HTML if a `.txt` extension [is
   requested](https://docs.mojolicious.org/Mojolicious/Plugin/DefaultHelpers#respond_to)
   (JSON?)
1. Post thread via SMS (twil.io??)
1. Option to remark without bumping?
