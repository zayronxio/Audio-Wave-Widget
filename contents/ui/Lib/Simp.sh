#!/bin/bash
command="$($HOME/.local/share/plasma/plasmoids/Audio.Wave.Widget/contents/ui/Lib/audio_analyzer 2>/dev/null | grep "Frecuencia:" | sed 's/Frecuencia://g' | sed 's/ dB//g' )"
elimEtiquetas="$(echo "$command" | sed 's/20 Hz - 121 Hz: //g' | sed 's/121 Hz - 501 Hz: //g' | sed 's/501 Hz - 901 Hz: //g' | sed 's/901 Hz - 1421 Hz: //g' | sed 's/1421 Hz - 2001 Hz: //g' | sed 's/2001 Hz - 3001 Hz: //g'  | sed 's/3001 Hz - 4351 Hz: //g' | sed 's/4351 Hz - 6801 Hz: //g' | sed 's/6801 Hz - 13000 Hz: //g')"
elimSaltos="$(echo "$elimEtiquetas" | sed ':a;N;$!ba;s/\n/ /g' )"
echo "$elimSaltos"
