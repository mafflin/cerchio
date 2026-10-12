import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! Status icons above the time; each shows when it has something to report
class StatusBar {

    //! Optical lift
    private const LIFT_DIVISOR = 22;

    //! Half an icon, shrinking to fit the round screen
    private const GAP_DIVISOR = 2;
    private const MIN_GAP = 2;
    private const MARGIN = 2;

    private var icons as Array<Icon>;

    private var mirrorY as Number = 0;

    private var rowLeft as Number = 0;
    private var rowTop as Number = 0;
    private var rowHeight as Number = 0;
    private var gap as Number = 0;

    function initialize() {
        icons = [
            new Battery(),
            new Phone(),
            new Alarm(),
            new Recovery(),
            new Wind(),
            new Meridiem()
        ] as Array<Icon>;
    }

    function setColor(color as Number) as Void {
        for (var i = 0; i < icons.size(); i++) {
            icons[i].setTint(color);
        }
    }

    //! The line below the time to mirror
    function mirror(y as Number) as Void {
        mirrorY = y;
    }

    function draw(dc as Dc) as Void {
        var count = countShown();

        if (count == 0) {
            return;
        }

        layOut(count);
        drawIcons(dc);
    }

    private function layOut(count as Number) as Void {
        rowHeight = tallestShown();
        rowTop = rowCenterY() - (rowHeight / 2);

        var iconsWidth = shownWidth();

        gap = gapFor(count, chordAt(rowTop) - iconsWidth, rowHeight);
        rowLeft = (Dial.screenWidth - (iconsWidth + ((count - 1) * gap))) / 2;
    }

    private function drawIcons(dc as Dc) as Void {
        var middle = rowTop + (rowHeight / 2);
        var x = rowLeft;

        for (var i = 0; i < icons.size(); i++) {
            var icon = icons[i];

            if (!icon.isShown()) {
                continue;
            }

            icon.draw(dc, x, middle - (icon.height() / 2));
            x += icon.width() + gap;
        }
    }

    //! Mirrors the frame line
    private function rowCenterY() as Number {
        var screenHeight = Dial.screenHeight;

        return screenHeight - mirrorY - (rowHeight / 2) - (screenHeight / LIFT_DIVISOR);
    }

    private function shownWidth() as Number {
        var total = 0;

        for (var i = 0; i < icons.size(); i++) {
            if (icons[i].isShown()) {
                total += icons[i].width();
            }
        }

        return total;
    }

    private function tallestShown() as Number {
        var tallest = 0;

        for (var i = 0; i < icons.size(); i++) {
            if (icons[i].isShown() && (icons[i].height() > tallest)) {
                tallest = icons[i].height();
            }
        }

        return tallest;
    }

    //! spare: width left beside the icons
    function gapFor(count as Number, spare as Number, height as Number) as Number {
        var preferred = height / GAP_DIVISOR;

        if (count < 2) {
            return preferred;
        }

        var room = spare / (count - 1);

        return Numbers.max(Numbers.min(room, preferred), MIN_GAP);
    }

    //! Screen width at y = top, less margins
    function chordAt(top as Number) as Number {
        var rim = Dial.rim;
        var fromMiddle = Dial.centerY - top;

        if (fromMiddle >= rim) {
            return Dial.screenWidth;
        }

        var half = Math.sqrt((rim * rim) - (fromMiddle * fromMiddle));
        var chord = (2 * half).toNumber() - (2 * MARGIN);

        return Numbers.min(chord, Dial.screenWidth);
    }

    private function countShown() as Number {
        var settings = Clock.settings();
        var count = 0;

        for (var i = 0; i < icons.size(); i++) {
            if (icons[i].updateShown(settings)) {
                count++;
            }
        }

        return count;
    }
}
