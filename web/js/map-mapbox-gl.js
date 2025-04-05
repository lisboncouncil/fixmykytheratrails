
fixmystreet.maps.setup_mapbox = function(options) {
    mapboxgl.accessToken = options.apiKey;
    
    var map = new mapboxgl.Map({
        container: 'map',
        style: options.style,
        center: options.center || [-0.1275, 51.5072],
        zoom: options.zoom || 13
    });

    // Aggiungi i controlli necessari
    map.addControl(new mapboxgl.NavigationControl());
    map.addControl(new mapboxgl.GeolocateControl({
        positionOptions: {
            enableHighAccuracy: true
        },
        trackUserLocation: true
    }));

    return map;
};