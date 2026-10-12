import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Ring with a direction wedge; bare ring when calm or unknown
class Wind extends Icon {

    //! Degrees
    private const EIGHTH = 45;
    private const EIGHTHS = 8;

    //! Clockwise from north, named for where the wind comes from
    private var images as Array<ResourceId> = [
        Rez.Drawables.WindN,
        Rez.Drawables.WindNe,
        Rez.Drawables.WindE,
        Rez.Drawables.WindSe,
        Rez.Drawables.WindS,
        Rez.Drawables.WindSw,
        Rez.Drawables.WindW,
        Rez.Drawables.WindNw
    ];

    private var calmImage as ResourceId = Rez.Drawables.WindCalm;

    private var windReading as WindReading;

    function initialize() {
        Icon.initialize(null);
        windReading = new WindReading();
    }

    function isReporting(settings as System.DeviceSettings) as Boolean {
        windReading.refresh();

        return windReading.hasWeather();
    }

    protected function bitmap() as BitmapResource {
        var bearing = windReading.bearing();

        if ((bearing == null) || windReading.isCalm()) {
            return chooseResource(calmImage);
        }

        return choose(images, eighthOf(bearing));
    }

    protected function tint() as Number {
        return windReading.colorFor(Icon.tint());
    }

    //! 0 for north
    function eighthOf(bearing as Number) as Number {
        return ((bearing + (EIGHTH / 2)) / EIGHTH) % EIGHTHS;
    }
}
