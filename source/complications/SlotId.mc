//! Editor slot ids; must match watchface.xml
module SlotId {
    enum Value {
        CENTER = 1,
        GOAL = 2,
        STATUS = 3,

        //! Not an editor slot yet: always recovery time
        LOWER = 4
    }
}
