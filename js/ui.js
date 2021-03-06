var cfg;

(function() {
    'use strict';

    var Cfg = function() {
        // TODO: Define config fields and defaults here
        this.debugView = -1;
        this.debugScissor = false;
        this.bloom = false;
        this.sobel = false;
        this.toon = false;
    };

    var init = function() {
        cfg = new Cfg();

        var gui = new dat.GUI();
        // TODO: Define any other possible config values
        gui.add(cfg, 'debugView', {
            'None':             -1,
            '0 Depth':           0,
            '1 Position':        1,
            // '2 Geometry normal': 2,
            // '3 Color map':       3,
            // '4 Normal map':      4,
            '2 Surface normal':  2,
            '3 Color Map':  3
        });
        gui.add(cfg, 'debugScissor');

        var eff0 = gui.addFolder('Post processing');
        eff0.open();
        eff0.add(cfg, 'bloom');
        eff0.add(cfg, 'toon');
        eff0.add(cfg, 'sobel');

        // TODO: add more effects toggles and parameters here
    };

    window.handle_load.push(init);
})();
