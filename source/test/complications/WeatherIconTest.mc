import Toybox.Lang;
import Toybox.Test;
import Toybox.Weather;

(:test)
module WeatherIconTest {

    (:test)
    function unknown(logger as Test.Logger) as Boolean {
        checkImage(null, Rez.Drawables.WeatherUnknown, Rez.Drawables.WeatherUnknown, "not known");
        checkImage(Weather.CONDITION_UNKNOWN, Rez.Drawables.WeatherUnknown, Rez.Drawables.WeatherUnknown, "unknown");
        checkImage(9999, Rez.Drawables.WeatherUnknown, Rez.Drawables.WeatherUnknown, "a condition from a later system");
        checkImage(Weather.CONDITION_UNKNOWN_PRECIPITATION, Rez.Drawables.WeatherCloudQuestion, Rez.Drawables.WeatherCloudQuestion, "unknown precipitation");

        return true;
    }

    (:test)
    function turnsAtNight(logger as Test.Logger) as Boolean {
        checkImage(Weather.CONDITION_CLEAR, Rez.Drawables.WeatherSunny, Rez.Drawables.WeatherNight, "clear");
        checkImage(Weather.CONDITION_FAIR, Rez.Drawables.WeatherSunny, Rez.Drawables.WeatherNight, "fair");
        checkImage(Weather.CONDITION_PARTLY_CLOUDY, Rez.Drawables.WeatherPartlyCloudy, Rez.Drawables.WeatherNightPartlyCloudy, "partly cloudy");
        checkImage(Weather.CONDITION_MOSTLY_CLEAR, Rez.Drawables.WeatherPartlyCloudy, Rez.Drawables.WeatherNightPartlyCloudy, "mostly clear");
        checkImage(Weather.CONDITION_SCATTERED_SHOWERS, Rez.Drawables.WeatherPartlyRainy, Rez.Drawables.WeatherRainy, "scattered showers");
        checkImage(Weather.CONDITION_CHANCE_OF_SNOW, Rez.Drawables.WeatherPartlySnowy, Rez.Drawables.WeatherSnowy, "chance of snow");
        checkImage(Weather.CONDITION_CHANCE_OF_RAIN_SNOW, Rez.Drawables.WeatherPartlySnowyRainy, Rez.Drawables.WeatherSnowyRainy, "chance of rain and snow");
        checkImage(Weather.CONDITION_SCATTERED_THUNDERSTORMS, Rez.Drawables.WeatherPartlyLightning, Rez.Drawables.WeatherLightning, "scattered thunderstorms");
        checkImage(Weather.CONDITION_HAZE, Rez.Drawables.WeatherHazy, Rez.Drawables.WeatherFog, "haze");

        return true;
    }

    (:test)
    function sameAtNight(logger as Test.Logger) as Boolean {
        checkImage(Weather.CONDITION_CLOUDY, Rez.Drawables.WeatherCloudy, Rez.Drawables.WeatherCloudy, "cloudy");
        checkImage(Weather.CONDITION_RAIN, Rez.Drawables.WeatherRainy, Rez.Drawables.WeatherRainy, "rain");
        checkImage(Weather.CONDITION_HEAVY_RAIN, Rez.Drawables.WeatherPouring, Rez.Drawables.WeatherPouring, "heavy rain");
        checkImage(Weather.CONDITION_SNOW, Rez.Drawables.WeatherSnowy, Rez.Drawables.WeatherSnowy, "snow");
        checkImage(Weather.CONDITION_HEAVY_SNOW, Rez.Drawables.WeatherSnowyHeavy, Rez.Drawables.WeatherSnowyHeavy, "heavy snow");
        checkImage(Weather.CONDITION_SLEET, Rez.Drawables.WeatherSnowyRainy, Rez.Drawables.WeatherSnowyRainy, "sleet");
        checkImage(Weather.CONDITION_THUNDERSTORMS, Rez.Drawables.WeatherLightningRainy, Rez.Drawables.WeatherLightningRainy, "thunderstorms");
        checkImage(Weather.CONDITION_HAIL, Rez.Drawables.WeatherHail, Rez.Drawables.WeatherHail, "hail");
        checkImage(Weather.CONDITION_ICE, Rez.Drawables.WeatherSnowflake, Rez.Drawables.WeatherSnowflake, "ice");
        checkImage(Weather.CONDITION_WINDY, Rez.Drawables.WeatherWindy, Rez.Drawables.WeatherWindy, "windy");
        checkImage(Weather.CONDITION_SQUALL, Rez.Drawables.WeatherWindyVariant, Rez.Drawables.WeatherWindyVariant, "squall");
        checkImage(Weather.CONDITION_FOG, Rez.Drawables.WeatherFog, Rez.Drawables.WeatherFog, "fog");
        checkImage(Weather.CONDITION_DUST, Rez.Drawables.WeatherDust, Rez.Drawables.WeatherDust, "dust");
        checkImage(Weather.CONDITION_SMOKE, Rez.Drawables.WeatherSmoke, Rez.Drawables.WeatherSmoke, "smoke");
        checkImage(Weather.CONDITION_VOLCANIC_ASH, Rez.Drawables.WeatherVolcano, Rez.Drawables.WeatherVolcano, "volcanic ash");
        checkImage(Weather.CONDITION_TORNADO, Rez.Drawables.WeatherTornado, Rez.Drawables.WeatherTornado, "tornado");
        checkImage(Weather.CONDITION_HURRICANE, Rez.Drawables.WeatherHurricane, Rez.Drawables.WeatherHurricane, "hurricane");
        checkImage(Weather.CONDITION_TROPICAL_STORM, Rez.Drawables.WeatherHurricaneOutline, Rez.Drawables.WeatherHurricaneOutline, "tropical storm");

        return true;
    }

    (:debug)
    function checkImage(condition as Number?, day as ResourceId, night as ResourceId, name as String) as Void {
        var icon = new WeatherIcon();

        Approx.checkEqual(icon.imageFor(condition, false), day, name + " by day");
        Approx.checkEqual(icon.imageFor(condition, true), night, name + " by night");
    }
}
