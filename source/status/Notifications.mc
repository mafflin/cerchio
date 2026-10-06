import Toybox.Lang;
import Toybox.System;

//! Shown while there are unread notifications.
class Notifications extends Icon {

    function initialize() {
        Icon.initialize(Rez.Drawables.Notifications);
    }

    function isReporting(settings as System.DeviceSettings) as Boolean {
        var count = settings.notificationCount;

        return (count != null) && (count > 0);
    }
}
