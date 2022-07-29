#!/usr/bin/env perl

# PostText v0.1
# Jul 22

use Mojolicious::Lite -signatures;
use Mojo::Pg;

# Load the local modules too
use lib 'lib';
use PostText::Model::Thread;

# Load Mojo plugins
plugin 'Config';

# Helpers
helper pg => sub {
    state $pg = Mojo::Pg->new(app->config->{app->mode}{'pg_string'})
};

# Begin routing
under sub ($c) {
    $c->session(expires => time() + 1800);

    1;
};

# Root redirect
get '/', sub ($c) { $c->redirect_to('view') };

get '/view', sub ($c) {
    $c->render()
};

app->secrets(app->config->{'secrets'}) || die $@;

app->start();
