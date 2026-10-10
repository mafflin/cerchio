import Toybox.Complications;
import Toybox.Lang;

//! Today's sunrise and sunset off the complications, solar noon halfway
//! between, and dawn and dusk either side of noon. Read once a minute,
//! worked out again only when the sun moves, or once the latitude comes
//! in: asked for with the sun, and hourly until known.
class Daylight {

    //! Minutes past midnight, null when not known
    private var sunriseMinute as Number? = null;
    private var sunsetMinute as Number? = null;
    private var dawnMinute as Number? = null;
    private var duskMinute as Number? = null;

    //! Degrees, north positive, as twilight was last worked out for; null
    //! when not known
    private var latitudeDegrees as Float? = null;

    //! Unknown, it is asked for again this often: the phone or a fix may
    //! have come in meanwhile
    private const LATITUDE_RETRY_MINUTES = Clock.MINUTES_PER_HOUR;

    //! The Clock.minuteOfDay() it was last asked for, null before the first
    private var latitudeAskedMinute as Number? = null;

    private var sunriseId as Complications.Id;
    private var sunsetId as Complications.Id;
    private var minuteGate as MinuteGate;

    function initialize() {
        sunriseId = new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE);
        sunsetId = new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET);
        minuteGate = new MinuteGate();
    }

    //! Once per full update; reads at most once a minute
    function refresh() as Void {
        if (!minuteGate.opens()) {
            return;
        }

        var sunrise = minutesOf(sunriseId);
        var sunset = minutesOf(sunsetId);
        var sunMoved = (sunrise != sunriseMinute) || (sunset != sunsetMinute);
        var sunKnown = (sunrise != null) && (sunset != null);

        // The latitude goes with the sun, not the minute: read every minute
        // it would flap between the weather's station and the last fix, and
        // dawn and dusk with it. Nothing to work out without the sun.
        var wantsLatitude = sunKnown && (sunMoved || isLatitudeDue());

        if (!sunMoved && !wantsLatitude) {
            return;
        }

        if (wantsLatitude && !readLatitude() && !sunMoved) {
            return;
        }

        sunriseMinute = sunrise;
        sunsetMinute = sunset;
        refreshTwilight();
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

    //! Between sunrise and sunset; null while either is not known
    function isUpAt(minute as Number) as Boolean? {
        var rise = sunriseMinute;
        var set = sunsetMinute;

        if ((rise == null) || (set == null)) {
            return null;
        }

        return Numbers.isBetween(minute, rise, set);
    }

    //! From dawn to sunrise, or sunset to dusk; false while they are not
    //! known
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

    //! Solar noon, halfway from sunrise to sunset; null with either unknown
    function zenith() as Number? {
        var rise = sunriseMinute;
        var length = dayLength();

        if ((rise == null) || (length == null)) {
            return null;
        }

        return Clock.wrapMinutes(rise + (length / 2));
    }

    //! Minutes from sunrise to sunset, which may run across midnight
    private function dayLength() as Number? {
        var rise = sunriseMinute;
        var set = sunsetMinute;

        if ((rise == null) || (set == null)) {
            return null;
        }

        return Clock.wrapMinutes(set - rise);
    }

    //! Unknown, and not asked for an hour
    private function isLatitudeDue() as Boolean {
        var asked = latitudeAskedMinute;

        if (latitudeDegrees != null) {
            return false;
        }

        return (asked == null) || (Clock.wrapMinutes(Clock.minuteOfDay() - asked) >= LATITUDE_RETRY_MINUTES);
    }

    //! Whether it came in. The watch has not moved just because the phone
    //! is away: the last known latitude stands.
    private function readLatitude() as Boolean {
        var latitude = Latitude.read();

        latitudeAskedMinute = Clock.minuteOfDay();

        if (latitude == null) {
            return false;
        }

        latitudeDegrees = latitude;

        return true;
    }

    //! Twilight has to reach past sunrise and sunset, or the latitude is off
    private function refreshTwilight() as Void {
        dawnMinute = null;
        duskMinute = null;

        var noon = zenith();
        var length = dayLength();

        if ((noon == null) || (length == null)) {
            return;
        }

        var fromNoon = Twilight.minutesFromNoon(length, latitudeDegrees);

        if ((fromNoon == null) || ((fromNoon * 2) <= length)) {
            return;
        }

        dawnMinute = Clock.wrapMinutes(noon - fromNoon);
        duskMinute = Clock.wrapMinutes(noon + fromNoon);
    }

    //! The complication carries seconds past midnight
    private function minutesOf(id as Complications.Id) as Number? {
        var value = ComplicationReader.valueOf(id);

        if (value == null) {
            return null;
        }

        return ValueFormat.wholeNumber(value) / Clock.SECONDS_PER_MINUTE;
    }
}
