function RR_intervalli = calcolo_hrv(tempi_R)

    if length(tempi_R) < 2
        error('Impossibile calcolare l''HRV: sono necessari almeno 2 picchi R validi')
    end

    RR_secondi = diff(tempi_R); % distanza in secondi tra picchi R consecutivi
    RR_intervalli_grezzi = RR_secondi * 1000; 
    
    % Filtraggio degli outlier fisiologici
    % Nonostante la validazione geometrica dei picchi abbia rimosso i falsi
    % picchi, possono verificarsi anomalie residue. Applichiamo un filtro
    % di validazione degli intervalli RR basato sulla fisiologia umana
    % nell'intervallo [300 ms, 1500 ms]:
    % - sotto i 300 ms (oltre a 200 BPM): clinicamente impossibile per un guidatore seduto. Ciò significa che
    %   è un falso positivo (rumore scambiato come picco R)
    % - sopra i 1500 ms (meno di 40 BPM): clinicamente impossibile per un guidatore sveglio. Significa che
    %   l'algoritmo ha saltato un picco R reale, raddoppiando artificialmente la distanza (falso negativo)
    %
    % Tutto ciò è ricavato dalla frequenza cardiaca istantanea:
    % BPM = 60000 / RR [ms]
    RR_validi = RR_intervalli_grezzi(RR_intervalli_grezzi >= 300 & RR_intervalli_grezzi <= 1500);

    RR_intervalli = RR_validi;

end