#!/usr/bin/env perl

# PostText v0.1
# Jul 22

use Mojolicious::Lite -signatures;

get '/', sub ($c) {
    $c->render(text => 'ayy... lmao')
};

app->start();
