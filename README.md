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

1. Return the last remark with remark form
1. Method names may need to be shortened, should use POD instead to
   describe their function
