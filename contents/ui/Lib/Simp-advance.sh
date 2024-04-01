#!/bin/bash
command="$($HOME/.local/share/plasma/plasmoids/Audio.Wave.Widget/contents/ui/Lib/audio_analyzer2 2>/dev/null | grep "Frecuencia:" | sed 's/Frecuencia://g' | sed 's/ dB//g' )"
elimEtiquetas="$(echo "$command" | sed 's/20 Hz - 1346 Hz: //g' | sed 's/1346 Hz - 2672 Hz: //g' | sed 's/2672 Hz - 3998 Hz: //g' | sed 's/4000 Hz - 5333 Hz: //g' | sed 's/5333 Hz - 6666 Hz: //g' | sed 's/5333 Hz - 6666 Hz: //g'  | sed 's/6666 Hz - 7999 Hz: //g' | sed 's/7999 Hz - 9332 Hz: //g' | sed 's/9332 Hz - 10665 Hz: //g' | sed 's/10665 Hz - 11998 Hz: //g')"
elimSaltos="$(echo "$elimEtiquetas" | sed ':a;N;$!ba;s/\n/ /g' )"
echo "$elimSaltos"
