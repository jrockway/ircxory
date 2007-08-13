# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::Account;
use strict;
use warnings;
use Template::Declare::Tags;
use App::Ircxory::View::TD::Wrapper;

template 'account/login' => sub {
    wrapper {
        h2 { 'Log in' };
        p {
            'Enter your OpenID URL, host name, or i-name to log in.'
        };
        form {
            attr { method => 'post',
                   action => uri_for('/login'),
            };
            label {
                attr { for => 'claimed_uri' };
                'OpenID'
            };
            input {
                attr { id    => 'claimed_uri',
                       name  => 'claimed_uri',
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
