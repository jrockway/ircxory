# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::Account;
use strict;
use warnings;
use Template::Declare::Tags;
use App::Ircxory::View::TD::Wrapper;

sub form(&) {
    my $content = shift;
    smart_tag_wrapper {
        my $attrs = {@_};
        my @pairs;
        foreach (keys %{$attrs||{}}){
            # XXX: XSS
            push @pairs, qq{$_="}. $attrs->{$_}. q{"};
        }
        outs_raw('<form '. (join ' ', @pairs). '>');
        $content->();
        outs_raw('</form>');
    };
}

template 'account/login' => sub {
    wrapper {
        h2 { 'Log in' };
        p { '... with your OpenID' };
        with (name   => 'login',
              method => 'POST',
              action => uri_for '/login',
             ),
        form {
              input {
                  attr { name  => 'openid',
                         type  => 'text',
                         class => 'openid',
                         };
              };
            input { 
                attr { type  => 'submit',
                         name  => 'submit', 
                           value => 'Log in',
                       };
            }
        }
    }
};

template 'account/logout' => sub {
    wrapper {
        h2 { 'Logout complete' };
        p { 'You have been logged out of ircxory.' };
    };
};

1;
