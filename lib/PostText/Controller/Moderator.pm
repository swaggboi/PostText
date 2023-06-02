package PostText::Controller::Moderator;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub flagged($self) {
    my $flagged_posts = $self->moderator->flagged;
    my @post_links    = map {
        $self->url_for(
            'hidden_' . $_->{'type'}, $_->{'type'} . '_id' => $_->{'id'}
          )
    } @{$flagged_posts};

    $self->stash(post_links => \@post_links);

    $self->render;
}

sub hidden($self) {
    my $hidden_posts = $self->moderator->hidden;
    my @post_links    = map {
        $self->url_for(
            'hidden_' . $_->{'type'}, $_->{'type'} . '_id' => $_->{'id'}
          )
    } @{$hidden_posts};

    $self->stash(post_links => \@post_links);

    $self->render;
}

sub login($self) {
    my $v;

    #Already logged in?
    return $self->redirect_to('flagged_list') if $self->is_mod;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('email'   )->size(6,    320);
        $v->required('password')->size(12, undef);

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my ($email, $password);

            $email    = $self->param('email'   );
            $password = $self->param('password');

            if ($self->moderator->check($email, $password)) {
                my ($mod_id, $mod_name, $admin_status);

                $mod_id       = $self->moderator->get_id($email);
                $mod_name     = $self->moderator->get_name($mod_id);
                $admin_status = $self->moderator->admin_status($mod_id);

                $self->session(
                    mod_id   => $mod_id,
                    author   => $mod_name,
                    is_admin => $admin_status
                    );
                $self->flash(info => "Hello, $mod_name 😎");
                $self->moderator->login_timestamp($mod_id);

                return $self->redirect_to('flagged_list');
            }
            else {
                $self->stash(
                    status => 403,
                    error  => 'Invalid login! 🧐'
                    )
            }
        }
    }

    return $self->render;
}

sub logout($self) {
    delete $self->session->%{qw(mod_id is_admin)};

    $self->flash(info => 'Logged out successfully 👋');

    $self->redirect_to('threads_list');
}

sub unflag_thread($self) {
    my $thread_id    = $self->param('thread_id');
    my $redirect_url = $self->url_for('flagged_list')->fragment('info')->to_abs;

    $self->moderator->unflag_thread($thread_id);
    $self->flash(info => "Thread #$thread_id has been unflagged. ◀️");

    $self->redirect_to($redirect_url);
}

sub hide_thread($self) {
    my $thread_id    = $self->param('thread_id');
    my $redirect_url = $self->url_for('flagged_list')->fragment('info')->to_abs;

    $self->moderator->hide_thread($thread_id);
    $self->flash(info => "Thread #$thread_id has been hidden. 🫥");

    $self->redirect_to($redirect_url);
}

sub unhide_thread($self) {
    my $thread_id    = $self->param('thread_id');
    my $redirect_url = $self->url_for('hidden_list')->fragment('info')->to_abs;

    $self->moderator->unhide_thread($thread_id);
    $self->flash(info => "Thread #$thread_id has been unhidden. ⏪");

    $self->redirect_to($redirect_url);
}

sub unflag_remark($self) {
    my $remark_id    = $self->param('remark_id');
    my $thread_id    = $self->remark->thread_id_for($remark_id);
    my $redirect_url = $self->url_for('flagged_list')->fragment('info')->to_abs;

    $self->moderator->unflag_remark($remark_id);
    $self->flash(info => "Remark #$remark_id has been unflagged. ◀️");

    $self->redirect_to($redirect_url);
}

sub hide_remark($self) {
    my $remark_id    = $self->param('remark_id');
    my $redirect_url = $self->url_for('flagged_list')->fragment('info')->to_abs;

    $self->moderator->hide_remark($remark_id);
    $self->flash(info => "Remark #$remark_id has been hidden. 🫥");

    $self->redirect_to($redirect_url);
}

sub unhide_remark($self) {
    my $remark_id    = $self->param('remark_id');
    my $thread_id    = $self->remark->thread_id_for($remark_id);
    my $redirect_url = $self->url_for('hidden_list')->fragment('info')->to_abs;

    $self->moderator->unhide_remark($remark_id);
    $self->flash(info => "Remark #$remark_id has been unhidden. ⏪");

    $self->redirect_to($redirect_url);
}

sub create($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('name'    )->size(1,     64);
        $v->required('email'   )->size(6,    320);
        $v->required('password')->size(12, undef);

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my ($name, $email, $password);

            $name     = $self->param('name'    );
            $email    = $self->param('email'   );
            $password = $self->param('password');

            $self->moderator->create($name, $email, $password);
            $self->stash(info => "Created moderator account for $name 🧑‍🏭");
        }
    }

    return $self->render;
}

sub admin_reset($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('email'   )->size(6,    320);
        $v->required('password')->size(12, undef);

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my ($email, $password);

            $email    = $self->param('email'   );
            $password = $self->param('password');

            $self->moderator->admin_reset($email, $password);
            $self->stash(info => "Reset password for $email 🔐");
        }
    }

    return $self->render;
}

sub mod_reset($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('password')->size(12, undef);

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my ($password, $mod_id);

            $password = $self->param('password');
            $mod_id   = $self->session->{'mod_id'};

            $self->moderator->mod_reset($mod_id, $password);
            $self->flash(info => "Password has been reset 🔐");

            return $self->redirect_to('flagged_list');
        }
    }

    return $self->render;
}

sub lock_acct($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('email')->size(6, 320);

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my $email = $self->param('email');

            $self->moderator->lock_acct($email);
            $self->stash(info => "Account $email has been locked 🔒");
        }
    }

    return $self->render;
}

sub unlock_acct($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('email')->size(6, 320);

        if ($v->has_error) {
            $self->stash(status => 400)
        }
        else {
            my $email = $self->param('email');

            $self->moderator->unlock_acct($email);
            $self->stash(info => "Account $email has been unlocked 🔓");
        }
    }

    return $self->render;
}

sub promote($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('email')->size(6, 320);

        if ($v->has_error) {
            $self->stash(status => 404)
        }
        else {
            my $email = $self->param('email');

            $self->moderator->promote($email);
            $self->stash(info => "Account $email has been promoted to admin 🧑‍🎓");
        }
    }

    return $self->render;
}

sub demote($self) {
    my $v;

    $v = $self->validation if $self->req->method eq 'POST';

    if ($v && $v->has_data) {
        $v->required('email')->size(6, 320);

        if ($v->has_error) {
            $self->stash(status => 404)
        }
        else {
            my $email = $self->param('email');

            $self->moderator->demote($email);
            $self->stash(info => "Account $email has been demoted to mod 🧒");
        }
    }

    return $self->render;
}

sub check($self) {
    return 1 if $self->is_mod;

    # Return undef otherwise body is rendered with redirect
    return $self->redirect_to('mod_login'), undef;
}

sub admin_check($self) {
    return 1 if $self->is_admin;

    return $self->redirect_to('mod_login'), undef;
}

sub thread_by_id($self) {
    my $thread_id = $self->param('thread_id');
    my $thread    = $self->moderator->thread_by_id($thread_id);

    $self->stash(thread => $thread);

    $self->stash(status => 404, error => 'Thread not found 🤷')
        unless keys %{$thread};

    $self->render;
}

sub remark_by_id($self) {
    my $remark_id = $self->param('remark_id');
    my $remark    = $self->moderator->remark_by_id($remark_id);

    $self->stash(remark => $remark);

    $self->stash(error => 'Remark not found 🤷')
        unless keys %{$remark};

    $self->render;
}

1;
