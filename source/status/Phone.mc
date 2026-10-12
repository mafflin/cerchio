import Toybox.Lang;
import Toybox.System;

class Phone extends Icon {

    function initialize() {
        Icon.initialize(Rez.Drawables.Phone);
    }

    function isReporting(settings as System.DeviceSettings) as Boolean {
        return settings.phoneConnected;
    }
}
