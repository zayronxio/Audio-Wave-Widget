import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.private.mpris as Mpris

PlasmoidItem {
    id: root
    width: 400
    height: 180

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: "NoBackground"

    property string artist: mpris2Model.currentPlayer?.artist ?? ""
    property string track: mpris2Model.currentPlayer?.track
    readonly property int playbackStatus: mpris2Model.currentPlayer?.playbackStatus ?? 0
    readonly property bool isPlaying: root.playbackStatus === Mpris.PlaybackStatus.Playing

    AudioAnalizer {
		id: audioAnalizer

		maxheight: barras.height
		minwid: barras.width/16
	}
	ColumnLayout {
        id: wrapper
        width:  parent.width
        height: parent.height
        Layout.minimumWidth: 290
        Layout.minimumHeight: 170
        Column {
            width:  parent.width
            height: parent.height
            anchors.centerIn: parent
            Row {
                id: barras
                width: height
                height: trackMusic.height/infotrack.height < .60 ? (parent.height*.55) > parent.width ? parent.width : parent.height*.55 : (parent.height*.45) > parent.width ? parent.width : parent.height*.45
                spacing: (width-((width/16)*9))/8
                anchors.horizontalCenter: parent.horizontalCenter
                //visible: trackMusic.length > 0 ? true : false
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: isPlaying ? audioAnalizer.one : width
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: isPlaying ?  audioAnalizer.two : width
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: isPlaying ? audioAnalizer.three : width
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: isPlaying ? audioAnalizer.four : width
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: isPlaying ? audioAnalizer.five : width
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: isPlaying ? audioAnalizer.six : width
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: isPlaying ? audioAnalizer.seven : width
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: isPlaying ? audioAnalizer.eight : width
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "white"
                    width: barras.width/16
                    height: isPlaying ? audioAnalizer.nine : width
                    radius: width/2
                    anchors.verticalCenter: parent.verticalCenter

                }
            }

            Column {
                id: infotrack
                width: wrapper.width
                height: parent.height-(barras.height)
                spacing: 0
                Rectangle {
                    width: wrapper.width
                    height: parent.height*.65
                    color: "transparent"
                    Text {
                        id: trackMusic
                        width: wrapper.width
                        font.pixelSize: parent.height*.4
                        text: track
                        color: "white"
                        font.bold: true
                        lineHeight: 0.8
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.Bottom
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        anchors.bottom: parent.bottom
                    }
                }

            Text {
                id: artisMusic
                width: wrapper.width
                height: parent.height*.35
                font.pixelSize: height*.4
                text: artist
                color: "white"
                opacity: .80
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            }

        }
    }
    Mpris.Mpris2Model {
        id: mpris2Model
    }
}
