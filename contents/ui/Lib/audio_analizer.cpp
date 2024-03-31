#include <iostream>
#include <vector>
#include <cmath>
#include <portaudio.h>

#define SAMPLE_RATE         (44100)
#define FRAMES_PER_BUFFER   (256)
#define NUM_CHANNELS        (1)

#define NUM_BANDS           (9)

#define BAND1_MIN_FREQ      (20)
#define BAND1_MAX_FREQ      (120)
#define BAND2_MIN_FREQ      (121)
#define BAND2_MAX_FREQ      (500)
#define BAND3_MIN_FREQ      (501)
#define BAND3_MAX_FREQ      (900)
#define BAND4_MIN_FREQ      (901)
#define BAND4_MAX_FREQ      (1420)
#define BAND5_MIN_FREQ      (1421)
#define BAND5_MAX_FREQ      (2000)
#define BAND6_MIN_FREQ      (2001)
#define BAND6_MAX_FREQ      (3000)
#define BAND7_MIN_FREQ      (3001)
#define BAND7_MAX_FREQ      (4350)
#define BAND8_MIN_FREQ      (4351)
#define BAND8_MAX_FREQ      (6800)
#define BAND9_MIN_FREQ      (6801)
#define BAND9_MAX_FREQ      (13000)

#define DECIBEL_SCALE       (20.0 * std::log10(2.0))

// Función para calcular el índice de la frecuencia en el espectro
int calculateIndex(double freq, int sampleRate, int bufferSize) {
    return (int)std::round(freq / sampleRate * bufferSize);
}

// Función para calcular la energía en una banda de frecuencia
double calculateBandEnergy(const std::vector<double>& spectrum, int startIndex, int endIndex) {
    double energy = 0.0;
    for (int i = startIndex; i < endIndex; ++i) {
        energy += spectrum[i] * spectrum[i];
    }
    return energy / (endIndex - startIndex);
}

// Función para imprimir la energía en una banda de frecuencia
void printBandEnergy(double bandFreqLow, double bandFreqHigh, const std::vector<double>& spectrum) {
    int startIdx = calculateIndex(bandFreqLow, SAMPLE_RATE, FRAMES_PER_BUFFER);
    int endIdx = calculateIndex(bandFreqHigh, SAMPLE_RATE, FRAMES_PER_BUFFER);
    double bandEnergy = calculateBandEnergy(spectrum, startIdx, endIdx);
    double bandDb = DECIBEL_SCALE * std::log10(1 + bandEnergy);
    std::cout << "Frecuencia: " << bandFreqLow << " Hz - " << bandFreqHigh << " Hz: " << bandDb << " dB\n";
}

// Función de callback para procesamiento de audio
static int audioCallback(const void* inputBuffer, void* outputBuffer,
                         unsigned long framesPerBuffer,
                         const PaStreamCallbackTimeInfo* timeInfo,
                         PaStreamCallbackFlags statusFlags,
                         void* userData) {
    const float* in = (const float*)inputBuffer;
    std::vector<double> audioBuffer(framesPerBuffer);
    std::copy(in, in + framesPerBuffer, audioBuffer.begin());

    // Calcular la transformada de Fourier de la señal de audio
    std::vector<double> spectrum(framesPerBuffer, 0.0);
    for (int k = 0; k < framesPerBuffer; ++k) {
        for (int n = 0; n < framesPerBuffer; ++n) {
            spectrum[k] += audioBuffer[n] * std::cos(-2 * M_PI * k * n / framesPerBuffer);
        }
    }

    // Definir los márgenes de frecuencia para cada banda
    double bandFreqs[NUM_BANDS + 1] = {
        BAND1_MIN_FREQ, BAND2_MIN_FREQ, BAND3_MIN_FREQ,
        BAND4_MIN_FREQ, BAND5_MIN_FREQ, BAND6_MIN_FREQ,
        BAND7_MIN_FREQ, BAND8_MIN_FREQ, BAND9_MIN_FREQ,
        BAND9_MAX_FREQ
    };

    // Calcular la energía en cada banda de frecuencia
    for (int i = 0; i < NUM_BANDS; ++i) {
        printBandEnergy(bandFreqs[i], bandFreqs[i + 1], spectrum);
    }

    return paComplete;
}

int main() {
    PaError err;
    PaStream* stream;

    // Inicializar PortAudio
    err = Pa_Initialize();
    if (err != paNoError) {
        std::cerr << "Error al inicializar PortAudio: " << Pa_GetErrorText(err) << std::endl;
        return 1;
    }

    // Configurar parámetros de audio
    PaStreamParameters inputParameters;
    inputParameters.device = Pa_GetDefaultInputDevice();
    inputParameters.channelCount = NUM_CHANNELS;
    inputParameters.sampleFormat = paFloat32;
    inputParameters.suggestedLatency = Pa_GetDeviceInfo(inputParameters.device)->defaultLowInputLatency;
    inputParameters.hostApiSpecificStreamInfo = NULL;

    // Abrir el stream de audio
    err = Pa_OpenStream(&stream, &inputParameters, NULL, SAMPLE_RATE, FRAMES_PER_BUFFER, paClipOff, audioCallback, NULL);
    if (err != paNoError) {
        std::cerr << "Error al abrir el stream de audio: " << Pa_GetErrorText(err) << std::endl;
        Pa_Terminate();
        return 1;
    }

    // Iniciar el stream de audio
    err = Pa_StartStream(stream);
    if (err != paNoError) {
        std::cerr << "Error al iniciar el stream de audio: " << Pa_GetErrorText(err) << std::endl;
        Pa_CloseStream(stream);
        Pa_Terminate();
        return 1;
    }

    std::cout << "Capturando audio y mostrando resultados. Esperando a que el procesamiento termine...\n";

    // Esperar a que el procesamiento termine
    while (Pa_IsStreamActive(stream)) {
        Pa_Sleep(100);
    }

    // Detener y cerrar el stream de audio
    err = Pa_StopStream(stream);
    if (err != paNoError) {
        std::cerr << "Error al detener el stream de audio: " << Pa_GetErrorText(err) << std::endl;
    }
    err = Pa_CloseStream(stream);
    if (err != paNoError) {
        std::cerr << "Error al cerrar el stream de audio: " << Pa_GetErrorText(err) << std::endl;
    }

    // Finalizar PortAudio
    Pa_Terminate();

    return 0;
}
