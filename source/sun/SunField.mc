import Toybox.Graphics;
import Toybox.Lang;

//! The sun below the data fields. The minutes left through the hour before
//! sunrise or sunset, behind its sun, orange once dawn has come. The sunset's
//! sun alone, orange, from sunset to dusk; the sunrise's from dawn when dawn
//! comes earlier than that hour; the sunset's in the data color around solar
//! noon.
class SunField {

    private const COUNTDOWN_MINUTES = Clock.MINUTES_PER_HOUR;

    //! Either side of solar noon
    private const NOON_MINUTES = 30;

    private const TWILIGHT_COLOR = Palette.ORANGE;

    private var daylight as Daylight;
    private var sunriseIcon as Icon;
    private var sunsetIcon as Icon;

    private var dataColor as Number = Graphics.COLOR_WHITE;

    //! Resolved in prepare()
    private var centerX as Number = 0;
    private var top as Number = 0;

    //! Set in refresh(); the text empty for the icon alone
    private var shown as Boolean = false;
    private var icon as Icon;
    private var text as String = "";
    private var color as Number = Graphics.COLOR_WHITE;

    function initialize(daylight as Daylight) {
        self.daylight = daylight;
        sunriseIcon = new Icon(Rez.Drawables.Sunrise);
        sunsetIcon = new Icon(Rez.Drawables.Sunset);
        icon = sunriseIcon;
    }

    //! Once per layout, top being below where the data fields end
    function prepare(centerX as Number, top as Number) as Void {
        self.centerX = centerX;
        self.top = top;
    }

    function setColor(color as Number) as Void {
        dataColor = color;
    }

    //! Once per full draw, after the daylight has refreshed
    function refresh() as Void {
        shown = false;

        var minute = Clock.minuteOfDay();
        var sunrise = daylight.sunrise();
        var sunset = daylight.sunset();
        var sunriseLeft = countdownTo(sunrise, minute);
        var sunsetLeft = countdownTo(sunset, minute);
        var isDawn = isBetween(minute, daylight.dawn(), sunrise);

        if (sunriseLeft != null) {
            show(sunriseIcon, sunriseLeft.toString(), isDawn ? TWILIGHT_COLOR : dataColor);
        } else if (sunsetLeft != null) {
            show(sunsetIcon, sunsetLeft.toString(), dataColor);
        } else if (isDawn) {
            show(sunriseIcon, "", TWILIGHT_COLOR);
        } else if (isBetween(minute, sunset, daylight.dusk())) {
            show(sunsetIcon, "", TWILIGHT_COLOR);
        } else if (isNearNoon(minute)) {
            show(sunsetIcon, "", dataColor);
        }
    }

    function draw(dc as Dc) as Void {
        if (shown) {
            IconText.draw(dc, centerX, top, icon, text, color);
        }
    }

    private function show(icon as Icon, text as String, color as Number) as Void {
        self.icon = icon;
        self.text = text;
        self.color = color;
        shown = true;
    }

    //! Minutes left within the hour before, null outside it or when the
    //! event is not known
    private function countdownTo(event as Number?, minute as Number) as Number? {
        if (event == null) {
            return null;
        }

        var left = Clock.minutesFrom(minute, event);

        return ((left > 0) && (left <= COUNTDOWN_MINUTES)) ? left : null;
    }

    //! From one moment up to but not including the other, across midnight
    //! too; false with either not known
    private function isBetween(minute as Number, from as Number?, to as Number?) as Boolean {
        if ((from == null) || (to == null)) {
            return false;
        }

        return Clock.minutesFrom(from, minute) < Clock.minutesFrom(from, to);
    }

    private function isNearNoon(minute as Number) as Boolean {
        var noon = daylight.zenith();

        if (noon == null) {
            return false;
        }

        var sinceNoon = Clock.minutesFrom(noon, minute);

        return (sinceNoon <= NOON_MINUTES) || (sinceNoon >= (Clock.MINUTES_PER_DAY - NOON_MINUTES));
    }
}
