import Toybox.Lang;
import Toybox.Test;

(:test)
module StatusBarTest {

    //! The screen's width at a height, 2px kept clear each side
    (:test)
    function chord(logger as Test.Logger) as Boolean {
        var sizes = Probe.screenSizes();

        for (var i = 0; i < sizes.size(); i++) {
            var size = sizes[i];
            var bar = new StatusBar();

            Probe.screen(size);

            var middle = Dial.centerY;

            Approx.checkEqual(bar.chordAt(middle), (2 * Dial.rim) - 4, size + "px across the middle");
            Approx.checkEqual(bar.chordAt(middle - Dial.rim), size, size + "px at the top, the whole width");
            Approx.checkEqual(bar.chordAt(middle - 40), bar.chordAt(middle + 40), size + "px the same above and below");
            Approx.check(bar.chordAt(middle - 60) < bar.chordAt(middle - 20), size + "px narrower further out");
        }

        return true;
    }

    //! Half the row's height, giving way down to 2px before the row runs off
    //! the glass
    (:test)
    function gap(logger as Test.Logger) as Boolean {
        var bar = new StatusBar();
        var height = 24;

        Approx.checkEqual(bar.gapFor(1, 0, height), 12, "one icon: half its height");
        Approx.checkEqual(bar.gapFor(3, 100, height), 12, "room to spare");
        Approx.checkEqual(bar.gapFor(3, 10, height), 5, "giving way");
        Approx.checkEqual(bar.gapFor(3, 2, height), 2, "no less than 2px");
        Approx.checkEqual(bar.gapFor(3, -20, height), 2, "no less than 2px, overflowing");

        return true;
    }

    //! Whatever the watch reports, laid out and drawn without failing
    (:test)
    function draws(logger as Test.Logger) as Boolean {
        var sizes = Probe.screenSizes();

        for (var i = 0; i < sizes.size(); i++) {
            var bitmap = Probe.screen(sizes[i]);
            var bar = new StatusBar();

            bar.mirror((Dial.screenHeight * 0.66).toNumber());
            bar.draw(bitmap.getDc());
        }

        return true;
    }
}
