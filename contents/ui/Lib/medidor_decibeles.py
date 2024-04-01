import subprocess
import numpy as np

# Constantes
SAMPLE_RATE = 44100
NUM_CHANNELS = 2
NUM_BANDS = 9

BANDS = [(20, 120), (121, 500), (501, 900), (901, 1420),
         (1421, 2000), (2001, 3000), (3001, 4350), (4351, 6800), (6801, 13000)]

DECIBEL_SCALE = 20.0 * np.log10(2.0)

# Valores a restar por banda de frecuencia
VALORES_A_RESTAR = [60.84, 59.65, 59.65, 59.65, 59.58, 61.90, 60.57, 56.88, 57.17]

def calculate_band_energy(spectrum_mag, start_idx, end_idx):
    energy = np.sum(np.square(spectrum_mag[start_idx:end_idx]))
    return energy / (end_idx - start_idx + 1)

def print_band_energy(band_freq_low, band_freq_high, spectrum_mag, idx):
    start_idx = int(band_freq_low / SAMPLE_RATE * len(spectrum_mag))
    end_idx = int(band_freq_high / SAMPLE_RATE * len(spectrum_mag))
    band_energy = calculate_band_energy(spectrum_mag, start_idx, end_idx)
    band_db = DECIBEL_SCALE * np.log10(1 + band_energy) - VALORES_A_RESTAR[idx]
    print(f"Frecuencia: {band_freq_low} Hz - {band_freq_high} Hz: {band_db:.2f} dB")

# Capturar una muestra de audio utilizando arecord
arecord_command = ['arecord', '-s', '500', '-f', 'S16_LE', '-r', str(SAMPLE_RATE), '-c', str(NUM_CHANNELS), '-']

# Capturar audio utilizando arecord
audio_data = subprocess.check_output(arecord_command)

# Convertir los datos de audio en un array numpy
audio_array = np.frombuffer(audio_data, dtype=np.int16)

# Calcular la transformada de Fourier de la señal de audio
spectrum = np.fft.fft(audio_array)

# Calcular la magnitud de la transformada de Fourier
spectrum_mag = np.abs(spectrum)

# Calcular la energía en cada banda de frecuencia
for i, band_freqs in enumerate(BANDS):
    print_band_energy(band_freqs[0], band_freqs[1], spectrum_mag, i)
