# FixMyStreet::Map::Mapbox
# Esempio di integrazione di Mapbox in FixMyStreet (OpenLayers).

package FixMyStreet::Map::Mapbox;

use Moo;
extends 'FixMyStreet::Map::Base';

use Math::Trig;
use Utils;

# Mappa base: per OSM era "OpenLayers.Layer.OSM.Mapnik"
# Qui si può usare ad es. "OpenLayers.Layer.XYZ" o similari.
has map_type => ( is => 'ro', default => 'OpenLayers.Layer.XYZ' );

# Nome del template che verrà usato (equivalente a "osm" in OSM.pm)
# Dovrai quindi avere un template es. "mapbox.html.tt" in templates/web/maps/
has map_template => ( is => 'ro', default => 'mapbox' );

# Se la logica JavaScript è uguale a OSM (basta caricare gli stessi file .js),
# puoi riutilizzare quelli, altrimenti personalizza se necessario.
sub map_javascript { [
    '/vendor/OpenLayers/OpenLayers.wfs.js',
    '/js/map-OpenLayers.js',
    # Se hai un JS dedicato a Mapbox + OpenLayers, lo aggiungi qui
    # '/js/map-mapbox-ol.js', 
] }

# Costruzione degli URL dei tile per Mapbox
sub map_tiles {
    my ( $self, %params ) = @_;
    my ( $x, $y, $z ) = ( $params{x_tile}, $params{y_tile}, $params{zoom_act} );

    # Recupera token e style id dalla config di FixMyStreet (o scrivili fissi)
    my $token    = FixMyStreet->config('MAPBOX_API_KEY') || 'INSERISCI_QUI_IL_TUO_TOKEN';
    my $style_id = FixMyStreet->config('MAPBOX_STYLE_2')     || 'username/style-id';

    # Esempio di URL tiles Mapbox:
    # https://api.mapbox.com/styles/v1/<user_or_org>/<style_id>/tiles/256/{z}/{x}/{y}?access_token=...
    my $base_url = "https://api.mapbox.com/styles/v1/$style_id/tiles/256";

    return [
        "$base_url/$z/$x/$y?access_token=$token"
    ];
}

# Attribuzione obbligatoria (Mapbox + OSM).
has copyright => (
    is => 'lazy',
    default => sub {
        return qq|&copy; <a href="https://www.mapbox.com/about/maps/">Mapbox</a>, |
             . qq|<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors|;
    },
);

# Per calcolare zoom di default, bounding box, ecc. (se serve):
# puoi usare lo stesso metodo di OSM.pm o personalizzarlo.
sub generate_map_data {
    my ($self, %params) = @_;

    # Logica simile a OSM.pm:
    my $zoom_params = $self->calculate_zoom(%params);
    $params{zoom_act} = $zoom_params->{zoom_act};

    # Calcolo x_tile, y_tile per posizionare la mappa
    ($params{x_tile}, $params{y_tile}) = $self->latlon_to_tile_with_adjust(
        $params{latitude},
        $params{longitude},
        $zoom_params->{zoom_act},
    );

    # Calcolo posizioni pixel dei "pin" (marker) sulla mappa
    foreach my $pin (@{ $params{pins} }) {
        ($pin->{px}, $pin->{py}) = $self->latlon_to_px(
            $pin->{latitude},
            $pin->{longitude},
            $params{x_tile},
            $params{y_tile},
            $zoom_params->{zoom_act}
        );
    }

    return {
        %params,
        %$zoom_params,
        type => $self->map_template(),
        map_type => $self->map_type(),
        tiles => $self->map_tiles(%params),
        copyright => $self->copyright(),
        compass => $self->compass(
            $params{x_tile},
            $params{y_tile},
            $zoom_params->{zoom_act}
        ),
    };
}

# Di seguito, la stessa logica di conversione tile<->lat/lon usata in OSM.pm.
# Puoi copiare in blocco le funzioni latlon_to_tile, tile_to_latlon, etc.
# se non vengono già ereditate da un'altra classe.

sub compass {
    my ( $self, $x, $y, $z ) = @_;
    return {
        north => [ map { Utils::truncate_coordinate($_) } $self->tile_to_latlon( $x, $y-1, $z ) ],
        south => [ map { Utils::truncate_coordinate($_) } $self->tile_to_latlon( $x, $y+1, $z ) ],
        west  => [ map { Utils::truncate_coordinate($_) } $self->tile_to_latlon( $x-1, $y, $z ) ],
        east  => [ map { Utils::truncate_coordinate($_) } $self->tile_to_latlon( $x+1, $y, $z ) ],
        here  => [ map { Utils::truncate_coordinate($_) } $self->tile_to_latlon( $x, $y, $z ) ],
    };
}

sub latlon_to_tile {
    my ($self, $lat, $lon, $zoom) = @_;
    my $x_tile = ($lon + 180) / 360 * 2**$zoom;
    my $y_tile = (1 - log(tan(deg2rad($lat)) + sec(deg2rad($lat))) / pi) / 2 * 2**$zoom;
    return ( $x_tile, $y_tile );
}

sub latlon_to_tile_with_adjust {
    my ($self, $lat, $lon, $zoom) = @_;
    my ($x_tile, $y_tile) = $self->latlon_to_tile($lat, $lon, $zoom);

    # Aggiusta la tile in modo da centrare il pin
    if ($x_tile - int($x_tile) > 0.5) {
        $x_tile += 1;
    }
    if ($y_tile - int($y_tile) > 0.5) {
        $y_tile += 1;
    }

    return ( int($x_tile), int($y_tile) );
}

sub tile_to_latlon {
    my ($self, $x, $y, $zoom) = @_;
    my $n   = 2 ** $zoom;
    my $lon = $x / $n * 360 - 180;
    my $lat = rad2deg(atan(sinh(pi * (1 - 2 * $y / $n))));
    return ( $lat, $lon );
}

sub latlon_to_px {
    my ($self, $lat, $lon, $x_tile, $y_tile, $zoom) = @_;
    my ($pin_x_tile, $pin_y_tile) = $self->latlon_to_tile($lat, $lon, $zoom);
    my $pin_x = tile_to_px($pin_x_tile, $x_tile);
    my $pin_y = tile_to_px($pin_y_tile, $y_tile);
    return ($pin_x, $pin_y);
}

sub tile_to_px {
    my ($p, $c) = @_;
    $p = 256 * ($p - $c + 1);
    $p = int($p + .5 * ($p <=> 0));
    return $p;
}

sub click_to_tile {
    my ($pin_tile, $pin) = @_;
    $pin -= 256 while $pin > 256;
    $pin += 256 while $pin < 0;
    return $pin_tile + $pin / 256;
}

sub click_to_wgs84 {
    my ($cls, $c, $pin_tile_x, $pin_x, $pin_tile_y, $pin_y) = @_;
    my $self = $cls->new;
    my $tile_x = click_to_tile($pin_tile_x, $pin_x);
    my $tile_y = click_to_tile($pin_tile_y, $pin_y);
    my $zoom = $self->min_zoom_level 
             + (defined $c->get_param('zoom') ? $c->get_param('zoom') : 3);
    my ($lat, $lon) = $self->tile_to_latlon($tile_x, $tile_y, $zoom);
    return ( $lat, $lon );
}

1;
