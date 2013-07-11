window.google = {
    load: function(api, version, other_params) {
        other_params.callback()
    },
    maps: {
        Geocoder: function() {
            return {
                geocode: function(params, callback) {
                    if (Math.floor(Math.random() * 5) < 1) {
                        callback([], "OVER_QUERY_LIMIT");
                    } else {
                        callback(FotomooFixtures.locations[Math.floor(Math.random() * 31)].results, "OK");
                    }
                }
            };
        },
        LatLng: function(l1,l2){}
    }
};