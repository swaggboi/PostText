#!/usr/bin/env perl

# PostText v0.1
# Jul 22

use Mojolicious::Lite -signatures;

# Root redirect
get '/', sub ($c) { $c->redirect_to('view') };

get '/view', sub ($c) {
    $c->render()
};

app->start();
