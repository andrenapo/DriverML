% DriverML: pipeline completa
filename = 'features_dataset.mat';

if isfile(filename)
    load(filename,'X','Y');
    fprintf('Dataset caricato da %s\n',filename);
else

    % ================
    % RECORDS
    % ================
    records = {'drive05','drive06','drive07','drive08','drive09', ...
               'drive10','drive11','drive12','drive15','drive16'};
    dataset = cell(1, length(records));

    % ======================
    % INTERVALLI DI STRESS
    % ======================
    stress_start = containers.Map;
    stress_end = containers.Map;

    stress_start('drive05') = 16; stress_end('drive05') = 68;
    stress_start('drive06') = 17; stress_end('drive06') = 65;
    stress_start('drive07') = 17; stress_end('drive07') = 71;
    stress_start('drive08') = 16; stress_end('drive08') = 65;
    stress_start('drive09') = 17; stress_end('drive09') = 69;
    stress_start('drive10') = 18; stress_end('drive10') = 66;
    stress_start('drive11') = 17; stress_end('drive11') = 65;
    stress_start('drive12') = 21; stress_end('drive12') = 67;
    stress_start('drive15') = 16; stress_end('drive15') = 60;
    stress_start('drive16') = 16; stress_end('drive16') = 65;

    % ==================
    % PRE-ALLOCAZIONE
    % ==================
    MAX_WINDOWS = 2000;
    NUM_FEATURES = 20;

    X = zeros(MAX_WINDOWS, NUM_FEATURES);
    Y = categorical(strings(MAX_WINDOWS, 1));
    SubjectID = strings(MAX_WINDOWS, 1);
    contX = 1;

    DURATA_FINESTRA_SEC = 60;
    STEP_SCORRIMENTO = 60;

    % ==================
    % CICLO PRINCIPALE
    % ==================
    for i = 1:length(records)

        current_record = records{i};
        fprintf('\nElaborazione di %s...\n', current_record);

        try
            header_info = leggi_header(current_record);
            raw_signal_data = leggi_segnali(current_record, header_info);

            dataset{i}.header = header_info;
            dataset{i}.signals = raw_signal_data;

            fprintf('> Trovati %d sengnali.\n', header_info.num_signals);

            filtered_signal_data = pre_processing_signals(raw_signal_data, current_record);
            dataset{i}.filtered_signals = filtered_signal_data;

            % ==================
            % ELABORAZIONE ECG
            % ==================
            if isfield(filtered_signal_data, 'ECG')
                % ==================================
                % RILEVAMENTO PICCHI E CALCOLO HRV
                % ==================================
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

                % =========================================
                % ESTRAZIONE FEATURE A FINESTRE SCORREVOLI
                % =========================================
                [finestre, num_finestre] = sliding_window(ecg_sig_uV, fs_ecg);
                matrice_feature = zeros(num_finestre, NUM_FEATURES);
                fprintf('\nEstrazione delle %d feature da %d finestre temporali sul segnale ECG...\n', NUM_FEATURES, num_finestre);

                for f = 1:num_finestre
                    segmento_ecg = finestre{f};
                    featureECG = estrazioneFeatureECG(segmento_ecg);

                    riga_matrice = [
                        featureECG.Mean, ...
                        featureECG.Median, ...
                        featureECG.StdDev, ...
                        featureECG.Q1, ...
                        featureECG.Q2, ...
                        featureECG.Q3, ...
                        featureECG.IQR, ...
                        featureECG.Max, ...
                        featureECG.Min, ...
                        featureECG.Variance, ...
                        featureECG.Skewness, ...
                        featureECG.Kurtosis, ...
                        featureECG.RMS, ...
                        featureECG.Energy, ...
                        featureECG.Power, ...
                        featureECG.ApEn, ...
                        featureECG.Hurst, ...
                        featureECG.Nanmean, ...
                        featureECG.Trimmean, ...
                        featureECG.HarmonicMean];

                    matrice_feature(f, :) = riga_matrice;

                    % Assegnazione etichetta stress/no stress 
                    if f < stress_start(current_record)
                        Y(contX) = categorical("no stress");
                    elseif f <= stress_end(current_record)
                        Y(contX) = categorical("stress");
                    else
                        Y(contX) = categorical("no stress");
                    end

                    X(contX,:) = riga_matrice;
                    SubjectID(contX) = current_record;
                    contX = contX + 1;

                    if mod(f, 20) == 0
                        fprintf('  Finestra %d/%d completata\n', f, num_finestre);
                    end
                end

                fprintf('  %s completato: %d finestre estratte.\n', current_record, num_finestre);

                dataset{i}.features.matrice = matrice_feature;
                dataset{i}.features.nomi_feature = fieldnames(featureECG);

                % la struttura featureECG contiene i campi .mean, .median,
                % .variance, ecc.; lanciando fieldnames(featureECG), MATLAB
                % genera un cell array: {'mean','variance','energy',...}

            end

        catch ME
            fprintf('> ERRORE in %s: %s\n', current_record, ME.message);
        end
    end

end

disp('Elaborazione dataset completata')

% =============================
% ELIMINAZIONE RIGHE NON USATE
% =============================
X = X(1:contX-1, :);
Y = Y(1:contX-1);
SubjectID = SubjectID(1:contX-1);
fprintf('\nNumero totale di finestre estratte: %d\n', size(X,1));

% =============================
% SALVATAGGIO DEL DATASET
% =============================
save('features_dataset.mat', 'X', 'Y');
fprintf('Dataset salvato in features_dataset.mat\n');

Y = categorical(Y);

% =============================
% LOSO (Leave-One-Subject-Out)
% =============================
fprintf('\nAvvio valutazione LOSO...\n');
loso_evaluation(X, Y, SubjectID);