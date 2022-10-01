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

1. Document post_text.conf (whoopsie)
1. Bump button
1. CSS
1. Configure `perlcritic`

## Crazy future ideas

### (Lord knows there's TODOs I could be working on...)

1. CAPTCHA with
   [Lingua::EN::Inflexion](https://metacpan.org/pod/Lingua::EN::Inflexion#cardinal()-and-cardinal($threshold))
1. Return a text response instead of HTML if a `.txt` extension [is
   requested](https://docs.mojolicious.org/Mojolicious/Plugin/DefaultHelpers#respond_to)
1. Post thread via SMS (twil.io??)
1. Implement
   [bcrypt](https://metacpan.org/pod/Mojolicious::Plugin::BcryptSecure)
