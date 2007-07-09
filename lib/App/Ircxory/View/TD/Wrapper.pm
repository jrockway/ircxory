# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::TD::Wrapper;
use strict;
use warnings;
use Template::Declare::Tags;

use base 'Exporter';
our @EXPORT = qw/wrapper uri_for/;

sub uri_for($;@) {
    my $path = shift;
    c->uri_for($path, @_);
}

sub wrapper(&) {
    my $content = shift;
    smart_tag_wrapper {
        outs_raw(q{<?xml version="1.0" encoding="utf-8"?>});
        outs_raw(q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
                      "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">});
        html {
            head {
                title { c->stash->{title} || c->config->{name} || 'Ircxory' };
                link {
                    attr { rel  => 'stylesheet',
                           type => 'text/css',
                           href => uri_for '/static/main.css',
                       }
                }; 
            };
            body {
                h1 { 
                    a { attr { href => uri_for '/' };
                        'Ircxory';
                    }
                };
                $content->();
                div {
                    attr { id => 'logos' };
                    a { 
                        attr { href => 'http://www.catalystframework.org/' };
                        img { 
                            attr 
                              { alt => 'Built with Catalyst',
                                src => 
                                  uri_for '/static/btn_120x50_built.png',
                              }
                          }
                    }
                }
            }
        }
    }
}

1;
