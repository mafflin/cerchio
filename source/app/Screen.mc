import Toybox.Graphics;
import Toybox.Lang;

//! The size of the glass and its middle, for everything laid out on it.
module Screen {

    var width as Number = 0;
    var height as Number = 0;
    var centerX as Number = 0;
    var centerY as Number = 0;

    //! Before anything sizes itself off the glass
    function setup(dc as Dc) as Void {
        width = dc.getWidth();
        height = dc.getHeight();
        centerX = width / 2;
        centerY = height / 2;
    }
}
