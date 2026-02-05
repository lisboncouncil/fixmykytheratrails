package FixMyStreet::Cobrand::Fmsk;
use base 'FixMyStreet::Cobrand::Default';

use strict;
use warnings;
use FixMyStreet::Map;

=head1 NAME

FixMyStreet::Cobrand::Fmsk - Cobrand for FixMyKytheraTrails (Kythira, Greece)

=head1 DESCRIPTION

This cobrand provides customizations for the FixMyKytheraTrails installation,
including a dynamic map on the front page showing recent problem reports.

=cut

sub country {
    return 'GR';
}

=head2 front_page_data

Provides data for the dynamic map on the front page, including recent problem
pins with color coding based on their status.

=cut

sub front_page_data {
    my ($self, $c) = @_;

    # Kythira coordinates
    my $latitude = 36.21596;
    my $longitude = 22.9769;
    my $zoom = 12;

    # Get recent confirmed/fixed problems (limit 50)
    my @problems = $self->problems->search({
        state => [ FixMyStreet::DB::Result::Problem->visible_states() ],
    }, {
        order_by => { -desc => 'confirmed' },
        rows => 50,
    })->all;

    # Build pins array with color coding
    my @pins;
    foreach my $problem (@problems) {
        my $colour = $problem->is_fixed ? 'green' : 'yellow';
        push @pins, {
            latitude => $problem->latitude,
            longitude => $problem->longitude,
            colour => $colour,
            id => $problem->id,
            title => $problem->title,
        };
    }

    # Set up the map class
    FixMyStreet::Map::set_map_class($c->cobrand);

    # Call display_map to generate map data
    FixMyStreet::Map::display_map(
        $c,
        latitude => $latitude,
        longitude => $longitude,
        pins => \@pins,
        any_zoom => 1,
    );

    # Override zoom in stash
    if ($c->stash->{map}) {
        $c->stash->{map}->{zoom} = $zoom;
        $c->stash->{map}->{zoom_act} = $zoom;
    }

    return 1;
}

1;
