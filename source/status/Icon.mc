import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! One status bar item. No settings: it shows whenever it has something to
//! report.
class Icon {

    private const NONE_CHOSEN = -1;


    //! For icons with just the one bitmap
    private var resourceId as ResourceId?;

    private var loaded as BitmapResource? = null;

    //! For icons that pick from a set
    private var chosenIndex as Number = NONE_CHOSEN;

    //! Asked of the bitmap once: loading is not free
    private var measuredWidth as Number? = null;
    private var measuredHeight as Number? = null;

    private var shown as Boolean = false;

    //! The artwork is white on transparent and tinted as it draws
    private var plainTint as Number = Graphics.COLOR_WHITE;

    //! Off for the status slot's item the editor did not pick
    private var enabled as Boolean = true;

    //! resourceId is null for icons that override bitmap()
    function initialize(resourceId as ResourceId?) {
        self.resourceId = resourceId;
    }

    //! Whether there is anything to report. Overridden per icon.
    function isReporting(settings as System.DeviceSettings) as Boolean {
        return true;
    }

    function setTint(color as Number) as Void {
        plainTint = color;
    }

    function setEnabled(enabled as Boolean) as Void {
        self.enabled = enabled;
    }

    //! Settle whether the icon shows this draw. Compared to true: a setting
    //! like alarmCount is null on a watch without the feature.
    function updateShown(settings as System.DeviceSettings) as Boolean {
        shown = enabled && (isReporting(settings) == true);

        return shown;
    }

    function isShown() as Boolean {
        return shown;
    }

    function width() as Number {
        measure();

        return measuredWidth as Number;
    }

    function height() as Number {
        measure();

        return measuredHeight as Number;
    }

    function draw(dc as Dc, x as Number, y as Number) as Void {
        if (!(dc has :drawBitmap2)) {
            dc.drawBitmap(x, y, bitmap());
            return;
        }

        dc.drawBitmap2(x, y, bitmap(), { :tintColor => tint() });
    }

    //! Overridden by icons that pick from a set
    protected function bitmap() as BitmapResource {
        if (loaded == null) {
            loaded = WatchUi.loadResource(resourceId as ResourceId) as BitmapResource;
        }

        return loaded as BitmapResource;
    }

    //! Overridden by the battery and the wind, which say something with color
    protected function tint() as Number {
        return plainTint;
    }

    //! One of a set, held until the choice moves
    protected function choose(images as Array<ResourceId>, index as Number) as BitmapResource {
        if (index != chosenIndex) {
            chosenIndex = index;
            loaded = WatchUi.loadResource(images[index]) as BitmapResource;
        }

        return loaded as BitmapResource;
    }

    private function measure() as Void {
        if (measuredWidth != null) {
            return;
        }

        var image = bitmap();

        measuredWidth = image.getWidth();
        measuredHeight = image.getHeight();
    }
}
