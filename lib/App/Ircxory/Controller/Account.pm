# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::Controller::Account;
use strict;
use warnings;
use base 'Catalyst::Controller';

sub login :Global :Args(0) {
    my ($self, $c) = @_;
    my $openid = $c->req->params->{claimed_uri};
    
    if ($c->req->param != 0) {
        if (!$openid && $c->req->params->{submit}) {
            $c->stash(error => 'Please enter your OpenID.');
            $c->detach;
        };
        
        if (eval {$c->authenticate} ) {
            $c->flash->{message} = 
              'Successfully logged in as '. $c->user->{display};
            $c->res->redirect($c->uri_for('/'));
        }
        else {
            $c->log->debug("failed login for ". 
                           $c->req->params->{claimed_uri}. ": $@")
              if $c->debug;
            
            $c->stash(error => 
                      'You could not be authenticated with that OpenID');
        }
        
        $c->detach;
    };
};

sub logout :Global :Args(0) {
    my ($self, $c) = @_;
    $c->logout;
}

1;
