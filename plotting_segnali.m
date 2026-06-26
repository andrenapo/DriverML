function plotting_segnali(signal_data, record_name)
    nomi_segnali = fieldnames(signal_data);
    num_segnali = length(nomi_segnali);

    figure('Name', ['Analisi multiparametrica - ' record_name], 'NumberTitle', 'off');

    colonne = 2;
    righe = ceil(num_segnali / colonne);
    colori = {'b', 'g', 'r', 'c', 'm', 'k', 'b', 'g', 'r', 'c'};

    for i = 1:num_segnali
        nome_corrente = nomi_segnali{i};
        segnale_info = signal_data.(nome_corrente);

        subplot(righe, colonne, i);
        idx_colore = mod(i-1, length(colori)) + 1;
        plot(segnale_info.t, segnale_info.data, 'Color', colori{idx_colore}, 'LineWidth', 1.2);
        title(sprintf('%s (%.1f Hz)', nome_corrente, segnale_info.fs), 'Interpreter', 'none');
        xlabel('Tempo (s)'); ylabel('Ampiezza (u.f.)'); % unità fisica generica (tipo per bpm o L)
        xlim([0 30]); grid on;
    end
end