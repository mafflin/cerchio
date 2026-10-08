import Toybox.Lang;

//! The editor's styles. Ids must match the <style> ids in watchface.xml.
module Styles {
    enum Value {
        NUMERALS = 1,
        PLAIN = 2
    }

    const DEFAULT = NUMERALS;

    //! The numerals round the glass, the one nearest the second picked out
    //! in place of a seconds hand; without them the circle moves out to the
    //! glass
    function hasNumerals(style as Number) as Boolean {
        return style == NUMERALS;
    }

    //! A second row of data fields below the first
    function hasSecondFieldRow(style as Number) as Boolean {
        return style == PLAIN;
    }
}
