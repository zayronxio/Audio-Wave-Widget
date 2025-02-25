import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.plasma.plasma5support as Plasma5Support

Item {

    property var spectrumData: []
    property string updatescommand: `dbus-monitor "interface='org.plasma.AudioSpectrumAnalyzer'" | head -n 16`
    property int maxheight: 200
    property int minwid: 16
    property bool timerRepat: true
    property int frecu: 100

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: "$HOME/.local/share/plasma/plasmoids/Audio.Wave.Widget/contents/ui/Lib/fft_dbus default"
        onNewData: function(source, data) {
            disconnectSource(source)
        }

    }

    function generatorFrecu(num){

        var highestValue = Math.max(...spectrumData);
        var dividend = highestValue < maxheight ? highestValue : 60000
        var value = spectrumData[num]/dividend
        if (value < minwid) {
            return minwid
        } else if (value > maxheight) {
            return maxheight
        } else {
            return value
        }

    }
    property int one: generatorFrecu(8)
    property int two: generatorFrecu(6)
    property int three: generatorFrecu(4)
    property int four: generatorFrecu(2)
    property int five: generatorFrecu(1)
    property int six: generatorFrecu(3)
    property int seven: generatorFrecu(5)
    property int eight: generatorFrecu(6)
    property int nine: generatorFrecu(8)

    Plasma5Support.DataSource {
        id: executable2
        engine: "executable"
        connectedSources: []

        onNewData: {
            disconnectSource(sourceName);
            processStdout(data.stdout);
        }

        function exec(cmd) {
            connectSource(cmd);
        }

    }
    function executeCommand() {
        executable2.exec(updatescommand)
    }

    function processStdout(stdout) {
        var arrayPattern = /array \[\s*([\s\S]*?)\s*\]/;
        var match = arrayPattern.exec(stdout);
        if (match) {
            var arrayString = match[1];
            var numberPattern = /double\s+([\d\.e\+\-]+)/g;
            var numbers = [];
            var numberMatch;
            while ((numberMatch = numberPattern.exec(arrayString)) !== null) {
                numbers.push(parseFloat(numberMatch[1]));
            }
            spectrumData = numbers;
        }
    }


    Component.onDestruction: {
        console.log("terminacion")
        executable.disconnectSource(executable.source)
        executable.exec("killall fft_dbus")

    }

    Timer {
        id: timer
        interval: 25
        running: true
        repeat: true
        onTriggered: {
            if (timerRepat == true) {
                executeCommand()
            }

        }
    }

}
