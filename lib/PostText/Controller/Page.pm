package PostText::Controller::Page;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::Util qw{b64_decode gunzip};
use Roman::Unicode qw{to_roman to_perl};

sub about($self) { $self->render }

sub rules($self) { $self->render }

sub feeds($self) { $self->render }

sub javascript($self) { $self->render }

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
                    status => 400,
                    error  => 'Sounds like something a robot would say...'
                    )
            }
        }
    }

    my $random_int    = 1 + int rand 9;
    my $roman_numeral = to_roman $random_int;

    $self->stash(roman_numeral => $roman_numeral);

    $self->render;
}

sub search($self) {
    my $v              = $self->validation;
    my $search_results = [];
    my ($search_query, $this_page, $last_page, $base_path);

    if ($v->has_data) {
        $v->required('q'   )->size(1, 2_047);
        $v->optional('page');

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            $search_query   = $v->param('q');
            $this_page      = $v->param('page') || 1;
            $last_page      = $self->page->last_page_for($search_query);
            $base_path      = $self->url_for->query(q => $search_query);
            $search_results = $self->page->search($search_query, $this_page);

            $self->stash(status => 404, error => 'No posts found. 🔎')
                unless scalar @{$search_results};
        }
    }

    $self->stash(
        this_page      => $this_page,
        last_page      => $last_page,
        base_path      => $base_path,
        search_results => $search_results
        );

    $self->render;
}

1;
