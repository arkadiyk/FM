module("Ember.js Library", {
    setup: function() {
        Ember.run(FM, FM.advanceReadiness);
    },
    teardown: function() {
        FM.reset();
    }
});

test("Check HTML is returned", function() {

    visit("/").then(function() {
        ok(exists("*"), "Found HTML!");
    });

});