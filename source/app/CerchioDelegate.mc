import Toybox.Application.WatchFaceConfig;
import Toybox.Lang;
import Toybox.WatchUi;

//! Editor edits, and the power budget notice for partial updates.
class CerchioDelegate extends WatchUi.WatchFaceDelegate {

    private var view as CerchioView;

    function initialize(view as CerchioView) {
        WatchFaceDelegate.initialize();
        self.view = view;
    }

    function onWatchFaceConfigEdited(options as {:configId as WatchFaceConfig.Id, :type as WatchFaceConfigType?, :committed as Boolean}) as Void {
        var id = options[:configId] as WatchFaceConfig.Id?;

        if (id == null) {
            return;
        }

        var settings = WatchFaceConfig.getSettings(id);

        if (settings != null) {
            view.updateConfiguration(settings);
        }
    }

    //! The system stops calling onPartialUpdate after this
    function onPowerBudgetExceeded(powerInfo as WatchFacePowerInfo) as Void {
        view.turnPartialUpdatesOff();
    }
}
