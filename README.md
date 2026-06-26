# DriverML
Progetto HML: creazione di un modello machine learning per la classificazione del livello di stress di un guidatore

## Paper di riferimento
- ***DriverML*** contiene le *specifiche generali* per lo sviluppo del modello;
- ***Automatic stress detection in car drivers*** contiene le *specifiche di riferimento numerico* al quale i nostri valori devono avvicinarsi dopo la classificazione. 

Per le ***feature aggiuntive*** al paper DriverML, ci basiamo sulle *feature che vengono calcolate nel secondo paper*.

## Come creare il progetto su MATLAB
All'interno della repository troverete:
1. `visual_data_record.m`: main del progetto, da cui vengono chiamati tutti i filtri e le funzioni di estrazione delle feature
2. tutte gli altri `.m`: funzioni a supporto del progetto, utili per l'analisi dei segnali e l'estrazione delle feature

Si noti come il dataset ***non*** è caricato in quanto è troppo grade. All'interno del progetto MATLAB che creerete, oltre ad aggiungere i file `.m`, aggiungete la cartella contenente tutti i driveXX.
