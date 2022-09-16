# Post::Text

A textboard written in Perl

## Installing locally

Install dependencies

    cpanm --installdeps .

## Running locally

Run it in development mode

    morbo -w assets/css/ -w lib/ -w migrations/ -w t/ -w templates/ PostText.pl

Now try requesting http://localhost:3000

## Testing

Run the tests locally (against development environment)

    prove -l

## TODOs

1. I think I should revist the Post and Remark routes...
1. Grow into full blown Mojo?
1. More granular tests
1. Document post_text.conf (whoopsie)
1. Configure `perlcritic`

## Crazy future ideas

### (Lord knows there's TODOs I could be working on...)

1. Return a text response instead of HTML if a `.txt` extension is requested
1. Post thread via SMS (twil.io??)
