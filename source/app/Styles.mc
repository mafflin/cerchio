import Toybox.Lang;

//! The editor's styles. Ids must match the <style> ids in watchface.xml.
module Styles {
    enum Value {
        PLAIN = 1,
        GOAL = 2,
        GOAL_RECOVERY = 3
    }

    const DEFAULT = PLAIN;

    //! The goal dot
    function hasGoal(style as Number) as Boolean {
        return (style == GOAL) || hasRecovery(style);
    }

    //! The numeral of the recovery hours left picked out
    function hasRecovery(style as Number) as Boolean {
        return style == GOAL_RECOVERY;
    }
}
