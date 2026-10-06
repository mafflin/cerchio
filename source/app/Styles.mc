import Toybox.Lang;

//! The editor's styles. Ids must match the <style> ids in watchface.xml.
module Styles {
    enum Value {
        PLAIN = 1,
        GOAL = 2
    }

    const DEFAULT = PLAIN;
}
