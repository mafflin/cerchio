import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! A tinted bitmap: a status bar item, which shows whenever it has something
//! to report, or a data field's icon.
class Icon {

    //! For icons with just the one bitmap
    private var resourceId as ResourceId?;

    private var loaded as BitmapResource? = null;

    //! For icons that pick from a set
    private var chosenId as ResourceId? = null;

    private var shown as Boolean = false;

    //! The artwork is white on transparent and tinted as it draws
    private var plainTint as Number = Graphics.COLOR_WHITE;

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

    //! Settle whether the icon shows this draw. Compared to true: a setting
    //! like alarmCount is null on a watch without the feature.
    function updateShown(settings as System.DeviceSettings) as Boolean {
        shown = (isReporting(settings) == true);

        return shown;
    }

    function isShown() as Boolean {
        return shown;
    }

    //! Of the bitmap it would draw now, which a set's members need not share
    function width() as Number {
        return bitmap().getWidth();
    }

    function height() as Number {
        return bitmap().getHeight();
    }

    function draw(dc as Dc, x as Number, y as Number) as Void {
        dc.drawBitmap2(x, y, bitmap(), { :tintColor => tint() });
    }

    //! Overridden by icons that pick from a set
    protected function bitmap() as BitmapResource {
        if (loaded == null) {
            loaded = WatchUi.loadResource(resourceId as ResourceId) as BitmapResource;
        }

        return loaded as BitmapResource;
    }

    //! Overridden by the battery, which says something with color
    protected function tint() as Number {
        return plainTint;
    }

    //! One of a set, held until the choice moves
    protected function choose(images as Array<ResourceId>, index as Number) as BitmapResource {
        return chooseResource(images[index]);
    }

    //! As choose(), for a set picked by the resource itself
    protected function chooseResource(resourceId as ResourceId) as BitmapResource {
        if (resourceId != chosenId) {
            chosenId = resourceId;
            loaded = WatchUi.loadResource(resourceId) as BitmapResource;
        }

        return loaded as BitmapResource;
    }
}
