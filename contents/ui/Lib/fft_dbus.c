#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <signal.h>
#include <alsa/asoundlib.h>
#include <dbus/dbus.h>

#define N_SAMPLES 1024
#define SAMPLE_RATE 44100

uint16_t indices[N_SAMPLES];

typedef struct {
    double re;
    double im;
} Complex;

DBusConnection *connection;
DBusError error;

void sigint_handler(int signo)
{
    if (signo == SIGINT) {
        dbus_connection_unref(connection);
        exit(0);
    }
}

void reverse_index_bits()
{
    uint16_t reversed;
    uint16_t bits = log2(N_SAMPLES);
    for (uint16_t i = 0; i < N_SAMPLES; i++) {
        indices[i] = i;
        reversed = 0;
        for (uint16_t bit = 0; bit < bits; bit++) {
            reversed <<= 1;
            reversed += indices[i] & 1;
            indices[i] >>= 1;
        }
        indices[i] = reversed;
    }
}

Complex complex_exp(Complex z)
{
    Complex result;
    result.re = cos(z.im);
    result.im = sin(z.im);
    return result;
}

Complex cmul(Complex z1, Complex z2)
{
    Complex result;
    result.re = z1.re * z2.re - z1.im * z2.im;
    result.im = z1.re * z2.im + z1.im * z2.re;
    return result;
}

void fft(Complex result[N_SAMPLES], short buffer[N_SAMPLES])
{
    for (uint16_t bin = 0; bin < N_SAMPLES; bin++) {
        result[bin].re = buffer[indices[bin]];
        result[bin].im = 0.0;
    }

    for (uint16_t M = 2; M <= N_SAMPLES; M *= 2) {
        for (uint16_t subproblem = 0; subproblem < N_SAMPLES / M; subproblem++) {
            for (uint16_t k = 0; k < M / 2; k++) {
                Complex w = {.re = 0, .im = -2 * M_PI * k / M};
                Complex twiddle_factor = complex_exp(w);

                uint16_t even_index = subproblem * M + k;
                uint16_t odd_index = subproblem * M + k + M / 2;
                Complex even = result[even_index];
                Complex odd = cmul(twiddle_factor, result[odd_index]);
                result[even_index].re = even.re + odd.re;
                result[even_index].im = even.im + odd.im;
                result[odd_index].re = even.re - odd.re;
                result[odd_index].im = even.im - odd.im;
            }
        }
    }
}

void apply_hann_window(short samples[N_SAMPLES])
{
    for (uint16_t i = 0; i < N_SAMPLES; i++) {
        float ratio = (float)i / (N_SAMPLES - 1);
        float weight = 0.5 * (1 - cos(2 * M_PI * ratio));
        samples[i] *= weight;
    }
}

void send_spectrum_over_dbus(double magnitudes[9])
{
    DBusMessage *message;
    DBusMessageIter args, array_iter;

    // Crear una nueva señal D-Bus
    message = dbus_message_new_signal("/org/plasma/AudioSpectrumAnalyzer", "org.plasma.AudioSpectrumAnalyzer", "SpectrumDataUpdated");

    // Inicializar el iterador de mensajes
    dbus_message_iter_init_append(message, &args);

    // Abrir un contenedor para el array de doubles
    dbus_message_iter_open_container(&args, DBUS_TYPE_ARRAY, DBUS_TYPE_DOUBLE_AS_STRING, &array_iter);

    // Agregar cada valor del array al contenedor
    for (int i = 0; i < 9; i++) {
        double value = magnitudes[i];
        dbus_message_iter_append_basic(&array_iter, DBUS_TYPE_DOUBLE, &value);
    }

    // Cerrar el contenedor del array
    dbus_message_iter_close_container(&args, &array_iter);

    // Enviar la señal
    dbus_connection_send(connection, message, NULL);
    dbus_message_unref(message);
}

