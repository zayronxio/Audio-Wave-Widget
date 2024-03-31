#include <iostream>
#include <cmath>
#include <fftw3.h>
#include <portaudio.h>

#define SAMPLE_RATE         (44100)
#define FRAMES_PER_BUFFER   (256)
#define NUM_CHANNELS        (1)

#define NUM_LOW_BANDS       (3)
#define NUM_HIGH_BANDS      (6)

#define MIN_FREQ_LOW        (20)
#define MAX_FREQ_LOW        (4000)
#define MIN_FREQ_HIGH       (4000)
#define MAX_FREQ_HIGH       (12000)

#define DECIBEL_SCALE       (20.0 * log10(2.0))

// Estructura de datos para almacenar información del audio
typedef struct {
    fftw_complex* in;
    fftw_complex* out;
    fftw_plan plan;
} AudioData;

// Función para calcular el índice de la frecuencia en el espectro
int calculateIndex(double freq, int sampleRate, int bufferSize) {
    return (int)round(freq / sampleRate * bufferSize);
}

// Función de callback para procesamiento de audio
static int audioCallback(const void* inputBuffer, void* outputBuffer,
                         unsigned long framesPerBuffer,
                         const PaStreamCallbackTimeInfo* timeInfo,
                         PaStreamCallbackFlags statusFlags,
                         void* userData) {
    AudioData* audioData = (AudioData*)userData;

    // Convertir el buffer de entrada en un arreglo de tipo double
    const float* in = (const float*)inputBuffer;
    for (int i = 0; i < framesPerBuffer; ++i) {
        audioData->in[i][0] = in[i];
        audioData->in[i][1] = 0.0;
    }

    // Calcular la transformada de Fourier
    fftw_execute(audioData->plan);

    // Calcular la energía en las bandas de frecuencia bajas
    double bandFreqLow = MIN_FREQ_LOW;
    double bandWidthLow = (MAX_FREQ_LOW - MIN_FREQ_LOW) / NUM_LOW_BANDS;
    for (int i = 0; i < NUM_LOW_BANDS; ++i) {
        double bandEnergy = 0.0;
        int startIdx = calculateIndex(bandFreqLow, SAMPLE_RATE, FRAMES_PER_BUFFER);
        int endIdx = calculateIndex(bandFreqLow + bandWidthLow, SAMPLE_RATE, FRAMES_PER_BUFFER);
        for (int j = startIdx; j < endIdx; ++j) {
            bandEnergy += pow(audioData->out[j][0], 2) + pow(audioData->out[j][1], 2);
        }
        bandEnergy /= (endIdx - startIdx); // Promedio de energía en la banda
        double bandDb = DECIBEL_SCALE * log10(1 + bandEnergy);

        std::cout << "Frecuencia: " << bandFreqLow << " Hz - " << (bandFreqLow + bandWidthLow) << " Hz: " << bandDb << " dB\n";

        bandFreqLow += bandWidthLow;
    }

    // Calcular la energía en las bandas de frecuencia altas
    double bandFreqHigh = MIN_FREQ_HIGH;
    double bandWidthHigh = (MAX_FREQ_HIGH - MIN_FREQ_HIGH) / NUM_HIGH_BANDS;
    for (int i = 0; i < NUM_HIGH_BANDS; ++i) {
        double bandEnergy = 0.0;
        int startIdx = calculateIndex(bandFreqHigh, SAMPLE_RATE, FRAMES_PER_BUFFER);
        int endIdx = calculateIndex(bandFreqHigh + bandWidthHigh, SAMPLE_RATE, FRAMES_PER_BUFFER);
        for (int j = startIdx; j < endIdx; ++j) {
            bandEnergy += pow(audioData->out[j][0], 2) + pow(audioData->out[j][1], 2);
        }
        bandEnergy /= (endIdx - startIdx); // Promedio de energía en la banda
        double bandDb = DECIBEL_SCALE * log10(1 + bandEnergy);

        std::cout << "Frecuencia: " << bandFreqHigh << " Hz - " << (bandFreqHigh + bandWidthHigh) << " Hz: " << bandDb << " dB\n";

        bandFreqHigh += bandWidthHigh;
    }

    return paComplete; // Detener el stream después de una ejecución
}

int main() {
    PaError err;
    PaStream* stream;
    AudioData audioData;

    // Inicializar PortAudio
    err = Pa_Initialize();
    if (err != paNoError) {
        std::cerr << "Error al inicializar PortAudio: " << Pa_GetErrorText(err) << std::endl;
        return 1;
    }

    // Preparar la estructura de datos para audio
    audioData.in = (fftw_complex*)fftw_malloc(sizeof(fftw_complex) * FRAMES_PER_BUFFER);
    audioData.out = (fftw_complex*)fftw_malloc(sizeof(fftw_complex) * FRAMES_PER_BUFFER);
    audioData.plan = fftw_plan_dft_1d(FRAMES_PER_BUFFER, audioData.in, audioData.out, FFTW_FORWARD, FFTW_ESTIMATE);

    // Abrir el stream de audio
    err = Pa_OpenDefaultStream(&stream, NUM_CHANNELS, NUM_CHANNELS, paFloat32, SAMPLE_RATE, FRAMES_PER_BUFFER, audioCallback, &audioData);
    if (err != paNoError) {
        std::cerr << "Error al abrir el stream de audio: " << Pa_GetErrorText(err) << std::endl;
        return 1;
    }

    // Iniciar el stream de audio
    err = Pa_StartStream(stream);
    if (err != paNoError) {
        std::cerr << "Error al iniciar el stream de audio: " << Pa_GetErrorText(err) << std::endl;
        return 1;
    }

    // Esperar a que el callback de audio termine (stream se detendrá automáticamente)
    while (Pa_IsStreamActive(stream)) {
        Pa_Sleep(100);
    }

    // Cerrar el stream de audio
    err = Pa_CloseStream(stream);
    if (err != paNoError) {
        std::cerr << "Error al cerrar el stream de audio: " << Pa_GetErrorText(err) << std::endl;
        return 1;
    }

    // Liberar memoria y finalizar PortAudio
    fftw_destroy_plan(audioData.plan);
    fftw_free(audioData.in);
    fftw_free(audioData.out);
    Pa_Terminate();

    return 0;
}
