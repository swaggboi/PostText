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

1. Method names may need to be shortened, should use POD instead to
   describe their function
1. Single remark view

## Crazy future ideas

### (Lord knows there's TODOs I could be working on...)

1. Return a text response instead of HTML if a `.txt` extension is requested
1. Post thread via SMS (twil.io??)
