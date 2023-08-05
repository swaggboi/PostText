package PostText::Controller::Page;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::Util qw{b64_decode gunzip};
use Roman::Unicode qw{to_roman to_perl};

sub about($self) { $self->render }

sub rules($self) { $self->render }

sub captcha($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('answer')->num(1,  9);
        $v->required('number')->size(1, 4);

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my $answer        = $v->param('answer');
            my $roman_numeral = $v->param('number');
            my $return_url    =
                gunzip b64_decode $self->param('return_url');

            if ($answer == to_perl $roman_numeral) {
                $self->session(is_human => 1);

                return $self->redirect_to($return_url);
            }
            else {
                $self->stash(
                    error => 'Sounds like something a robot would say...'
                    )
            }
        }
    }

    my $random_int    = 1 + int rand 9;
    my $roman_numeral = to_roman $random_int;

    $self->stash(roman_numeral => $roman_numeral);

    $self->render;
}

1;
