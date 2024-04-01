import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot

    signal configurationChanged
    QtObject {
        id: initialValue
        property var value
    }

    property alias cfg_dataExtractionMethod: initialValue.value

    ColumnLayout {
        spacing: units.smallSpacing * 2
        width: configRoot.width
        height: configRoot.height


            Column{
                width: parent.width
                height: parent.width
            Label {
                text: i18n("Data Extraction Method")
                font.bold: true
            }
            Label {
                width: parent.width
                text: i18n("extracting the data with python is the most recommended!")
                opacity: 0.8
                wrapMode: Text.WordWrap
                visible: initialValue.value === 0 ? true :  false
            }
            Label {
                text: i18n("This process to extract the data requires the portaudio19-dev library, if installing this seems complicated, use python as the method to extract data")
                opacity: 0.8
                width: parent.width
                wrapMode: Text.WordWrap
                visible: initialValue.value === 1 ? true :  false
            }
            Label {
                text: i18n("This process to extract the data requires the portaudio19-dev and fftw3 library, if installing this seems complicated, use python as a method to extract data")
                opacity: 0.8
                width: parent.width
                wrapMode: Text.WordWrap
                visible: initialValue.value === 2 ? true :  false
            }
            ComboBox {
            textRole: "text"
            valueRole: "value"
			id: initial
			currentIndex: initialValue.value
			model: [
                {text: i18n("python and arecord"), value: 0},
                {text: i18n("portaudio"), value: 1},
                {text: i18n("portaudio and fftw3"), value: 2}
            ]
            onActivated: initialValue.value = currentValue
            Component.onCompleted: currentIndex = indexOfValue(initialValue.value)
		}
        }

   }
}
