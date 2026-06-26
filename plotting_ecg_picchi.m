function plotting_ecg_picchi(filtered_signal_data, hrv_data, record_name)
% PLOTTING_ECG_PICCHI Mostra l'ECG filtrato e sovrappone i picchi R validati dall'algoritmo
%
% INPUT:
%   - filtered_signal_data : La struttura dei segnali filtrati del record corrente
%   - hrv_data             : La sotto-struttura hrv (contenente indici_R e tempi_R)
%   - record_name          : Stringa con il nome del record (es. 'drive01') per il titolo

% Verifichiamo che il segnale ECG esista nella struttura passata
if ~isfield(filtered_signal_data, 'ECG')
    warning('Segnale ECG non trovato per il record %s. Impossibile fare il plot.', record_name);
    return;
end

% Estrazione dei vettori principali dell'ECG filtrato
ecg_data = filtered_signal_data.ECG.data; % Ampiezze [uV]
t_ecg    = filtered_signal_data.ECG.t;    % Asse dei tempi [s]

% Estrazione delle coordinate dei picchi validati
tempi_picchi   = hrv_data.tempi_R;   % Coordinate X dei picchi (in secondi)
indici_picchi  = hrv_data.indici_R;  % Indici dei campioni per estrarre le ampiezze

% Calcoliamo le ampiezze dei picchi (Coordinate Y) prendendo i valori del 
% segnale ECG filtrato esattamente nei punti indicati da indici_R
ampiezze_picchi = ecg_data(indici_picchi);

% =========================================================================
% CREAZIONE E CONFIGURAZIONE DELLA FIGURA
% =========================================================================
figure('Name', ['Validazione Picchi R - ' record_name], 'NumberTitle', 'off');

% 1. Plot del segnale ECG continuo (linea blu sottile)
plot(t_ecg, ecg_data, 'b-', 'LineWidth', 1.0); 
hold on; % Mantiene il grafico attivo per poter sovrapporre i picchi senza cancellare la linea

% 2. Plot dei picchi R validati (Marker a forma di cerchio rosso 'ro')
% - 'MarkerSize', 8 : rende il pallino ben visibile
% - 'LineWidth', 2  : ispessisce il bordo del cerchietto
plot(tempi_picchi, ampiezze_picchi, 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'r');

% =========================================================================
% ABBELLIMENTO E LIMITI DEL GRAFICO (ZOOM SUI PRIMI 30 SECONDI)
% =========================================================================
% Come nella tua funzione precedente, facciamo uno zoom sui primi 30 secondi 
% per poter apprezzare visivamente la forma d'onda del complesso QRS.
xlim([0 30]); 

title(sprintf('Rilevamento Geometrico Picchi R - %s', record_name), 'Interpreter', 'none');
xlabel('Tempo (secondi)');
ylabel('Ampiezza (\muV)');

% Aggiungiamo una legenda chiara per distinguere il segnale dai marker
legend('ECG Filtrato (0.5 - 49 Hz)', 'Picchi R Validati', 'Location', 'northeast');

grid on; % Attiva la griglia di sfondo per facilitare la lettura dei tempi
hold off; % Rilascia la figura
end