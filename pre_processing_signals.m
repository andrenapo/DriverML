function sig_filtrato = pre_processing_signals(sig_grezzi, record_name)
        % sig_grezzi è una struttura con i seguenti campi:
        % - ECG
        % - EMG
        % - footGSR
        % - handGSR
        % - marker
        % - RESP
        % Ognuno di questi campi
        % può essere pieno o vuoto a seconda del driveXX.dat considerato

    % Struttura per segnali filtrati
    sig_filtrato = struct();

    % Lista dei segnali presenti in sig_grezzi (es. {'ECG', 'EMG',
    % 'footGSR', ...})
    campi_segnali = fieldnames(sig_grezzi);

    % 2. FILTRAGGIO BASATO SUL PAPER
    for idx = 1:length(campi_segnali)   
        nome_campo = campi_segnali{idx}; % ad ogni ciclo, considera un segnale diverso, es. i = 3, per drive01 c'è footGSR

        % Estrazione dati dai segnali
        segnale_originale = sig_grezzi.(nome_campo).data;
        fs = sig_grezzi.(nome_campo).fs; % frequenza di campionamento
        t = sig_grezzi.(nome_campo).t; % vettore tempo

        segnale_filtrato = segnale_originale;

        % ('IgnoreCase', true) viene utilizzato nel contains per un motivo: di
        % base, se si cerca la parola 'ECG' e il canale si chiama 'ecg', la
        % funzione contains restituisce falso. Con 'IgnoreCase', true viene
        % ignorato il fatto che la parola cercata sia maiuscola o minuscola,
        % restituendo true in tutti
        % i casi in cui in nome_campo è presente la parola 'ECG'

        if contains(nome_campo, 'ECG', 'IgnoreCase', true)
            fprintf('> Filtraggio %s: FFT (Rimozione Baseline wander <= 0.5 Hz)\n', nome_campo);
            % capire come fare FFT
            [sos, g] = butter(2, [0.5 40]/(fs/2), 'bandpass');
            segnale_filtrato = filtfilt(sos, g, segnale_originale - mean(segnale_originale, 'omitnan'));

        elseif contains(nome_campo, 'GSR', 'IgnoreCase', true)
            fprintf('> Filtraggio %s, FFT (Rimozione componente continua DC a 0 Hz)\n', nome_campo);
            % capire come fare FFT 
            [sos, g] = butter(2, 1/(fs/2), 'low');
            segnale_filtrato = filtfilt(sos, g, segnale_originale - mean(segnale_originale, 'omitnan'));

        elseif contains(nome_campo, 'EMG', 'IgnoreCase', true)
            fprintf('> Filtraggio %s: Butterworth passa-banda (0.1-2 Hz)\n', nome_campo);
            [sos, g] = butter(2, [20 450]/(fs/2), 'bandpass');
            segnale_filtrato = filtfilt(sos, g, segnale_originale - mean(segnale_originale, 'omitnan'));

        elseif contains(nome_campo, 'RESP', 'IgnoreCase', true)
            fprintf('> Filtraggio %s: Butterworth passa-banda (0.1-2 Hz)\n', nome_campo);
            [sos, g] = butter(2, [0.1 2]/(fs/2), 'bandpass');
            segnale_filtrato = filtfilt(sos, g, segnale_originale - mean(segnale_originale, 'omitnan'));

        elseif contains(nome_campo, 'HR', 'IgnoreCase', true)
            fprintf('> Filtraggio %s: Media mobile\n', nome_campo);
            finestra_campioni = round(5 * fs);
            segnale_filtrato = movmean(segnale_originale, finestra_campioni);
        end

        % 3. SALVATAGGIO DATI
        sig_filtrato.(nome_campo).data = segnale_filtrato;
        sig_filtrato.(nome_campo).fs = fs;
        sig_filtrato.(nome_campo).t = t;
    end

    % 4. CREAZIONE CARTELLA DRIVE FILTRATI
    folder_name = 'record_filtrati';
    if ~exist(folder_name, 'dir')
        mkdir(folder_name);
        fprintf('> Cartella "%s" creata.\n', folder_name);
    end

    out_filename = fullfile(folder_name, sprintf('%s_filtrati.mat', record_name));
    save(out_filename, 'sig_filtrato');
    fprintf('\n=== Pre-processing completato! File salvato: %s ===\n', out_filename);
end