void print_spectrum(Complex fft_res[N_SAMPLES])
{
    double frequency_resolution = (double)SAMPLE_RATE / N_SAMPLES;
    double magnitudes[9] = {0};
    double frequencies[9][2] = {
        {20, 250},
        {251, 500},
        {501, 1500},
        {1501, 2000},
        {2001, 3000},
        {3001, 4000},
        {4001, 6000},
        {6001, 16000},
        {16001, 22800}
    };

    for (int i = 0; i < N_SAMPLES / 2; i++) {
        double frequency = i * frequency_resolution;
        double magnitude = sqrt(fft_res[i].re * fft_res[i].re + fft_res[i].im * fft_res[i].im);
        for (int j = 0; j < 9; j++) {
            if (frequency >= frequencies[j][0] && frequency < frequencies[j][1]) {
                magnitudes[j] += magnitude;
                break;
            }
        }
    }

    send_spectrum_over_dbus(magnitudes);
}

int main(int argc, char *argv[])
{
    int err;
    snd_pcm_t *capture_handle;
    snd_pcm_hw_params_t *hw_params;
    snd_pcm_format_t format = SND_PCM_FORMAT_S16_LE; // Formato de 16 bits

    unsigned int sample_rate = SAMPLE_RATE;
    unsigned int buffer_time = 500000; // Tiempo del buffer en microsegundos
    snd_pcm_uframes_t buffer_size = N_SAMPLES;

    dbus_error_init(&error);
    connection = dbus_bus_get(DBUS_BUS_SESSION, &error);

    if (dbus_error_is_set(&error)) {
        fprintf(stderr, "Connection Error (%s)\n", error.message);
        dbus_error_free(&error);
        return 1;
    }

    // Solicitar un nombre de servicio único
    dbus_bus_request_name(connection, "org.plasma.AudioSpectrumAnalyzerService", DBUS_NAME_FLAG_REPLACE_EXISTING, &error);

    if (dbus_error_is_set(&error)) {
        fprintf(stderr, "Name Error (%s)\n", error.message);
        dbus_error_free(&error);
        return 1;
    }

    if ((err = snd_pcm_open(&capture_handle, argv[1], SND_PCM_STREAM_CAPTURE, 0)) < 0) {
        printf("Cannot open audio device %s (%s)\n", argv[1], snd_strerror(err));
        exit(1);
    }

    snd_pcm_hw_params_malloc(&hw_params);
    snd_pcm_hw_params_any(capture_handle, hw_params);
    snd_pcm_hw_params_set_access(capture_handle, hw_params, SND_PCM_ACCESS_RW_INTERLEAVED);
    snd_pcm_hw_params_set_format(capture_handle, hw_params, format);
    snd_pcm_hw_params_set_rate_near(capture_handle, hw_params, &sample_rate, 0);
    snd_pcm_hw_params_set_channels(capture_handle, hw_params, 1);
    snd_pcm_hw_params_set_buffer_time_near(capture_handle, hw_params, &buffer_time, 0);
    snd_pcm_hw_params_set_period_size_near(capture_handle, hw_params, &buffer_size, 0);
    if ((err = snd_pcm_hw_params(capture_handle, hw_params)) < 0) {
        fprintf(stderr, "Cannot set parameters (%s)\n", snd_strerror(err));
        exit(1);
    }
    snd_pcm_hw_params_free(hw_params);

    reverse_index_bits();
    short buf[N_SAMPLES];
    Complex result[N_SAMPLES];

    signal(SIGINT, sigint_handler);

    while (1) {
        if ((err = snd_pcm_readi(capture_handle, buf, N_SAMPLES)) != N_SAMPLES) {
            fprintf(stderr, "read from audio interface failed (%s)\n", snd_strerror(err));
        }

        apply_hann_window(buf);
        fft(result, buf);
        print_spectrum(result);
    }

    snd_pcm_close(capture_handle);
    dbus_connection_unref(connection);
    return 0;
}
