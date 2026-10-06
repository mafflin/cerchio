import Toybox.Lang;

//! The editor's styles. Ids must match the <style> ids in watchface.xml.
module Styles {
    enum Value {
        PLAIN = 1,
        GOAL = 2,
        GOAL_GRAY = 3
    }

    const DEFAULT = PLAIN;

    //! A numeral picked out as far round as the goal is done
    function hasGoal(style as Number) as Boolean {
        return (style == GOAL) || (style == GOAL_GRAY);
    }

    //! The numerals gray rather than in the day's colors
    function hasGrayNumerals(style as Number) as Boolean {
        return style == GOAL_GRAY;
    }
}
