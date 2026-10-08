import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! A data container below the time: whichever complication the user picked
//! in the editor, its icon and its value as its FieldKind shows them. A Drawable so the editor can pulse
//! it in place.
class ComplicationField extends WatchUi.Drawable {

    //! Fixed, so the tap target does not shift as values change; three
    //! across the screen
    private const WIDTH_RATIO = 0.25;

    //! Matches the slot id in watchface.xml
    private var slotId as Number;

    private var complicationId as Complications.Id;
    private var text as String = "";

    //! How the type is shown, made again only when the type moves; null
    //! while nothing is known
    private var kind as FieldKind? = null;
    private var kindType as Complications.Type? = null;
    private var color as Number = Graphics.COLOR_WHITE;

    //! defaultType shows until the user picks one
    function initialize(slotId as Number, defaultType as Complications.Type) {
        Drawable.initialize({ :identifier => slotId });

        self.slotId = slotId;
        complicationId = new Complications.Id(defaultType);
    }

    //! Once per layout
    function prepare(dc as Dc, centerX as Number, centerY as Number) as Void {
        width = widthIn(dc);
        height = heightIn(dc);
        locX = (centerX - (width / 2)).toNumber();
        locY = (centerY - (height / 2)).toNumber();
    }

    function widthIn(dc as Dc) as Number {
        return (dc.getWidth() * WIDTH_RATIO).toNumber();
    }

    function heightIn(dc as Dc) as Number {
        return IconText.heightIn(dc);
    }

    function getSlotId() as Number {
        return slotId;
    }

    function getComplicationId() as Complications.Id {
        return complicationId;
    }

    function setComplicationId(complicationId as Complications.Id) as Void {
        self.complicationId = complicationId;
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    function shows(other as Complications.Id) as Boolean {
        return complicationId.equals(other);
    }

    //! Read the complication's current value
    function refresh() as Void {
        var complication = ComplicationReader.read(complicationId);

        if (complication == null) {
            text = ValueFormat.NOTHING;
            kind = null;
            kindType = null;
            return;
        }

        var shown = kindOf(complication.getType());
        var icon = shown.icon();

        text = shown.text(complication);

        if (icon != null) {
            icon.refresh();
        }
    }

    //! Also drawn by the editor while it pulses the field
    function draw(dc as Dc) as Void {
        var shown = kind;

        IconText.draw(dc, (locX + (width / 2)).toNumber(), locY.toNumber(), (shown != null) ? shown.icon() : null, text, color);
    }

    //! What the editor outlines and taps are tested against
    function getBoundingBox() as Graphics.BoundingBox {
        var boundingBox = new Graphics.BoundingBox();
        boundingBox.addRectangle(locX.toNumber(), locY.toNumber(), width.toNumber(), height.toNumber());

        return boundingBox;
    }

    function containsPoint(x as Number, y as Number) as Boolean {
        return getBoundingBox().includesPoint(x, y);
    }

    //! The kind for a type, kept until the type moves
    private function kindOf(type as Complications.Type?) as FieldKind {
        var current = kind;

        if ((current != null) && (type == kindType)) {
            return current;
        }

        current = FieldKinds.of(type);
        kind = current;
        kindType = type;

        return current;
    }
}
