% INDIVIDUAZIONE PICCHI R NEL SEGNALE ECG
% I segnali fisiologici sono indicatori robusti dello stato interno
% dell'utente perché governati dal Sistema Nervoso Autonomo:
%   1. Il sistema nervoso simpatico si attiva in condizioni di stress, ansia
%      o sforzo cognitivo, aumentando la frequenza cardiaca e rendendo il ritmo
%      più regolare (bassa HRV)
%   2. Il Sistema parasimpatico domina in condizioni di riposo o, nel
%      nostro caso, durante gli stati di ipovigilanza (stato di attenzione costante), 
%      sonnolenza e fatica, rallentando il cuore e modulando fortemente il ritmo 
%      battito per battito (HRV)
% 
% Per estrarre l'HRV
% non è necessario conoscere l'intera morfologia dell'ECG, ma ci interessa
% conoscere le esatte coordinate temporali di ogni picco R
% (depolarizzazione dei ventricoli). La distanza tra due picchi R
% successivi è l'intervallo R-R

% Questa funzione implementa la logica di ricostruzione e filtraggio
% destritta dal paper: elimina i picchi illusori, causati dai movimenti del
% sedile (artefatti da movimento > 3000\muV) e analizza la pendenza (slope)
% dei rami QR e RS per confermare la presenza di un vero complesso QRS

% Identifica i picchi R reali dal segnale ECG filtrato
% INPUT:
% - ecg_filtrato: vettore del segnale ECG pre-analizzato
% - fs: frequenza di campionamento (Hz)
% - t: vettore tempo associato al segnale (s)
%
% OUTPUT
% - indici_R: vettore contenente gli indici dei picchi R validi
% - tempi_R: coordinate temporali (s) dei picchi R validi

