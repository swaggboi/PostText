package PostText::Controller::Thread;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Date::Format;
use XML::RSS;

sub create($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('author')->size(1,   63);
        $v->required('title' )->size(1,  127);
        $v->required('body'  )->size(2, 4000);

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my $thread_author = $v->param('author');
            my $thread_title  = $v->param('title' );
            my $thread_body   = $v->param('body'  );

            my $new_thread_id = $self->thread->create(
                $thread_author,
                $thread_title,
                $thread_body
                );

            $self->session(author => $thread_author);

            return $self->redirect_to(
                single_thread => {thread_id => $new_thread_id}
                );
        }
    }

    return $self->render;
}

sub by_id($self) {
    my $thread_id = $self->param('thread_id');
    my $thread    = $self->thread->by_id($thread_id);
    my $base_path = $self->match->path_for(thread_page => undef)->{'path'};
    my $this_page = $self->param('thread_page');
    my $last_page = $self->remark->last_page_for($thread_id);
    my $remarks   = $self->remark->by_page_for($thread_id, $this_page);

    $self->stash(
        thread    => $thread,
        base_path => $base_path,
        this_page => $this_page,
        last_page => $last_page,
        remarks   => $remarks
        );

    $self->stash(status => 404, error => 'Thread not found 🤷')
        unless keys %{$thread};

    # Check for remarks or thread page number to make sure
    # remark->by_page_for did its job
    $self->stash(status => 404, error => 'Page not found 🕵️')
        unless 1 >= $this_page || scalar @{$remarks};

    $self->render;
}

sub by_page($self) {
    my $base_path = $self->match->path_for(list_page => undef)->{'path'};
    my $this_page = $self->param('list_page');
    my $last_page = $self->thread->last_page;
    my $threads   = $self->thread->by_page($this_page);

    $self->stash(
        threads   => $threads,
        this_page => $this_page,
        last_page => $last_page,
        base_path => $base_path
        );

    $self->stash(status => 404, error => 'Page not found 🕵️')
        unless scalar @{$threads};

    $self->render;
}

sub feed($self) {
    my $threads   = $self->thread->feed;
    my $rss       = XML::RSS->new(version => '2.0');
    my $chan_link = $self->url_for(threads_list => {list_page => 1} )->to_abs;
    my $rss_link  = $self->url_for(threads_feed => {format => 'rss'})->to_abs;
    my $rss_title = 'Post::Text';
    my $rss_image = $self->url_for('/images/icon_small.png')->to_abs;

    $rss->add_module(
        prefix => 'atom',
        uri    => 'http://www.w3.org/2005/Atom'
        );

    $rss->channel(
        title         => $rss_title,
        description   => 'In UTF-8 we trust. 🫡',
        link          => $chan_link,
        lastBuildDate => time2str('%a, %d %b %Y %X %z', time),
        atom          => {
            link => {
                href => "$rss_link", # This has to be quoted idk why
                rel  => 'self',
                type => 'application/rss+xml'
            }
        });

    $rss->image(
        title       => $rss_title,
        url         => $rss_image,
        link        => $chan_link,
        width       => 144,
        height      => 144,
        description => 'A small nerdy anime girl'
        );

    for my $thread (@{$threads}) {
        my $description = $self->markdown($thread->{'body'});
        my $item_link   = $self->url_for(
            single_thread => {thread_id => $thread->{'id'}}
            )->to_abs;

        $rss->add_item(
            title       => $thread->{'title'},
            link        => $item_link,
            permaLink   => $item_link,
            description => $description,
            pubDate     => $thread->{'date'}
            );
    }

    $self->render(text => $rss->as_string);
}

sub bump($self) {
    my $thread_id = $self->param('thread_id');

    $self->thread->bump($thread_id);
    $self->flash(info => "Thread #$thread_id has been bumped. 🔝");

    $self->redirect_to(
        $self->url_for('threads_list')->fragment('info')->to_abs
        );
}

sub flag($self) {
    my $thread_id    = $self->param('thread_id');
    my $redirect_url = $self->url_for('threads_list')->fragment('info')->to_abs;

    $self->thread->flag($thread_id);
    $self->flash(
        info => "Thread #$thread_id has been flagged for moderator. 🚩"
        );

    $self->redirect_to($redirect_url);
}

1;
