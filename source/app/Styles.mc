import Toybox.Lang;

//! The editor's styles. Ids must match the <style> ids in watchface.xml.
module Styles {
    enum Value {
        PLAIN = 1,
        RECOVERY = 2,
        RECOVERY_GOAL = 3
    }

    const DEFAULT = PLAIN;

    //! The numeral of the recovery hours left picked out
    function hasRecovery(style as Number) as Boolean {
        return (style == RECOVERY) || hasGoal(style);
    }

    //! The goal dot
    function hasGoal(style as Number) as Boolean {
        return style == RECOVERY_GOAL;
    }
}
