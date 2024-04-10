import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.plasma.plasma5support as Plasma5Support



Item {

    property string codesByAudio: "0"
    property string numeros: codesByAudio.toString();
    property string updatescommand0: "bash $HOME/.local/share/plasma/plasmoids/Audio.Wave.Widget/contents/ui/Lib/Simp-simple.sh"
    property string updatescommand1: "bash $HOME/.local/share/plasma/plasmoids/Audio.Wave.Widget/contents/ui/Lib/Simp.sh"
    property string updatescommand2:  "bash $HOME/.local/share/plasma/plasmoids/Audio.Wave.Widget/contents/ui/Lib/Simp-advance.sh"
    property string updatescommand: "bash $HOME/.local/share/plasma/plasmoids/Audio.Wave.Widget/contents/ui/Lib/ejecutor.sh" // plasmoid.configuration.dataExtractionMethod === 0 ? updatescommand0 : plasmoid.configuration.dataExtractionMethod === 1 ? updatescommand1 : updatescommand2
    property int maxheight: 200
    property int minwid: 10
    property bool timerRepat: true


    property int one: establerAnchoDeBar(8,maxheight,minwid)
    property int two: establerAnchoDeBar(6,maxheight,minwid)
    property int three: establerAnchoDeBar(4,maxheight,minwid)
    property int four: establerAnchoDeBar(2,maxheight,minwid)
    property int five: establerAnchoDeBar(1,maxheight,minwid)
    property int six: establerAnchoDeBar(3,maxheight,minwid)
    property int seven: establerAnchoDeBar(5,maxheight,minwid)
    property int eight: establerAnchoDeBar(7,maxheight,minwid)
    property int nine: establerAnchoDeBar(8,maxheight,minwid)

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
            return heig/4
        } else if (numero == 2) {
            return heig/6
        } else if (numero == 3) {
            return  heig/6
        } else if (numero == 4) {
            return  heig/10
        } else if (numero == 5) {
            return heig/10
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
        var numSinExp = (getPrimerNumero(numeros, asignacion))
        var num = (heig/18)*(numSinExp*50) + balancecentar(asignacion,heig)
        if (num < min) {
            return min
        } else { if (num > heig) {
            return heig
        } else {

            if (asignacion === 1) {
                if (num*1.8 > heig) {
            return heig
        } else {
            return num*1.8 }
        }
                else {
                    if (asignacion === 2) {
                        if (num*1.2 > heig) {
            return heig
        } else {
            return num*1.2 }
                    }
                        else {
                            if (asignacion === 3) {
                                if (num*1.2 > heig) {
            return heig
        } else {
            return num*1.2 }
                            }
                                else {
                                        return num
                                    }
                        }
                }
            }
        }

        }

Timer {
    id: timer
    interval: 75
    running: true
    repeat: true
    onTriggered: {
        if (timerRepat == true) {
          executeCommand()
        }

    }
}

}
