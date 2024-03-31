import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot

    signal configurationChanged

    property alias cfg_fontSize: sizeFontSpinBox.value

    ColumnLayout {
        spacing: units.smallSpacing * 2


        RowLayout{
            Label {
                text: i18n("Font Size")
            }
            SpinBox {
                id: sizeFontSpinBox
                from: 0
                to: 300
            }
        }

   }
}
