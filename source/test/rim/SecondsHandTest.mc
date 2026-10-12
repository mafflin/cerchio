import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;

(:test)
module SecondsHandTest {

    (:test)
    function boxes(logger as Test.Logger) as Boolean {
        var sizes = Probe.screenSizes();

        for (var i = 0; i < sizes.size(); i++) {
            var size = sizes[i];
            var circle = placedCircle(size);
            var hand = new SecondsHand();
            var dotRadius = Dial.rim / 21;
            var reach = circle.inner() - Dial.air - dotRadius;

            hand.place(circle.inner());

            for (var second = 0; second < Dial.SECONDS_PER_TURN; second++) {
                var name = size + "px, second " + second;
                var center = hand.centerOf(second);
                var box = hand.boxOf(second);
                var x = center[0];
                var y = center[1];

                Approx.check((box[0] >= 0) && (box[1] >= 0) && (box[2] <= size) && (box[3] <= size), name + " on screen");
                Approx.check(box[0] <= Numbers.max(x - dotRadius, 0), name + " covers the left");
                Approx.check(box[1] <= Numbers.max(y - dotRadius, 0), name + " covers the top");
                Approx.check(box[2] >= Numbers.min(x + dotRadius + 1, size), name + " covers the right");
                Approx.check(box[3] >= Numbers.min(y + dotRadius + 1, size), name + " covers the bottom");

                var fromCenter = Math.sqrt(Math.pow(x - Dial.centerX, 2) + Math.pow(y - Dial.centerY, 2));

                Approx.check(Approx.isNear(fromCenter, reach.toFloat(), 1.0), name + " on its radius");
            }
        }

        return true;
    }

    (:test)
    function quarters(logger as Test.Logger) as Boolean {
        var circle = placedCircle(Probe.SMALL_SCREEN);
        var hand = new SecondsHand();

        hand.place(circle.inner());

        Approx.checkEqual(hand.centerOf(0)[0], Dial.centerX, "0 straight up");
        Approx.check(hand.centerOf(0)[1] < Dial.centerY, "0 above the middle");
        Approx.checkEqual(hand.centerOf(15)[1], Dial.centerY, "15 level");
        Approx.check(hand.centerOf(15)[0] > Dial.centerX, "15 on the right");
        Approx.check(hand.centerOf(30)[1] > Dial.centerY, "30 below the middle");
        Approx.check(hand.centerOf(45)[0] < Dial.centerX, "45 on the left");

        return true;
    }

    (:test)
    function drawsPartially(logger as Test.Logger) as Boolean {
        var circle = placedCircle(Probe.SMALL_SCREEN);
        var screen = Probe.screen(Probe.SMALL_SCREEN);
        var face = Probe.screen(Probe.SMALL_SCREEN);
        var hand = new SecondsHand();

        hand.place(circle.inner());
        hand.draw(screen.getDc());
        hand.forget();
        hand.drawPartial(screen.getDc(), face);
        hand.drawPartial(screen.getDc(), face);

        return true;
    }

    (:debug)
    function placedCircle(size as Number) as DayCircle {
        Probe.screen(size);

        var circle = new DayCircle(new Daylight());

        circle.prepare();

        return circle;
    }
}
