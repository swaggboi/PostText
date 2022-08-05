#!/usr/bin/env perl

# PostText v0.1
# Jul 22

use Mojolicious::Lite -signatures;
use Mojo::Pg;

# Load the local modules too
use lib 'lib';
use PostText::Model::Thread;
#use Data::Dumper; # For your debugging pleasure

# Load Mojo plugins
plugin 'Config';

# Helpers
helper pg => sub {
    state $pg = Mojo::Pg->new(app->config->{app->mode}{'pg_string'})
};

helper thread => sub {
    state $thread = PostText::Model::Thread->new(pg => shift->pg)
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
    my $threads = $c->thread->get_threads();

    $c->stash(threads => $threads);

    $c->render();
};

# Post
any [qw{GET POST}], '/post', sub ($c) {
    my $thread_author = $c->param('name' );
    my $thread_title  = $c->param('title');
    my $thread_body   = $c->param('post' );

    if ($thread_author && $thread_title && $thread_body) {
        $c->thread->create_thread($thread_author, $thread_title, $thread_body);

        return $c->redirect_to('view');
    }

    return $c->render();
};

# Configure things
app->secrets(app->config->{'secrets'}) || die $@;

app->pg->migrations->from_dir('migrations')->migrate(3);

# Send it
app->start();
