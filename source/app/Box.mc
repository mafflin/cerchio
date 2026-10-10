import Toybox.Graphics;
import Toybox.Lang;

//! A box of pixels as [left, top, right, bottom], right and bottom one past
//! the last pixel.
module Box {

    //! The box round both, either of which may be null
    function union(first as Array<Number>?, second as Array<Number>?) as Array<Number>? {
        if (first == null) {
            return second;
        }

        if (second == null) {
            return first;
        }

        return [
            Numbers.min(first[0], second[0]),
            Numbers.min(first[1], second[1]),
            Numbers.max(first[2], second[2]),
            Numbers.max(first[3], second[3])
        ];
    }

    //! Drawing kept inside the box until clearClip()
    function clip(dc as Dc, box as Array<Number>) as Void {
        dc.setClip(box[0], box[1], box[2] - box[0], box[3] - box[1]);
    }

    //! In the current foreground color
    function fill(dc as Dc, box as Array<Number>) as Void {
        dc.fillRectangle(box[0], box[1], box[2] - box[0], box[3] - box[1]);
    }
}
