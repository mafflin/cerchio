import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! 12 hour watches only
class Meridiem extends Icon {

    private const MORNING_IMAGE = 0;
    private const AFTERNOON_IMAGE = 1;

    private var images as Array<ResourceId> = [
        Rez.Drawables.Am,
        Rez.Drawables.Pm
    ];

    private var isMorning as Boolean = true;

    function initialize() {
        Icon.initialize(null);
    }

    function isReporting(settings as System.DeviceSettings) as Boolean {
        if (settings.is24Hour) {
            return false;
        }

        isMorning = Clock.isMorning(Clock.now().hour);

        return true;
    }

    protected function bitmap() as BitmapResource {
        return choose(images, isMorning ? MORNING_IMAGE : AFTERNOON_IMAGE);
    }
}
