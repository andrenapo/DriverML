function features = estrazioneFeatureECG(ecg_window)

    features = struct();

    if isempty(ecg_window) || length(ecg_window) < 10
        fprintf('ATTENZIONE: Finestra ECG non valida (length = %d). Restituisco struct vuota!\n', length(ecg_window));
        return
    end

    ecg_window = ecg_window(:)';
    N = length(ecg_window);

    % QUINDICI FEATURES LINEARI NEL DOMINIO DELLE TEMPO

    features.Mean = mean(ecg_window);
    features.Median = median(ecg_window);
    features.StdDev = std(ecg_window);

    features.Q1 = prctile(ecg_window, 25);
    features.Q2 = prctile(ecg_window, 50); % coincide alla mediana
    features.Q3 = prctile(ecg_window, 75);
    features.IQR = iqr(ecg_window);

    features.Max = max(ecg_window);
    features.Min = min(ecg_window);
    features.Variance = var(ecg_window);

    features.Skewness = skewness(ecg_window);
    features.Kurtosis = kurtosis(ecg_window);

    features.RMS = rms(ecg_window);
    features.Energy = sum(ecg_window.^2);
    features.Power = features.Energy / N; % formula per la potenza media di un segnale discreto nel tempo, ovvero energia / N

    % CINQUE FEATURE NEL DOMINIO DEL FREQUENZE

    % ===================================
    % MIGLIORAMENTO CALCOLI ApEn e Hurst
    % ===================================
    % ApEn (Approximate Entropy)
    % ha complessità O(N^2). Con N = 29760
    % campioni (60 s a 469 Hz), il calcolo richiederebbe circa 885 milioni
    % di operazioni per finestra.
    %
    % Per ridurre le tempistiche, decimiamo il segnale di un fattore 4 (da
    % 496 Hz a circa 124 Hz) solo per ApEn e Hurst. Il trend di complessità
    % del segnale non cambia,
    % ma il calcolo diventa circa 16 volte più veloce
    ecg_decimato = ecg_window(1:4:end);
    
    features.ApEn = approximateEntropy(ecg_decimato);
    features.Hurst = hurst(ecg_decimato);

    features.Nanmean = mean(ecg_window, 'omitnan');
    features.Trimmean = trimmean(ecg_window, 12);
    features.HarmonicMean = harmmean(abs(ecg_window));

end