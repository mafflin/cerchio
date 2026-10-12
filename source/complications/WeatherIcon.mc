import Toybox.Lang;
import Toybox.Weather;
import Toybox.WatchUi;

//! At night a sun becomes a moon, or just its cloud
class WeatherIcon extends Icon {

    //! Weather.CONDITION_*
    private var condition as Number? = null;

    function initialize() {
        Icon.initialize(null);
    }

    function setCondition(condition as Number?) as Void {
        self.condition = condition;
    }

    //! Day or night per draw, so it turns at sunset
    protected function bitmap() as BitmapResource {
        var isUp = Sun.daylight().isUpAt(Clock.minuteOfDay());

        return chooseResource(imageFor(condition, isUp == false));
    }

    function imageFor(condition as Number?, night as Boolean) as ResourceId {
        if (condition == null) {
            return Rez.Drawables.WeatherUnknown;
        }

        switch (condition) {
            case Weather.CONDITION_CLEAR:
            case Weather.CONDITION_FAIR:
                return night ? Rez.Drawables.WeatherNight : Rez.Drawables.WeatherSunny;

            case Weather.CONDITION_PARTLY_CLOUDY:
            case Weather.CONDITION_PARTLY_CLEAR:
            case Weather.CONDITION_MOSTLY_CLEAR:
            case Weather.CONDITION_THIN_CLOUDS:
                return night ? Rez.Drawables.WeatherNightPartlyCloudy : Rez.Drawables.WeatherPartlyCloudy;

            case Weather.CONDITION_MOSTLY_CLOUDY:
            case Weather.CONDITION_CLOUDY:
                return Rez.Drawables.WeatherCloudy;

            case Weather.CONDITION_RAIN:
            case Weather.CONDITION_LIGHT_RAIN:
            case Weather.CONDITION_LIGHT_SHOWERS:
            case Weather.CONDITION_SHOWERS:
            case Weather.CONDITION_DRIZZLE:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:
                return Rez.Drawables.WeatherRainy;

            case Weather.CONDITION_HEAVY_RAIN:
            case Weather.CONDITION_HEAVY_SHOWERS:
                return Rez.Drawables.WeatherPouring;

            case Weather.CONDITION_SCATTERED_SHOWERS:
            case Weather.CONDITION_CHANCE_OF_SHOWERS:
                return night ? Rez.Drawables.WeatherRainy : Rez.Drawables.WeatherPartlyRainy;

            case Weather.CONDITION_SNOW:
            case Weather.CONDITION_LIGHT_SNOW:
            case Weather.CONDITION_FLURRIES:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW:
                return Rez.Drawables.WeatherSnowy;

            case Weather.CONDITION_HEAVY_SNOW:
                return Rez.Drawables.WeatherSnowyHeavy;

            case Weather.CONDITION_CHANCE_OF_SNOW:
                return night ? Rez.Drawables.WeatherSnowy : Rez.Drawables.WeatherPartlySnowy;

            case Weather.CONDITION_WINTRY_MIX:
            case Weather.CONDITION_LIGHT_RAIN_SNOW:
            case Weather.CONDITION_HEAVY_RAIN_SNOW:
            case Weather.CONDITION_RAIN_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW:
            case Weather.CONDITION_FREEZING_RAIN:
            case Weather.CONDITION_SLEET:
                return Rez.Drawables.WeatherSnowyRainy;

            case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:
                return night ? Rez.Drawables.WeatherSnowyRainy : Rez.Drawables.WeatherPartlySnowyRainy;

            case Weather.CONDITION_THUNDERSTORMS:
                return Rez.Drawables.WeatherLightningRainy;

            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:
                return night ? Rez.Drawables.WeatherLightning : Rez.Drawables.WeatherPartlyLightning;

            case Weather.CONDITION_HAIL:
            case Weather.CONDITION_ICE_SNOW:
                return Rez.Drawables.WeatherHail;

            case Weather.CONDITION_ICE:
                return Rez.Drawables.WeatherSnowflake;

            case Weather.CONDITION_WINDY:
                return Rez.Drawables.WeatherWindy;

            case Weather.CONDITION_SQUALL:
                return Rez.Drawables.WeatherWindyVariant;

            case Weather.CONDITION_FOG:
            case Weather.CONDITION_MIST:
                return Rez.Drawables.WeatherFog;

            // The hazy icon has a sun
            case Weather.CONDITION_HAZY:
            case Weather.CONDITION_HAZE:
                return night ? Rez.Drawables.WeatherFog : Rez.Drawables.WeatherHazy;

            case Weather.CONDITION_DUST:
            case Weather.CONDITION_SAND:
            case Weather.CONDITION_SANDSTORM:
                return Rez.Drawables.WeatherDust;

            case Weather.CONDITION_SMOKE:
                return Rez.Drawables.WeatherSmoke;

            case Weather.CONDITION_VOLCANIC_ASH:
                return Rez.Drawables.WeatherVolcano;

            case Weather.CONDITION_TORNADO:
                return Rez.Drawables.WeatherTornado;

            case Weather.CONDITION_HURRICANE:
                return Rez.Drawables.WeatherHurricane;

            case Weather.CONDITION_TROPICAL_STORM:
                return Rez.Drawables.WeatherHurricaneOutline;

            case Weather.CONDITION_UNKNOWN_PRECIPITATION:
                return Rez.Drawables.WeatherCloudQuestion;
        }

        return Rez.Drawables.WeatherUnknown;
    }
}
