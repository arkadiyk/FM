window.google = {
    maps: {
        Geocoder: function() {
            return {
                geocode: function(params, callback) {
                    return callback(FotomooFixtures.locations[Math.floor(Math.random() * 31)].results, "OK");
                }
            };
        },
        LatLng: function() {}
    }
};