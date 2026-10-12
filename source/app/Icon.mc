import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! A tinted bitmap: a status bar item or a data field icon.
class Icon {

    private var resourceId as ResourceId?;

    private var loaded as BitmapResource? = null;

    private var chosenId as ResourceId? = null;

    private var measuredWidth as Number? = null;
    private var measuredHeight as Number? = null;

    private var shown as Boolean = false;

    private var plainTint as Number = Graphics.COLOR_WHITE;

    //! Null for icons that override bitmap()
    function initialize(resourceId as ResourceId?) {
        self.resourceId = resourceId;
    }

    function isReporting(settings as System.DeviceSettings) as Boolean {
        return true;
    }

    function setTint(color as Number) as Void {
        plainTint = color;
    }

    //! Compared to true: settings may be null without the feature
    function updateShown(settings as System.DeviceSettings) as Boolean {
        shown = (isReporting(settings) == true);

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
        dc.drawBitmap2(x, y, bitmap(), { :tintColor => tint() });
    }

    protected function bitmap() as BitmapResource {
        if (loaded == null) {
            loaded = WatchUi.loadResource(resourceId as ResourceId) as BitmapResource;
        }

        return loaded as BitmapResource;
    }

    protected function tint() as Number {
        return plainTint;
    }

    protected function choose(images as Array<ResourceId>, index as Number) as BitmapResource {
        return chooseResource(images[index]);
    }

    //! Set members must share a size: measured once
    protected function chooseResource(resourceId as ResourceId) as BitmapResource {
        if (resourceId != chosenId) {
            chosenId = resourceId;
            loaded = WatchUi.loadResource(resourceId) as BitmapResource;
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
