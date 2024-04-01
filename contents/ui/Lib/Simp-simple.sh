#!/bin/bash
command="$(python3 $HOME/.local/share/plasma/plasmoids/Audio.Wave.Widget/contents/ui/Lib/medidor_decibeles.py 2>/dev/null | grep "Frecuencia:" | sed 's/Frecuencia://g' | sed 's/ dB//g' )"
elimEtiquetas="$(echo "$command" | sed 's/ 20 Hz - 120 Hz: //g' | sed 's/ 121 Hz - 500 Hz: //g' | sed 's/ 501 Hz - 900 Hz: //g' | sed 's/ 901 Hz - 1420 Hz: //g' | sed 's/ 1421 Hz - 2000 Hz: //g' | sed 's/ 2001 Hz - 3000 Hz: //g'  | sed 's/ 3001 Hz - 4350 Hz: //g' | sed 's/ 4351 Hz - 6800 Hz: //g' | sed 's/ 6801 Hz - 13000 Hz: //g')"
elimSaltos="$(echo "$elimEtiquetas" | sed ':a;N;$!ba;s/\n/ /g' )"
echo "$elimSaltos"