function [indici_R, tempi_R] = findRpeaks(ecg_filtrato, fs, t)

    % 1. IMPOSTAZIONE SOGLIE DA PAPER PER RIMOZIONE RUMORI
    % il paper specifica che gli artefatti di movimento > 3000\muV creano
    % picchi R falsi.
    SOGLIA_ARTEFATTI = 3000; % i picchi oltre i 3000 uV sono falsi (artefatti di movimento)
    SOGLIA_QRS_BASE = 200; % soglia a 200 uV  richiesta per identificare QRS

    % distanza minima tra due battiti (distanza picchi)
    % Un battito cardiaco umano massimo (es. sotto sforzo/stress) raggiunge i
    % 180-200 BPM. Quindi, i secondi tra un battito e l'altro sono: 60 / 200
    % BPM = 0.3 s
    distanza_minima = 0.3; 

    % 2. RILEVAMENTO PICCHI
    % candidati picchi R: esclude rumore < 200uS e doppi conteggi (distanza min. 0.3 s)
    [pks_R, locs] = findpeaks(ecg_filtrato, fs, 'MinPeakHeight', SOGLIA_QRS_BASE, 'MinPeakDistance', distanza_minima);

    indici_R = []; % vettore contenente gli indici interi dei picchi R validi all'interno dell'ECG
    tempi_R = []; % vettore contenente i tempi in secondi dei picchi R all'interno dell'ECG

    % 3. ALGORITMO RICOTRUZIONE E VALIDAZIONE PICCHI R
    % Il paper richiede di verificare la pendenza (slope) prima e dopo il picco
    % a 200 uV per confermare la forma geometrica del QRS
    % 
    % "The Q and S points that are situated before and after R is captured based 
    % on slope of QR and slope of RS at 200 µV to identify the QRS of the entire
    % ECG data"

    for i = 1:length(pks_R)
        picco_attuale = pks_R(i);
        tempo_attuale = locs(i); % tempo in secondi

        % La funzione findpeaks, avendo ricevuto la frequenza fs come
        % input, restituisce la posizione del picco espressa in secondi (es. 1.2 s).
        % MATLAB non può accedere agli elenti di un vettore (quello dei
        % picchi) usando i secondi: richiede indici interi positivi
        % 1) tempo_attuale * fs: moltiplica il tempo per il numero di
        % campioni al secondo. Se il
        % picco è a 1.2 s e lo strumento registra a 500 Hz, significa che
        % fino a quel momento sono passati 1.2 * 500 = 602 campioni. 
        % 2) round(...): arrotonda
        % il risultato al numero intero più vicino
        % 3) + 1: a differenza di altri linguaggi, in MATLAB il primo
        % campione del segnale (al secondo 0) occupa la posizione 1
        %
        % idx_picco rappresenta l'indice esatto del picco R all'interno del
        % segnale. Grazie a questo, possiamo verificare la pendenza del
        % segnale prima e dopo il picco come richiesto dal paper
        idx_picco = round(tempo_attuale * fs) + 1;

        % Il complesso QRS è un
        % evento fisiologico molto rapido. Per calcolare la pendenza
        % (slope) della salita (QR) e della discesa (RS), dobbiamo isolare
        % solo pochi millisecondi immediatamente prima e dopo idx_picco
        % 
        % Il paper richiede un'analisi stretta: esprimiamo 40 ms in s
        % 40 ms = 40 / 1000 = 0.04 s 
        % Moltiplicando 0.04 per la frequenza fs (es. 0.04 * 500 Hz = 20 campioni) 
        % otteniamo il numero il numero di campioni da osservare a destra (20 campioni) e
        % a sinistra (20 campioni) del picco R
        %
        semi_ampiezza_QRS = round(0.04 * fs);

        % Prima di estrarre le parti QR e RS, dobbiamo assicurarci che ci
        % sia abbastanza spazio nel vettore sia a sinistra sia a destra di
        % idx_picco. Se un picco si trova troppo vicino all'inizio o alla
        % fine della registrazione, l'estrazione fallirebbe.
        % - idx_picco - semi_ampiezza_QRS < 1: verifica se andando a sx di
        % 40 ms
        % usciamo dall'indice minimo (1)
        % - idx_picco + semi_ampiezza_QRS > length(ecg_filtrato): veridica se
        % andando a destra di 40 ms superiamo la lunghezza massima del
        % segnale
        %
        % Ogni picco R, con il suo relativo complesso QRS, deve essere
        % obbligatoriamente dentro il segnale ECG di riferimento: ne < 1
        % (indice del primo picco possibile con relativo QR e RS è 1) ne >
        % length(ecg_filtrato) (ogni picco R e relativi QR e RS devono essere dentro il segnale ECG)
        if idx_picco - semi_ampiezza_QRS < 1 || idx_picco + semi_ampiezza_QRS > length(ecg_filtrato)
            continue;
        end

        % Estrazione segmenti QR e RS
        % Usando la semi-ampiezza appena calcolata, separiamo i due lati
        % del complesso QRS a partire da R:
        % - lato_QR: va da 40 ms prima del picco fino alla punta del picco.
        % Questo ci permette di individuare la rampa di salita del
        % complesso QRS, ovvero QR (ci si aspetta sia positiva)
        % - lato_RS: va dalla punta del picco fino a 40 ms dopo il picco.
        % Questo ci permette di individuare la rampa di discesa del
        % complesso QRS, ovvero RS (ci si aspetta sia negativa)
        lato_QR = ecg_filtrato(idx_picco - semi_ampiezza_QRS : idx_picco); % insieme dei campioni su QR
        lato_RS = ecg_filtrato(idx_picco : idx_picco + semi_ampiezza_QRS); % insieme dei campioni su RS

        % Calcola la pendenza (slope)
        % Dato che la distanza tra un campione e il successivo è fissa e
        % costante (1/fs), per calcolare la pendenza massima lungo un
        % segmento ci basta calcolare la differenza punto a punto tra i
        % valori di ampiezza del segnale. L'operazione di differenza tra
        % elementi consecutivi di un vettore viene calcolata tramite la
        % funzione diff(vettore).
        %
        % Questa calcola la differenza tra elementi adiacenti [vettore(2) - vettore(1), vettore (3) - vettore(2), ...]
        % - per lato_QR: cerchiamo la massima pendenza positiva (salita più rapida)
        % - per lato_RS: cerchiamo la minima pendenza negativa (discesa più rapida)
        slope_QR = max(diff(lato_QR)); % valore positivo (pendenza QR)
        slope_RS = min(diff(lato_RS)); % valore negativo (pendenza RS)

        % Regola 1 paper: escludiamo i picchi illusori oltre i 3000 uV
        if picco_attuale > SOGLIA_ARTEFATTI
            continue;
        end

        % Regola 2 paper: validazione geometrica dei picchi
        % Per confermare che idx_picco sia un vero picco R del complesso QRS,
        % verifichiamo che rispetti contemporaneamente due vincoli:
        % 1) slope_QR > 0: la rampa precedente al picco R deve essere in
        % salita. Se il segnale fosse piatto o in discesa (es. artefatto o
        % altro), il controllo fallisce
        % 2) slope_RS < 0: la rampa successiva al picco R deve essere in
        % discesa. Se il segnale continuasse a salire (es. deriva lenta
        % della baseline che non è stata corretta dal filtro) il controllo
        % fallisce
        
        if slope_QR > 0 && slope_RS < 0
            % In MATLAB, scrivendo [vettore; nuovo_elemento] indichiamo al software
            % di mantenere intatto tutto il contenuto precedentemente salvato 
            % ('indici_R' e 'tempi_R') e di appendere in coda (andando a capo tramite 
            % il punto e virgola ';') il valore del picco corrente.
            %
            % Se scrivessimo solo '[idx_picco]', il vettore verrebbe sovrascritto
            % ad ogni ciclo, lasciandoci alla fine solo l'ultimo picco rilevato.
            indici_R = [indici_R; idx_picco]; 
            tempi_R = [tempi_R; tempo_attuale];
        end
    end

    fprintf('\nRilevamento completato: %d picchi R validi su %d candidati.\n', length(indici_R), length(pks_R))

end
