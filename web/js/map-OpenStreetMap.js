fixmystreet.maps.config = function() {
    fixmystreet.maps.controls.unshift( new OpenLayers.Control.AttributionFMS() );
    if (OpenLayers.Layer.BingAerial) {
        fixmystreet.layer_options = [
          { map_type: fixmystreet.map_type },
          { map_type: OpenLayers.Layer.BingAerial }
        ];
    }
};

// http://www.openstreetmap.org/openlayers/OpenStreetMap.js (added maxResolution)

/**
 * Class: OpenLayers.Layer.OSM.Mapnik
 *
 * Inherits from:
 *  - <OpenLayers.Layer.OSM>
 */
OpenLayers.Layer.OSM.Mapnik = OpenLayers.Class(OpenLayers.Layer.OSM, {


    

    /**
     * Constructor: OpenLayers.Layer.OSM.Mapnik
     *
     * Parameters:
     * name - {String}
     * options - {Object} Hashtable of extra options to tag onto the layer
     */
    initialize: function(name, options) {

        var _myvar = '?pippo';

        var url = [

            'https://api.mapbox.com/styles/v1/andriatz/cm4h15h92015r01s6c6gl78b8/tiles/256/${z}/${x}/${y}@2x?access_token=pk.eyJ1IjoiYW5kcmlhdHoiLCJhIjoiY200Z3czZ2ZmMDB0ajJpcXJlaXRubnYxNiJ9.lMzdXLvFB7pxyh3e23yhgw',
            'https://api.mapbox.com/styles/v1/andriatz/cm4h15h92015r01s6c6gl78b8/tiles/256/${z}/${x}/${y}@2x?access_token=pk.eyJ1IjoiYW5kcmlhdHoiLCJhIjoiY200Z3czZ2ZmMDB0ajJpcXJlaXRubnYxNiJ9.lMzdXLvFB7pxyh3e23yhgw',
/*
            "https://a.tile.openstreetmap.org/${z}/${x}/${y}.png" + _myvar,
            "https://b.tile.openstreetmap.org/${z}/${x}/${y}.png" + _myvar,
            "https://c.tile.openstreetmap.org/${z}/${x}/${y}.png" + _myvar
*/
        ];
        options = OpenLayers.Util.extend({
            /* Below line added to OSM's file in order to allow minimum zoom level */
            maxResolution: 156543.03390625/Math.pow(2, options.zoomOffset || 0),
            numZoomLevels: 20,
            buffer: 0
        }, options);
        var newArguments = [name, url, options];
        OpenLayers.Layer.OSM.prototype.initialize.apply(this, newArguments);
    },

    CLASS_NAME: "OpenLayers.Layer.OSM.Mapnik"
});

/**
 * Class: OpenLayers.Layer.OSM.CycleMap
 *
 * Inherits from:
 *  - <OpenLayers.Layer.OSM>
 */
OpenLayers.Layer.OSM.CycleMap = OpenLayers.Class(OpenLayers.Layer.OSM, {
    /**
     * Constructor: OpenLayers.Layer.OSM.CycleMap
     *
     * Parameters:
     * name - {String}
     * options - {Object} Hashtable of extra options to tag onto the layer
     */
    initialize: function(name, options) {
        var url = [
            "http://a.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png",
            "http://b.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png",
            "http://c.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png"
        ];
        options = OpenLayers.Util.extend({
            /* Below line added to OSM's file in order to allow minimum zoom level */
            maxResolution: 156543.03390625/Math.pow(2, options.zoomOffset || 0),
            numZoomLevels: 20,
            buffer: 0
        }, options);
        var newArguments = [name, url, options];
        OpenLayers.Layer.OSM.prototype.initialize.apply(this, newArguments);
    },

    CLASS_NAME: "OpenLayers.Layer.OSM.CycleMap"
});
