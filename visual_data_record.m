records = {'drive01'};

dataset = cell(1,length(records)); % cell array vuoto 

for i = 1:length(records)
    current_record = records{i};
    fprintf('Elaborazione di %s...\n', current_record);
    
    try
        header_info = leggi_header(current_record);
        raw_signal_data = leggi_segnali(current_record, header_info);
        
        dataset{i}.header = header_info;
        dataset{i}.signals = raw_signal_data;

        % raw_signal_data è una struttura con i seguenti campi:
        % - ECG
        % - EMG
        % - footGSR
        % - handGSR
        % - marker
        % - RESP
        % Ognuno di questi campi
        % può essere pieno o vuoto a seconda del driveXX.dat considerato
        
        fprintf('> Trovati %d segnali. \n', header_info.num_signals);

        filtered_signal_data = pre_processing_signals(raw_signal_data, current_record);
        dataset{i}.filtered_signals = filtered_signal_data;

        % ELABORAZIONE ECG: RILEVAMENTO PICCHI E CALCOLO HRV
        if isfield(filtered_signal_data, 'ECG')
            ecg_sig_mV = filtered_signal_data.ECG.data;
            fs_ecg = filtered_signal_data.ECG.fs;
            t_ecg = filtered_signal_data.ECG.t;

            % Dal momento che leggi_header ci dice che l'ECG è espresso in
            % mV, e il paper richiede soglie rigorose in Microvolt (200 uV
            % e 3000 uV), convertiamo il segnale ECG moltiplicandolo per
            % 1000 (1 mV = 1000 uV)

            ecg_sig_uV = ecg_sig_mV * 1000;

            [indici_R, tempi_R] = findRpeaks(ecg_sig_uV, fs_ecg, t_ecg);
            RR_intervalli = calcolo_hrv(tempi_R);

            dataset{i}.hrv.indici_R = indici_R;
            dataset{i}.hrv.tempi_R = tempi_R;
            dataset{i}.hrv.RR_intervalli = RR_intervalli;

            plotting_ecg_picchi(filtered_signal_data, dataset{i}.hrv, current_record);

            % ESTRAZIONE FEATURE A FINESTRE SCORREVOLI (vi spiegherò, per ora date per buono che sia vero)
            durata_finestra = 60; % secondi
            step_scorrimento = 30; % secondi

            punti_finestra = durata_finestra * fs_ecg;
            punti_step = step_scorrimento * fs_ecg;
            
            lunghezza_segnale = length(ecg_sig_uV);
            num_finestre = floor((lunghezza_segnale - punti_finestra) / punti_step) + 1;

            matrice_feature = [];
            fprintf('Estrazione delle 20 features da %d finestre temporali sul segnale ECG...\n', num_finestre);
            for f = 1:num_finestre
                idx_inizio = (f-1) * punti_step + 1;
                idx_fine = idx_inizio + punti_finestra - 1;

                segmento_ecg = ecg_sig_uV(idx_inizio : idx_fine);
                featureECG = estrazioneFeatureECG(segmento_ecg, fs_ecg);
                riga_matrice = strct2array(featureECG);
                matrice_feature = [matrice_feature; riga_matrice];
            end

            dataset{i}.features.matrice = matrice_feature;
            dataset{i}.features.nomi_feature = fieldnames(featureECG);

            % la struttura featureECG contiene i campi .Mean, .Median,
            % .StdDev, ecc...; lanciando fieldnames(featureECG), MATLAB
            % genera un cell array così composto:
            % {'Mean','Median','StdDev',...,'HarmonicMean'}

        end

        % plotting_segnali(raw_signal_data, [current_record ' - GREZZO']);
        % plotting_segnali(filtered_signal_data, [current_record ' - FILTRATO']);
        
    catch ME
        fprintf('> ERRORE in %s: %s\n', current_record, ME.message);
    end
end

disp('Elaborazione dataset completata')