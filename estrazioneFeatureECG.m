function features = estrazioneFeatureECG(ecg_window, fs)

    features = struct();

    if isempty(ecg_window) || length(ecg_window) < 10
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
    features.ApEn = '';
    features.Hurst = '';

    features.Nanmean = '';
    features.Trimmean = '';
    features.HarmonicMean = '';

    % guardate se va fatta anche la moda

end