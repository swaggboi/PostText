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

    morbo -w public/ -w lib/ -w templates/ -w script/ script/post_text

Now try requesting http://localhost:3000

## Testing

First, create a valid first thread and first remark to the first
thread. The tests rely on the existence of thread #1 and remark #1
being the first remark to that first thread. Then you can run the
tests locally:

    prove -l

## Building/running container

### Build

    podman build -t post_text .

### Tag

    podman tag post_text \
        git.seriousbusiness.international/swaggboi_priv/post_text

### Push

    podman push git.seriousbusiness.international/swaggboi_priv/post_text

### Pull

    podman pull git.seriousbusiness.international/swaggboi_priv/post_text

### Run

    podman run -dt --rm --name post_text -p 3002:3000 post_text

### Generate unit file

    podman generate systemd --files --new --name post_text

## TODOs

- Do I need `SUM` for `by_id()`?

## AGPL-3.0+ANTIFA compliance

- Antifa
- Trans Rights
- Black Lives Matter
