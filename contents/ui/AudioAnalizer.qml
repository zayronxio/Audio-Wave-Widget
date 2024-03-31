import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.plasma.plasma5support as Plasma5Support



Item {

    property string codesByAudio: "0"
    property string numeros: codesByAudio.toString();
    property string updatescommand: "bash $HOME/.local/share/plasma/plasmoids/Audio.Wave.Widget/contents/ui/Lib/Simp.sh"
    property int maxheight: 200

    property int one: establerAnchoDeBar(8,maxheight,width)
    property int two: establerAnchoDeBar(6,maxheight,width)
    property int three: establerAnchoDeBar(4,maxheight,width)
    property int four: establerAnchoDeBar(2,maxheight,width)
    property int five: establerAnchoDeBar(1,maxheight,width)
    property int six: establerAnchoDeBar(3,maxheight,width)
    property int seven: establerAnchoDeBar(5,maxheight,width)
    property int eight: establerAnchoDeBar(7,maxheight,width)
    property int nine: establerAnchoDeBar(8,maxheight,width)

   /***/
   Plasma5Support.DataSource {
      id: executable2
      engine: "executable"
      connectedSources: []
      onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
                  }
     function exec(cmd) {
            connectSource(cmd)
           }
     signal exited(int exitCode, int exitStatus, string stdout, string stderr)
       }

   Connections {
     target: executable2
     onExited: {
                    codesByAudio = stdout.toString()
                }
          }
    function executeCommand() {
        executable2.exec(updatescommand)
    }
    ///*//

    function getPrimerNumero(texto, b) {
        var regexp = /(-?\d+(\.\d+)?)/g; // Expresión regular para encontrar números enteros, decimales y negativos
        var matches = texto.match(regexp); // Busca todos los números en la cadena
        if (matches && matches.length > 0) {
            return Number(matches[b]); // Devuelve el primer número encontrado
        } else {
            return 5;
        }
    }


    function balancecentar(numero,heig) {
        if (numero == 1) {
            return heig/6
        } else if (numero == 2) {
            return heig/8
        } else if (numero == 3) {
            return  heig/8
        } else if (numero == 4) {
            return  heig/12
        } else if (numero == 5) {
            return heig/12
        } else if (numero == 6) {
            return -heig/25
        } else if (numero == 7) {
            return -heig/25
        } else if (numero == 8) {
            return -heig/12
        } else if (numero == 9) {
            return -heig/12
        } else if (numero == 10) {
            return -heig/8
        } else {
            return 0
        }
    }
    function establerAnchoDeBar(asignacion,heig,min) {
        var numSinExp = (getPrimerNumero(numeros, asignacion)+2)
        var num = (heig/14)*numSinExp + balancecentar(asignacion,heig)
        if (num < min) {
            return min
        } else { if (num > heig) {
            return heig
        } else {
            return num
        }

        }
    }

Timer {
    id: timer
    interval: 150
    running: true
    repeat: true
    onTriggered: {
        executeCommand()
    }
}
}
