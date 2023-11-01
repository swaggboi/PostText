package PostText::Controller::Remark;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Date::Format;
use XML::RSS;

sub by_id($self) {
    my $remark_id = $self->param('remark_id');
    my $remark    = $self->remark->by_id($remark_id);

    $self->stash(remark => $remark);

    $self->stash(status => 404, error => 'Remark not found. 🤷')
        unless keys %{$remark};

    # Set filename for right-click & save-as behavior
    if ($self->accepts(0, 'txt')) {
        $self->res->headers->content_disposition(
            "inline; filename=remark_${remark_id}.txt"
            )
    }

    $self->render;
}

sub create($self) {
    my $thread_id  = $self->param('thread_id');
    my $remark_id  = $self->param('remark_id');
    my $body_limit = $self->config->{'body_max_length'} || 4_000;
    my ($v, $draft);

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('author' )->size(1,          63);
        $v->required('body'   )->size(2, $body_limit);
        $v->optional('bump'   );
        $v->optional('preview');

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my $remark_author = $v->param('author' );
            my $remark_body   = $v->param('body'   );
            my $bump_thread   = $v->param('bump'   );
            my $preview       = $v->param('preview');

            $self->session(author => $remark_author);

            unless ($preview) {
                $self->remark->create(
                    $thread_id,
                    $remark_author,
                    $remark_body
                    );

                $self->thread->bump($thread_id) if $bump_thread;

                return $self->redirect_to($self->url_for(single_thread => {
                    thread_id   => $thread_id,
                    thread_page => $self->remark->last_page_for($thread_id)
                })->fragment('remarks'));
            }

            $draft = $remark_body;
        }
    }

    my $thread      = $self->thread->by_id($thread_id);
    my $last_remark = $remark_id
        ? $self->remark->by_id($remark_id)
        : $self->remark->last_for($thread_id);

    $self->stash(
        thread      => $thread,
        last_remark => $last_remark,
        draft       => $draft,
        body_limit  => $body_limit
        );

    $self->stash(status => 404, error => 'Thread not found. 🤷')
        unless keys %{$thread};

    return $self->render;
}

sub flag($self) {
    my $remark_id    = $self->param('remark_id');
    my $thread_id    = $self->remark->thread_id_for($remark_id);
    my $redirect_url =
        $self->url_for('single_thread', thread_id => $thread_id)
            ->fragment('info')->to_abs;


    $self->remark->flag($remark_id);
    $self->flash(
        info => "Remark #$remark_id has been flagged for moderator. 🚩"
        );

    $self->redirect_to($redirect_url);
}

sub feed($self) {
    my $remarks   = $self->remark->feed;
    my $rss       = XML::RSS->new(version => '2.0');
    my $chan_link = $self->url_for(threads_list => {list_page => 1} )->to_abs;
    my $rss_link  = $self->url_for(remarks_feed => {format => 'rss'})->to_abs;
    my $rss_title = 'Post::Text Remarks';
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

    for my $remark (@{$remarks}) {
        my $description = $self->markdown($remark->{'body'});
        my $item_link   = $self->url_for(
            single_remark => {remark_id => $remark->{'id'}}
            )->to_abs;

        $rss->add_item(
            # Maybe do like Re: $thread_title but that's too much
            # effort tonight am lazy
            #title       => $remark->{'title'},
            link        => $item_link,
            permaLink   => $item_link,
            description => $description,
            pubDate     => $remark->{'date'}
            );
    }

    $self->render(text => $rss->as_string);
}

1;
