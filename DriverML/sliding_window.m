function [finestre, num_finestre] = sliding_window(ecg, fs)

    durata_finestra = 60;
    step_scorrimento = 60;

    punti_finestra = round(durata_finestra * fs);
    punti_step = round(step_scorrimento * fs);

    num_finestre = floor((length(ecg) - punti_finestra) / punti_step) + 1;
    finestre = cell(1, num_finestre);

    for i = 1:num_finestre
        idx_inizio = (i-1) * punti_step + 1;
        idx_fine = idx_inizio + punti_finestra - 1;
        finestre{i} = ecg(idx_inizio:idx_fine);
    end
end