import Toybox.Lang;

//! The editor's styles. Ids must match the <style> ids in watchface.xml.
module Styles {
    enum Value {
        PLAIN = 1,
        GOAL = 2,
        GOAL_GRAY = 3,
        GOAL_GRAY_SMALL = 4,
        GOAL_GRAY_EDGE = 5
    }

    const DEFAULT = PLAIN;

    //! A numeral picked out as far round as the goal is done
    function hasGoal(style as Number) as Boolean {
        return (style == GOAL) || hasGrayNumerals(style);
    }

    //! The numerals gray rather than in the day's colors
    function hasGrayNumerals(style as Number) as Boolean {
        return (style == GOAL_GRAY) || hasSmallTime(style) || hasEdgeCircle(style);
    }

    //! The circle round the edge of the glass, the numerals inside it
    function hasEdgeCircle(style as Number) as Boolean {
        return style == GOAL_GRAY_EDGE;
    }

    //! The time a font step smaller
    function hasSmallTime(style as Number) as Boolean {
        return style == GOAL_GRAY_SMALL;
    }
}
