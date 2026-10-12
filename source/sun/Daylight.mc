import Toybox.Complications;
import Toybox.Lang;

//! Today's sunrise, sunset, solar noon, dawn and dusk
class Daylight {

    //! Minutes past midnight
    private var sunriseMinute as Number? = null;
    private var sunsetMinute as Number? = null;
    private var dawnMinute as Number? = null;
    private var duskMinute as Number? = null;

    //! Degrees, north positive
    private var latitudeDegrees as Float? = null;

    //! Either side of solar noon
    const ZENITH_MINUTES = 15;

    //! Retry while unknown
    private const LATITUDE_RETRY_MINUTES = Clock.MINUTES_PER_HOUR;

    private var latitudeAskedMinute as Number? = null;

    private var latitudeSource as Method;

    private var sunriseId as Complications.Id;
    private var sunsetId as Complications.Id;
    private var minuteGate as MinuteGate;

    function initialize() {
        sunriseId = new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE);
        sunsetId = new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET);
        minuteGate = new MinuteGate();
        latitudeSource = new Lang.Method(Latitude, :read);
    }

    //! At most once a minute
    function refresh() as Void {
        if (!minuteGate.opens()) {
            return;
        }

        update(minutesOf(sunriseId), minutesOf(sunsetId), Clock.minuteOfDay(), Twilight.declination());
    }

    //! sunDeclination in radians
    function update(sunrise as Number?, sunset as Number?, minute as Number, sunDeclination as Decimal) as Void {
        var sunMoved = (sunrise != sunriseMinute) || (sunset != sunsetMinute);
        var sunKnown = (sunrise != null) && (sunset != null);

        // Not every minute: it would flap between weather station and last fix.
        var cameIn = sunKnown && (sunMoved || isLatitudeDue(minute)) && readLatitude(minute);

        if (!sunMoved && !cameIn) {
            return;
        }

        sunriseMinute = sunrise;
        sunsetMinute = sunset;
        refreshTwilight(sunDeclination);
    }

    //! For tests; answers Float? degrees
    function setLatitudeSource(source as Method) as Void {
        latitudeSource = source;
    }

    function sunrise() as Number? {
        return sunriseMinute;
    }

    function sunset() as Number? {
        return sunsetMinute;
    }

    function dawn() as Number? {
        return dawnMinute;
    }

    function dusk() as Number? {
        return duskMinute;
    }

    function isUpAt(minute as Number) as Boolean? {
        var rise = sunriseMinute;
        var set = sunsetMinute;

        if ((rise == null) || (set == null)) {
            return null;
        }

        return Numbers.isBetween(minute, rise, set);
    }

    function isTwilightAt(minute as Number) as Boolean {
        var rise = sunriseMinute;
        var set = sunsetMinute;
        var dawn = dawnMinute;
        var dusk = duskMinute;

        if ((rise == null) || (set == null) || (dawn == null) || (dusk == null)) {
            return false;
        }

        return Numbers.isBetween(minute, dawn, rise) || Numbers.isBetween(minute, set, dusk);
    }

    function isZenithAt(minute as Number) as Boolean {
        var noon = zenith();

        if (noon == null) {
            return false;
        }

        return Numbers.isBetween(minute, Clock.wrapMinutes(noon - ZENITH_MINUTES), Clock.wrapMinutes(noon + ZENITH_MINUTES + 1));
    }

    //! Solar noon
    function zenith() as Number? {
        var rise = sunriseMinute;
        var length = dayLength();

        if ((rise == null) || (length == null)) {
            return null;
        }

        return Clock.wrapMinutes(rise + (length / 2));
    }

    //! May run across midnight
    private function dayLength() as Number? {
        var rise = sunriseMinute;
        var set = sunsetMinute;

        if ((rise == null) || (set == null)) {
            return null;
        }

        return Clock.wrapMinutes(set - rise);
    }

    private function isLatitudeDue(minute as Number) as Boolean {
        var asked = latitudeAskedMinute;

        if (latitudeDegrees != null) {
            return false;
        }

        return (asked == null) || (Clock.wrapMinutes(minute - asked) >= LATITUDE_RETRY_MINUTES);
    }

    //! A missing reading keeps the last latitude
    private function readLatitude(minute as Number) as Boolean {
        var latitude = latitudeSource.invoke() as Float?;

        latitudeAskedMinute = minute;

        if (latitude == null) {
            return false;
        }

        latitudeDegrees = latitude;

        return true;
    }

    //! Twilight inside the day means a bad latitude
    private function refreshTwilight(sunDeclination as Decimal) as Void {
        dawnMinute = null;
        duskMinute = null;

        var noon = zenith();
        var length = dayLength();

        if ((noon == null) || (length == null)) {
            return;
        }

        var fromNoon = Twilight.minutesFromNoon(length, latitudeDegrees, sunDeclination);

        if ((fromNoon == null) || ((fromNoon * 2) <= length)) {
            return;
        }

        dawnMinute = Clock.wrapMinutes(noon - fromNoon);
        duskMinute = Clock.wrapMinutes(noon + fromNoon);
    }

    //! The complication gives seconds
    private function minutesOf(id as Complications.Id) as Number? {
        var value = ComplicationReader.valueOf(id);

        if (value == null) {
            return null;
        }

        return ValueFormat.wholeNumber(value) / Clock.SECONDS_PER_MINUTE;
    }
}
