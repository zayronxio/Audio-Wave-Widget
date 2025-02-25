<div align="center">
  <h1>Audio Wave Widget</h1>
  <a href="https://kde.org">
  <img src="https://img.shields.io/badge/KDE_Plasma-6.1+-blue?style=flat&logo=kde" alt="License: GPLv3">
</a>
 <a href="https://www.gnu.org/licenses/gpl-3.0.html">
  <img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License: GPLv3">
</a>
  <a href="https://www.paypal.com/paypalme/zayronxio">
  <img src="https://img.shields.io/badge/donate-PayPal-%2337a556" alt="License: GPLv3">
</a>
  </a>
  <a href="https://store.kde.org/p/2142681">
  <img src="https://img.shields.io/badge/KDE%20Plasma-1D99F3?logo=kdeplasma&logoColor=fff" alt="License: GPLv3">
</a></div>

## ✨ Features
- **Real-Time Audio Visualization**: 9-band frequency bars powered by a Radix-2 FFT algorithm.
- **Smart Activation**: Automatically shows visualization **only** when audio is playing.
- **Media Info Display**: Shows current song title and artist (via MPRIS-compatible players).
- **Customizable**: Adjust update frequency and color via plasmoid settings.
- **Lightweight Backend**: C program using ALSA for audio capture and DBus for communication.
- **Precompiled Binaries**: Available for x86-64 systems.

## 🖼️ Preview
<img src="https://raw.githubusercontent.com/zayronxio/Audio-Wave-Widget/main/img/preview.jpg" alt="Imagen del proyecto" width="500"/>

## 📦 Dependencies
### For the C Program (Backend)
- `libasound2` (ALSA audio library)
- `libdbus-1-dev` (DBus communication)
- `build-essential` (GCC compiler & tools)

#### KDE Store in x86-64
1. install libdbus-1-dev
2. Right click on the desktop
3. Click on "Add Widgets"
4. Click on "Get New Widgets"
5. Click on "Download New Plasma Widgets"
6. Search for "Audio Wave Widget"
7. Click on "Install" and you're done!

## 🔧 Compile the Backend (Optional)
1. install from kde store
2. navigate to the directory "$HOME/.local/share/plasma/plasmoids/Audio.Wave.Widget/contents/ui/Lib"
```bash
sudo apt install libasound2-dev libdbus-1-dev build-essential

gcc fft_dbus.c -o fft_dbus -lasound -ldbus-1 -l
