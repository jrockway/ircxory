# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

package App::Ircxory::View::Atom;
use strict;
use warnings;

use XML::Feed;

sub process {
    my ($self, $c) = @_;
    my $feed = XML::Feed->new('Atom');
    $feed->description('Recent activity on irc');
    $feed->title('Ircxory activity feed');
    $feed->link($c->uri_for('/feeds/activity.xml'));
    
    foreach my $item (@{$c->stash->{feed_entries}||[]}) {
        my $thing  = $item->thing->thing;
        my $reason = $item->reason;
        my $nick   = $item->nickname;
        my $points = $item->points;
        
        my $action = ($points == 0) ? '+-' :
                     ($points == 1) ? '++' : '--';

        my $entry = XML::Feed::Entry->new;        
        $entry->title("$thing$action");
        $entry->author($nick->nick. '@'. $nick->host);
        $entry->content($reason);
        $entry->id($c->req->base. ':'. $item->oid);
        $entry->link($c->uri_for('/things', $thing));
        $feed->add_entry($entry);
    }
    
    $c->response->body($feed->as_xml);
    $c->response->content_type('application/xml+atom');
}

1;
