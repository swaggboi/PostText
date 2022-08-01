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
    $c->session(expires => time() + 31536000);

    1;
};

# Root
get '/', sub ($c) { $c->redirect_to('view') };

# View
get '/view', sub ($c) {
    $c->render()
};

# Post
any [qw{GET POST}], '/post', sub ($c) {
    $c->render()
};

# Configure things
app->secrets(app->config->{'secrets'}) || die $@;

app->pg->migrations->from_dir('migrations')->migrate(3);

# Send it
app->start();
