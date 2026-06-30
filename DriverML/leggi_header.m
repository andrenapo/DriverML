% === FUNZIONE leggi_header === %
% L'obiettivo
% della funzione è estrarre le informazioni essenziali (frequenza base,
% nomi dei segnali, campioni per frame e gain) leggendo il file testuale
% .hea. In questo contesto, ricordiamo che il file .hea ha la seguente
% struttura:
%
% drive01 6 15.5 61499
% drive01.dat 16x32  1000  16 0 -42   9084 0 ECG
% drive01.dat 16x128 10000 16 0 68   11155 0 EMG
% drive01.dat 16x2   1000  16 0 2503 -24751 0 foot GSR
% drive01.dat 16x2   1000  16 0 11149 20466 0 hand GSR
% drive01.dat 16     1/bpm 16 0 84   18582 0 HR
% drive01.dat 16     500   16 0 5474 -19336 0 RESP
%
% La prima riga descrive il record nel suo insieme:
% - drive01: il nome del record
% - 6: numero di segnali
% - 15.5: frequenza base in Hz per frame
% - 61499: numero totale di frame nel file
%
% Le righe successive, invece, descrivono ognu segnale con il seguente
% formato:
% 
% file / formato / campioni per frame / gain / risoluzione / baseline / primo valore / checksum / nome segnale 
%
% La colonna più rilevante per la comprensione della struttura binaria è
% campioni per frame. La tabella seguente riassume le caratteristiche di
% tutti i segnali di drive01 (ma cambia a seconda del .dat):
%
% | Segnale  | Campioni/frame | Frequenza effettiva  | Guadagno (ADU/unità) | Unità fisiologica |
% | ECG      | 32             | 15.5 × 32 = 496 Hz   | 1000                 | mV                |
% | EMG      | 128            | 15.5 × 128 = 1984 Hz | 10000                | mV                |
% | foot GSR | 2              | 15.5 × 2 = 31 Hz     | 1000                 | µs                |
% | hand GSR | 2              | 15.5 × 2 = 31 Hz     | 1000                 | µs                |
% | HR       | 1              | 15.5 Hz              | -                    | bpm               |
% | RESP     | 1              | 15.5 Hz              | 500                  | -                    |
%
% Campioni totali per frame in drive01: 32 + 128 + 2 + 2 + 1 + 1 = 166 campioni/frame
%
% Si nota che il formato 16xN indica che ci sono N campioni per frame. In altri casi,
% invece, se c'è solo 16, significica che c'è un solo campione per frame.

function header_info = leggi_header(record_name)
    filename = strcat(record_name, '.hea');
    fID = fopen(filename, 'r');
    if fID == -1
        error('File header %s non trovato', filename);
    end

    % Lettura prima riga del .hea (es: drive01 6 15.5 61499)
    first_line = fgetl(fID);
    info_parts = strsplit(first_line, ' ');

    header_info.record_name = info_parts{1};
    header_info.num_signals = str2double(info_parts{2});
    header_info.fs_base = str2double(info_parts{3});
    header_info.tot_frames = str2double(info_parts{4});

    % Inizializzazione array per i dati dei segnali
    header_info.signals = struct('name', {}, 'campioni_per_frame', {}, 'gain', {});

    % Lettura delle righe dei segnali
    for i = 1:header_info.num_signals
        line = fgetl(fID);
        parts = strsplit(strtrim(line), '\t');
        if length(parts) == 1
            parts = strsplit(strtrim(line), ' ');
            parts = parts(~cellfun('isempty', parts)); % rimozione stringhe vuote
        end 

        % Estrazione campioni per frame (colonna 2)
        format_str = parts{2};
        if contains(format_str, 'x')
            format_parts = strsplit(format_str, 'x');
            campioni = str2double(format_parts{2}); % formato 16xN
        else 
            campioni = 1; % se c'è solo 16, il campione è 1
        end

        % Estrazione gain (colonna 3) e gestione unità di misura
        gain_str = parts{3};
        % A volte, il gain include
        % l'unità di misura come 1000/mV, prendiamo solo il numero
        if contains(gain_str, '/')
            gain_parts = strsplit(gain_str, '/');
            gain = str2double(gain_parts{1});
        else
            gain = str2double(gain_str);
        end

        % Se gain non è un numero valido (es. assente o calcolato in modo speciale come per HR e RESP di drive01)
        if isnan(gain)
            gain = 1;
        end

        % Estrazione nome del
        % segnale: il nome del segnale è riportato alla fine
        name = strjoin(parts(9:end), ' ');

        % Salvataggio dei dati della struttura
        header_info.signals(i).name = name; % es. header_info.signals(1).name = 'ECG'
        header_info.signals(i).campioni_per_frame = campioni;  
        header_info.signals(i).gain = gain;
    end
   fclose(fID);
end