window.google = {
    maps: {
        Geocoder: function() {
            return {
                geocode: function(params, callback) {
                    if (Math.floor(Math.random() * 4) < 1) {
                        callback([], "OVER_QUERY_LIMIT");
                    } else {
                        callback(FotomooFixtures.locations[Math.floor(Math.random() * 31)].results, "OK");
                    }
                }
            };
        },
        LatLng: function() {}
    }
};