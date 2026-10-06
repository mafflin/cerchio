import Toybox.Lang;
import Toybox.WatchUi;

//! The power budget notice for partial updates.
class CerchioDelegate extends WatchUi.WatchFaceDelegate {

    private var view as CerchioView;

    function initialize(view as CerchioView) {
        WatchFaceDelegate.initialize();
        self.view = view;
    }

    //! The system stops calling onPartialUpdate after this
    function onPowerBudgetExceeded(powerInfo as WatchFacePowerInfo) as Void {
        view.turnPartialUpdatesOff();
    }
}
