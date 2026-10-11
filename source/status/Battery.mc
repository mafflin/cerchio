import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! The charge as one of eleven bitmaps, orange when empty and amber when low.
class Battery extends Icon {

    private const PERCENT_PER_LEVEL = 10;
    private const EMPTY_LEVEL = 0;
    private const LOW_LEVEL = 1;
    private const TOP_LEVEL = 10;

    //! Both read against the black background
    private const EMPTY_COLOR = Palette.ORANGE;
    private const LOW_COLOR = Palette.AMBER;

    //! One per level
    private var images as Array<ResourceId> = [
        Rez.Drawables.Battery0,
        Rez.Drawables.Battery10,
        Rez.Drawables.Battery20,
        Rez.Drawables.Battery30,
        Rez.Drawables.Battery40,
        Rez.Drawables.Battery50,
        Rez.Drawables.Battery60,
        Rez.Drawables.Battery70,
        Rez.Drawables.Battery80,
        Rez.Drawables.Battery90,
        Rez.Drawables.Battery100
    ];

    //! Read once a minute
    private var level as Number = EMPTY_LEVEL;
    private var minuteGate as MinuteGate;

    function initialize() {
        Icon.initialize(null);
        minuteGate = new MinuteGate();
    }

    //! Always shown. Read here, once a minute: the row asks every icon
    //! before it draws.
    function isReporting(settings as System.DeviceSettings) as Boolean {
        if (minuteGate.opens()) {
            level = readLevel();
        }

        return true;
    }

    protected function bitmap() as BitmapResource {
        return choose(images, level);
    }

    protected function tint() as Number {
        return tintFor(level, Icon.tint());
    }

    //! Orange when empty, amber when low, the given color otherwise
    function tintFor(shownLevel as Number, plainColor as Number) as Number {
        if (shownLevel == EMPTY_LEVEL) {
            return EMPTY_COLOR;
        }

        if (shownLevel == LOW_LEVEL) {
            return LOW_COLOR;
        }

        return plainColor;
    }

    //! A tenth of the charge, rounded down: 0 below 10%, 10 at full
    function levelOf(percent as Float) as Number {
        var charge = percent.toNumber() / PERCENT_PER_LEVEL;

        return Numbers.min(Numbers.max(charge, EMPTY_LEVEL), TOP_LEVEL);
    }

    private function readLevel() as Number {
        return levelOf(System.getSystemStats().battery);
    }
}
