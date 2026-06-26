% Funzione che restituisce una struttura (oggetto struct) contenente i
% segnali fisiologici grezzi con relativi parametri.
% raw_data_struct (Variabile Principale di Output)
% │
% ├─── ECG (Sotto-struttura per il segnale ECG)
% │     ├──.data  ──> [Vettore Colonna/Riga] (Tutti i campioni convertiti dell'ECG)
% │     ├──.t     ──> [Vettore Colonna/Riga] (Asse dei tempi specifico per l'ECG)
% │     └──.fs    ──> Scalare (Frequenza di campionamento dell'ECG)
% │
% ├─── EMG (Sotto-struttura per il segnale EMG)
% │     ├──.data  ──> [Vettore Colonna/Riga] (Tutti i campioni convertiti dell'EMG)
% │     ├──.t     ──> [Vettore Colonna/Riga] (Asse dei tempi specifico per l'EMG)
% │     └──.fs    ──> Scalar (Frequenza di campionamento dell'EMG)
% │
% ├─── footGSR (Sotto-struttura per il GSR del piede)
% │     ├──.data  ──> [Vettore Colonna/Riga] (Campioni del footGSR)
% │     ├──.t     ──> [Vettore Colonna/Riga] (Asse dei tempi del footGSR)
% │     └──.fs    ──> Scalar (Frequenza di campionamento del footGSR)
% │
% └─── RESP (Sotto-struttura per la Respirazione)
% ├──.data  ──> [Vettore Colonna/Riga] (Campioni della respirazione)
% ├──.t     ──> [Vettore Colonna/Riga] (Asse dei tempi della respirazione)
% └──.fs    ──> Scalar (Frequenza di campionamento di RESP, es: 500 Hz)

function raw_data_struct = leggi_segnali(record_name, header_info)
    % Calcolo del totale dei campioni per frame
    total_camp_per_frame = sum([header_info.signals.campioni_per_frame]);

    % Apertura file .dat
    filename = strcat(record_name, '.dat');
    fID = fopen(filename,'rb');
    if fID == -1
        error('File %s .dat non trovato', filename);
    end

    % Lettura dei dati da driveXX.dat
    data = fread(fID, [total_camp_per_frame, Inf], 'int16');
    fclose(fID);

    % Estrazione e conversione dinamica dei segnali fisiologici
    raw_data_struct = struct();
    current_row = 1;

    for i = 1:header_info.num_signals
        signal = header_info.signals(i); % header_info.signals(1) è associato all'ECG, (2) all'EMG e così via
        N = signal.campioni_per_frame; % N = 32

        % Identificazione righe della matrice relative al segnale i
        end_row = current_row + N - 1;
        signal_matrice = data(current_row:end_row, :);

        % Convesione del segnale
        fs_effettiva = header_info.fs_base * N;
        signal_vettore = signal_matrice(:);
        signal_conv = signal_vettore / signal.gain; % ad i = 1, signal_conv contiene il segnale ECG corretto

        % Creazione asse temporale
        t_signal = (0:length(signal_conv)-1) / fs_effettiva;

        % Salvataggio dati nella struttura
        signal_name = matlab.lang.makeValidName(signal.name); % diventa automaticamente il nome di un segnale come, ad esempio, ECG, footGSR, ecc.
        raw_data_struct.(signal_name).data = signal_conv; % es. data_stuct.ECG.data = signal_conv
        raw_data_struct.(signal_name).t = t_signal;
        raw_data_struct.(signal_name).fs = fs_effettiva;

        % Aggiornamento indice riga per il prossimo segnale
        current_row = end_row + 1;
    end
end