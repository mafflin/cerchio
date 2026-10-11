import Toybox.Lang;
import Toybox.Test;

//! Eighths clockwise from north, each 45° wide and centered on its point
(:test)
module WindTest {

    (:test)
    function eighths(logger as Test.Logger) as Boolean {
        var wind = new Wind();

        Approx.checkEqual(wind.eighthOf(0), 0, "north");
        Approx.checkEqual(wind.eighthOf(22), 0, "still north");
        Approx.checkEqual(wind.eighthOf(23), 1, "northeast");
        Approx.checkEqual(wind.eighthOf(90), 2, "east");
        Approx.checkEqual(wind.eighthOf(180), 4, "south");
        Approx.checkEqual(wind.eighthOf(270), 6, "west");
        Approx.checkEqual(wind.eighthOf(337), 7, "northwest");
        Approx.checkEqual(wind.eighthOf(338), 0, "north again");
        Approx.checkEqual(wind.eighthOf(359), 0, "just west of north");

        return true;
    }
}
