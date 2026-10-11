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

    //! Either side of solar noon, the time it counts as noon: long enough to
    //! catch at a glance, short enough to stay a moment of the day
    const ZENITH_MINUTES = 15;

    //! Unknown, it is asked for again this often: the phone or a fix may
    //! have come in meanwhile
    private const LATITUDE_RETRY_MINUTES = Clock.MINUTES_PER_HOUR;

    //! The minute of the day it was last asked for, null before the first
    private var latitudeAskedMinute as Number? = null;

    //! Answers a Float or null, see setLatitudeSource()
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

    //! Once per full update; reads at most once a minute
    function refresh() as Void {
        if (!minuteGate.opens()) {
            return;
        }

        update(minutesOf(sunriseId), minutesOf(sunsetId), Clock.minuteOfDay(), Twilight.declination());
    }

    //! The sun as read at a minute of the day, sunDeclination being today's;
    //! refresh() hands over to it, and a test calls it directly
    function update(sunrise as Number?, sunset as Number?, minute as Number, sunDeclination as Decimal) as Void {
        var sunMoved = (sunrise != sunriseMinute) || (sunset != sunsetMinute);
        var sunKnown = (sunrise != null) && (sunset != null);

        // The latitude goes with the sun, not the minute: read every minute
        // it would flap between the weather's station and the last fix, and
        // dawn and dusk with it. Nothing to work out without the sun.
        var cameIn = sunKnown && (sunMoved || isLatitudeDue(minute)) && readLatitude(minute);

        if (!sunMoved && !cameIn) {
            return;
        }

        sunriseMinute = sunrise;
        sunsetMinute = sunset;
        refreshTwilight(sunDeclination);
    }

    //! Where the latitude comes from, Latitude.read() unless a test says
    //! otherwise: a method taking nothing and answering degrees or null
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

    //! Within ZENITH_MINUTES of solar noon, either side; false while it is
    //! not known
    function isZenithAt(minute as Number) as Boolean {
        var noon = zenith();

        if (noon == null) {
            return false;
        }

        return Numbers.isBetween(minute, Clock.wrapMinutes(noon - ZENITH_MINUTES), Clock.wrapMinutes(noon + ZENITH_MINUTES + 1));
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
    private function isLatitudeDue(minute as Number) as Boolean {
        var asked = latitudeAskedMinute;

        if (latitudeDegrees != null) {
            return false;
        }

        return (asked == null) || (Clock.wrapMinutes(minute - asked) >= LATITUDE_RETRY_MINUTES);
    }

    //! Whether it came in. The watch has not moved just because the phone
    //! is away: the last known latitude stands.
    private function readLatitude(minute as Number) as Boolean {
        var latitude = latitudeSource.invoke() as Float?;

        latitudeAskedMinute = minute;

        if (latitude == null) {
            return false;
        }

        latitudeDegrees = latitude;

        return true;
    }

    //! Twilight has to reach past sunrise and sunset, or the latitude is off
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

    //! The complication carries seconds past midnight
    private function minutesOf(id as Complications.Id) as Number? {
        var value = ComplicationReader.valueOf(id);

        if (value == null) {
            return null;
        }

        return ValueFormat.wholeNumber(value) / Clock.SECONDS_PER_MINUTE;
    }
}
