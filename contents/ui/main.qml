import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.private.mpris as Mpris

PlasmoidItem {
    id: root
    width: 400
    height: 200

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: "NoBackground"

    property string artist: mpris2Model.currentPlayer?.artist ?? ""
    property string track: mpris2Model.currentPlayer?.track
    readonly property int playbackStatus: mpris2Model.currentPlayer?.playbackStatus ?? 0
    readonly property bool isPlaying: root.playbackStatus === Mpris.PlaybackStatus.Playing

    AudioAnalizer {
		id: audioAnalizer
		maxheight: barras.height
	}
	fullRepresentation: ColumnLayout {
        id: wrapper
        width: parent.width
        height: parent.height
        Column {
            Layout.preferredWidth: (parent.height < parent.width) ? parent.height : parent.width
            Layout.preferredHeight: (parent.height < parent.width) ? parent.height : parent.width
            anchors.centerIn: parent
            Row {
                id: barras
                width: height*1.3
                height: parent.height*.4
                spacing: (width-((width/16)*9))/8
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    color: "white"
                    width: barras.width/14
                    height: audioAnalizer.one
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: audioAnalizer.two
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: audioAnalizer.three
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: audioAnalizer.four
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: audioAnalizer.five
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: audioAnalizer.six
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: audioAnalizer.seven
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: audioAnalizer.eight
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: audioAnalizer.nine
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                id: trackMusic
                width: parent.width
                height: parent.height*.35
                font.pixelSize: height*.6
                text: track
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 2
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: artisMusic
                width: parent.width
                height: parent.height*.25
                font.pixelSize: height*.3
                text: artist
                color: "white"
                opacity: .80
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }
    }
    Mpris.Mpris2Model {
        id: mpris2Model
    }
}
