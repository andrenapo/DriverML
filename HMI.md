# Interfacce uomo macchina

---

## Lezione 5

---

# Capitolo 4 — Esercitazione: Campionamento e Quantizzazione

---

## Introduzione al capitolo

I capitoli precedenti hanno costruito la teoria completa della conversione analogico digitale: la definizione di segnale, la classificazione analogico/digitale, il campionamento con relativo teorema di Nyquist-Shannon, il fenomeno dell'aliasing, la quantizzazione e la codifica binaria. Questo capitolo consolida questi concetti attraverso tre esercizi applicativi.

Gli esercizi 2 e 3 affrontano il ***campionamento***:
- l'*esercizio 2* mostra — tramite un segnale audio e codice MATHLAB — cosa accade quando si usa una frequenza di campionamento errata in fase di riproduzione: il risultato è una distorsione simultanea della velocità e del tono del suono, la cui natura si comprende direttamente in termini di campioni per unità di tempo

- l'*esercizio 3* introduce il ***segnale chirp*** — un segnale la cui frequenza varia linearmente nel tempo — come strumento per osservare l'aliasing sia visicamente (nel grafico della forma d'onda) sia uditivamente: nella parte iniziale del chirp la frequenza è bassa e il campionamento è sufficiente; nella parte finale supera il limite di Nyquist e l'aliasing si manifesta come un'inversione sonora

L'esercizio 4 affronta la ***quantizzazione*** in modo sistematico: a partire da un segnale sinusoidale con parametri fissi, si calcolano i parametri del quantizzatore per due risoluzioni diverse (2 e 4 bit), si implementa la quantizzazione uniforme (una quantizzazione ammissibile) si analizza l'errore tramire il ***Mean Squared Error*** (*MSE*) e si risponde alla domanda fondamentale — *"di quanti decibel (dB) migliora il rapporto segnale-rumore se si aggiunge un solo bit?"* — introducendo i concetti di decibel e di SQNR.

---

## 4.1 *Esercizio 2 — campionamento audio: l'effetto della frequenza di campionamento errata*

### 4.1.1 Contesto e motivazione

Un file audio digitale non è altro che una sequenza ordinata di numeri: i campioni del segnale sonoro, prelevati a intervalli regolari durante la registrazione. La ***frequenza di campionamento*** `f_s` usata durante la registrazione stabilisce quanti di questi unmeri corrispondono a un secondo di suono reale. Il software di riproduzione, però, non "sente" il suono: si limita a estrarre i numeri dalla lista e a trasmetterli al convertitore digitale-analogico (DAC) alla velocità di f_s campioni al secondo.

Questo porta ad una conseguenza immediata: se si dice al software di riprodurre i campioni ad una frequenza diversa da quella di registrazione, il suono risulterà distorto. La situazione è analoga a quella di un film proiettato alla velocità sbagliata: se il proiettore gira troppo velocemente, la scena accelera e le voci diventano acute; se gira troopo lentamente, tutto rallenta e le voci si abbassano.

Questo esercizio esplora numericamente questo fenomeno attraverso un segnale sinusoidale di riferimento — la nota La (A4) a $440\ \text{Hz}$ — e tre modalità di riproduzione.

### 4.1.2 Parametri dell'esercizio

| Parametro | Simbolo | Valore | Note |
|-----------|---------|--------|------|
| Frequenza di campionamento (standard CD) | $f_s$ | $44100\ \text{Hz}$ | Con $f_{max} = 20.000$, ovvero la frequenza massima udibile dall'orecchio umano, abbiamo che $f_s \geq f_{max}$ e quindi è soddisfatto il teorema di Nyquist-Shannon: non c'è aliasing |
| Durata del segnale | $d$ | $2\ \text{s}$ | — |
| Frequenza della nota La (A4) | $f_{nota}$ | $440\ \text{Hz}$ | Frequenza di riferimento internazionale |
| Ampiezza | $A$ | $0,8$ | — |

### 4.1.3 Codice MATLAB e il suo significato

Il codice genera il segnale e lo riproduce in tre modalità diverse.

---

#### Generazione del segnale

```matlab
f_s = 44100;                        
% Frequenza di campionamento (Hz) — standard audio CD

durata = 2;                         
% Durata del segnale (secondi)

t_camp = 0:1/f_s:durata;            
% Vettore dei tempi DISCRETI (istanti di campionamento)
% Passo temporale Ts = 1/f_s

f_nota = 440;                       
% Frequenza della sinusoide (Hz) — nota La (A4)

A = 0.8;                            
% Ampiezza di picco del segnale

x_camp = A*sin(2*pi*f_nota*t_camp);    
% Segnale sinusoidale campionato

figure, plot(t_camp(1:1000), x_signal(1:1000));  
% Grafico del segnale campionato nei primi 1000 campioni
```

> ***Vettore `t_camp`.***
> ```matlab
> t_camp = 0:1/f_s:durata;       
> ```
> Questo rappresenta il vettore degli istanti di campionamento, con passo di campionamento $T_s = \frac{1}{f_s} = \frac{1}{44100} \approx 22,7 \mu\text{s}$. Questo non è un tempo continuo, ma una griglia temporale campionata.

> ***Segnale campionato `x_camp`.***
> ```matlab
> x_camp = A*sin(2*pi*f_nota*t_camp);    
> ```
> Questo rappresenta il segnale sinusoidale campionato della nota: è ottenuto valutando la sinusoide solo negli istanti t_camp, quindi è un segnale discreto (non analogico).

> ***Rappresentazione del segnale***
> ```matlab
> figure, plot(t_camp(1:1000), x_signal(1:1000));  
> ```
> Questo rappresenta il grafico del segnale campionato. Con `plot` matlab unisce i punti con linee, dando l'illusione di un segnale continuo, ma in realtà sono solo campioni discreti.  
> 
> Si tratta, quindi, di una rappresentazione approssimata (discreta) del segnale analogico originale e, quindi, di come dovrebbe essere, ottenuta tramite campionamento. I campioni permettono di approssimare e, se rispettata la condizione di Nyquist, di ricostruire il segnale continuo. Ci da, quindi, l'idea di come dovrebbe essere il segnale analogico originale.

--- 

#### Modalità di riproduzione del segnale

```matlab
% Riproduzione 1: frequenza corretta
sound(x_camp, f_s);        % DAC legge 44100 campioni/s → suono originale
pause(2);

% Riproduzione 2: frequenza doppia (effetto accelerato)
sound(x_camp, f_s * 2);    % DAC legge 88200 campioni/s → consuma i dati al doppio
pause(2);

% Riproduzione 3: frequenza dimezzata (effetto rallentato)
sound(x_camp, f_s / 2);    % DAC legge 22050 campioni/s → consuma i dati alla metà
```

La funzione `sound(x_camp, f_s)` invia il vettore `x_camp` (il segnale campionato, contenente $N = f_s\cdot T = 44100\cdot 2 = 88200$ campioni) al DAC alla velocità di `f_s` campioni al secondo. Il vettore `x_camp` è sempre identico, cambia solo la velocità con cui i campioni del segnale vengono consumati (riprodotti).

---

### 4.1.4 Playback di un segnale campionato

Quando un segnale digitale viene riprodotto tramite un sistema audio, i campioni memorizzati in un vettore vengono letti da un convertitore digitale-analogico (DAC) a una certa velocità. Quando in matlab si scrive:
```matlab
sound(x_camp, fs)
```
con
- `x_camp` il vettore dei campioni del segnale (segnale campionato)
- $f_s$ la frequenza di playback (di riproduzione), in Hz

il significato è il seguente: il DAC interpreta il vettore `x_camp` come una sequenza di campioni acquisiti a $f_s$ campioni al secondo.

---

#### *Numero di campioni e durata del segnale*

Se un segnale è campionato con frequenza $f_s$ e ha durata $T$, il numero totale di campioni è:
$$N = f_s\cdot T$$
dove:
- $N$ è il numero di campioni del segnale
- $f_s$ è la frequenza di campionamento
- $T$ è la durata del segnale in secondi

> ***Esempio.*** Nel caso di $f_s = 44100\ \text{Hz}$ e $T = 2\ \text{s}$, abbiamo:
> $$N = 44100\cdot 2 = 88200\ \text{Hz}$$
> Il vettore `x_camp` contiene ***$88200$ campioni***.

#### *Cosa significa `sound(x_camp, fs)`*
Quando si scrive:
```matlab
sound(x_camp, fs)
```
allora si sta dicendo al sistema di riprodurre tutti i campioni del segnale `x_camp` (88200) alla velocità di 44100 campioni al secondo: questa funzione invia il vettore `x_camp` al DAC alla velocità di `fs` campioni al secondo.

Se il vettore ha $N$ campioni e il DAC li legge a frequenza $f_s$, la durata della riproduzione (playback) è:
$$T_{playback} = \frac{N}{f_s}$$
dove
- $T_{playback}$ è la durata della riproduzione, in secondi
- $N$ è il numeri di campioni nel vettore
- $f_s$ è la frequenza di riproduzione, in Hz

> ***Esempio.*** Nel caso di $N = 88200$ e $f_s = 44100\ \text{Hz}$, abbiamo:
> $$T_{playback} = \frac{88200}{44100} = 2\ \text{s}$$
> Il segnale `x_camp` viene riprodotto in 2 secondi ***reali***, cioè con la stessa durata con cui era stato originariamente campionato.

#### Perché la durata resta corretta

Un vettore di campioni non contiene il tempo in modo esplicito. Il tempo viene assegnato dalla frequenza `fs`. Se il file audio è stato generato a $f_s = 44100\ \text{Hz}$ e viene riprodotto con lo stesso valore $f_s^{playback} = 44100\ \text{Hz}$, allora ogni campione occupa esattamente
$$T_s = \frac{1}{44100}\ \text{s}$$
e la scala temporale della riproduzione coincide con quella del segnale originale. 

In sostanza, se ***ogni secondo di playback corrisponde a un secondo reale***, significa che il tempo digitale e il tempo fisico coincidono e quindi il segnale `x_camp` viene riprodotto correttamente (non accelerato, rallentato, ecc.): la *frequenza percepita* $f_{percepita}$ coincide con la *frequenza originale* del segnale. Questo accade solo se:
$$f_s^{(playback)} = f_s^{(originale)}$$

#### Cosa succede se la frequenza di playback cambia

Se il vettore `x_camp` viene riprodotto con una frequenza diversa da quella di campionamento originale, la durata e la frequenza percepita cambiano.

> ***Esempio.*** Se abbiamo `sound(x_camp, 22050)`, in questo caso i campioni vengono letti più lentamente. La nuova durata della riproduzione diventa:
> $$T_{playback} = \frac{88200}{22050} = 4\ \text{s}$$
> quindi il segnale dura il doppio e risulta più grave.

In generale, la frequenza percepita $f_{percepita}$ si scala con il rapporto tra frequenza di playback e frequenza originale:
$$f_{percepita} = f_{originale} \cdot \frac{f_s^{(playback)}}{f_s^{(originale)}}$$

> ***Esempio.*** Con $f_{originale} = 440\ \text{Hz}$, $f_s^{(originale)} = 44100\ \text{Hz}$ e $f_s^{(playback)} = 22050\ \text{Hz}$, otteniamo:
> $$f_{percepita} = 440 \cdot \frac{22050}{44100} = 220\ \text{Hz}$$
> Il segnale, quindi, diventa di un'ottava più basso.

### 4.1.5 Analisi dell'effetto della frequenza errata

> ***Caso 1 — Frequenza corretta: $f_s^{(originale)} = 44100\ \text{Hz}$.***  
Il DAC riproduce i campioni alla stessa velocità con cui sono stati generati: i campioni vengono riprodotti alla stessa frequenza ($f_s$) con cui il segnale è stato campionato. Quindi, la durata del suono è:
> $$T_{playback} = \frac{88200}{44100} = 2\ \text{secondi} $$
>
>La nota viene percepita esattamente a $440\ \text{Hz}$.

> ***Caso 2 — Frequenza doppia: $f_s^{(playback)} = 88200\ \text{Hz}$.***  
Il DAC dichiara di ricevere 88200 campioni al secondo, cioè il doppio. Gli stessi 88200 campioni (2 secondi di segnale), vengono consumati in soli:
> $$T_{playback} = \frac{88200}{88200} = 1\ \text{secondo} $$
>
>> **Velocità percepita**: aumentata. Il segnale dura la metà del tempo ($1\ \text{s}$ invece che $2\ \text{s}$)
>
>> **Intonazione (pitch) percepita**: la frequenza percepita raddoppia. Per capirlo si ragiona così: in ogni secondo di playback, il DAC trasmette 88200 campioni. Questi campioni erano stati generati come $2\cdot 44200$ campioni distribuiti su $2\ \text{s}$ di segnale a $440\ \text{Hz}$, quindi contenevano $2\cdot 440 = 880$ oscillazioni complete. Il DAC le "consuma" tutte in $1\ \text{s}$: la frequenza percepita è $880\ \text{Hz}$.
>>
>> Sapendo che, in generale, se il segnale è generato a $f_s^{(originale)}$ e viene riprodotto a $f_s^{(playback)}$, la frequenza percepità è:
>> $$f_{percepita} = f_{nota}\cdot \frac{f_s^{(playback)}}{f_s^{(originale)}}$$
>> In questo caso $ f_{percepita} = 440\cdot 2 = 880\ \text{Hz}$, quindi è un'ottava sopra.

> ***Caso 2 — Frequenza dimezzata: $f_s^{(playback)} = 22050\ \text{Hz}$.***  
Gli stessi 88200 campioni di `x_camp` vengono consumati in $T_{playback} = \frac{88200}{22050} = 4\ \text{s}$.
>
>> ***Velocità percepità***: diminuisce. Il segnale dura il doppio del tempo ($4\ \text{s}$ invece che $2\ \text{s}$)
>
>> ***Intonazione percepita***: la frequenza percepita dimezza. Infatti:
>> $f_{percepita} = 440\cdot \frac{22050}{44100} = \frac{440}{2} = 220\ \text{Hz}$
>> Le onde sonore risultano allungate nel tempo: un onda più lunga corrisponode ad una frequenza più bassa (effetto rallentatore).

Il quadro dei tre casi si riassume nella tabella seguente:

<div align = "center">

| Frequenza di riproduzione | Formula | $f_{percepita}$ | Durata percepita | Effetto |
|---|---|:---:|:---:|---|
| $44100\ \text{Hz}$ (corretta) | $440 \times (44100/44100)$ | $440\ \text{Hz}$ | $2\ \text{s}$ | Suono originale |
| $88200\ \text{Hz}$ (doppia) | $440 \times (88200/44100)$ | $880\ \text{Hz}$ | $1\ \text{s}$ | Veloce e acuto |
| $22050\ \text{Hz}$ (dimezzata) | $440 \times (22050/44100)$ | $220\ \text{Hz}$ | $4\ \text{s}$ | Lento e grave |

</div>

### 4.1.6 Interpretazione

Questo esercizio chiarisce un aspetto che va oltre la semplice teoria di Nyquist: la frequenza di campionamento non è solo la soglia che determina se si verifica aliasing, ma è un'informazione semantica che attribuisce una scala temporale ai campioni. I campioni numerici, da soli, non "contengono" la temporalità: è il software di riproduzione che la ricostruisce, assumendo che la lista di numeri sia stata generata alla frequenza $f_s$ dichiarata. Se l'assunzione è sbagliata, la ricostruzione è sbagliata — e il suono risultante è distorto in modo prevedibile e calcolabile attraverso la formula $f_{percepita} = f_{originale} \cdot \frac{f_s^{(playback)}}{f_s^{originale}}$.

## 4.2 *Esercizio 3 — analisi del Chirp e aliasing visivo-sonoro*

### 4.2.1 Segnale chirp: uno strumento per osservare l'aliasing

L'esercizio 2 ha lavorato con un segnale a frequenza fissa. Per osservare aliasing in modo diretto — cioè per confrontare la zona $f_s \geq 2\cdot f_{max}$ (sicura, senza aliasing) e la sona $f_s \leq f_{max}$ (con aliasing) sullo stesso segnale — si introduce il ***segnale di chirp***.

> ***Definizione (Segnale di Chirp).***  
Un segnale di chirp (*swept-frequency signal*, segnale a frequenza spazzolata) è un segnale sinusoidale la cui frequenza istantanea vatia nel tempo in modo continuo. Per un chirp lineare che va da una frequenza $f_0$ ad una frequenza $f_1$ in una durata $T_{dur}$, la frequenza istantanea all'istante $t$ è:
> $$f(t) = f_0 + \frac{f_1 - f_0}{T_{dur}}\cdot t$$

> ***Esempio.***  
Supponiamo di voler costruire un chirp che:
> - parte da $f_0 = 100\ \text{Hz}$
>- arriva a $f_1 = 1000\ \text{Hz}$
>- in una durata totale $T_{dur} = 2\ \text{s}$
>
> La frequenza istantanea vale:
> $$f(t) =  f_0 + \frac{f_1 - f_0}{T_{dur}}\cdot t$$
>
> Sostituendo i valori otteniamo:
> $$f(t) =  100 + \frac{1000 - 100}{2}\cdot t = 100 + 450t$$
>
> Quindi:
> - a t = 0\ \text{s}: $f(0) = 100 \ \text{Hz}$
> - a t = 1\ \text{s}: $f(1) = 550 \ \text{Hz}$
> - a t = 2\ \text{s}: $f(2) = 1000 \ \text{Hz}$

### 4.2.2 Fase istantanea 

> ***Definizione (fase istantanea).***  
La ***fase istantanea*** di un segnale sinusoidale è la funzione $\phi(t)$ che rappresenta l'argomento della sinusoide in ogni istante di tempo. Essa descrive la posizione angolare del segnale lungo la sua oscillazione e determina completamente l'andamento temporale del segnale.
>
> Un segnale può essere scritto nella forma
> $$x(t) = A\,\sin(\phi(t))$$
> dove:
> - $A$ è l'ampiezza del segnale
> - $\phi(t)$ è la fase istantanea (in radianti)
> - $t$ è il tempo
> 
> Se la fase è una funzione lineare del tempo, il segnale ha frequenza costante; se invece la fase non è lineare, la frequenza varia nel tempo.

> ***Esempio — fase lineare.***  
Si consideri il segnale $x(t) = \sin(2\pi 50t)$. Qui:
> $$\phi(t) = 2\pi 50t$$
> e quindi:
> - la fase è lineare
> - la frequenza è costante a $50\ \text{Hz}$
> - l'oscillazione è uniforme

> ***Esempio — fase con fase iniziale $\phi_0$.***  
Si consideri il segnale $x(t) = \sin(2\pi 50t + \frac{\pi}{4})$. Qui:
> $$\phi(t) = 2\pi 50t + \frac{\pi}{4}$$
> e quindi:
> - la fase è lineare
> - la frequenza è costante a $50\ \text{Hz}$
> - il segnale è traslato nel tempo
> - cambia il punto di partenza dell'oscillazione

> ***Esempio — fase non lineare.***  
Si consideri il segnale $x(t) = \sin(2\pi(100t + 50t^2))$. Qui:
> $$\phi(t) = 2\pi(100t + 50t^2)$$
> e quindi:
> - la fase non è lineare
> - la frequenza cambia nel tempo
> - è un chirp (la frequenza cambia in modo continuo nel tempo)

### 4.2.3 Fase istantanea

> ***Definizione (frequenza istantane).***  
La ***frequenza istantanea*** di un segnale sinusoidale è la frequenza che il segnale assume in un dato istante di tempo. Essa descrive la rapidità con cui la fase del segnale varia nel tempo.
>
> Se il segnale è espresso nella forma 
> $$x(t) = A\,\sin(\phi(t))$$
> dove:
> - $A$ è l'ampiezza
> - $\phi(t)$ è la fase istantanea
> - $t$ è il tempo
>
> allora la frequenza istantanea è definita come: 
> $$f(t) = \frac{1}{2\pi}\frac{d\phi(t)}{dt}$$
> dove:
> - $f(t)$ è la frequenza istantanea
> - $\frac{1}{2\pi}\frac{d\phi(t)}{dt}$ rappresenta la variazione della fase nel tempo
> - $d$ indica la derivata
>
> Nel caso in cui la fase sia lineare, cioè $\phi(t) = \omega + \phi_0$ ($\omega = 2\pi ft$), la ***frequenza istantanea*** è costante e pari a $f$ (quella presente in $\omega$). In generale, se $\phi(t)$ non è lineare, la frequenza istantanea varia nel tempo (si calcola con la formula). 

> ***Esempio.***  
Consideriamo il seguente segnale: $x(t) = \sin(2\pi(100t + 50t^2))$. In questo caso, data la forma $x(t) = \sin(\phi(t))$, la *fase istantanea* è $$\phi(t) = 2\pi(100t + 50t^2)$$
> 
> Per calcolare la fase istantanea, data la definizione
> $$f(t) = \frac{1}{2\pi}\frac{d\phi(t)}{dt}$$
> dobbiamo calcolare la derivata di $\phi(t)$:
> $$\frac{d\phi(t)}{dt} = 2\pi(100 + 100t)$$
>
> Quindi:
> $$f(t) = \frac{1}{2\pi}\cdot 2\pi(100+100t) = 100+100t$$
>
> La frequenza istantanea è quindi $f(t) = 100 + 100t$, quindi:
> - a $t = 0$: $f(0) = 100\ \text{Hz}$
> - a $t = 1$: $f(1) = 200\ \text{Hz}$
> - a $t = 2$: $f(2) = 300\ \text{Hz}$
>
> Il segnale aumenta continuamente la frequenza: è un ***chirp lineare crescente***. Inoltre:
> - la fase non è lineare (contiene $t^2$)
> - quindi la frequenza non è costante
> - la derivata della fase dà la frequenza istantanea

### 4.2.4 Parametri dell'esercizio

Il chirp usato nell'esercizio va da $f_0 = 0\ \text{Hz}$ a $f_1 = 20000\ \text{Hz}$ in $T_{dur} = 2\ \text{s}$, campionato originalmente a $f_s = 44100\ \text{Hz}$.

L'operazione chiave è il ***sottocampionamento per decimazione*** con fattore $N = 8$: invece di usare tutti i campioni ottenuti dalla frequenza di campionamento originale $f_s$, se ne prende uno ogni $N$. Questo è equivalente a riesaminare il segnale come se fosse stato campionato ad una frequenza di campionamento $\frac{f_s}{N}$.

---

#### *Calcolo della nuova frequenza di campionamento e di Nyquist*

$$f_s^{(new)} = \frac{f_s}{N} = \frac{44100}{8} = 5512,5\ \text{Hz}$$

In questo contesto, data la frequenza di campionamento $f_s^{(new)}$, la massima frequenza del segnale che può essere rappresentata correttamente (senza aliasing) è:
$$f_{N} = \frac{f_s^{(new)}}{2} = \frac{5512,5}{2} = 2756,25\ \text{Hz}$$

Dato che il segnale chirp contiene componenti con frequenza superiore a $f_N = 2756,25\ \text{Hz}$, come $f_1 = 20000\ \text{Hz}$, tutte queste non possono essere rappresentate correttamente e si verifica aliasing.

> **Ricorda.** Se il segnale contiene una componente a frequenza $f > f_N$, allora si verifica ***aliasing***.

---

### 4.2.5 Codice MATLAB e significato

```matlab
% Caricamento del segnale chirt
[y, fs] = audioread('chirp_signal.wav');   % y = campioni, fs = frequenza di campionamento originale
durata = length(y) / fs;  % durata (s) = numero campioni / fs -> T = n*T_s = n*1/fs = n/fs
t = (0:length(y)-1) / fs;  % asse del tempo da 0 a t-1, t(n) = n/fs: legame indice tempo

figure, plot(t(1:2205), y(1:2205))  % Visualizza ~0.05 s iniziali del chirp 
```

La formula `t = (0:length(y)-1) / fs` è il legame $t = \frac{n}{f_s}$ già incontrato nella teoria del campionamento: ci permette quindi di costruire l'asse del tempo in cui poter rappresentare il segnale chirp. Il `plot`, che ricostruisce la forma del segnale analogico tramite l'approssimazione dei suoi primi `y = 2205` campioni, mostra 
$$T = \frac{N}{f_s} = \frac{2205}{44100} \approx 0,05\ \text{s}$$

ovvero solo i primi $0,05\ \text{s}$ dell'intera durata del segnale chirp. Il chirp, in questo frangente, ha una frequenza istantanea pari a:
$$f(t) = f_0 + \frac{f_1 - f_0}{T_{dur}}\cdot t = 0 + \frac{20000}{2}\cdot 0,05 = 500\ \text{Hz}$$
che si tratta di una frequenza ancora relativamente bassa, quindi ben visibile come oscillazione regolare.

```matlab
% Sottocampionamento (Decimazione)
N = 8;               % Fattore di decimazione
y_down = y(1:N:end)  % Un campione ogni N: aliasing intenzionale
fs_new = fs / N      % Nuova fs: 44100/8 = 5512.5 Hz
t_new = (0:length(y_down)-1) / fs  % Asse del tempo per il segnale decimato

fprintf('Nuova fs: %d Hz\n', fs_new);  % Stampa: 5512.5 Hz
fprintf('Nuova frequenza di Nyquist: %d Hz\n', fs_new/2);  % Stampa: 2756.25 Hz
```

La riga `y(1:N:end)` preleva dall'array `y` (la totalità dei campioni sul segnale chirp), solo gli elementi di indice $1, 9, 17, 25, \ldots$, ovvero rappresenta l'insieme dei campioni prelevati uno ogni $N = 8$. Quindi, si stanno "saltando" 7 campioni su 8: il segnale vede $\frac{1}{8} = 12,5 \%$ dell'informazione originale. È intenzionalmente una decimazione senza filtro anti-aliasing, proprio per osservare il fenomeno in modo evidente.

```matlab
% 3. Analisi della Forma d'Onda (Confronto visivo)
figure('Name', 'Analisi Temporale Aliasing');

% Pannello superiore: inizio del chirp (bassa frequenza → nessun aliasing)
subplot(2,1,1); hold on;
plot(t, y, 'b', 'DisplayName', 'Originale');
stem(t_new, y_down, 'r', 'MarkerSize', 4, 'DisplayName', 'Campionato (Down)');
title('Inizio del Chirp: il campionamento segue la curva');
xlim([0.1, 0.102]);         % Zoom su 2 ms iniziali: f ≈ 1000 Hz < 2756 Hz
xlabel('Tempo (s)'); ylabel('Ampiezza'); legend;

% Pannello inferiore: fine del chirp (alta frequenza → aliasing evidente)
subplot(2,1,2);
hold on;
plot(t, y, 'b', 'DisplayName', 'Originale');
plot(t_new, y_down, 'r-o', 'MarkerSize', 4, 'DisplayName', 'Campionato (Down)');
title('Fine del Chirp: campionamento insufficiente (Aliasing)');
xlim([durata-0.002, durata]); % Zoom sugli ultimi 2 ms: f ≈ 20000 Hz >> 2756 Hz
xlabel('Tempo (s)'); ylabel('Ampiezza'); legend;
```

Il doppio pannello è la visualizzazione diretta dell'aliasing:
- ***pannello superiore*** (inizio chirp, frequenza $\approx 1000\ \text{Hz}$): i punti rossi decimato giaciono sulla curva blu originale. La frequenza istantanea è bassa — al di sotto di $f_N^{(new)} = 2756.25\ \text{Hz}$ — e il segnale originale rappresenta fedelmente l'originale
- ***pannello inferiore*** (fine del chirp, frequenza $\approx 20000\ \text{Hz}$); i punti rossi non seguono più la curva blu, che oscilla troppo velocemente per essere catturata da un campione ogni 8. Collegando i punti rossi con una linea (plot invece di stem), emerge una sinusoide a frequenza molto più bassa di quella reale: questa è la frequenza di aliasing

### 4.2.6 Test di ascolto

```matlab
fprintf('\nRiproduzione segnale ORIGINALE...');
sound(y, fs);             % Suono che sale monotonicamente da 0 a 20000 Hz
pause(durata + 1);

fprintf('\nRiproduzione segnale con ALIASING...');
sound(y_down, fs_new);    % Effetto fisarmonica
```

> ***Segnale originale.***  Il chirp originale produce un sibilo che sale progressivamente da $0$ a $20000\ \text{Hz}$: si percepisce un suono monotonicamente crescente, da molto grave a quasi inudibile 

> ***Segnale decimato.***  Il segnale decimato produce invece un suono che sale, raggiunge un punto di massimo e poi ***inverte la direzione***, ridiscendendo. Poi risale, ridiscende ancora, e così via — come una fisarmonica. Questo è l'***effetto fisarmonica*** (o bouncing).
>
> La spiegazione matematica è diretta. La frequenza di Nyquist del segnale decimato è $f_N^{(new)}= 2756,25\ \text{Hz}$. Quando la frequenza istantanea del chirp $f(t)$ supera questo valore, le componenti si "rispecchiano": una componente a frequenza $f$ con $f > f_N^{(new)}$ produce un alias a frequenza $|$f_s^{(new)} - f|$, che è inferiore a $f_N^{(new)}$. 
>
> Man mano che $f$ cresce verso $f_s^{(new)} = 5512,5\ \text{Hz}$, la frequenza alias $|5512,5 - f|$ scende verso $0\ \text{Hz}$. Quando $f$ supera $f_s^{(new)}$, il ciclo ricomincia. Il risultato è che la frequenza percepita non cresce mai oltre $f_N^{(new)}$: ogni volta che la raggiunge, rimbalza indietro verso $0\ \text{Hz}$, oscillando continuamente nell'intervallo $[0,\, f_N^{(new)}]$.

> **Nota — Il filtro anti-aliasing.** L'effetto fisarmonica è il motivo per cui, nell'elaborazione audio professionale, si usa sistematicamente un **filtro anti-aliasing** (filtro passa-basso con frequenza di taglio $f_N$) prima di qualsiasi operazione di campionamento o decimazione. Il filtro rimuove preventivamente tutte le componenti frequenziali che superano il limite di Nyquist, impedendo che si generino alias. Nel codice dell'esercizio la decimazione `y(1:N:end)` è intenzionalmente effettuata senza tale filtro, per rendere il fenomeno visibile e udibile nella sua forma più pura.

## 4.3 *Esercizio 4 — analisi del della quantizzazione: livelli, errori e decibel*

### 4.3.1 Testo del problema

Si consideri il seguente segnale sinusoidale: $$x(t) = A\sin(2\pi ft) \quad A = 1 \quad f = 50\ \text{Hz}$$

Il range del convertitore AD è $[x_{min}, x_{max}] = [-1, +1]$, che coincide con il range naturale della sinusoide con ampiezza $A = 1$.

> ***Parte A — Parametri del quantizzatore***
> 1. Calcolare il numero di livelli $L$ per $b = 2$ bit e per $b = 4$ bit
> 2. Calcolare il passo di quantizzaizone $\Delta$ in entrambi i casi

> ***Parte B — Implementazione***
> 1. Generare il segnale con $f_s = 1000\ \text{Hz}$, durata $T = 0,1\ \text{s}$
> 2. Implementare la quantizzazione uniforme
> 3. Visualizzare il confronto segnale originale e quantizzato

> ***Parte C — Analisi dell'errore***
> 1. Calcolare il segnale errore istantaneo
> 2. Calcolare l'MSE per $b = 2$ e $b = 4$; commentare come varia al raddoppiare dei bit
> 3. Calcolare il miglioramento del rapporto segnale-rumore in dB quando si aggiunge 1 bit (es. da 4 a 5 bit)

#### *Parte A — Parametri della quantizzazione*

> ***1. Numero di livelli $L$.***  
Con b bit si possono formare $L = 2^b$ livelli. Abbiamo quindi che:
> - $b = 2$ bit $\Rightarrow L = 2^2 = 4$ livelli
> - $b = 4$ bit $\Rightarrow L = 2^4 = 16$ livelli

> ***2. Passo di quantizzazione $\Delta$.***  
Il passo di quantizzazione è pari a $$\Delta = \frac{x_{max} - x_{min}}{L}$$
> in questo caso abbiamo:
> - $b = 2 \Rightarrow \Delta_2 = \frac{1 - (-1)}{4} = \frac{2}{4} = 0.5$
> - $b = 4 \Rightarrow \Delta_4 = \frac{1 - (-1)}{16} = \frac{2}{16} = 0.125$
>
> In entrambi i casi, possiamo stabilire in quale intervallo è compreso l'errore di quantizzazione $e_q(n)$ per avere una quantizzazione uniforme:
> - $b = 2 \Rightarrow |e_q(n)| \leq \frac{\Delta_2}{2} = 0.250 \Rightarrow [-0.250,\, +0.250]$
> - $b = 4 \Rightarrow |e_q(n)| \leq \frac{\Delta_4}{2} = 0.0625 \Rightarrow [-0.0625,\, +0.0625]$

<div align = "center">

| Bit $b$ | Livelli $L$ | Passo $\Delta$ | Errore max $\Delta/2$ |
|:---:|:---:|:---:|:---:|
| $2$ | $4$ | $0.500$ | $0.250$ |
| $4$ | $16$ | $0.125$ | $0.0625$ |

</div>

#### *Parte B — Implementazione*

> ***1. Generare il segnale come segnale campiato tramite $f_s = 1000\ \text{Hz}$, $\,T = 0.1\ \text{s}$.***  
Con $f_s = 1000\ \text{Hz}$ e $T = 0.1\ \text{s}$, il numero di campioni è:
> $$N = f_s\cdot T = 1000\cdot 0.1 = 100\ \text{campioni}$$
> 
> Applichiamo il teorema di Nyquist per verificare se tale segnale presenta o meno aliasing. In questo caso abbiamo:
> $$f_N = \frac{f_s}{2} = \frac{1000}{2} = 500\ \text{Hz}$$
> Abbiamo quindi che $f = 50\ \text{Hz}$ non è superiore al valore $f_N$ e, di conseguenza, non si verifica aliasing sul segnale.
> ```matlab
> [x_camp, t] = campiona(f, fs, T, A);
>
> function [x_camp, t] = campiona(f, fs, T, A)
>     Ts = 1/fs;
>     t = 0:Ts:T;
>     x_camp = A*sin(2*pi*f*t);
> end
> ```

> ***2. Implementazione quantizzazione del segnale.***  
> ```matlab
> [x_q, e_q] = quantizza(x_camp, -A, A, b);
>
> function [x_q, e_q] = quantizza(x_camp, x_min, x_max, b)
>     L = 2^b;                                    % Numero di livelli
>     delta = (x_max - x_min)/L;                  % Passo di quantizzazione
>     x_clip = max(x_min, min(x_max, x_camp));    % Clipping del segnale
>     k = round((x_clip - x_min)/delta);          % Indice di livello 
>     x_q = x_min+delta*k;                        % Segnale quantizzato
>     e_q =  x_camp - x_q;                        % Errore di quantizzazione
> end
> ```
> La funzione implementa esattamente il processo di quantizzazione nei due passi visti nel *Capitolo 3*: applica il clipping al segnale per gestire valori fuori intervallo, calcola l'indice $k$ utilizzando il segnale clippato ed effettuando arrotondamento, poi ricostruisce il valore fisico del segnale quantizzato.

> ***3. Visualizzazione del confronto.***  
> ```matlab
> figure('Name', 'Segnale quantizzato e errore');
> subplot(2,1,1);
> plot(t, x_camp, 'LineWidth', 1.2); hold on;
> stairs(t, x_q, 'r', 'LineWidth', 1.2); 
> title(sprintf('Quantizzazione [b = %d bit, L = %d livelli, \\Delta = %.3f]', b, L, delta));
> xlabel('Tempo(s)'); ylabel('Ampiezza');
> legend('Segnale originale', 'Segnale quantizzato');
> grid on;
> 
> subplot(2,1,2);
> plot(t, e_q, 'g', 'MarkerSize', 4);
> yline(delta/2,'r--', '+\Delta/2', 'LabelHorizontalAlignment','left');
> yline(-delta/2,'r--', '-\Delta/2', 'LabelHorizontalAlignment','left');
> title('Errore di quantizzazione e_q(n) = x_q(n) - x(n)');
> xlabel('Tempo (s)');
> ylabel('Errore');
> grid on;
> ```
> Si usa `stairs` invece di `plot` per il segnale quantizzato: questa funzione disegna la caratteristica "a scalini" tipica della quantizzazione uniforme, in cui il segnale mantiene costante il valore del livello quantizzato tra un campione e il successivo.

<div align = "center">

![alt text](image-1.png)

![alt text](image-2.png)

</div>

> ***La natura strutturata dell'errore.***  
Il segnale errore (pannello inferiore) non ha un aspetto casuale: ha la forma di una ***serie di denti di sega*** sincronizzati con la sinusoide del segnale quantizzato. Man mano che la sinusoide sale, l'errore cresce linearmente finché il segnale non "scatta" al gradino successivo; a quel punto l'errore crolla bruscamente verso zero, e il ciclo si ripete. Questo andamento è la conseguenza diretta del fatto che la quantizzazione introduce un arrotondamento sistematico: l'errore non è casuale, ma è perfettamente determinato dal valore istantaneo del segnale.

<!-- *[Grafico a doppio pannello. Asse orizzontale "Tempo (s)", range $[0,\ 0{,}1]$; asse verticale "Ampiezza", range $[-1{,}2,\ +1{,}2]$. Pannello superiore: la curva blu (sinusoide continua) e la curva rossa a scalini ($b = 2$, $L = 4$ livelli: $-1{,}0$, $-0{,}5$, $0{,}0$, $+0{,}5$). Gli scalini sono ampi e l'approssimazione è grossolana: la sinusoide appare come una funzione "a gradini" con forti deformazioni, specialmente vicino ai massimi e ai minimi. Pannello inferiore: stessa sinusoide blu, curva verde a scalini ($b = 4$, $L = 16$ livelli, passo $0{,}125$). Gli scalini sono quattro volte più fitti: la forma approssima bene la sinusoide e le deviazioni sono difficilmente percepibili a occhio nudo. Legenda in entrambi: "Originale" (blu), risoluzione ($2$ o $4$ bit) in rosso/verde.]* -->

#### *Parte C — Analisi dell'errore*

> ***1. Segnale errore istanteo.***  
Il segnale errore è la differenza, campione per campione, tra segnale campionato e segnale quantizzato: $$e_q(n) = x(n) - x_q(n)$$
>
> come spiegato nel *Capitol 3*. Per una quantizzazione uniforme, l'errore di quantizzazione è sempre compreso in:
> $$|e_q(n)|\leq \frac{\Delta}{2} \Rightarrow -\frac{\Delta}{2} \leq e_q(n) \leq +\frac{\Delta}{2}$$

> ***2. Mean Squared Error (MSE).***  
Il segnale errore varia campione per campione e non si presta ad essere descritto da un singolo numero istantaneo. La misura di errore standard è il ***Mean Squarred Error*** (*MSE*) o *Errore Medio Quadratico*.
>
>> ***Definizione (MSE).***  
>> Dato un segnale discreto di errore $e_q(n)$ con $N$ campioni, il ***Mean Squarred Error*** è:
>> $$\text{MSE} = \frac{1}{N}\sum_{n=0}^{N-1}e_{q}^{2}(n)$$
>> Il MSE è sempre non negativo. In altre parole, rappresenta l'errore quadratico medio del segnale quantizzato.
>
> Nel caso della quantizzazione uniforme ideale, è possibile derivare una formula analitica del MSE in funzione del passo di quantizzazione $\Delta$. Assumendo che l’errore di quantizzazione sia distribuito uniformemente nell’intervallo $[-\frac{\Delta}{2},\,+\frac{\Delta}{2}]$, si ottiene:
> $$MES_{(teorico)} = \frac{\Delta^2}{12}$$
>
> Questa relazione mostra che MSE è proporzionale al quadrato del passo di quantizzazione, ovvero:
> $$\text{MSE} \propto \Delta^2$$
> Ciò significa che una riduzione di $\Delta$ comporta una riduzione molto più rapida del MSE, essendo una dipendenza quadratica.
>
>> **Nota.** La formula $MES = \frac{\Delta^2}{12}$ è valida sotto ipotesi ideali: assenza di clipping e distribuzione uniforme dell’errore. Per segnali semplici (ad esempio sinusoidi pure) o con un numero molto basso di bit, l’errore reale può non essere perfettamente uniforme e il valore numerico del MSE può discostarsi da quello teorico. Rimane un'approssimazione valida per segnali sufficientemente "ricchi" (molti livelli attivi, comportamento quasi casuale dell'errore tra campioni successivi).
>
> In questo contesto, calcoliamo MSE per $b = 2$ e $b = 4$:
> - $b = 2$ ($\Delta_2 = 0.5$): $$MSE_2 = \frac{(0.5)^2}{12} = \frac{0.25}{12} \approx 0.0208$$
> - $b = 4$ ($\Delta_4 = 0.125$): $$MSE_4 = \frac{(0.125)^2}{12} = \frac{0.015625}{12} \approx 0.0013$$
>
> In matlab, l'MSE può essere implementato con `mean(e_q.^2)`, ovvero la media dei quadrati degli errori di quantizzazione per ogni singolo campione (`.^` considera tutti gli errori degli N campioni e ne esegue il quadrato).
> ```matlab
> MSE = mean(e_q.^2);
> fprintf('MSE (2 bit): %.5f\n', MSE);
> ```
>
>> ***Come cambia il MSE al raddoppiare dei bit.***  
>> Raddoppiare i bit $b$ (da 2 a 4), moltiplica $L$ per 4 e divide $\Delta$ per 4. Poiché $\text{MSE} \propto \Delta^2$, dividere $\Delta$ per $4$ riduce il MSE di un fattore $16$:
>> 
>> $$\frac{\text{MSE}_2}{\text{MSE}_4} = \frac{\Delta_2^2}{\Delta_4^2} = \left(\frac{0{,}5}{0{,}125}\right)^2 = 4^2 = 16$$
>>
>> Il MSE si riduce di un fattore $16$ raddoppiando i bit. Notiamo infatti che, considerando $MSE_2 \approx 0.0208$ e $MSE_4 \approx 0.0013$, dividendo $\Delta$ per 4 (da $0.5$ a $0.125$), il MSE di riduce di un fattore 16. Questo comportamento conferma rigorosamente la relazione quadratica:
>> $$\text{MSE} \propto \Delta^2$$
>> e mostra come l’aumento del numero di bit migliori rapidamente la qualità della quantizzazione.

<!-- Come si vedrà nella sezione successiva, un fattore $16$ in potenza corrisponde esattamente a $10\log_{10}(16) \approx 12\ \text{dB}$ di miglioramento del rapporto segnale-rumore. -->

> ***3. Decibel e SQNR.***  
>> ***Decibel.***
>> Come visto nel *Capitolo 3*, il **decibel** (dB) è un'unità logaritmica adimensionale usata per esprimere il rapporto tra due grandezze della stessa natura. Questo può essere espresso nelle forme:
> - ***potenza***: $dB = 10\log_{10}\frac{P_1}{P_2}$
> - ***ampiezza***: $dB = 20\log_{10}\frac{A_1}{A_2}$
> dove $dB = 10\log_{10}\frac{P_1}{P_2} = 20\log_{10}\frac{A_1}{A_2}$
>
>> ***SQNR.***
>> Come visto nel *Capitolo 3*, ***SQNR*** misura la qualità della conversione A/D, ed è calcolata come segue:
>> $$\text{SQNR} = \frac{P_{segnale}}{\text{MSE}}$$
>> Per una **sinusoide pura** $x(t) = A\sin(2\pi f t)$, la potenza media vale (Capitolo 2):
>> $$P_{segnale} = \frac{A^2}{2}$$
>> Con $A = 1$: $P_{segnale} = 0{,}5$. Il rumore di quantizzazione ha potenza $\text{MSE} = \Delta^2/12$. Sostituendo $\Delta = (x_{max} - x_{min})/2^b = 2/2^b$:
>> $$\text{MSE} = \frac{(2/2^b)^2}{12} = \frac{4}{12 \cdot 4^b} = \frac{1}{3 \cdot 4^b}$$
>> $$\text{SQNR} = \frac{A^2/2}{\Delta^2/12} = \frac{1/2}{1/(3 \cdot 4^b)} = \frac{3}{2} \cdot 4^b$$
>> In decibel:
>> $$\text{SQNR}_{dB} = 10\log_{10}\!\left(\frac{3}{2} \cdot 4^b\right) = 10\log_{10}(1{,}5) + 10\log_{10}(4^b)$$
>> $$= 10\log_{10}(1{,}5) + b \cdot 10\log_{10}(4) \approx 1{,}76 + b \cdot 6{,}02\ \text{dB}$$
>>
>> Questa è la **formula fondamentale dell'SQNR** per una sinusoide con quantizzazione uniforme:
>> $$\boxed{\text{SQNR}_{dB} \approx 1{,}76 + 6{,}02 \cdot b\ \text{dB}}$$
>
>> ***Miglioramento SQNR con l'aggiunta di un bit.*** 
>> Il miglioramento quando si aggiunge un solo bit (da $b$ a $b+1$) è:
>> $$\Delta\text{SQNR} = \text{SQNR}(b+1) - \text{SQNR}(b) = [1{,}76 + 6{,}02(b+1)] - [1{,}76 + 6{,}02 b] = 6{,}02\ \text{dB}$$
>>
>> **Il risultato non dipende da $b$**: aggiungere un bit migliora sempre il rapporto segnale-rumore di circa $6\ \text{dB}$, qualunque sia la risoluzione di partenza.
>>
>> La spiegazione intuitiva è diretta: aggiungere un bit raddoppia $L$ e dimezza $\Delta$. Poiché $\text{MSE} \propto \Delta^2$, dimezzare $\Delta$ riduce il MSE di un fattore $4$. L'SQNR aumenta di un fattore $4$ in potenza, ossia di $10\log_{10}(4) = 10 \times 2\log_{10}(2) \approx 6{,}02\ \text{dB}$.
>>
>> **Verifica numerica per $b = 4 \to 5$ bit:**
>> $$\text{SQNR}(4) \approx 1{,}76 + 6{,}02 \times 4 = 1{,}76 + 24{,}08 = 25{,}84\ \text{dB}$$
>> $$\text{SQNR}(5) \approx 1{,}76 + 6{,}02 \times 5 = 1{,}76 + 30{,}10 = 31{,}86\ \text{dB}$$
>> $$\Delta\text{SQNR} = 31{,}86 - 25{,}84 = 6{,}02\ \text{dB} \approx 6\ \text{dB} \quad \checkmark$$

---

## Lezione 6

---

# Capitolo 5 — Esercitazione: Percezione acustica e Dithering

---

## Introduzione al capitolo

Il Capitolo 4 ha ripreso la teoria della quantizzazione e ha posto la domanda fondamentale: "di quanti decibel migliora il rapporto segnale-rumore aggiungendo un bit?". La risposta — circa $6\ \text{dB}$ per ogni bit aggiunto — era ricavata in forma analitica dalla formula $\text{SQNR} \approx 1{,}76 + 6{,}02b$.

Il presente capitolo ha uno scopo diverso: verificare quella teoria numericamente, estenderla a segnali reali e scoprire un fenomeno che la formula da sola non cattura. Due esercizi guidano questa esplorazione.

L'**Esercizio 5** porta la quantizzazione su un segnale audio reale. L'obiettivo non è solo calcolare un MSE, ma *ascoltare* cosa significa quantizzare con 8, 4 e 2 bit: i gradini grossolani della forma d'onda si trasformano in una distorsione caratteristica chiamata "metallica", e il solo rumore di quantizzazione — ascoltato separatamente — rivela di essere una versione "fantasma" e strutturata del segnale originale.

L'**Esercizio 6** introduce il **dithering**: la tecnica controintuitiva con cui si migliora la qualità percepita di un segnale digitale *aggiungendo rumore* prima della quantizzazione. Questo esercizio costituisce un argomento nuovo rispetto ai capitoli precedenti e richiede un'introduzione teorica dedicata.

---

## 5.1 *Esercizio 5 — Percezione acustica dell'errore di quantizzazione*

### 5.1.1 Motivazione: dal segnale sinusoidale al segnale audio

L'esercizio 4 ha utilizzato una sinusoide pura come segnale di test. Questa scelta è comoda per i calcoli analitici (la formula $P_{segnale} = \frac{A^2}{2}$ è esatta, come vista nel *capitolo 2*), ma è potvera dal punto di vista percettivo: una sinusoide pura è il segnale più semplice possibile, e il suo errore di quantizzazione è altrettanto semplice.

Un segnale audio reale — musica, voce — è la sovrapposizione di molte componenti frequenziali diverse, con un'ampiezza istantanea che varia in modo irregolare e imprevedibile. Su questo tipo di segnale, la riduzione dei bit produce effetti percettivi ben distinti che vale la pena ascoltare direttamente.

### 5.1.2 Parametri dell'esercizio

Il segnale usato è `handel.wav`, un brano musicale incluso nella distribuzione standard di MATLAB (la Hallelujah di Handel). L'esercizio può essere ripetuto con qualsiasi file audio, inclusi `gong.mat` e `laughter.mat` (disponibili nella stessa distribuzione) o file personali in formato `.mp3` o `.wav`.

### 5.1.3 Codice MATLAB

```matlab
% 1. Caricamento e lettura del segnale audio
[x, fs] = audioread('handel.wav');       % x = segnale audio campionato (insieme di campioni che approssimano la forma d'onda del segnale analogico), fs = frequenza di campionamento
info = audioinfo('handel.wav');          % Metadati: durata, canali, bit rate, ecc

x = x(:,1);                              % Estrazione del canale sinistro (mono) se il file è stereo
figure, plot(x);                         % Visualizzazione della forma d'onda: usa i campioni per rappresentare la forma del segnale

% 2. Calcolo ampiezza del segnale, usata come dato per i limiti fisici di ADC
x_min = min(x);
x_max = max(x);

% Quantizzazione del segnale a tre diversi bit
[x_q8bit, e_q8bit, delta8bit] = quantizza (x, x_min, x_max, 8);
[x_q4bit, e_q4bit, delta4bit] = quantizza (x, x_min, x_max, 4);
[x_q2bit, e_q2bit, delta2bit] = quantizza (x, x_min, x_max, 2);

% figure, plot(x_q8bit);
% figure, plot(x_q4bit);
% figure, plot(x_q2bit);

% Test di ascolto: viene riprodotto il segnale audio (originale o quantizzato) ed effettua una 
% pausa dopo la riproduzione pari alla durata T del segnale audio stesso + 2 secondi
disp('Riproduzione originale tramite campionamento...'); sound(x, fs); pause(length(x)/fs + 2); 
disp('Riproduzione 8-bit...'); sound(x_q8bit, fs); pause(length(x)/fs + 2);
disp('Riproduzione 4-bit (distorsione)...'); sound(x_q4bit, fs); pause(length(x)/fs + 2);
disp('Riproduzione 2-bit (pesante)...'); sound(x_q2bit, fs); pause(length(x)/fs + 2);
disp('Solo il RUMORE di quantizzazione (2-bit)...'); sound(e_q2bit, fs);

% Funzione per la quantizzazione del segnale audio campionato
function [x_q, e_q, delta] = quantizza(x_camp, x_min, x_max, b)
    L = 2^b;    
    delta = (x_max - x_min)/(L-1);
    k = round((x_camp - x_min)/delta);
    x_q = x_min+delta*k;
    e_q =  x_camp - x_q;
end
```

### 5.1.4 Range adattivo di ADC per il quantizzatore

Un aspetto fondamentale di questo esercizio è la scelta del range di valori ammissibili dall'ADC: a differenza dell'esercizio 4 (dove il range era fisso a $[-1,\,+1]$ e coincideva esattamente con il range del segnale sinusoidale), qui si usano i valori `x_min = min(x)` e `x_max = max(x)` estratti direttamente dal segnale audio (campionato).

Questa scelta è detta ***range adattivo***.
> ***Definizione (range adattivo).***  
Il ***range adattivo*** è una strategia per l'implementazione di un ADC che permette di assegnare i suoi valori $x_{min}$ e $x_{max}$ in maniera adattiva rispetto al segnale di riferimento. 
>
> Questi limiti diventano quindi adattivi a seconda del segnale di ingresso nell'ADC che, quindi, ne permette una sua intera rappresentazione senza che si verifichi il fenomeno del clipping. Per farlo, sfrutta i valori $\max(x(n))$ e $\min(x(n))$ — i valori massimo e minimo del segnale campionato — per garantire la copertura dell'interno segnale.

L'ADC si adatta al segnale specifico, sfruttando tutta la scala di livelli disponibili senza sprecare nessun livello su ampiezze che il segnale non raggiunge mai. Il vantaggio è immediato: se si usasse un range fisso (es. $[-1, +1]$) su un segnale che in realtà occupa solo $[-0{,}3, +0{,}3]$, i livelli nelle zone $[-1, -0{,}3]$ e $[+0{,}3, +1]$ rimarrebbero inutilizzati e la risoluzione effettiva si ridurrebbe.

> **Nota.** Il range adattivo presentato in questo esercizio usa i valori estremi dell'intero file. In applicazioni pratiche (streaming audio, sistemi real-time) il range non può essere calcolato sull'intero file perché non è disponibile in anticipo: si usano stime basate su un breve segmento iniziale o su conoscenze a priori del tipo di segnale.

### 5.1.5 Test di ascolto: effetti percepiti a diversi bit

> ***Versione originale.***  
> ```matlab
> sound(x, fs);
> ```
> Il segnale originale di `handel.wav` è campionato a $f_s = 8192\ \text{Hz}$ e ha già una risoluzione di $16$ bit: la qualità è buona e la musica è riconoscibile e relativamente pulita.

> ***Versione a 8 bit.***  
> ```matlab
> sound(x_q8bit, fs);
> ```
> La distorsione è appena percepibile nelle parti più silenziose del brano: si avverte un leggero fruscio di fondo che si manifesta nei momenti in cui il segnale ha ampiezza ridotta. Questo fenomeno — chiamato ***rumore di quantizzazione a basso livello*** — è una caratteristica tipica della quantizzazione uniforme: quando il segnale è vicino allo zero, occupa solo i livelli centrali della scala, che sono pochi, e l'errore relativo diventa grande rispetto all'ampiezza del segnale.

> ***Versione a 4 bit.***  
> ```matlab
> sound(x_q4bit, fs);
> ```
> La distorsione diventa chiaramente udibile. Il suono appare "metallico": non si tratta solo di un fruscio aggiunto, ma di una distorsione della forma d'onda stessa. La musica è ancora riconoscibile, ma le sfumature timbriche sono perse.

> ***Versione a 2 bit.***  
> ```matlab
> sound(x_q2bit, fs);
> ```
> La distorsione è pesante: il segnale ha soltanto $4$ livelli e la forma d'onda è grossolanamente approssimata da gradini. Il brano è appena riconoscibile e il suono è fortemente distorto.

> ***Ascolto del solo rumore a 2 bit.***  
> ```matlab
> sound(e_q2bit, fs);
> ```
> Questo è l'aspetto più rivelatorio dell'intero esercizio. Ascoltando il vettore `e_q2bit` — la differenza campione per campione tra il segnale originale e la versione a 2 bit — si percepisce non un fruscio bianco casuale, ma una versione "fantasma" della musica stessa: metallica, distorta, ma riconoscibilmente musicale nella sua struttura temporale.
>
> Questo fenomeno ha una spiegazione precisa. L'errore di quantizzazione è ***correlato*** al segnale: il suo valore istantaneo dipende dal valore istantaneo del segnale quantizzato. Quando il segnale sale, l'errore sale con esso; quando il segnale scende, l'errore scende. Il risultato è che il rumore di quantizzazione "assomiglia" al segnale, poiché ne è una funzione deterministica.

<!-- *[Grafico — Quattro pannelli sovrapposti, uno per ciascuna versione: originale, 8 bit, 4 bit, 2 bit. Asse orizzontale "Campione $n$" o "Tempo (s)"; asse verticale "Ampiezza". Per ciascuna versione si mostra la forma d'onda del segnale quantizzato in rosso sovrapposta all'originale in blu tratteggiato. All'aumentare del numero di bit la curva rossa si avvicina alla blu. Un quinto pannello mostra il segnale errore a 2 bit: la sua forma d'onda è chiaramente correlata al segnale originale.]* -->

## 5.2 *Esercizio 6 — Dithering: migliorare l'audio con il rumore*

### 5.2.1 Problema: la correlazione tra errore e segnale

L'esercizio 5 ha rivelato una proprietà fondamentale della quantizzazione uniforme: l'errore di quantizzazione non è casuale, ma è correlato al segnale. Questa correlazione produce la distorsione "metallica" percepita a bassa risoluzione.

> ***Segnali $x(n)$ e $x_q(n)$ correlati.***  
Si dice che due segnali $x(n)$ e $x_q(n)$ sono ***correlati*** quando il valore di uno fornisce informazioni sul valore dell'altro. Nel caso della quantizzazione uniforme, la funzione 
> $$e_q(n) = x(n) - x_q(n)$$
> è una funzione deterministica di $x(n)$: dato $x(n)$, si può calcolare esattamente $e_q(n)$ senza incertezza. La correlazione è massima.

Il nostro sistema uditivo è più tollerante nei confronti di un rimore ***scorrelato*** (un fruscio casuale di fondo) che di un rumore ***correlato*** (distorsione armonica). Questo è il punto del ***dithering***.

### 5.2.2 Soluzione: il dithering

> ***Definizione (dithering).***  
Il ***dithering*** (dall'inglese dither, oscillazione) è la tecnica che consiste nell'aggiungere al segnale analogico un rumore casuale di ampiezza molto piccola — dell'ordine $\frac{\Delta}{2}$ — prima dell'operazione di quantizzazione.
>
> L'obiettivo non è ridurre l'errore di quantizzazione in senso quadratico (l'MSE può anche aumentare), ma ***rompere la correlazione*** tra l'errore e il segnale, trasformando la distorsione armonica in un fruscio casuale statisticamente indipendente dal segnale.

### 5.2.3 Rumore di dithering

Il rumore usato nell'esercizio è un rumore bianco uniforme nell'intervallo $[-\frac{\Delta}{2},\,+\frac{\Delta}{2}]$:
```matlab
rumore = (rand(size(x)) - 0.5) * step;  % x = segnale campionato
```
La funzione MATLAB `rand(size(x))` genera un vettore di numeri pseudocasuali uniformemente distribuiti in $[0,\,1]$. Sottraendo $0{,}5$ si ottiene una distribuzione centrata in zero nell'intervallo $[-0{,}5,\,+0{,}5]$; moltiplicando per `step` (il passo di quantizzazione $\Delta$) si ottiene la distribuzione finale $\left[-\frac{\Delta}{2},\,+\frac{\Delta}{2}\right]$.

La scelta dell'ampiezza $\frac{\Delta}{2}$ è fondamentale: il rumore $d(n)$ (sommato al segnale campionato per ottenere un segnale perdurbato da quantizzare) ha esattamente l'ampiezza del semipasso di quantizzazione. Un rumore più piccolo non sarebbe sufficiente a rompere la correlazione; un rumore più grande introdurrebbe un'alterazione percettibile del segnale.

Abbiamo quindi che il rumore di dithering $d(n)$ è anch'esso generato come distribuzione uniforme nell'intervallo $\left[-\frac{\Delta}{2},\,+\frac{\Delta}{2}\right]$ (prodotto esattamente da `(rand(...)-0.5)`).

### 5.2.4 Codice MATLAB

```matlab
% 1. Caricamento e lettura del segnale audio
[x, fs] = audioread('handel.wav');       % x = segnale audio campionato (insieme di campioni che approssimano la forma d'onda del segnale analogico), fs = frequenza di campionamento
info = audioinfo('handel.wav');          % Metadati: durata, canali, bit rate, ecc

x = x(:,1);                              % Estrazione del canale sinistro se il file è stereo:
                                         % x(:,1) seleziona tutte le righe della colonna 1

% 2. Range adattivo: limiti dell'ADC estratti dal segnale stesso
x_min = min(x);
x_max = max(x);

% 3. Quantizzazione standard a 4 bit
[x_q4bit, e_q4bit, delta4bit] = quantizza(x, x_min, x_max, 4);

% 4. Quantizzazione con dithering a 4 bit
step = delta4bit;                                    % Passo di quantizzazione Δ (già calcolato sopra)
rumore = (rand(size(x)) - 0.5)*step;                 % Rumore uniforme in [-Δ/2, +Δ/2]
x_rumore = x + rumore;                               % Segnale perturbato: segnale + rumore di dithering
x_dithered = quantizza(x_rumore, x_min, x_max, 4);   % Quantizzazione del segnale perturbato

% Test di ascolto
disp('Riproduzione 4-bit (distorsione)...'); 
sound(x_q4bit, fs); 
pause(length(x)/fs + 1);

disp('Riproduzione 4-bit con Dithering (suono più naturale)...'); 
sound(x_dithered, fs); 
pause(length(x)/fs + 1)

% Funzione per la quantizzazione del segnale audio campionato
function [x_q, e_q, delta] = quantizza(x_camp, x_min, x_max, b)
    L = 2^b;    
    delta = (x_max - x_min)/(L-1);
    k = round((x_camp - x_min)/delta);
    x_q = x_min+delta*k;
    e_q = x_camp-x_q;
end
```
Il processo si articola in tre passi: 
1. generare il rumore casuale di ampiezza $\Delta/2$ 
2. sommarlo al segnale originale 
3. quantizzare il segnale perturbato con la stessa risoluzione. 

Il risultato è una versione quantizzata in cui la correlazione tra errore e segnale è stata intenzionalmente "rotta" dalla perturbazione casuale.

### 5.2.5 Effetto del dithering sul MSE

Un aspetto controintuitivo del dithering è il suo effetto sul MSE. Per comprendere questa relazione è necessario chiarire prima il significato preciso del MSE e il suo legame con la nozione di potenza di un segnale.

---

#### *MSE come misura di potenza dell'errore.* 

Come definito nella *Sezione 4.3*, il ***Mean Squared Error*** di un segnale di errore $e(n)$ con $N$ campioni è:

$$\text{MSE} = \frac{1}{N}\sum_{n=0}^{N-1} e^2(n)$$

Questa formula calcola la **media dei quadrati** dei valori di errore. Per capire perché il MSE coincida con una misura di potenza, si richiama la definizione di potenza media di un segnale discreto (si veda il Capitolo 2):

$$P = \frac{1}{N}\sum_{n=0}^{N-1} |x(n)|^2$$

Le due formule sono strutturalmente identiche: la potenza media di un segnale è la media dei suoi valori al quadrato, esattamente come il MSE è la media dei quadrati dell'errore. Pertanto:

> **Il MSE dell'errore di quantizzazione coincide con la potenza media del segnale di errore.**

Questa equivalenza vale senza restrizioni aggiuntive quando, come nel caso dell'errore di quantizzazione ideale $e_q(n)$, il valor medio dell'errore è nullo (l'errore oscilla simmetricamente attorno allo zero). Per capire perché, è necessario introdurre il concetto di varianza.

> ***Definizione (variabile aleatoria).***  
Una **variabile aleatoria** è una variabile il cui valore non è determinato a priori, ma dipende dall'esito di un fenomeno casuale. Ogni volta che il fenomeno si realizza, la variabile assume un valore specifico (detto *realizzazione*); l'insieme di tutti i valori possibili e delle loro probabilità costituisce la *distribuzione* della variabile. 
>
> Nel contesto del dithering, il rumore $d(n)$ generato da `rand` è una variabile aleatoria: ogni campione è un numero diverso, estratto casualmente dalla distribuzione uniforme su $\left[-\frac{\Delta}{2},+\frac{\Delta}{2}\right]$. L'operatore $\mathbb{E}[\,\cdot\,]$ indica il **valor medio** (o *valore atteso*): la media pesata di tutti i valori possibili, ciascuno moltiplicato per la propria probabilità. Per una distribuzione uniforme su $[-a, +a]$, il valor medio è zero perché i valori positivi e negativi si bilanciano perfettamente.

> **Definizione (varianza).** Data una variabile aleatoria $e$ con valor medio $\mu = \mathbb{E}[e]$, la **varianza** è la media del quadrato dello scarto dalla media:
> $$\text{Var}(e) = \mathbb{E}\!\left[(e - \mu)^2\right] = \mathbb{E}[e^2] - \mu^2$$
> In altre parole, la varianza misura quanto i valori di $e$ si disperdono attorno al loro valor medio. Un'interpretazione geometrica diretta: se si "centra" la variabile (le si sottrae la media), la varianza è la potenza media della variabile centrata.

Il legame con il MSE emerge espandendo la definizione: $\mathbb{E}[e^2] = \text{Var}(e) + \mu^2$. Quando il valor medio è nullo ($\mu = 0$), il termine $\mu^2$ scompare e rimane:

$$\mathbb{E}[e^2] = \text{Var}(e)$$

Poiché il MSE è proprio $\mathbb{E}[e^2]$ (la media dei quadrati), si ottiene la catena di uguaglianze:

$$P = \text{MSE} = \mathbb{E}[e^2] = \text{Var}(e) \quad \text{(se } \mu = \mathbb{E}[e] = 0\text{)}$$

#### Potenza del rumore di quantizzazione standard

Nella sezione 4.3 è stato derivato che, per la quantizzazione uniforme ideale, l'errore $e_q(n)$ è distribuito uniformemente nell'intervallo $\left[-\frac{\Delta}{2},\,+\frac{\Delta}{2}\right]$. La varianza di una distribuzione uniforme su un intervallo $[a,\, b]$ è:

$$\text{Var} = \frac{(b - a)^2}{12}$$

Con $a = -\frac{\Delta}{2}$ e $b = +\frac{\Delta}{2}$, si ottiene $(b - a) = \Delta$, quindi:

$$\text{MSE}_{standard} = \frac{\Delta^2}{12}$$

#### Potenza del rumore di dithering

Il rumore di dithering $d(n)$ è anch'esso generato come distribuzione uniforme nell'intervallo $\left[-\frac{\Delta}{2},\,+\frac{\Delta}{2}\right]$ (la scelta di `(rand(...) - 0.5) * step` produce esattamente questo intervallo). Applicando la stessa formula della varianza:

$$\text{MSE}_{dithering} = \frac{\Delta^2}{12}$$

Il rumore di dithering ha quindi la stessa potenza del rumore di quantizzazione standard.

<!-- non mi è chiaro perché qui mi dice che l'MSE dithering è uguale a quello standard, mentre dopo mi dice che quello con dithering è il doppio di quello standard. C'è una discrepanza -->

---

#### *Dithering e MSE: composizione dei contributi d'errore*

Aggiungendo un rumore di dithering al segnale campionato, il segnale in ingresso alla quantizzazione è $x_{rumore}(n) = x(n) + d(n)$, ovvero un segnale perturbato. Il quantizzatore produce un errore di quantizzazione $e_q'(n)$ su questo segnale perturbato. L'errore totale rispetto al segnale originale $x(n)$ è:
$$e_{totale}(n) = x(n) - x_{dithered}(n) = e_q'(n) - d(n)$$
dove:
- $e_q'(n)$ è l'errore di quantizzazione del segnale perturbato
- $d(n)$ è il rumore di dithering aggiunto in ingresso

Poiché $d(n)$ è generato casualmente e indipendentemente dal segnale $x(n)$, i due contributi $e_q'(n)$ e $d(n)$ sono ***statisticamente indipendenti*** ed hanno valor medio nullo .

Per due variabili aleatorie indipendenti a valor medio nullo, le varianze (e quindi le potenze) si sommano:

$$\text{MSE}_{totale} = \text{Var}(e_q') + \text{Var}(d) = \frac{\Delta^2}{12} + \frac{\Delta^2}{12} = \frac{\Delta^2}{6}$$

In decibel, il rapporto tra MSE (dato che sono due potenze per quanto discusso precedentemente) con dithering e quello standard, è:

$$10\log_{10}\!\left(\frac{\Delta^2/6}{\Delta^2/12}\right) = 10\log_{10}(2) \approx 3{,}01\ \text{dB}$$

Il MSE totale del segnale, con l'aggiunta del dithering, è circa il doppio dell'MSE standard del segnale senza dithering: il dithering introduce un peggioramento di circa $3\ \text{dB}$ nel rapporto segnale-rumore (SQNR del segnale quantizzato uniforme) misurato in senso quadratico.

#### *Contraddizione apparente: MSE peggiore, qualità percepità migliore*

Il risultato è apparentemente paradossale: aggiungendo rumore si peggiora il MSE, eppure la qualità percepita del segnale audio migliora. La contraddizione si risolve distinguendo due concetti che il MSE non differenzia:

- ***struttura dell'errore***: il MSE misura la potenza complessiva dell'errore, ma è completamente insensibile alla struttura temporale. Due segnali di errore con lo stesso MSE possono essere percettivamente molto diversi se uno è correlato al segnale (distorsione armonica) e l'altro è casuale (fruscio bianco).

- ***percezione uditiva***: il sistema uditivo umano è particolarmente sensibile ai **pattern strutturati** — cioè alle ripetizioni, alle armonie, alle variazioni sistematiche — perché li interpreta come segnali informativi. Un errore correlato al segnale (come l'errore di quantizzazione uniforme a bassa risoluzione) introduce componenti armoniche che il sistema uditivo rileva come distorsione "metallica". Al contrario, un errore casuale e scorrelato — un fruscio bianco — viene percepito come rumore di fondo neutro, molto meno fastidioso anche se di potenza maggiore.

Il dithering trasforma un errore strutturato in un errore casuale al prezzo di un ***leggero aumento di potenza***. Dal punto di vista del *MSE*, è un ***peggioramento***; dal punto di vista della *qualità percepita*, è un ***miglioramento*** netto.

---

#### Quantizzazione standarf vs dithering

<div align = "center">

| Proprietà | Quantizzazione standard | Quantizzazione con dithering |
|---|---|---|
| **MSE** | $\dfrac{\Delta^2}{12}$ | $\dfrac{\Delta^2}{6}$ (circa $3\ \text{dB}$ peggiore) |
| **Struttura dell'errore** | Correlata al segnale | Scorrelata (casuale) |
| **Effetto percettivo** | Distorsione metallica | Fruscio bianco neutro |
| **Qualità soggettiva** | Peggiore a bassa risoluzione | Migliore a bassa risoluzione |

</div>

In sintesi: la quantizzazione standard minimizza il MSE ma produce un errore strutturato e percettivamente fastidioso; il dithering aumenta leggermente il MSE ma rende l'errore casuale e percettivamente neutro. La scelta tra i due approcci dipende dal criterio di qualità: matematico (MSE) o percettivo.

---

## Lezione 7

---

# Capitolo 6 — Filtraggio

---

## Introduzione al capitolo

I capitoli precedenti hanno costruito, passo dopo passo, l'intera catena che trasforma un segnale fisico in informazione digitale: la definizione di segnale analogico, la sua rappresentazione nel dominio della frequenza tramite la serie di Fourier, le due operazioni fondamentali di campionamento e quantizzazione, la codifica binaria tramite indice di livello, la misura di qualità fornita dall'SQNR, e infine le tecniche più avanzate di analisi dell'errore e di dithering.

---

## 6.1 *Riepilogo: campionamento, quantizzazione e misure di qualità*

Richiamiamo in forma sintetica le formule fondamentali viste fino ad ora. 

### 6.1.1 Campionamento

Un segnale analogico con componente di frequenza massima $f_{max}$ può essere campionato senza perdita di informazione se e solo se la frequenza di campionamento $f_s$ soddisfa la condizione di Nyquist-Shannon $$f_s \geq 2\cdot f_{max}$$

La soglia $f_N = \frac{f_s}{2}$ è detta *frequenza di Nyquist*, ovvero la massima frequenza del segnale che può essere rappresentata correttamente senza aliasing. In questo caso, se un segnale contiene componenti a frequenza $f$ superiore a $f_N$, queste non possono essere rappresentate correttamente e si verifica il fenomeno dell'*aliasing*. 

L'aliasing, in modo equivalente, si verifica quando la frequenza di campionamento è insufficiente, cioè quando: $$f_s < 2\cdot f_{max}$$ In questo caso, le componenti frequenziali alte vengono "confuse" con frequenze più basse nel segnale ricostruito, producendo una frequenza apparente $f_{alias} = |f_{reale} - k\cdot f_s|$, con $k$ intero scelto in modo che $0\leq f_{alias}\leq \frac{f_s}{2}$.

### 6.1.2 Quantizzazione

Dati il range $[x_{min},\, x_{max}]$ e il numero di bit $b$, i parametri della quantizzazione uniforme sono
$$L = 2^b\quad \text{(numero di livelli)} \qquad \Delta = \frac{x_{max} - x_{min}}{L}\quad \text{(passo di quantizzazione)}$$

L'errore di quantizzazione è limitato da $|e_q(n)|\leq\frac{\Delta}{2}$, e la sua potenza media vale $P_{errore} = \text{MSE} = \frac{\Delta^2}{12}$.

### 6.1.3 Bitrate 

Il ***bitrate*** $R$ (numero di bit trasmessi o memorizzati per unità di tempo) è il prodotto tra la frequenza di campionamento e il numero di bit per campione: $$R = f_s\cdot b \quad [\text{bit}/\text{s}]$$

### 6.1.4 Decibel e SQNR

Il rapporto tra due potenze di esprime in decibel come: $$\text{dB} = 10\log_{10}\frac{P_1}{P_2}$$ o, espresso nell'ordine di ampiezza $$\text{dB} = 20\log_{10}\frac{A_1}{A_2}$$

Il rapporto segnale-rumore di quantizzazione per una sinusoide pura con quantizzazione uniforme a $b$ bit è dato dalla formula empirica fondamentale: $$\text{SQNR} \approx 6{,}02\cdot b + 1{,}76 \quad [\text{dB}]$$

Questa formula implica che ogni bit aggiunto incrementa l'SQNR di circa $6{,}02 \text{dB}$. Più è alto il valore di SQNR, migliore è la qualità della quantizzazione del segnale.

## 6.2 *Filtraggio dei segnali* 

### 6.2.1 Segnali rumorosi e artefatti

La catena di acquisizione digitale di un segnale — campionamento, quantizzazione, codifica — produce un segnale numerico che idealmente è una rappresentazione fedele del fenomeno fisico misurato. Nella realtà, i segnali acquisiti presentano quasi sempre ***componenti indesiderate*** che si sovrappongono all'informazione utile, degradando la qualità e l'interpretabilità del segnale e del dato trasmesso.

Queste componenti indesiderate vengono chiamate artefatti (*artifacts*) e si classificano in due categorie:
1. ***Artefatti correlati all'individuo*** (per segnali biomedici): sono disturbi causati dalle stesse attività fisiologiche del soggetto misurato, ma che interferiscono con il segnale di interesse. 
    > ***Esempio.*** Nel caso di un elettroencefalogramma (EEG) o di un elettrocardiogramma (ECG), questi disturbi possono essere causati dal battito di ciglia, i movimenti oculari, gli artefatti cardiaci (pulsazione del sangue, ecc.) e artefatti muscolari (contrazioni muscolari, ecc.)

2. ***Artefatti di origine esterna***: sono disturbi prodotti dall'ambiente di misurazione o dall'apparecchiatura stessa.
    > ***Esempio.*** In questo contesto, alcuni esempi sono rappresentati da artefatti da linea di trasmissione, artefatti da elettrodo e artefatti ambientali.

Il confronto tra il segnale grezzo e il segnale dopo il filtraffio rende chiara la differenza tra i due segnali e permette di analizzarlo in maniera pragmtica e corretta.

> ***Esempio.*** Possiamo notare come, nel confronto tra segnale EEG grezzo e segnale EEG filtrato, in quello filtrato le singole bande di attività cerebrale diventano distinguibili, permettendo così un'analisi accurata del segnale e del dato trasmesso.
> <div align = "center">
> 
> ![alt text](filtered_signal.png)
>
> </div>

Da questo aspetto ci si domanda: come si progetta un'operazione matematica che, applicata ai campioni del segnale digitale, rimuova le componenti indesiderate presercando quelle utili?

### 6.2.2 Definizione di filtraggio

Al fine di migliorare la qualità di un segnale digitale una tecnica di fondamentale importanza è il ***filtraggio***.

> ***Definizione (filtraggio).***  
Il ***filtraggio*** è un'eperazione di elaborazione dei segnali che permette di isolare ed evidenzaire specifiche proprietà del segnale, eliminando contestualmente le componenti indesiderate. 
> 
> Si definisce come una ***funzione d'intorno***: il valore di ogni campione in uscita $y(n)$ non dipende dal campione in ingresso nella stessa posizione $x(n)$ (con $n$ la posizione), ma dall'applicazione di un ***operatore locale*** sui campioni (intorno di campioni vicini) del segnale di ingresso. 

Questa operazione avviene tramite una ***finestra di elaborazione***, la cui estensione è tipicamente molto ridotta rispetto alla durata complessiva del segnale, su un interno di campioni vicini del segnale. 

Intuitivamente, il filtro "guarda" un piccolo gruppo di campioni consecutivi, li combina in qualche modo, e produce un singolo valore in uscita; poi la finestra di elaborazione si sposta di una posizione e il processo si ripete per tutti i campioni del segnale.

> **Osservazione.** Il fatto che il filtro sia una funzione di intorno ha un significato preciso: significa che ciascun campione in uscita $y(n)$ contiene informazione non solo sull'istante $n$, ma anche sugli istanti precedenti e successivi. 

### 6.2.3 Convoluzione: meccanismo di funzionamento dei filtri locali

Il meccanismo con cui i filtri locali (o kernel) trasformano il segnale si chiama ***convoluzione***. Per comprenderlo concretamente, si immagina di far scorrere una piccola sequenza di numeri (pesi numerici) — il *kernel* — lungo il segnale campionato. In ogni posizione, il kernel si "allinea" con un gruppo di campioni vicini, si moltiplica elemento per elemento con essi, e la somma di questi prodotti produce il campione in uscita in quella posizione. 

Formalmente, se il kernel ha dimensione $M$ e i suoi pesi sono $w_1, w_2, \ldots, w_M$ e il segnale in ingresso ha campioni $i_1, i_2, \ldots$, allora il campione di uscita $c_n$ nella posizione $n$ è: 
$$ c_n =  w_1\cdot i_{n-1} + w_2\cdot i_n + w_3\cdot i_{n+1} + \ldots = \sum_{k = 1}^{M} w_k\cdot i_{n+k-\lceil M/2 \rceil} $$
dove: 
- $i$ è calcolato in modo che il kernel sia centrato sul campione $i_n$
- $\lceil M/2 \rceil$ rappresenta l'arrotondamento per eccesso di $M/2$

> ***Esempio.***  
Si consideri il kernel $\mathbf{w} = [w_1,\ w_2,\ w_3]$ e il segnale $\mathbf{i} = [i_1, i_2, i_3, i_4, i_5, i_6]$. Quando il kernel è centrato sul terzo campione $i_3$ (il kernel copre $i_2$, $i_3$, $i_4$): $$c_3 = w_1\cdot i_2 + w_2\cdot i_3 + w_3\cdot i_4$$
> 
> Il kernel si sposta poi sul campione $i_4$ (copre $i_3$, $i_4$, $i_5$), e così via fino all'ultimo campione su cui può essere centrato senza uscire dai bordi del segnale.
>
> <div align = "center">
> 
> ![alt text](filtro_locale.png)
> 
> </div>

La convoluzione è, dunque, la sistematizzazione matematica dell'idea del filtro come funzione d'intorno: i pesi del kernel determinano come i campioni vicini vengono combinati. Cambiando i pesi si ottengono filtri con effetti completamente diversi sul segnale.

### 6.2.4 Filtro di media mobile: effetto passa-basso

#### *Kernel (media mobile)*

Il filtro (kernel) di media mobile è il più semplice filtro lineare e l'esempio più diretto di filtro a effetto passa-basso. Si costruisce con un kernel (ad esempio, di dimensione $3\times 1$) in cui tutti i suoi pesi sono positivi e che sommati danno $1$.

Si consideri il seguente kernel uniforme di dimensione $3$: $$\mathbf{w} = \left[\frac{1}{3}, \frac{1}{3}, \frac{1}{3}\right]$$

Il valore di ciascun campione in uscita è quindi la media aritmetica del campione centrale $x(n)$ e dei suoi due campioni vicini: $$y(n) = \frac{1}{3}\cdot x(n-1) + \frac{1}{3}\cdot x(n) + \frac{1}{3}\cdot x(n+1)$$

> **Perché la somma dei pesi deve essere $1$.**  
La condizione $\sum_k w_k = 1$ garantisce che il filtro non alteri la scala del segnale: se il segnale in ingresso è costante (tutti i campioni uguali a $c$), il segnale in uscita è ancora costante e uguale a $c$. Se i pesi sommassero a un valore diverso da $1$, il filtro amplificherebbe o attenuerebbe il segnale, introducendo una distorsione di ampiezza indesiderata.

#### *Effetto sul segnale: smoothing e soppressione delle alte frequenze*

La media mobile ha un effetto di ***smoothing*** sul segnale. Ogni campione in uscita è la media di tre campioni contigui in ingresso; di conseguenza, le variazioni rapide — che producono differenze grandi tra campioni adiacenti — vengono attenuate dal filtro, perché il valore alto viene "diluito" nella media con i valori vicini. Le variazioni lente che producono campioni contigui simili tra loro, invece, passano attraverso il filtro quasi invariate.

In termini frequenziali, questo meccanismo corrisponde ad un ***filtro passa-basso***: le basse frequenze (variazioni lente) vengono preservate, mentre le alte frequenze (variazioni rapide, picchi di rumore) vengono attenuate. 

Il filtro media mobile è quindi lo strumento principale per ridurre il rumore ad alta frequenza in un segnale digitale.

> ***Esempio.***  
Si consideri il segnale $\mathbf{x} = [10,20,10,30,10]$ e il kernel a media pesata 
> $$\mathbf{w} = [0.2, 0.6, 0.2]$$
> 
> Questo kernel assegna peso maggiore al campione centrale $(0.6)$ e peso minore ai vicini $(0.2)$, con somma $0.2 + 0.6 + 0.2 = 1$ Il kernel scorre lungo il segnale a partire dal primo campione avente un campione a sinistra e a destra, ovvero parte dalla posizione $2$. Rappresenta, quindi, la prima posizione su cui il kernel può essere centrato senza uscire dai bordi.
>
> - Posizione $2$ (campione centrale $20$): il kernel copre i valori $[10,20,10]$
> $$y(2) = (0.2\cdot 10) + (0.6\cdot 20) + (0.2\cdot 10) = 2 + 12 + 2 = 16$$
>
> - Posizione $3$ (campione centrale $10$): il kernel copre i valori $[20,10,30]$
> $$y(3) = (0.2\cdot 20) + (0.6\cdot 10) + (0.2\cdot 30) = 4 + 6 + 6 = 16$$
>
> - Posizione $4$ (campione centrale $30$): il kernel copre i valori $[10,30,10]$
> $$y(4) = (0.2\cdot 10) + (0.6\cdot 30) + (0.2\cdot 10) = 2 + 18 + 2 = 22$$
> 
> Il segnale filtrato per le posizioni interne è quindi $[16,16,22]$. Quindi: 
> $$\text{segnale input: } [10,20,10,30,10] \to \text{segnale filtrato: } [16,16,22]$$
>
>> **Interpretazione.**  Il picco originale a $30$ è stato ridotto a $22$: il valore $30$ è diluito nella media con i valori vicini $10$ e $10$. Il valore $20$ è sceso a $16$ per lo stesso motivo. Questo è esattamente il comportamento di uno smoothing: i valori "esterni" vengono avvicinati ai loro vicini, rendendo il segnale più uniforme.

### 6.2.5 Gestione dei campioni sui bordi

Quando la finestra del kernel si trova alle estremità del segnale, si verifica un problema: i campioni adiacenti che il kernel dovrebbe includere nel calcolo non esistono. 

> ***Esempio.*** Per calcolare il campione di uscita nella posizione $1$ del kernel con un kernel di dimensione $3$, il kernel richiederebbe il campione in posizione $0$, che non è presente nel segnale.

Esistono tre strategie per gestire questo problema:
1. ***Esclusione dei bordi***: non si calcolano i campioni di uscita nelle posizioni in cui il kernel non è completamente contenuto nel segnale. Il risultato è un segnale di uscita più corto di quello di ingresso. Per un kernel di dimensione $M$ su un segnale di lunghezza $N$, il segnale filtrato ha lunghezza $N - M + 1$
    > ***Esempio.*** Nel segnale $[10,20,10,30,10]$ di lunghezzza $N = 5$, il segnale filtrato d'uscita ha $5 - 3 + 1$ campioni invece di $5$, ovvero $[16,16,22]$.

2. ***Zero-padding***: si "allungano" virtualmente i bordi del segnale aggiungendo campioni artificiali di valore zero. Questa strategia consente di produrre un segnale di uscita della stessa lunghezza di quello in ingresso. Questa strategia aggiunge, però, un artefatto: i campioni aggiunti (uguali a zero) influenzano la media nelle posizioni di bordo, abbassando artificialmente il valore del campione filtrato.

3. ***Estensione per periodicità***: si tratta il segnale come se fosse periodico, assumendo che i campioni oltre il bordo destro siano uguali all'inizio del segnale (bordo sinistro), e viceversa. Questa strategia è coerente con l'analisi di Fourier (che tratta i segnali come periodici), ma introduce discontinuità se il segnale non è effettivamente periodico. 

### 6.2.6 Filtro derivato: effetto passa-alto

#### *Kernel (deriavato)* 

Il filtro (kernel) derivato è l'esempio canonico di filtro a effetto passa-alto. A differenza del filtro media mobile, il kernel del filtro derivato contiene pesi di segno opposto che sommati danno $0$. 

Consideriamo, ad esempio, il seguente kernel: $$\mathbf{w} = [-1, 0, 1]$$

Il campione di uscita in posizione $n$ è: $$y(n) = (-1)\cdot x(n-1) + 0\cdot x(n) + (+1)\cdot x(n+1) = x(n+1) - x(n-1)$$

Il valore di uscita è la ***differenza*** tra il campione alla destra e quello alla sinistra del campione centrale. Questa è un'approssimazione discreta della derivata del segnale: misura la variazione del segnale in un intorno del campione $n$. 

> **Nota sulla somma dei pesi.** Si osservi che per questo kernel la somma dei pesi è $-1 + 0 + 1 = 0$. Questo significa che il filtro derivativo elimina completamente le componenti costanti del segnale: se il segnale è costante (tutti i campioni uguali), la differenza tra campioni adiacenti è zero, e l'uscita è zero per ogni posizione. Questo è coerente con l'analogia continua: la derivata di una costante è zero.

#### *Effetto sul segnale: rilevamento dei bordi e aplificazione delle alte frequenze*

Il filtro derivato produce un valore di uscita elevato (in valore assoluto) dove il segnale varia rapidamente — cioè dove c'è un "bordo", un cambiamento brusco di ampiezza — e produce un valore vicino a zero dove il segnale è costante o varia lentamente.

L'effetto è, quindi, opposto rispetto al filtro di media mobile: la variabili rapide (alte frequenze) vengono amplificate, mentre le variabili lente (basse frequenze) vengono soppresse o azzerate.

In termini frequenziali, questo corrisponde ad un ***filtro passa-alto***: le alte frequenze passano, le basse frequenze rimangono bloccate.

> ***Esempio.***  
Si consideri un segnale che simula un gradino: $\mathbf{x} = [10,10,10,50,50,50]$. Il segnale vale $10$ nei primi tre campioni, poi salta a $50$ negli ultimi tre. Il kernel scorre lungo il segnale a partire dal primo campione avente un campione a sinistra e a destra, ovvero parte dalla posizione $2$:
> - Posizione $2$ (campione centrale "10"): il kernel copre $[10,10,10]$
> $$y(2) = (-1\cdot 10) + (0\cdot 10) + (1\cdot 10) = -10 + 10 = 0$$
>
> - Posizione $3$ (campione centrale "10"): il kernel copre $[10,10,50]$
> $$y(3) = (-1\cdot 10) + (0\cdot 10) + (1\cdot 50) = -10 + 50 = +40$$
>
> - Posizione $4$ (campione centrale "50"): il kernel copre $[10,50,50]$
> $$y(4) = (-1\cdot 10) + (0\cdot 50) + (1\cdot 50) = -10 + 50 = +40$$
>
> - Posizione $5$ (campione centrale "50"): il kernel copre $[50,50,50]$
> $$y(5) = (-1\cdot 50) + (0\cdot 50) + (1\cdot 50) = -50 + 50 = 0$$
>
> Il segnale filtrato finale è $[0,+40,+40,0]$.
>
>> **Interpretazione.**  Le parti costanti del segnale (dove il valore non cambia tra campioni vicini) producono un'uscita nulla. Il filtro "vede" zero variazione e risponde con zero. Le posizioni in cui il segnale cambia bruscamente (il gradino da $10$ a $50$) producono un impulso forte ($+40$): il filtro "rileva il bordo" e lo segnala con un valore elevato in uscita.

Il filtro derivativo è quindi uno strumento fondamentale per il ***rilevamento di cambiamenti*** nei segnali

### 6.2.7 Filtro come operatore matematico

I due esempi precedenti mostrano come un filtro riceve un segnale in ingresso e produce un segnale in uscità; è quindi naturale descriverlo come un ***operatore matematico*** di sequenze (in questo caso, di campioni). 

Formalmente, possiamo definire il filtro come una ***funzione $T$*** che prende in ingresso una sequenza intera $x(n)$ e ne restituisce una nuova $y(n)$:
$$y(n) = T[x(n)]$$

<div align = "center">

![alt text](funzione_filtro.png)

</div>

La notazione $T[x(n)]$ si legge: "l'operatore $T$ applicato alla sequenza $x$, valutato nella posizione $n$". Questa formalizzazione è potente perché permette di studiare le proprietà dei filtri in modo astratto — indipendentemente da come è costruito il kernel specifico — attraverso le proprietà matematiche dell'operatore $T$.

## 6.3 *Filtri lineari: principio di sovrapposizione*

Un ***filtro lineare*** è un sistema che applica un operatore lineare a un segnale in ingresso per modificarne determinate caratteristiche (solitamente la frequenza), producendo un segnale in uscita.

> ***Definizione (filtro lineare).***  
Un filtro (o sistema) $T$ si dice ***lineare*** se soddisfa il ***principio di sovrapposizione***: se un ingresso $x_1(n)$ produce l'uscita $y_1(n)$ e un ingresso $x_2(n)$ produce $y_2(n)$, allora verifica le seguenti proprietà
> - ***moltiplicativa o di scala***: un ingresso $\alpha\cdot x_1(n)$ produce l'uscita $\alpha\cdot y_1(n)$ ($\alpha$ è uno scalare)
> - ***additiva***: un ingresso $x_1(n) + x_2(n)$ produce l'uscita $y_1(n) + y_2(n)$

Formalmente, il ***principio di sovrapposizione*** afferma come la risposta $y(n)$ ad una combinazione lineare di ingressi $x(n) =\alpha_1\cdot x_1(n) + \alpha_2\cdot x_2(n) + \ldots$ è uguale alla combinazizone lineare delle risposte del sistema $T$ ai singoli ingressi (presenti nella combinazione lineare degli ingressi) $y(n) = T[x(n)] =\alpha_1\cdot T[x_1(n)] + \alpha_2\cdot T[x_2(n)] + \ldots$

Siano $x_1(n)$ e $x_2(n)$ due segnali in ingresso, e $\alpha_1$, $\alpha_2$ due costanti scalari reali. Il segnale combinato è:

$$x(n) = \alpha_1 x_1(n) + \alpha_2 x_2(n)$$

Il filtro $T$ è ***lineare*** se e solo se:

$$ y(n) = T[x(n)] = T[\alpha_1 x_1(n) + \alpha_2 x_2(n)] = \alpha_1\, T[x_1(n)] + \alpha_2\, T[x_2(n)]$$

In altri termini: filtrare una somma pesata di segnali è equivalente a filtrare ciascun segnale separatamente e poi sommare i risultati pesati.

### 6.3.1 *Decomposizione in due proprietà elementari* 

Il principio di sovrapposizione si può scomporre in due proprietà più semplici, ottenute scegliendo casi speciali dei coefficienti $\alpha_1$ e $\alpha_2$.

1. ***Proprietà moltiplicativa (o di scala)***: si pone $\alpha_2 = 0$ (si considera un solo segnale in ingresso, scalato di $\alpha_1$): $$T[\alpha_1 x_1(n)] = \alpha_1\, T[x_1(n)]$$
Un ingresso scalato di $\alpha_1$ produce un'uscita scalata dello stesso fattore $\alpha_1$. Intuitivamente: se si raddoppia il volume di un suono in ingresso a un filtro lineare, l'uscita del filtro è lo stesso suono ma con il doppio del volume.

2. ***Proprietà additiva***: si pone $\alpha_1 = \alpha_2 = 1$ (si considera la somma di due segnali senza scala): $$T[x_1(n) + x_2(n)] = T[x_1(n)] + T[x_2(n)]$$
La risposta alla somma di due segnali è la somma delle risposte individuali. Intuitivamente: filtrare un segnale che contiene simultaneamente un tono a $440\ \text{Hz}$ e uno a $1000\ \text{Hz}$ è equivalente a filtrare separatamente i due toni e sommare i risultati.

<div align = "center">

![alt text](linearità_filtro.png)

</div>

> ***Esempi: verifica della linearità.***  
Per determinare se un operatore $T$ è lineare si verifica il principio di sovrapposizione: si controlla, quindi $$T[x(n)] = T[\alpha_1 x_1(n) + \alpha_2 x_2(n)] = \alpha_1 T[x_1(n)] + \alpha_2 T[x_2(n)]$$
>
>> **Caso 1: $T[x(n)] = x(n+1)$ (traslazione temporale).**  
>> $$T[\alpha_1 x_1(n) + \alpha_2 x_2(n)] = \alpha_1 x_1(n+1) + \alpha_2 x_2(n+1) = \alpha_1 T[x_1(n)] + \alpha_2 T[x_2(n)] \quad \checkmark$$
>>
>> La traslazione temporale è **lineare**: spostare nel tempo una combinazione lineare equivale a combinare linearmente le singole traslazioni. Questo risultato è intuitivo: l'operatore di ritardo non altera le ampiezze, solo la posizione temporale.
>
>> **Caso 2: $T[x(n)] = n \cdot x(n)$ (moltiplicazione per l'indice $n$)**  
>> $$T[\alpha_1 x_1(n) + \alpha_2 x_2(n)] = n \cdot (\alpha_1 x_1(n) + \alpha_2 x_2(n)) = \alpha_1 n x_1(n) + \alpha_2 n x_2(n) = \alpha_1 T[x_1(n)] + \alpha_2 T[x_2(n)] \quad \checkmark$$
>>
>> Anche questo operatore è **lineare**: il fattore $n$ è una costante (rispetto ai valori del segnale $x$) per ogni posizione fissa, quindi la distribuzione del prodotto è valida.
>
>> **Caso 3: $T[x(n)] = x^2(n)$ (elevamento al quadrato)**  
Si verifica la proprietà moltiplicativa con $\alpha_1 = 2$, $\alpha_2 = 0$:
>> $$T[2 x_1(n)] = (2 x_1(n))^2 = 4 x_1^2(n)$$
>> $$2 \cdot T[x_1(n)] = 2 x_1^2(n)$$
>>
>> Poiché $4 x_1^2(n) \neq 2 x_1^2(n)$ in generale, l'operatore è **non lineare**. La quadratura non preserva la linearità: raddoppiare l'ingresso quadruplica l'uscita.

## Lezione 8

---

# Capitolo 6 — Filtraggio (continuazione)

---

## 6.4 *Filtri non lineari*

Mentre il *filtraggio lineare* si basa su somme e moltiplicazioni e, in generale, sul *principio di sovrapposizione*, nel filtraggio non lineare questa regola non vale. 

Un ***filtro non lineare*** calcola il valore di ogni campione di uscita $y(n)$ applicando una regola logica o un'***operatore di rango*** (*operatore non lineare*) ai campioni della finestra del filtro: anziché combinarili linearmente (moltiplicazione e somma), li ordina e seleziona un valore secondo la posizione nel ranking.

### 6.4.1 Operatore $\max$

L'operatore ***massimo*** ($\max$) è un esempio di operatore non lineare. Si consideri $\mathbf{x_1} = [4,7,2,9,0]$ e $\mathbf{x_2} = [6,3,10,2,1]$, con $\alpha_1 = 1$ e $\alpha_2 = -1$:
$$\max(\alpha_1\mathbf{x_1} + \alpha_2\mathbf{x_2}) = \max(1\cdot[4,7,2,9,0] -1\cdot[6,3,10,2,1]) = \max([4,7,2,9,0] + [-6,-3,-10,-2,-1]) = \max([-2,4,-8,7,-1]) = 7$$
$$\alpha_1\max(\mathbf{x_1}) + \alpha_2\max(\mathbf{x_2}) = 1\cdot 9 + (-1)\cdot 10 = -1$$

Poiché $7\neq -1$, il principio di sovrapposizione è violato: l'operatore massimo ***non è lineare***.

La non linearità implica che i risultati ottenuti appliando il filtro alla somma di due segnali non sono prevedibili a partire dai risultati sui segnali separati. Questo rende l'analisi teorica dei filtri non lineari più complessa; tuttavia, essi hanno impieghi specifici in cui la non linearità è un vantaggio (come per il *filtro mediano*). 

## 6.5 *Filtro mediano*

### 6.5.1 Problema del rumore impulsivo

Nella pratica dell'acquisizione di segnali fisiologici o sensoristici, accade spesso che singoli campioni assumano valori del tutto anomali rispetto al contesto locale: picchi isolati, detti ***spike*** o ***outlier***, prodotti da disturbi transitori come l'attrito di un elettrodo, un'interferenza elettromagnetica momentanea, un battito di ciglia durate un EEG. Questi *spike* si distinguono dal *rumore gaussiano* per due caratteristiche:
- la loro ampiezza è molto maggiore del segnale utile
- la loro durata è breve, spesso riferita ad un solo campione

#### *Spike e filtri lineari*

Come si è visto analizzando il filtro di media mobile, un filtro lineare risponde ad uno *spike* diffondendone l'effetto sui campioni vicini: il valore anomalo, anziché sparire, viene "spalmato" sull'intera finestra di campioni del filtro, contaminando campioni che in origine erano corretti. Questo comportamento è una conseguenza diretta della linearità: il filtro calcola una combinazione lineare di tutti i campioni della finestra, incluso quello anomalo. 

#### *Filtro mediano e spike*

Il *filtro mediano* aggira il problema che lo spike arreca ai filtri lineari: invece di calcolare la media pesata dei campioni della finestra, li *ordina* e ne restituisce il ***valore centrale*** (la *mediana statistica*). La mediana è robusta per costruzione: un valore anomalo, una volta inserito nella sequenza ordinata, finisce inevitabilmente ad un estremo dell'ordinamento e non viene mai selezionato come valore centrale. L'outlier, quindi, viene ignorato e non attenuato (come nei filtri lineari).

### 6.5.2 Definizione e algoritmo del filtro mediano

> ***Definizione (filtro mediano).***  
Il ***filtro mediano*** su un segnale monodimensionale, ovvero una sequenza $x(n)$ con finestra di ampiezza $N$ (dove $N$ è un intero dispari) produce un segnale di uscita $y(n)$ in cui ciascun campione è definito come:
> $$y(n) = \text{mediana}\left(x(n - \lfloor N/2 \rfloor),\ \ldots,\ x(n),\ \ldots,\ x(n + \lfloor N/2 \rfloor)\right)$$
>
> dove la mediana di un insieme di N valori è il valore che occupa la posizione centrale $\left(\frac{N+1}{2}\right)$-esima dopo che i valori sono stati ordinati in senso crescente.

I parametri dell'algoritmo sono:
- $x(n)$: segnale di ingresso, sequenza di campioni digitali (segnale campionato)
- $N$: dimensione della finestra (si usa quasi sempre un numero dispari, affinché esista un campione centrale ben definito)
- $y(n)$: segnale di uscita, avente la stessa lunghezza dell'ingresso (con opportuna gestione dei bordi)

> ***Algoritmo.***  Per ogni posizione $n$ del segnale di ingresso:
> 1. Estrarre i $N$ campioni centrati in $n$: $[x(n - k),\ \ldots,\ x(n),\ \ldots,\ x(n + k)]$, con $k = \lfloor N/2 \rfloor$
> 2. Ordinare i $N$ campioni in senso crescente
> 3. Selezionare il valore nella posizione centrale $\left(\frac{N+1}{2}\right)$-esima
> 4. Assegnare tale valore a $y(n)$

> ***Gestione dei bordi.***  Quando la finestra si affaccia oltre i limiti del segnale (per i campioni iniziali e finali), si adottano le stesse strategie già discusse per il filtro media mobile: mantenere il valore originale, aggiungere zeri (zero-padding) oppure trattare il segnale come periodico. In MATLAB, la funzione `medfilt1` gestisce automaticamente i bordi.

> ***Esempio.***  
Si consideri il segnale $x = [2,3,2,20,3,2,1]$. Il valore $20$ è un *outlier* (*spike*) chiaramente anomalo rispetto al contesto, in cui tutti gli altri valori sono compresi tra $1$ e $3$. Si applica il filtro mediano con finestra $N = 3$. 
>
> <div align = "center">
>
> | Posizione $n$ | Finestra estratta | Ordinamento | Mediana |
> |:-------------:|:-----------------:|:-----------:|:-------:|
> | $2$ | $[2,3,2]$  | $[2,2,3]$  | $2$ |
> | $3$ | $[3,2,20]$ | $[2,3,20]$ | $3$ |
> | $4$ | $[2,20,3]$ | $[2,3,20]$ | $3$ |
> | $5$ | $[20,3,2]$ | $[2,3,20]$ | $3$ |
> | $6$ | $[3,2,1]$  | $[1,2,3]$  | $2$ |
> 
> </div>
>
> Il segnale filtrato risultante (escludendo i campioni di bordo) è: 
> $$y = [?, 2,3,3,3,2, ?]$$
>
> **Nota.** Il campione $20$ in posizione $n=4$ è completamente eliminato dall'uscita. In tutte e tre le finestre che lo contenevano (posizioni $n = 3, 4, 5$), una volta ordinati i valori esso si trovava all'estremo destro dell'ordinamento e non è mai stato selezionato come mediana. Il filtro lo ha ignorato per costruzione, senza che il suo valore numerico influenzasse minimamente l'uscita.

### 6.5.3 Confronto con il filtro di media mobile

Per rendere evidente la differenza tra i due approcci, si applica il filtro di media mobile (con finestra $N = 3$, pesi uniformi $w = [\frac{1}{3}, \frac{1}{3}, \frac{1}{3}]$) alla stessa finestra che contiene lo spike: $[2,20,3]$. 
$$y_{media}(4) = \frac{2+20+3}{3} = \frac{25}{3} \approx 8.33$$

Il filtro di media mobile produce il valore $8.33$, che è molto lontano dallo sia dallo spike $(20)$ sia dai campioni puliti circostanti (intorno a $2-3$). Questo valore contamina l'uscita: dove prima c'era un campione basso, ora appare un picco attenuato ma ancora significativo. Il disturbo non è sparito: è stato redistribuito.

| Criterio | Filtro di media mobile | Filtro mediano |
|---|---|---|
| Operazione sui campioni | Media pesata (combinazione lineare) | Mediana (operatore di rango) |
| Risposta a uno spike isolato | Attenua e sposta l'outlier sui vicini | Elimina completamente l'outlier |
| Dipendenza dall'ampiezza dell'outlier | Sì — un valore più grande contamina di più | No — l'outlier va all'estremo e viene ignorato |
| Linearità | Sì | No |

In sintesi: il filtro di media mobile risponde alla domanda "qual è il valore medio atteso in questo intorno?"; il filtro mediano risponde alla domanda "qual è il valore più rappresentativo in questo intorno, al netto degli estremi anomali?".

## 6.6 *Confronto sperimentale: filtro di media mobile vs filtro mediano al variare del tipo di rumore e della dimensione della finestra*

La scelta tra filtro di media mobile e filtro mediano non è arbitraria: dipende dalla natura del rumore presente nel segnale. Analizziamo i due casi fondamentali — rumore impulsivo e rumore gaussiano — attraverso due script MATLAB.

### 6.6.1 Impostazione degli esperimenti

Entrambi gli scritp utilizzano un ***segnale di riferimento comune***: una sinusoide di base a $50\ \text{Hz}$, campionata a $f_s = 1000\ \text{Hz}$, su un intervallo di durata $T = 0.2\ \text{s}$:

```matlab
fs = 1000;           % Frequenza di campionamento
t = 0:1/fs:0.2;      % Vettore dei tempi discreti (istanti di campionamento)
x = sin(2*pi*50*t);  % Sinusoide pura a 50 Hz, segnale campionato rappresentativo del segnale analogico
```

<div align = "center">

![alt text](image-16.png)

</div>

Questa sinusoide costituisce il segnale utile, con ampiezza unitaria e 10 periodi completi nell'intervallo osservato. Il rumore viene aggiunto artificialmente, con caratteristiche diverse nei due script.

#### *Implementazione in MATLAB dei due filtri*

- ***Filtro di media mobile***: funzione `filter` con coefficienti uniformi `b = ones(1,N)/N` ed `a = 1`. Questa realizza la convoluzione del segnale con un kernel a pesi uniformi
- ***Filtro mediano***: funzione `medfilt1(segnale, N)`, che applica il filtro monodimensionale con finestra di $N$ campioni

### 6.6.2 Scenario 1 — rumore impulsivo (spike)

Il seguente script aggiunge al segnale pulito un rumore impulsivo: il $5\%$ dei campioni del segnale, selezionati casualmente tramite `rand(size(t)) > 0.95`, viene portato al valore $+2$ (il doppio dell'ampiezza di picco $A$ della sinusoide $\sin(2\pi 50t)$):

```matlab
noisy_x = x;  
% Copia il segnale originale "x" (array di campioni) in "noisy_x", così da non modificare direttamente il segnale pulito

spikes = rand(size(t)) > 0.95;  
% Genera un array logico della stessa dimensione di "t":
% - rand(size(t)) produce numeri casuali uniformi tra 0 e 1
% - il confronto > 0.95 restituisce 1 per circa il 5% dei campioni
% → "spikes" indica le posizioni in cui verrà inserito il rumore impulsivo

noisy_x(spikes) = 2;  
% Sostituisce i valori di "noisy_x" nelle posizioni indicate da "spikes"
% (cioè dove spikes == 1) con il valore 2
% → introduce spike impulsivi di ampiezza pari a 2 (maggiore del picco della sinusoide)
```

<div align = "center">

![alt text](image-12.png)

</div>

Il segnale rumoroso presenta quindi picchi verticali isolati di ampiezza $2$, visivamente distinguibili dalla sinusoide di ampiezza $1$.

#### *Risultato con $N = 5$*

> ***Filtro di media mobile.***  
> ```matlab
> % 1. Filtro lineare: media mobile (moving average)
> window_size = 5;  % Lunghezza della finestra del filtro (numero di campioni su cui fare la media)
> b = (1/window_size) * ones(1, window_size);
> a = 1;
> y_linear = filter(b, a, noisy_x);  
> % Applica il filtro al segnale rumoroso "noisy_x"
> % → il risultato "y_linear" è il segnale smussato
> % → il filtro riduce il rumore distribuendo (mediando) i valori nel tempo
> ```
> 
> <div align = "center">
>
> ![alt text](image-14.png)
> 
> </div>
>
> Il filtro distribuisce il valore $2$ dello spike uniformemente sui $5$ campioni della finestra. Ogni spike isolato, anziché sparire, produce un "dosso" di ampiezza ridotta ma esteso su più campioni dell'uscita. Visivamente, il segnale filtrato appare quasi sinusoidale nelle zone senza spike, ma presenta deformazioni locali nelle zone in cui lo spike era presente: l'errore è "spalmato", non eliminato.

> ***Filtro mediano.***  
> ```matlab
> % 2. Filtro non lineare: mediano
> window_size = 5;  
> y_nonlinear = medfilt1(noisy_x, window_size);  
> % Applica un filtro mediano al segnale rumoroso "noisy_x"
> % → per ogni campione, considera una finestra di ampiezza "window_size"
> % → sostituisce il valore centrale con la mediana dei campioni nella finestra
> % → è molto efficace nel rimuovere rumore impulsivo (spike) senza sfumare troppo il segnale
> ```
>
> <div align = "center">
>
> ![alt text](image-15.png)
> 
> </div>
>
> Con $N = 5$, la finestra contiene $5$ campioni. Uno spike isolato occupa una singola posizione; una volta ordinati i $5$ valori, esso si trova all'estremo superiore e non viene selezionato come mediana. Il segnale filtrato in uscita è praticamente identico alla sinusoide originale: gli spike scompaiono completamente. Il filtro mediano con $N = 5$ è **molto efficace** contro spike isolati.

#### *Risultato con $N = 11$*

Considerando il seguente segnale con rumore impulsivo:
<div align = "center">

![alt text](image-17.png)

</div>

> ***Filtro di media mobile.***  
> ```matlab
> % 1. Filtro lineare: media mobile (moving average)
> window_size =11;  
> b = (1/window_size) * ones(1, window_size);
> a = 1;
> y_linear = filter(b, a, noisy_x);  
> ```
> 
> <div align = "center">
>
> ![alt text](image-18.png)
> 
> </div>
>
> Aumentare la finestra a $11$ campioni non risolve il problema degli spike: al contrario, lo aggrava in un senso. Il segnale diventa più levigato nelle zone prive di rumore, ma dove erano presenti gli spike il valore anomalo viene ora distribuito su una regione più ampia. Si osservano inoltre due effetti collaterali negativi importanti:
> 1. ***Attenuazione dell'ampiezza utile.*** La sinusoide a $50\ \text{Hz}$ ha un periodo di $T = 1/50 = 20\ \text{ms}$, corrispondente a $20$ campioni a $f_s = 1000\ \text{Hz}$. Una finestra di $11$ campioni copre già più della metà del periodo. Il filtro inizia a "scambiare" le oscillazioni del segnale utile per variazioni lente da attenuare: la sinusoide in uscita perde ampiezza (l'ampiezza di picco scende da $1$ a circa $0{,}5$-$0{,}6$).
> 2. ***Diffusione degli spike.*** Ogni spike viene diluito su una zona di $11$ campioni, producendo un rigonfiamento ben visibile nel grafico anziché un picco netto.

> ***Filtro mediano.***  
> ```matlab
> % 2. Filtro non lineare: mediano
> window_size = 11;  
> y_nonlinear = medfilt1(noisy_x, window_size);  
> ```
>
> <div align = "center">
>
> ![alt text](image-19.png)
> 
> </div>
>
> Con $N = 11$, il filtro mediano diventa più ***robusto*** contro spike multipli ravvicinati. Se due o tre spike si trovano consecutivi, una finestra piccola ($N = 5$) potrebbe fallire perché la maggioranza dei valori nella finestra sono spike, e la mediana selezionerebbe anch'essa uno spike. Una finestra di $N = 11$ ha un "margine di sicurezza" maggiore: fino a $5$ spike consecutivi vengono eliminati correttamente. 
>
> Tuttavia, emerge un effetto negativo rilevante: la finestra di $11$ campioni supera più della metà del periodo della sinusoide, e il filtro inizia a "tagliare le punte" della sinusoide. Il segnale in uscita assume una forma ***trapezoidale***: le creste e i avvallamenti sinusoidali vengono appiattiti perché, nelle zone di massimo e minimo, la mediana dei $11$ campioni è un valore minore dell'effettivo massimo della sinusoide.

### 6.6.3 Scenario 2 — rumore gaussiano

Il seguente script aggiunge al segnale pulito un rumore gaussiano (bianco), generato con `randn(size(t))` scalato di un'ampiezza $0.2$.

```matlab
noise_amplitude = 0.2;
noisy_x = x + noise_amplitude * randn(size(t));
```

<div align = "center">

![alt text](image-20.png)

</div>

La funzione `randn` genera campioni con distribuzione normale di media $0$ e varianza $1$. Il rumore ha quindi ampiezza tipica $\pm 0{,}2$ e si distribuisce su tutti i campioni in modo continuo, senza picchi isolati. Il segnale rumoroso appare come una sinusoide "frastagliata" lungo tutta la sua estensione.

#### *Risultato con $N = 5$*

> ***Filtro di media mobile.***  
> ```matlab
> % 1. Filtro lineare: media mobile
> window_size = 5;
> b = (1/window_size) * ones(1, window_size);
> a = 1;
> y_linear = filter(b, a, noisy_x);
> ```
> 
> <div align = "center">
>
> ![alt text](image-21.png)
> 
> </div>
>
> Il filtro di media mobile è ben adattato al rumore gaussiano per una ragione matematica precisa: il rumore gaussiano ha ***media zero***. Ogni campione di rumore è la somma di contributi positivi e negativi di pari probabilità. Mediando $5$ campioni adiacenti, i contributi positivi e negativi tendono ad annullarsi reciprocamente. Il risultato è un segnale notevolmente più liscio, con la sinusoide che emerge chiaramente dal rumore. L'ampiezza del segnale utile è preservata, poiché la sinusoide stessa contribuisce coerentemente alla media.

> ***Filtro mediano.***  
> ```matlab
> % 2. Filtro non lineare: mediano
> window_size = 5;  
> y_median = medfilt1(noisy_x, window_size);
> ```
>
> <div align = "center">
>
> ![alt text](image-22.png)
> 
> </div>
>
> Con $N = 5$, il filtro mediano produce un risultato visivamente meno pulito di quello del filtro di media: il segnale di uscita è ancora un po' "frastagliato" e presenta piccole irregolarità. Questo accade perché il rumore gaussiano non ha picchi isolati da ignorare: i valori di rumore si distribuiscono in modo continuo attorno alla sinusoide, e la mediana — che seleziona il valore centrale tra i $5$ disponibili — non può sfruttare il principio di cancellazione che rende efficace la media. La mediana tende a "saltare" da un valore reale all'altro senza effettuare la transizione progressiva che la media garantisce.

#### *Risultato con $N = 11$*

Considerando il seguente segnale con rumore gaussiano:
<div align = "center">

![alt text](image-25.png)

</div>

> ***Filtro di media mobile.***  
> ```matlab
> % 1. Filtro lineare: media mobile
> window_size = 11;
> b = (1/window_size) * ones(1, window_size);
> a = 1;
> y_linear = filter(b, a, noisy_x);
> ```
> 
> <div align = "center">
>
> ![alt text](image-23.png)
> 
> </div>
>
> Con una finestra più ampia, il numero di campioni di rumore mediati aumenta, e la cancellazione statistica diventa più efficace. Il segnale in uscita è più liscio rispetto a $N = 5$, con la sinusoide quasi perfettamente recuperata. Resta però il rischio: se la finestra diventasse molto grande (ad esempio $N = 25$ o $N = 50$, corrispondenti a più di un intero periodo della sinusoide a $50\ \text{Hz}$), la media del segnale utile in una finestra di un intero ciclo sarebbe vicina a zero — il filtro cancellerebbe anche la sinusoide stessa, non solo il rumore.

> ***Filtro mediano.***  
> ```matlab
> % 2. Filtro non lineare: mediano
> window_size = 11;  
> y_median = medfilt1(noisy_x, window_size);
> ```
>
> <div align = "center">
>
> ![alt text](image-24.png)
> 
> </div>
>
> Con $N = 11$, il filtro mediano introduce distorsioni geometriche significative sul rumore gaussiano. Poiché la finestra è ampia e il rumore è distribuito in modo continuo, la mediana inizia a "tagliare" le sommità della sinusoide in modo netto: l'onda sinusoidale si trasforma in una forma simile a un'***onda quadra*** o ***trapezoidale***, con le creste piatte e le transizioni ripide. Questo effetto è dovuto al fatto che, nelle zone di massimo della sinusoide, molti dei $11$ campioni della finestra hanno valori elevati, ma la mediana sceglie il valore intermedio, che è inferiore al massimo effettivo. Il segnale risultante ha preservato la struttura periodica di base, ma ha perso la forma sinusoidale.

### 6.6.4 Tabella riepilogativa

La tabella seguente sintetizza il comportamento comparato dei due filtri nei quattro scenari esaminati.

| | **Filtro di media mobile** | **Filtro mediano** |
|---|---|---|
| **Rumore gaussiano** | Ottimo: sfrutta la media zero del rumore per cancellarlo statisticamente. Con finestre grandi rischia di attenuare il segnale utile. | Discreto: riduce il rumore ma il segnale rimane leggermente frastagliato. Con finestre grandi distorce la forma d'onda (onda trapezoidale). |
| **Rumore impulsivo** | Scarso: l'outlier viene attenuato ma spalmato sui campioni vicini, contaminando zone che erano pulite. | Ottimo: l'outlier va all'estremo dell'ordinamento e viene ignorato. Con finestre grandi gestisce anche spike multipli ravvicinati. |
| **Preservazione dei bordi/transizioni** | Li sfoca: le transizioni nette diventano graduali. | Li preserva: le variazioni brusche vengono mantenute, poiché la mediana non mescola campioni di livelli diversi. |
| **Complessità computazionale** | Bassa: richiede solo una somma e una divisione per ogni campione — $O(N)$ operazioni. | Media: richiede l'ordinamento dei $N$ campioni per ogni posizione — $O(N \log N)$ operazioni con algoritmi efficienti. |

### 6.6.5 Criteri di scelta della dimensione della finestra

Indipendentemente dal tipo di filtro, la scelta della dimensione $N$ della finestra è governata da due vincoli contrapposti che definiscono un intervallo ammissibile dei suoi valori:
1. ***vincolo inferiore***: la finestra deve essere ***sufficientemente grande*** da coprire la durata del disturbo (rumore) più lungo che si intende eliminare. Per spike singoli, $N = 3$ o $N = 5$ è sufficiente; per gruppi di spike ravvicinati, $N$ deve essere almeno il doppio del numero massimo di spike consentito più uno
2. ***vincolo superiore***: la finestra deve essere sufficientemente piccola da non coprire i dettagli importanti del segnale utile, quali la larghezza di un picco fisiologico o la durata di una transizione rilevante. Come regola pratica, la finestra non dovrebbe superare un quarto del periodo della componente di frequenza più bassa del segnale utile

Il valore ottimale di $N$ si trova bilanciando questi due vincoli: è sempre il risultato di un compromesso tra capacità di soppressione del rumore e fedeltà al segnale utile.

## 6.7 *Filtri lineari nel dominio delle frequenze*

### 6.7.1 Dalla convoluzione alla risposta in frequenza

Fino ad ora i filtri sono stati descritti nel dominio del tempo: il filtro di media mobile produce smoothing sul segnale, dove le basse frequenze vengono preservate e le alte frequenze alte vengono attenuate; il filtro derivato enfatizza le alte frequenze, sopprimendo o azzerando le basse frequenze.

#### *Funzione di trasferimento*

Per rispondere alla domanda "quali frequenze vengono attenuate e quali vengono preservate?", dobbiamo caratterizzare i filtri direttamente nel ***dominio delle frequenze***. Il motivo è il seguente: la convoluzione nel dominio del tempo equivale a una moltiplicazione nel dominio delle frequenze. Di conseguenza, se un segnale viene scomposto nelle sue componenti sinusoidali, il filtro agisce su ognuna di queste componenti moltiplicandola per un fattore che dipende dalla frequenza. 

In altre altre parole, un filtro lineare moltiplica ad ogni componente di un segnale un fattore detto ***funzione di trasferimento $H(f)$*** del filtro: indica, per ogni frequenza $f$, come il filtro modifica quella componente del segnale, specificando quando il filtro la moltiplichi (amplifichi o attenuti). 

#### *Risposta in ampiezza*

La quantità più intuitiva da interpretare è la ***risposta in ampiezza*** (o *risposta in frequenza*).

La risposta in ampiezza, indicata come il modulo della funzione di trasferimento $$|H(f)|$$ indica di quando viene moltiplicata l'***ampiezza*** di una sinusoide alla frequenza $f$, ovvero ne specifica il guadagno che il filtro applica al segnale. In particolare:
- $|H(f)| = 1$: la componente con frequenza $f$ passa inalterata nel filtro
- $|H(f)| = 0$: la componente con frequenza $f$ viene annullata (soppressa) dal filtro
- $0 < |H(f)| < 1$: la componente con frequenza $f$ viene attenuata
- $|H(f)| > 1$: la componente viene amplificata

Se il segnale di ingresso ad un filtro contiene una componente sinusoidale del tipo $$x(t) = A\sin(2\pi ft)$$ all'uscita del filtro si ottiene, idealmente $$y(t) = A\cdot|H(f)|\sin(2\pi ft + \omega)$$ dove $\omega$ è l'eventuale fase (spostamento del segnale lungo l'asse del tempo) introdotto dal filtro.

In altre parole, la ***risposta in ampiezza*** dice esattamente ***quanto dell'ampiezza originale sopravvive dopo il filtraggio***.

### 6.7.2 Classificazione dei filtri lineari per banda

I filtri lineari si classificano in quattro categorie fondamentali in base alla forma della loro *risposta in ampiezza*, ovvero definite in base all'intervallo di frequenze che lasciano passare (banda passante) rispetto a quello che attenuano (banda di attenuazione).

#### *Filtro passa-basso*

Questo filtro lascia passare le frequenze inferiori ad una soglia chiamata ***frequenza di taglio*** (o di cutoff) $f_c$, e attenua le frequenze superiori a questa frequenza. Matematicamente, la risposta in ampiezza *ideale* soddisfa:

$$|H(f)| \approx 1 \quad \text{per }\, f < f_c \qquad |H(f)| \approx 0 \quad \text{per }\, f > f_c$$

<div align = "center">

![alt text](filtro_passa_basso.png)

</div>

Tale filtro ha un effetto preciso sul segnale in ingresso $x(n)$: elimina le variazioni rapide (rumore ad alta frequenza) preservando l'andamento lento del segnale (basse frequenze). Per questo motivo un filtro passa-basso è spesso usato per *ridurre il rumore ad alta frequenza*. Un filtro media mobile è un esempio di filtro passa-basso non ideale. 

Viene utilizzato tipicamente come filtro anti-aliasing prima della conversione analogico-digitale, per garantire che le componenti ad alta frequenza del segnale non producano aliasing. In questo caso, il filtro passa-basso viene applicato al segnale analogico prima del campionamento, limitando la banda del segnale (le frequenza che possono passare attraverso il filtro) alla frequenza di Nyquist $\frac{f_s}{2}$.

#### *Filtro passa-alto*

Questo filtro lascia passare le frequenze superiori a $f_c$ e attenua/blocca le frequenze inferiori. La risposta in ampiezza ideale soddisfa:

$$|H(f)| \approx 1 \quad \text{per }\, f > f_c \qquad |H(f)| \approx 0 \quad \text{per }\, f < f_c$$

<div align = "center">

![alt text](filtro_passa_alto.png)

</div>

Il filtro passa-alto ideale blocca completamente la ***frequenza continua*** (DC, corrispondente alla componente a $f = 0\ \text{Hz}$) e tutte le basse frequenze fino a $f_c$. Questo ha un effetto ben preciso sul segnale: enfatizza le variazioni brusche (frequenze alte) e i dettagli fini, sopprimendo le variazioni lente (frequenze basse, derive, offset). 

In altre parole, un filtro passa-alto è l'opposto del filtro passa-basso: attenua le basse frequenze e lascia passare le alte. Un filtro derivato con kernel $[-1,0,1]$ è un esempio di filtro passa-alto.

#### *Filtro passa-banda*

Questo filtro lascia passare le frequenze comprese in un intervallo specifico $[f_1, f_2]$ (la banda passante, frequenze che passano il filtro) e attenua tutto il resto — sia le componenti inferiori a $f_1$ sia quelle superiori a $f_2$. 

$$|H(f)| \approx 1 \quad \text{per }\, f_1 < f < f_2 \qquad |H(f)| \approx 0 \quad \text{altrove} $$

<div align = "center">

![alt text](filtro_passa_banda.png)

</div>

È lo strumento ideale quanto il segnale utile è localizzato in un intervallo di frequenze preciso e si vogliono eliminare sia il rumore ad alta frequenza sia le derive a bassa frequenza.

#### *Filtro arresta banda*

Detto filtro ***elimina banda*** o ***notch***, è il complementare al filtro passa-banda: attenua pesantemente le frequenze appartenenti ad un intervallo stretto $[f_1, f_2]$ e lascia passare tutto il resto.

<div align = "center">

![alt text](filtro_arresta_banda.png)

</div>

È il filtro più adatto quando si conosce con precisione la frequenza di un disturbo da eliminare.

### 6.7.3 Implementazione digitale di un filtro

Nei sistemi digitali (discreti, segnali discreti, campionati), un filtro non è implementato (descritto) direttamente tramite la funzione di trasferimento $H(f)$, ma attraverso una funzione di trasferimento nel dominio $z$:
$$H(z) = \frac{b_0 + b_1 z^{-1} + \ldots b_M z^{-M}}{a_0 + a_1 z^{-1} + \ldots + a_M z^{-N}} = \frac{B(z)}{A(z)}$$
dove:
- $b_k$: coefficienti del numeratore
- $a_k$: coefficienti del denominatore

Questa rappresentazione definisce completamente il filtro (digitale) e determina la relazione tra segnale di ingresso al filtro $x(n)$ e segnale in uscita dal filtro $y(n)$ (il segnale filtrato).

> ***Ricorda.*** I coefficienti $b$ ed $a$ ***definiscono il filtro***, cioè determinano completamente il suo comportamento. Da questi coefficienti si ricava la risposta in ampiezza.

> **Nota.** In ambienti di calcolo come MATLAB, vengono restituiti questi coefficienti in modo tale da poter implementare il filtro numericamente, ricostruendo successivamente il segnale filtrato $y(n)$ a partire dai valori dei coefficienti $b$ ed $a$.

#### *Forma generale per qualsiasi filtro digitale*

La funzione di trasferimento nel dominio $\mathbf{z}$: 
$$H(z) = \frac{B(z)}{A(z)}$$

ha una forma generale valida per qualsiasi filtro digitale lineare (tempo-invariante) (es. passa-basso, passa-alto, passa-banda, Butterworth, ecc.).

#### *Implementazione filtro digitale in MATLAB*

Per la costruzione di un filtro digitale in MATLAB, si usa la seguente funzione:
```matlab
[b, a] = butter(N, Wn);
```
dove:
- $N$: ordine del filtro
- $Wn = \frac{f_c}{f_N}$: frequenza di cutoff normalizzata rispetto alla frequenza di Nyquist
- $b,\; a$: coefficienti della funzione di trasferimento $H(z)$

In questo specifico contesto, stiamo costruendo un filtro digitale la cui risposta in ampiezza approssima la formula teorica della risposta in ampiezza del filtro di Butterworth. 

Altre implementazioni dello stesso comando, permettono di rappresentare altri filtri. Ad esempio:
```matlab
[b, a] = butter(N, Wn, 'low');   % passa-basso
[b, a] = butter(N, Wn, 'high');  % passa-alto
```
implementano i filtri passa-basso e passa-alto.

### 6.7.4 Filtro passa-basso nel dominio delle frequenze

#### *Funzione di trasferimento ideale*

Un filtro passa-basso ideale ha una funzione di trasferimento definita a tratti: 

$$H_{ideale}(f) = \begin{cases} 1 & \text{se } |f| \leq f_c \\ 0 & \text{se } |f| > f_c \end{cases}$$

dove $f_c$ è la frequenza di cutoff. La sua interpretazione è immediata: tutte le frequenze inferiori o uguali alla cutoff passano inalterate, tutte le altre vengono eliminate.
- risposta in ampiezza $|H(f)| = 1$ per tutte le frequenze inferiori a $f_c$ (guadagno unitario: la componente con frequenza $f\leq f_c$ passa inalterata)
- $|H(f)| = 0$ per le frequenze superiori (soppressione totale). 

Questo filtro ***preserva la componente continua*** (DC), poiché $f = 0 < f_c$. 

<div align = "center">

![alt text](filtro_passa_basso_ideale.png)

</div>

Quindi, la funzione di trasferimento ideale è una funzione definita a tratti, che assume valore 1 (guadagno unitario) quando $f \leq f_c$, mentre assume valore $0$ altrove.

#### *Problema del filtro ideale*

Un filtro con la risposta in ampiezza a forma di rettangolo perfetto descritta sopra non è realizzabile fisicamente con un numero finito di coefficienti. Nella realtà, infatti, si ricorre ad ***approssimazioni*** del filtro ideale.

#### ***Filtro di Butterworth passa-basso***

Tra le apporssimazioni del filtro passa-basso ideale, quello più usato è il ***filtro di Butterworth***, scelto per la sua ***risposta monotona*** e ***senza oscillazioni***. La sua caratteristica principale è la massima piattezza nella banda passante: la risposta in ampiezza è il più possibile vicina ad $1$ per $f\leq f_c$ e descrescente in modo progressivo (senza oscillazioni) per $f > f_c$. 

Inoltre la transizione da $1$ a $0$ non è istantanea ma segue una pendenza (chiamata ***roll-off***) determinata dall'***ordine $N$ del filtro***. Il roll-off rappresenta la risposta di un Butterworth che, spesso, viene spesso espressa in potenza:
$$|H(f)|^2 = \frac{1}{1 + \left(\frac{f}{f_c}\right)^{2N}} \quad \text{risposta in potenza}$$
dove:
- $f$: frequenza della componente in esame ($\text{Hz}$)
- $f_c$: frequenza di cutoff ($\text{Hz}$) — la frequenza alla quale il guadagno vale $\frac{1}{\sqrt{2}} \approx 0.707$ (ovvero $-3\ \text{dB}$)
- $N$: ordine del filtro. Maggiore è $N$, più ripida è la transizione attorno a $f_c$ e più il filtro si avvicina al comportamento ideale (è più simile ad una transizione a scalino)

La corrispondente risposta in ampiezza è: 
$$|H(f)| = \frac{1}{\sqrt{1 + \left(\frac{f}{f_c}\right)^{2N}}} \quad \text{risposta in ampiezza}$$

Questa distinizione è fonndamentale, in quanto:
- $|H(f)|$ dice quanto resta dell’ampiezza;
- $|H(f)|^2$ dice quanto resta della potenza.

<div align = "center">

![alt text](filtro_butterworth.png)

</div>

Quindi:
- $f < f_c \to |H(f)| \approx 1 \to \text{passa}$
- $f = f_c \to |H(f)| \approx 0.707$
- $f > f_c \to |H(f)| \approx 0 \to \text{attenuato}$

mantenendo quindi variazioni lente ed eliminando variazioni rapide nelle componenti del segnale.

---

> ***Cosa significa $|H(f)|$.***  
$|H(f)|$ è il ***guadagno in ampiezza***. Se una sinusoide in ingresso al filtro ha ampiezza $A$, in uscita avrà ampiezza $$A_{out} = A |H(f)|$$ quindi:
> - se $|H(f)| = 1$, l'ampizza resta identica
> - se $|H(f)| = 0.707$, l'ampiezza finale è il $70.7\%$ di quella iniziale, ovvero è stata attenuata del $29.3\%$
> - se $|H(f)| = 0.1$, l'ampiezza finale è il $10\%$ di quella iniziale, ovvero è stata attenuata del $90\%$
>
>> **Nota.** Non è una riduzione di $0.707$ in senso assoluto, ma una riduzione al $70.7\%$ del valore iniziale

> ***Perché si parla di $-3\ \text{dB}$.***  
Alla frequenza di taglio $f_c = f$, la formula di Butterworth da: $$|H(f_c)|^2 = \frac{1}{2} \qquad |H(f_c)| = \frac{1}{\sqrt(2)} \approx 0.707$$
>
> Questo vuol dire che:
> - l'ampiezza si riduce al $70.7\%$
> - la potenza in uscita dal filtro si riduce della metà rispetto a quella iniziale
> 
> La ragione è semplice: la potenza di una sinusoide è $P \propto A^2$, ovvero è proporzionale al quadrato dell'ampiezza. Per una sinusoide, se l'ampiezza viene moltiplicata per un fattore $k$, la potenza viene moltiplicata per un $k^2$. 
> 
> Nel nostro caso, se l'ampiezza viene moltiplicata per $k = \frac{1}{\sqrt 2}$, la potenza viene moltiplicata per $$k^2 = \left(\frac{1}{\sqrt 2}\right)$$ cioè $$P_{out} = \frac{1}{2}P_{in}$$
>
>> ***Da dove viene questa relazione?***  
Per un segnale sinusoidale puro $x(t) = A\sin(2\pi ft)$, la potenza media è proporzionale ad $A^2$. Più precisamente, su un carico unitario, la potenza media è $P = \frac{A^2}{2}$. Se il filtro riduce l'ampiezza da $A$ a $\frac{A}{\sqrt 2}$, allora la potenza diventa: $$P_{out} = \frac{(A/\sqrt 2)^2}{2} = \frac{A^2/2}{2} = \frac{1}{2}\cdot \frac{A^2}{2} = \frac{1}{2}P_{in}$$
>
>> ***Attenuazione di $3\ \text{dB}$***  
I decibel sono un modo logaritmico di esprimere un rapporto di potenze: $$\text{dB} = 10\log_{10}\left(\frac{P_{out}}{P_{in}}\right)$$ Se la potenza si dimezza $$\frac{P_{out}}{P_{in}} = \frac{1}{2}$$ allora: $$10\log_{10}\left(\frac{1}{2}\right) \approx -3.01\ \text{dB}$$ Per questo motivo, alla frequenza di taglio di Butterworth si dice che il filtro è $-3\ \text{dB}$: la potenza è scesa della metà.
>
>> ***Rapporto generale tra $P_{out}$ e $|H(f)|^2$.***  
Generalmente, una volta calcolato $|H(f)|^2$, allora la potenza in uscita dal filtro è: $$P_{out} = |H(f)|^2 P_{in} \quad [\text{Watt}] $$ Nel caso da noi analizzato, con sinusoide pura $A\sin(2\pi ft)$, abbiamo $$P_{out} = |H(f)|^2\cdot \frac{A^2}{2} \quad [\text{Watt}]$$ che, in decibel $$P_{out_{dB}} = 10\log_{10}(P_{out}) \quad [\text{dB}]$$ L'attenuazione di potenza del segnale attuata dal filtro è pari a $$10\log_{10}\left(\frac{P_{out}}{P_{in}}\right) \quad [\text{dB}]$$

> ***Ruolo dell'ordine $N$.***  
L'ordine $N$ controlla la rapidità del passaggio tra banda passante e banda attenuata, cioè il ***roll-off***. Più $N$ è grande, più il filtro si avvicina al comportamento ideale. In questo contesto, nei Butterworth l'ordine descrive la complessità del filtro e la rapidità della sua transizione in frequenza.

> ***Esempio: Butterworth passa-basso***  
Prendiamo un Butterworth passa-basso di ordine $N = 2$, con cutoff $f_c = 200\ \text{Hz}$.
> - A $f = 50\ \text{Hz}$, molto sotto il cutoff, è atteso un guadagno vicino a $1$: il segnale passa quasi invariato in ampiezza $$|H(f)|^2 = \frac{1}{1 + \left(\frac{50}{200}\right)^4} \approx 0.996 \qquad |H(f)| = \sqrt{|H(f)|^2} \approx 0.997$$ La componente a $f = 50\ \text{Hz}$ passa praticamente inalterata in ampiezza
>
> - A $f = 200\ \text{Hz}$, il guadagno vale $\frac{1}{\sqrt{2}}\approx 0.707$: si è esattamente al punto di taglio $$|H(f)|^2 = \frac{1}{1 + \left(\frac{200}{200}\right)^4} = \frac{1}{2} \qquad |H(f)| = \frac{1}{\sqrt{2}}$$ La componente a $200\ \text{Hz}$ passa, ma attenutata del $29.3\%$ in ampiezza e dimezzata in potenza
>
> - A $f = 900\ \text{Hz}$, molto sopra al cutoff, è atteso un guadagno molto piccolo vicino allo $0$: il segnale passa viene fortemente attenuato $$|H(f)|^2 = \frac{1}{1 + \left(\frac{900}{200}\right)^4} \approx 0.0024 \qquad |H(f)| \approx 0.049$$ La componente a $900\ \text{Hz}$ è stata soppressa del $95.1\%$, quindi è stata fortemente attenuata dal filtro
---

In MATLAB, il filtro Butterworth passa-basso di ordine $N$ con frequenza di cutoff $f_c$ è progettato come segue:
```matlab
fc = 300;    % Frequenza di taglio (Hz)
fs = 1000;   % Frequenza di campionamento (Hz)

% Secondo la legge di Nyquist, la frequenza massima rappresentabile è fs/2 = 500.
% La frequenza di cutoff va normalizzata rispetto a fs/2
[b,a] = butter(6, fc/(fs/2)); 
freqz(b,a,[],fs);  % Visualizza automaticamente la risposta in ampiezza del filtro sul segnale
```

In questo contesto, la funzione `freqz(b, a, [], fs)` visualizza automaticamente la risposta in ampiezza (magnitudine e fase) in Hz, mostrando come il filtro lasci passare le frequenza $f_s < f_c$ ed attenui drasticamente le componenti tra $300$ e $500\ \text{Hz}$. 

> ***Normalizzazione della frequenza di taglio.***  
In un sistema digitale, la frequenza di cutoff deve essere espressa in forma normalizzata rispetto alla frequenza di Nyquist: 
> $$f_N = \frac{f_s}{2} \qquad W_n = \frac{f_c}{f_N} = \frac{2f_c}{f_s}$$
>
> Questo perché MATLAB, nella progettazione digitale, lavora con frequenze normalizzate, cioè adimensionali. Se ad esempio $f_s = 100\ \text{Hz}$ e $f_c = 300\ \text{Hz}$, allora: 
> $$f_N = 500\ \text{Hz} \qquad W_n = \frac{300}{500} = 0.6$$
>
>> **Nota.** La normalizzazione non serve ad evitare l'aliasing in senso diretto: l'aliasing dipende dal campionamento del segnale. La normalizzazione serve, invece, a progettare correttamente il filtro digitale in relazione al limite imposto dal campionamento.

Questo ci fa capire che questo filtro è ideale per pulire un segnale da rumori ad alta frequenza mantenendo l'integrità della banda bassa.

<div align = "center">

![alt text](image-27.png)
![alt text](image-28.png)

</div>

---

#### *Esempio applicativo filtro Butterworth*

Si consideri un segnale composto da una sinusoide utile a $50\ \text{Hz}$, campionato a $f_s = 1000\ \text{Hz}$ e da un disturbo ad alta frequenza a $400\ \text{Hz}$. 

```matlab
% 1. Parametri del segnale
fs = 1000;
t = 0:1/fs:0.2;

% 2. Creazione del segnale: utile (50Hz) + disturbo (400 Hz)
segnale_pulito = sin(2*pi*50*t);
disturbo = 0.5*sin(2*pi*400*t);
segnale_rumoroso = segnale_pulito + disturbo;

% 3. Progettazione del filtro
fc = 300;
[b, a] = butter(6, fc/(fs/2));

% 4. Applicazione del filtro sul segnale
segnale_filtrato = filtfilt(b, a, segnale rumoroso);

% 5. Visualizzazione risultati
figure;
```

<div align = "center">

![alt text](image-26.png)

</div>

---

### 6.7.5 Filtro passa-alto nel dominio delle frequenze

Il filtro passa-alto è il complementare del filtro passa-basso: la sua funzione di trasferimento ideale vale $1$ per le frequenze superiori a $f_c$ e $0$ per le frequenze inferiori: 
$$H_{ideale}(f) = \begin{cases} 0 & \text{se } |f| \leq f_c \\ 1 & \text{se } |f| > f_c \end{cases}$$

Un filtro passa-alto ideale ***blocca completamente la frequenza continua*** (DC, $f = 0 < f_c$) e tutte le frequenze lente fino a $f_c$. La risposta in ampiezza reale (ad esempio Butterworth) cresce gradualmente da $0$ verso $1$ con un *roll-off* determinato dall'ordine: alla frequenza di cufoff $f_c$ il guadagno vale $\frac{1}{\sqrt{2}} \approx 0.707$ (ovvero $-3\ \text{dB}$).

#### *Problema del filtro ideale*

Anche in questo caso, il filtro passa-alto ideale non è realizzabile fisicamente. Nella realtà, si ricorre ad approssimazioni del filtro ideale passa-alto tramite il ***filtro di Butterworth passa-alto***.

#### ***Filtro di Butterworth passa-alto***  

Il ***filtro di Butterworth passa-alto*** si ottiene dalla forma base del filtro di Butterworth invertendo il ruolo delle frequenze, infatti $$f \to \frac{f_c}{f}$$ Da qui abbiamo quindi: 
$$|H_{HP}(f)|^2 =  \frac{1}{1+\left(\frac{f_c}{f}\right)^{2N}} \qquad |H_{HP}(f)| = \sqrt{\frac{1}{1+\left(\frac{f_c}{f}\right)^{2N}}}$$

Quindi:
- $f < f_c \to |H(f)| \approx 0 \to \text{attenutato}$
- $f = f_c \to |H(f)| \approx 0.707$
- $f > f_c \to |H(f)| \approx 1 \to \text{passa}$

eliminando quindi variazioni lente (DC incluso) e mantenendo variazioni rapide nelle componenti del segnale.

### 6.7.5 Differenze tra i due filtri

Consideriamo un segnale misto $x(t) = \sin(2\pi 2t) + 0.5\sin(2\pi 50t)$ con frequenza di taglio $f_c = 10\ \text{Hz}$:
- Il ***filtro passa-basso*** lascia passare solo le frequenze $f \leq f_c$ a $2\ \text{Hz}$, eliminando quella a $50\ \text{Hz}$: in questo caso, passa solo $\sin(2\pi 2t)$ $(f = 2\ \text{Hz})$
- Il ***filtro passa-alto*** lascia passare solo le frequenze $f \geq f_c$ a $50\ \text{Hz}$, eliminando quella a $2\ \text{Hz}$: in questo caso, passa solo $0.5\sin(2\pi 50t)$ $(f = 50\ \text{Hz})$

<div align = "center">

![alt text](differenze_passa_alto_basso.png)

</div>

I due filtri sono quindi complementari: applicati allo stesso segnale, decompongono il segnale nelle sue componenti a frequenza bassa e alta, rispettivamente.

---

## 6.8 *Normalizzazione della frequenza*

Nel contesto dell'elaborazione dei segnali, le frequenze possono essere espresse in Hertz (Hz). Tuttavia, questa rappresentazione dipende direttamente dalla frequenza di campionamento $f_s$ (come già spiegato nei capitoli iniziali). In particolare:
- una stessa frequenza (ad esempio $f = 100\ \text{Hz}$) può avere significati diversi a seconda del valore di $f_s$
- la progettazione dei sistemi digitali (come i filtri) richiede una rappresentazione ***indipendente dall'unità fisica***

È quindi necessario introdurre una forma di rappresentazione ***normalizzata della frequenza***.

### 6.8.1 Frequenza normalizzata

La ***normalizzazione della frequenza*** consiste nell'esprimere una frequenza $f$ come rapporto rispetto ad una frequenza di riferimento. 

Nel contesto del *campionamento*, la scelta naturale come riferimento è la ***frequenza di Nyquist***: $$f_N = \frac{f_s}{2}$$

Si definisce quindi ***frequenza normalizzata rispetto a Nyquist*** la quantità: 
$$f_{norm} = \frac{f}{f_N} = \frac{2f}{f_s}$$

---

#### *Interpretazione* 

La frequenza noramlizzata $f_{norm}$ è una quantità ***adimensionale*** che rappresenta la posizione della frequenza $f$ rispetto al limite massimo rappresentabile senza aliasing. I valori notevoli sono:
- $f_{norm} = 0 \to$ componente continua (DC)
- $0 < f_{norm} < 1 \to$ frequenze correttamente rappresentabili
- $f_{norm} = 1 \to$ frequenza di Nyquist
- $f_norm > 1 \to$ frequenze non rappresentabili correttamente: aliasing

Questo garantisce che tutte le frequenze vengano interpretate in relazione al limite massimo imposto da $f_N$ (in relazione con $f_s$).

> ***Esempio.***  
Si consideri un sistema con $f_s = 1000\ \text{Hz}$. Allora: $$f_N = \frac{1000}{2} = 500\ \text{Hz}$$ Per una frequenza $f = 100\ \text{Hz}$, si ottiene $$f_{norm} = \frac{100}{500} = 0.2$$ ovvero, la frequenza considerata è pari al $20\%$ della frequenza di Nyquist.

#### Utilizzo nella progettazione dei sistemi digitali

Nella progettazione di filtri e sistemi DSP, si preferisce lavorare con frequenze normalizzate, perché:
- le formule diventano indipendenti da $f_s$
- evidenzia il limite imposto dalla frequenza di campionamento
- un progetto può essere modificato cambiando solo la frequenza di campionamento
- si evita di lavorare continuamente su unità fisiche

> ***Esempio: frequenza di taglio normalizzata***  
Si consideri un filtro con frequenza di taglio: $$f_c = 200\ \text{Hz}\; e \;f_s = 1000\ \text{Hz}$$ Allora: $$f_{c,\,norm} = \frac{2\cdot 200}{1000} = 0.4$$ Il filtro può essere progettato utilizzando il valore normalizzato $0.4$, indipendentemente dal sistema fisico.  

---

---

## Lezione 9

---

# Capitolo 6 — Filtraggio (continuazione): esempi MATLAB, denoising audio e rapporto segnale-rumore

---

## Introduzione al capitolo

Il capitolo precedente ha costruito l'intero quadro teorico del filtraggio nel dominio delle frequenze: la classificazione dei filtri lineari (*passa-basso*, *passa-alto*, *elimina-banda*), la *funzione di trasferimento* (ideale e reale), il *filtro di Butterworth* come approssimazione pratica con massima piattezza della banda passante, e l'effetto dell'ordine del filtro sulla pendenza di roll-off. Quella trattazione, pur completa dal punto di vista teorico, si limitava a descrivere i filtri come oggetti matematici.

Il presente capitolo affronta questi argomenti da una prospettiva pratica e applicativa, mostrado come le scente progettuali teoriche — il tipo di filtro, la frequenza di taglio, l'ordine — si traducano in risultati concreti e misurabili su segnali reali.

---

## 6.8 *Filtro passa-basso e passa-alto: separazione di componenti frequenziali*

### 6.8.1 Problema della separazione spettrale

Si consideri il segnale $x(t)$ composto da due sinusoidi a frequenze molto diverse: 
$$x(t) = \sin(2\pi\cdot 2\cdot t) + 0.5\sin(2\pi\cdot 50\cdot t)$$

dove:
- $\sin(2\pi\cdot 2\cdot t)$ — componente a $2\ \text{Hz}$ — rappresenta una ***variazione lenta*** del segnale (ad esempio, un artefatto di movimento in un ECG, una deriva termica, ecc.)
- $0.5\sin(2\pi\cdot 50\cdot t)$ — componente a $50\ \text{Hz}$ — rappresenta una ***varaizione veloce*** del segnale (ad esempio, segnale fisiologico utile, un disturbo di rete, ecc.)

Queste due componenti si sovrappongono nel segnale $x(t)$ e non sono distinguibili nel grafico in funzione del tempo, in cui l'ampiezza totale oscilla mostrando contemporaneamente le variazioni lente e veloci.

L'obiettivo è ***separare*** le due componenti: estrarre da $x(t)$ solo la componente lenta con un filtro passa-basso, e solo la componente veloce con un filtro passa-alto. 

> **Nota.** Si è scelta una frequenza di taglio $f_c = 10\ \text{Hz}$ per avere un compromesso ottimale per la ricezione di più dettagli possibili delle due componenti una volta utilizzati i filtri. Questa frequenza, infatti, è $2\ \text{Hz} < f_c < 50\ \text{Hz}$: se $f_c$ fosse troppo bassa, il filtro passa-basso non riuscirebbe a cogliere il segnale (o alcuni dei suoi dettagli) a variazione lenta; se $f_c$ fosse troppo alto, il filtro passa-alto non riuscirebbe a cogliere il segnale (o alcuni dei suoi dettagli) a variazione rapida.

### 6.8.2 Costruzione del segnale e progettazione del filtro

```matlab
fs = 1000;       % Frequenza di campionamento (Hz)
t = 0:1/fs:1;    % Vettore tempo: 1 secondo, con periodo di campionamento T_s = 1/1000.
f_slow = 2;      % Frequenza della componente lenta (Hz) (es. deriva)
f_fast = 50;     % Frequenza della componente veloce (Hz) (es. disturbo)

% Segnale misto (campionato): componente lenta + componente veloce con ampiezza 0.5
x = sin(2*pi*f_slow*t) + 0.5*sin(2*pi*f_fast*t);

% --- PROGETTAZIONE FILTRI --- %
fc = 10;            % Frequenza di taglio condivisa (Hz)
Wn = fc / (fs/2);   % Normalizzazione del segnale rispetto alla frequenza di Nyquist

% Filtro passa-basso (ordine 4): lascia passare f < 10 Hz
[b_lp, a_lp] = butter(4, Wn, 'low');
y_low = filter(b_lp, a_lp, x);         % Segnale filtrato da filtro passa-basso

% Filtro passa-alto (ordine 4): lascia passare f > 10 Hz
[b_hp, a_hp] = butter(4, Wn, 'high');
y_high = filter(b_hp, a_hp, x);        % Segnale filtrato da filtro passa-alto
```

Tre aspetti tecnici merita una spiegazione esplicità.

> ***Normalizzazione `Wn = fc / (fs/2)`.***  
La funzione `butter` di MATLAB non accetta la frequenza di taglio in Hertz, ma richiede una ***frequenza normalizzata*** compresa tra $[0,1]$, dove $1$ corrisponde alla frequenza di Nyquist $f_N = \frac{f_s}{2}$. In questo caso, la normalizzazione è pari a: $$W_n = \frac{f_c}{f_N} = \frac{10}{500} = 0.02$$ Un valore $W_n = 0.02$ significa che la frequenza di taglio corrisponde al $2\%$ della frequenza di Nyquist. Valori vicini a $0$ corrispondono a tagli molto bassi nel range delle frequenze rappresentabili; valori vicini a $1$ corrispondono a tagli vicini alla frequenza di Nyquist,

> ***Ordine del filtro (4).***  
Come discusso nella *Sezione 6.7.4*, l'ordine del filtro di Butterworth determina la ripidità del roll-off. Con ordine $4$, la trasizione attorno a $f_c = 10\ \text{Hz}$ è sufficientemente ripida da attenuare efficacemente la componente a $50\ \text{Hz}$ (viceversa, per il passa-alto).

> ***Funzione `filter` vs `filtfilt`.***  
Lo script usa la funzione `filter`, che applica il filtro ***una sola volta*** in direzione casuale (dal campione iniziale al campione finale). Questa funzione introduce un ritardo di fase che dipende dall'ordine del filtro: il segnale in uscita è temporalmente leggermente "in ritardo" rispetto all'ingresso. 
>
> Quando la coerenza temporale è importante (ad esempio nell'analisi di eventi fisiologici), si preferisce `filtfilt`, che applica il filtro due volte (avanti e indietro), annullando il ritardo di fase. Per la separazione spettrale illustrativa di questo esempio, `filter` è sufficiente.

### 6.8.3 Visualizzazione e interpretazione dei risultati

```matlab
figure;
subplot(3,1,1);
plot(t, x, 'LineWidth', 1.2); 
title('Segnale originale (lento + veloce)');
grid on;

subplot(3,1,2);
plot(t, y_low, 'r', 'LineWidth', 1.2);
title('Filtro passa-basso: resta la componente lenta (2 Hz)');
grid on;

subplot(3,1,3);
plot(t, y_low, 'r', 'LineWidth', 1.2);
title('Filtro passa-alto: resta la componente veloce (50 Hz)');
grid on;
```

<div align = "center">

![alt text](image-29.png)
![alt text](image-30.png)

</div> 

> ***Segnale filtrato del passa-basso.***  
Il filtro ha lasciato passare quasi inalterata la componente a $2\ \text{Hz}$, mentre ha fortemente attenuato la componente a $50\ \text{Hz}$. La ragione è che $50\ \text{Hz}$ si trova cinque volte sopra la frequenza di taglio ($50 / 10 = 5$), nella zona di forte attenuazione della curva di Butterworth. 
>
> Il segnale in uscita dal fltro è una sinusoide quasi pura a $2\ \text{Hz}$: l'andamento lento originale del segnale è stato recuperato.

> ***Segnale filtrato del passa-alto.***  
Il filtro ha bloccato la componente a $2\ \text{Hz}$ (che si trovava molto al di sotto della frequenza di taglio, a $2/10 = 0{,}2$ della frequenza di cutoff) e ha lasciato passare la componente a $50\ \text{Hz}$. 
>
> Il segnale in uscita dal filtro è una sinusoide quasi pura a $50\ \text{Hz}$ con l'ampiezza originale di $0{,}5$: la variazione rapida è stata isolata.

> **Nota.** Se si sommassero i due segnali filtrati $y_{low}(t) + y_{high}(t)$, si otterrebbe un segnale quasi identico all'originale $x(t)$. I due filtri **decompongono** il segnale in due sottocomponenti frequenzialmente non sovrapposte, e la loro unione ricostruisce l'originale. Questa proprietà è sfruttata in analisi multi-risoluzione e nei banchi di filtri.

## 6.9 *Filtro passa-banda: isolamento di una componente specifica*

### 6.9.1 Contesto applicativo

La sezione precedente ha mostrato come il filtro passa-basso e passa alto riescano a separare due componenti quando il segnale utile è rispettivamente a bassa o ad alta frequenza rispetto al disturbo. 

Esistono scenari in cui ***entrambe*** le direzioni dello spettro del segnale contengono disturbi, e il segnale utile si trova in una banda intermedia tra due disturbi. In questo caso, né il passa-basso né il passa-alto da soli sono sufficienti: è necessario un filtro che apra una "finestra" attorno alla frequenza utile.

Il ***filtro passa-banda***, quindi, è l'ideale quando sappiamo ***esattamente*** dove si trova il *segnale utile* (di interesse) e vogliamo ***eliminare*** tutto ciò che si trova *sopra* (rumore acuto) e tutto ciò che sta *sotto* (deriva lenta): dobbiamo definire un intervallo di frequenze (finestra spettrale) per effettuare il filtraggio.

Lo script seguente costruisce esattamente questo scenario: un segnale che contiene una sinusoide utile a $50\ \text{Hz}$, una derivata lenta molto intensa a $2\ \text{Hz}$, e un rumore gaussiano distribuito su tutte le frequenze.

### 6.9.2 Costruzione del segnale disturbato e applicazione del filtro

```matlab
fs = 1000;     % Frequenza di campionamento
t = 0:1/fs:1;  % Vettore tempo

% Componenti del segnale 
x_clean = sin(2*pi*50*t);                          % Segnale utile: sinusoide a 50 Hz
x_drift = 2*sin(2*pi*2*t);                         % Deriva: ampiezza 2, il doppio del segnale
noisy_x = x_clean + x_drift + 0.5*randn(size(t));  % Segnale disturbato: utile + deriva + rumore gaussiano

% --- PROGETTAZIONE FILTRO PASSA-BANDA --- %
f_pass = [40, 60];                    % Banda passante: 40-60 Hz (centrata sul segnale a 50 Hz)
Wn = f_pass/(fs/2);                   % Normalizzazione rispetto alla frequenza di Nyquist
[b, a] = butter(4, Wn, 'bandpass');   % Butterworth ordine 4, tipo passa-banda

% --- APPLICAZIONE DEL FILTRO --- %
y = filtfilt(b, a, noisy_x);
```

Quattro aspetti sono degni di attenzione.

> ***Struttura del segnale disturbato.***  
La deriva a $2\ \text{Hz}$ ha ampiezza $2$, il doppio dell'ampiezza del segnale utile. Questo rende il segnale `noisy_x` dominato visivamente dalla variazione lenta: nel grafico, la sinusoide a $50\ \text{Hz}$ è quasi invisibile rispetto all'andamento ondulatorio lento. A questo si aggiunge il rumore gaussiano generato da `randn`, che ha distribuzione normale di media zero e varianza unitaria, scalata di $0.5$.
>
> <div align = "center"> 
>
> ![alt text](image-34.png)
>
> </div>

> ***Normalizzazione del vettore di frequenze.***  
Per un *filtro passa-banda*, l'argomento `Wn` di `butter` è un vettore di due elementi — anziché uno scalare come per passa-basso e passa-alto. I due valori rappresentano la frequenza di inizio e la frequenza di fine della banda passante, entrambi normalizzati rispetto a $f_N = \frac{f_s}{2}$. In particolare: $$Wn = \left[\frac{f_1}{f_N},\, \frac{f_2}{f_N}\right] = \left[\frac{40}{500},\, \frac{60}{500}\right] = [0.08, 0.12]$$
>
> Il vettore $[0.08, 0.12]$ istruisce `butter` a costruire un filtro che lasci passare le frequenze comprese tra l'$8\%$ e il $12\%$ della frequenza di Nyquist, corrispondenti a $40-60\ \text{Hz}$.

> ***Argomento `'bandpass'`.***  
La stringa `'bandpass'` specifica il tipo di filtro. In assenza di questo argomento, `butter` con un vettore di due frequenze produrrebbe comunque un passa-banda, ma la forma esplicita è preferibile perché rende il codice leggibile e non ambiguo. 
>
> Le alternative sono `'low'` (passa-basso), `'high'` (passa-alto) e `'stop'` (elimina-banda).

> ***Uso di `filtfilt` invece di `filter`.***  
In questo script il filtro viene applicato tramite `filtfilt`, che esegue il filtraggio due volte: prima in avanti (dal campione 1 all'ultimo) e poi all'indietro (dall'ultimo al primo). Il risultato è una risposta di fase nulla: il segnale filtrato non presenta alcun ritardo temporale rispetto all'ingresso. 
>
> Questa proprietà è cruciale quando si vuole confrontare il segnale filtrato con il segnale originale pulito (come nel grafico che sovrappone `y` e `x_clean`), perché i due sono allineati nell'asse del tempo. Con `filter`, il segnale filtrato sarebbe ritardato di un numero di campioni pari alla metà dell'ordine del filtro, rendendo il confronto visivo fuorviante.

### 6.9.3 Filtro di Butterworth passa-banda

Come possiamo notare, anche in questo contesto il comportamento del filtro passa-banda ideale non è realizzabile a livello fisico. Per questo motivo si ricorre ad una approssimazione basata sul filtro di Butterworth chiamata ***filtro di Butterworth passa-banda***. 

In questo contesto, il filtro lascia passare un intervallo $[f_1, f_2]$. Nonstante ciò, non esiste una formula semplice come per i precedenti filtri per ricavare $|H(f)|$, ma concettualmente consiste nel ***combinare un filtro passa-alto e un filtro passa-basso***. Una forma qualitativa è, quindi: $$|H_{BP}(f)|^2 = \frac{1}{1 + \left(\frac{f^2 - f_0^2}{f\cdot B}\right)^{2N}}$$ dove:
- $f_0 = \sqrt{f_1 \cdot f_2}$: la frequenza centrale 
- $B = f_2 - f_1$: banda

In questo contesto, quindi:
- se $f$ è vicino a $f_0$, allora passa
- altrimenti, se è fuori banda, viene attenuata


### 6.9.4 Visualizzazione e interpretazione 

```matlab
figure;

subplot(2,1,1);
plot(t, noisy_x, 'r');
title('Segnale Originale (molto rumoroso)');
xlabel('Tempo (s)');
ylabel('Ampiezza');
legend('Segnale disturbato');
grid on;

subplot(2,1,2);
plot(t, x_clean, 'LineWidth', 3); hold on;
plot(t, y, 'g', 'LineWidth', 1.2);
title('Dopo Filtro Passa-Banda (40–60 Hz)');
xlabel('Tempo (s)');
ylabel('Ampiezza');
legend('Segnale pulito', 'Segnale filtrato');
grid on;
```

<div align = "center">

![alt text](image-35.png)

</div>

La corrispondenza quasi perfetta tra la curva verde (filtrata) e quella blu (segnale pulito di riferimento) dimostra l'efficacia del filtro passa-banda in questo scenario. 
- la *deriva* a $2\ \text{Hz}$, benché avesse ampiezza doppia rispetto al segnale utile, è stata completamente eliminata perché si trovava a $40\ \text{Hz}$ al di sotto del bordo inferiore della banda passante
- il *rumore gaussiano* è stato fortemente ridotto: non è stato eliminato del tutto (il rumore gaussiano è presente a tutte le frequenze, incluse quelle comprese tra $40$ e $60\ \text{Hz}$), ma la sua potenza è stata ridotta proporzionalmente alla larghezza della banda passante rispetto alla larghezza totale dello spettro.

### 6.9.5 Effetto dei parametri del filtro passa-banda

Quando usiamo filtri più complessi come il passa-banda di Butterworth, il concetto di `window_size` viene sostituito dall'ordine del filtro e dalla larghezza della banda:
- ***larghezza di banda $[f_1, f_2]$***: se è troppo stretta (ad esempio, $[49, 51]\ \text{Hz}$), il filtro diventa instabile e tende a "risuonare", introducendo oscillazioni artificiali nel segnale (***ringing*** del segnale filtrato). Se è troppo larga (ad esempio, $[10, 90]\ \text{Hz}$), il filtro lascerebbe passare una quantità eccessiva di rumore gaussiano distribuito alla frequenza utile, e non eliminerebbe completamente la deriva se questa si estende al di sopra di $10\ \text{Hz}$

La scelta di $[40, 60]\ \text{Hz}$ — una banda di $20\ \text{Hz}$, simmetrica attorno alla frequenza utile di $50\ \text{Hz}$ — è un equilibrio ragionevole in questo contesto.

- ***ordine del filtro***: un ordine elevato $(ad esempo, N = 10)$ rende il filtro molto selettivo, con transizioni ripide ai bordi della banda (roll-off ripido ai bordi della banda passante), tagliando tutto ciò che non è esattamente $50\ \text{Hz}$. Tuttavia, nel dominio del tempo, un ordine elevato può causare oscillazioni (***ringing***) ai bordi del segnale (inizio e fine del segnale), che non appartengono al segnale utile. Un ordine basso (ad esempio, $N = 2$) rende il filtro più $tollerante$ producendo transizioni dolci e privo di ringing, diventando quindi più stabile ma meno efficace nell'eliminare il rumore vicino ai bordi della banda passante $40-60\ \text{Hz}$ (il rumore vicino ai $50\ \text{Hz}$) 

L'ordine $N = 4$ è una scelta di compromesso ampiamente usata nella pratica.

## 6.10 *Sintesi dei tre filtri*

Il ***filtro passa-basso*** risponde alla domanda "voglio conservare le variazioni lente"; il ***filtro passa-alto*** risponde alla domanda "voglio conservare le variazioni veloci"; il ***filtro passa-banda*** risponde alla domanda "voglio conservare solo le variazioni comprese in una fascia spettrale precisa, eliminando sia il rumore lento sia quello veloce".

## 6.11 *Esercizio: denoising di un segnale audio*

### 6.11.1 Descrizione del problema

Immaginiamo di aver registrato una nota musicale: il ***La centrale*** (*A4*), corrispondente alla frequenza di $440\ \text{Hz}$. In forma di segnale, è sinusoide pura a $440\ \text{Hz}$: $$\text{segnale\_utile}(t) = \sin(2\pi\cdot 440\cdot t)$$

La registrazione risulta corrotta da due disturbi sovrapposti di natura diversa:
1. un ***ronzio elettrico*** a $50\ \text{Hz}$ e $0.5$ di ampiezza: tipica interferenza prodotta dalla rete elettrica, percepita come una bassa frequenza
2. un ***fruscio ad alta frequenza*** di ampiezza $0.2$: un rumore casuale distribuito su tutto lo spettro del segnale, simulato in MATLAB dalla funzione `randn`, che genera campioni con distribuzione gaussiana a media zero

Il segnale acquisito è quindi:
$$\text{segnale\_disturbato} = \underbrace{\sin(2\pi\cdot 440\cdot t)}_{\text{segnale utile}} + \underbrace{0.5\sin(2\cdot pi\cdot 50\cdot t)}_{\text{ronzio a 50 Hz}} + \underbrace{0.2\text{rumore gaussiano}}_{\text{rumore gaussiano}}$$

L'obiettivo dell'esercizio è progettare una ***catena di filtraggio*** che elimini entrambi i disturbi e recuperi, con la massima fedeltà possibile, la nota $440\ \text{Hz}$

### 6.11.2 Analisi del problema nel dominio delle frequenze

Prima di scegliere i filtri, è necessario ragionare nel dominio delle frequenze per comprendere la struttura spettrale del problema.
- Il ***segnale utile*** si trova a $440\ \text{Hz}$: una sinusoide pura
- Il ***ronzio*** a $50\ \text{Hz}$ si trova a bassa frequenza rispetto al segnale utile: $50\ \text{Hz}$ contro $440\ \text{Hz}$. Questo contamina la banda bassa del segnale
- Il ***fruscio ad alta frequenza*** è distribuito su tutto lo spettro del segnale (rumore bianco approssimato). La sua energia al si sopra di una certa frequenza di taglio $f_c$ può essere soppressa da un filtro passa-basso

La strategia deve quindi agire su entrabe le direzioni:
- un ***filtro passa-alto*** elimina il ronzio a a $50\ \text{Hz}$ sopprimendo tutte le componenti al di sotto di una frequenza di taglio $f_{c,\ high}$ scelta superiore a $50\ \text{Hz}$ ma inferiore a $440\ \text{Hz}$
- un ***filtro passa-basso*** elimina il fruscio ad alta frequenza, sopprimendo le componenti al di sopra di una frequenza di taglio $f_{c,\ low}$ scelta superiore a $440\ \text{Hz}$ ma il più bassa possibile per risurre il rumore residuo

I deu filtri vengono applicati in cascata: prima si applica uno, poi l'altro sull'uscita del primo. Come si vedrà, l'ordine di applicazione non influenza il risultato finale. 

### 6.11.3 Scelta delle frequenze di taglio

> ***Filtro passa-alto con $f_{c,\ high} = 150\ \text{Hz}$.***  
La funzione di questo filtro è quella di ridurre il disturbo a bassa frequenza, in particolare il ronzio di rete a $50\ \text{Hz}$. La frequenza di taglio non viene posta esattamente a $50\ \text{Hz}$, ma più in alto, a $150\ \text{Hz}$. Questa scelta non è arbistraria: serve a fare in modo che la componente indesiderata cada in una zona di attenuazione significativa del filtro, mentre la componente utile resti ben all'interno della banda passante.
> 
>> ***Caso 1: $f_c = f = 50\ \text{Hz}$.***  
Per un filtro Butterworth passa-alto di ordine $N = 2$, se si scegliesse $f_c = 50\ \text{Hz}$, esattamente la frequenza del ronzio, questa componente si troverebbe nel punto di cutoff $$|H(50)| = \frac{1}{\sqrt 2} \approx 0.707$$ La componente a $50\ \text{Hz}$ passerebbe attraverso il filtro con un'attenuazione del $29.3\%$ in ampiezza e con una potenza ridotta del $50\%$ ($-3 \text{dB}$): non è sufficiente a sopprimere in modo deciso un ronzio evidente.
>
>> ***Caso 2: $f_c = 150\ \text{Hz}$***  
La scelta di $f_c = 150\ \text{Hz}$ è più perché colloca il disturbo a $50 \text{Hz}$ ben al di sotto della soglia di taglio. In questo modo, la componente indesiderata rientra nella regione in cui il filtro passa-alto attenua fortemente le basse frequenze. Dal punto di vista teorico, con $f = 50\ \text{Hz}$, $f_c = 150\ \text{Hz}$ e $N=2$, si ottiene: 
>> $$|H(50)|^2 = \frac{1}{82} \qquad |H(50)| \approx 0.11$$ Ciò signicia che il ronzio viene ridotto dell'$89\%$ in ampiezza, ovvero $$A_{out} = 0.5 \cdot 0.11 = 0.055$$ risultando fortemente attenuato.
>>
>> Allo stesso tempo, la nota utile a $440\ \text{Hz}$ si trova ben al di opra della frequenza di taglio. In questo caso, abbiamo $$|H(440)|^2 \approx 0.99 \qquad |H(440)| \approx 0.97$$ Ciò significa che il segnale utile viene quasi del tutto preservato, in quanto $$A_{out} = 1 \cdot 0.97 = 0.97$$
>
> In sintesi, la scelta di $f_{c,\ high} = 150\ \text{Hz}$ realizza un compromesso efficace: il ronzio di rete viene attenuato in modo marcato, mentre la nota musicale viene conservata con alterazioni minime.

> ***Filtro passa-basso con $f_{c,\ low} = 3000\ \text{Hz}$.***  
Dopo la rimozione del disturbo a bassa frequenza, è necessario ridurre il fruscio ad alta frequenza. A tale scopo si impiega un filtro passa-basso con frequenza di taglio $f_{c,\ low} = 3000\ \text{Hz}$. Questo filtro lascia passare senza attenuazione significativa tutte le componenti inferiori a $3000\ \text{Hz}$, mentre attenua progressivamente quelle superiori.
>
> La scelta di $3000\ \text{Hz}$ è motivata dal fatto che la componente utile del segnale, cioè la nota $440\ \text{Hz}$, è molto al di sotto della frequenza di taglio. Pertanto, essa ricade pienamente nella banda passante del filtro e viene conservata praticamente invariata. Al contrario, il rumore ad alta frequenza, distribuito su una porzione ampia dello spettro, viene ridotto in modo sensibile nelle regioni superiori ai $3000\ \text{Hz}$. 
>
> Poiché il campionamento dell'audio digitale avviene a $f_s = 44100\ \text{Hz}$, la frequenza di Nyquist vale $f_N = 22050\ \text{Hz}$
> La frequenza di taglio $3000\ \text{Hz}$ è dunque molto inferiore al limite di Nyquist e si colloca in una regione perfettamente rappresentabile nel dominio digitale. La nota utile a $440\ \text{Hz}$ si trova inoltre molto lontana dalla soglia di taglio, con il risultato che il filtro agisce quasi esclusivamente sulle componenti indesiderate più alte dello spettro.
>
> In questo modo il passa-basso svolge una funzione complementare rispetto al passa-alto: mentre il primo elimina le basse frequenze indesiderate, il secondo attenua il rumore ad alta frequenza, lasciando intatta la banda che contiene il segnale utile.

### 6.11.4 Implementazione MATLAB

```matlab
% 1. Parametri del segnale
fs = 44100;     % Frequenza di campionamento (Hz)
t = 0:1/fs:2;   % Vettore tempo: 2 secondi di registrazione

% 2. Generazione dei segnali
segnale_pulito = sin(2*pi*440*t);                         % La a 440 Hz - segnale utile
ronzio = 0.5*sin(2*pi*50*t);                              % Ronzio di rete (50 Hz)
fruscio = 0.2*randn(size(t));                             % Rumore gaussiano
segnale_disturbato = segnale_pulito + ronzio + fruscio;   % Segnale disturbato

% --- 3. PROGETTAZIONE DELLA CATENA DI FILTRI --- % 

% Filtro Passa-Alto: elimina il ronzio a 50 Hz
% Frequenza di taglio: 150 Hz (3 volte la freq. del disturbo, ben al di sotto del La)
fc_hp = 150;
Wn_hp = fc_hp / (fs/2)
[b_hp, a_hp] = butter(2, Wn_hp, 'high');

% Filtro Passa-Basso: elimina il fruscio ad alta frequenza
% Frequenza di taglio: 3000 Hz (ben al di sopra del La a 440 Hz)
fc_lp = 3000;
Wn_lp = fc_lp / (fs/2);
[b_lp, a_lp] = butter(2, Wn_lp, 'low');

% --- 4. APPLICAZIONE DEI FILTRI IN CASCATA ---
% Prima si applica il passa-alto all'audio disturbato,
% poi il passa-basso all'uscita del passa-alto.

y_senza_ronzio = filtfilt(b_hp, a_hp, segnale_disturbato);
y_filtrato = filtfilt(b_lp, a_lp, y_senza_ronzio);

% --- 5. VISUALIZZAZIONE RISULTATI E ASCOLTO --- % 
figure; 
subplot(3,1,2);
plot(t(1:1000), segnale_disturbato(1:1000));
title('Segnale disturbato');
grid on;

subplot(3,1,1);
plot(t(1:1000), nota_originale(1:1000));
title('Segnale originale');
grid on;

subplot(3,1,3);
plot(t(1:1000), y_filtrato(1:1000));
title('Segnale filtrato (catena passa-alto + passa-basso)');
grid on;

sound(segnale_pulito, fs);       % Ascolto del segnale originale
sound(segnale_disturbato, fs);   % Ascolto del segnale corrotto
sound(y_filtrato, fs);           % Ascolto del segnale recuperato
```

<div align = "center">

![alt text](image-36.png)
![alt text](image-38.png)
![alt text](image-39.png)

</div>

### 6.11.5 Domande di analisi 

La progettazione della catena di filtraggio dell'esercizio è arricchita da due domande di approfondimento che incoraggiano un'analisi critica delle scelte effettuate. 

> ***Domanda 1: l'ordine di applicazione dei filtri influisce sul risultato?***  
No: l'ordine di applicazione dei filtri passa-alto e passa-basso in cascata ***non influisce sul risultato finale***. La ragione è la proprietà di linearità e di invarianza temporale del filtro di Butterworth: il sistema complessivo (passa-alto seguito da passa-basso, oppure passa-basso seguito da passa-alto) produce la stessa funzione di trasferimento. Matematicamente, la funzione di trasferimento della cascata è il prodotto delle funzioni di trasferimento individuali, e la moltiplicazione è commutativa:
>
> $$H_{tot}(f) = H_{LP}(f) \cdot H_{HP}(f) = H_{HP}(f) \cdot H_{LP}(f)$$
>
> In pratica, applicare prima `filter(b_hp, a_hp, x)` e poi `filter(b_lp, a_lp, ·)` produce lo stesso risultato di applicarle nell'ordine inverso, almeno per segnali di lunghezza finita senza effetti di bordo rilevanti.

> ***Domanda 2: Effetto dell'aumento dell'ordine da 2 a 6.***  
Aumentare l'ordine del filtro di Butterworth da $N = 2$ a $N = 6$ ha due effetti contrapposti. 
> 1. Il roll-off diventa molto più ripido: il ronzio a $50\ \text{Hz}$ viene attenuato con molto maggiore forza (il filtro ha una risposta più "squadrata"), e la "zona di transizione" tra frequenze attenuate e frequenze ammesse si restringe. Questo migliora la pulizia del segnale filtrato: le componenti al di fuori della banda desiderata vengono soppresse più efficacemente.
> 
> 2. Un ordine più elevato corrisponde a una risposta impulsiva più lunga, che può introdurre due effetti indesiderati

## 6.12 *Rapporto segnale-rumore (SNR)*

### 6.12.1 Problema della valutazione della qualità del filtraggio

Nei paragrafi precedenti la qualità del filtraggio è stata valutata attraverso l'ispezione visiva dei grafici: il segnale filtrato "assomiglia" a quello originale, oppure "appare più pulito" rispetto al segnale disturbato. Questa valutazione è qualitativa e soggettiva.

Occorre uno strumento ***quantitativo*** che risponda in modo univoco alla domanda: *quanto il segnale filtrato si avvicina al segnale utile originale, rispetto a quanto se ne allontana il segnale disturbato?* Questo strumento è il ***rapporto segnale-rumore***.

### 6.12.2 Definizione e formula

> ***Definizione (rapporto segnale-rumore).***  
Il ***rapporto segnale-rumore*** (*SNR*, *Signal-to-Noise Ratio*) è il rapporto tra la ***potenza del segnale utile*** e la ***potenza del rumore*** (o del disturbo residuo), espresso in decibel (dB): $$SNR_{dB} = 10\log_{10}\frac{P_{signal}}{P_{noise}}$$ dove:
- $P_{signal}$ è la ***potenza media del segnale di riferimento*** (pulito, senza disturbi)
- $P_{noise}$ è la ***potenza media del rumore***, definita come la potenza dell'errore tra il segnale osservato (disturbato o filtrato) e il segnale di riferimento (utile)

#### *Potenza media del segnale $P_{signal}$*

La ***potenza media*** di una sequenza discreta (segnale campionato) $x(n)$ di $N$ campioni è definita come la media dei quadrati dei valori: $$P_{signal} = \frac{1}{N}\sum_{n = 0}^{N-1} \left|x(n)\right|^2$$ Questa formula è analoga al ***Mean Square*** (quadrato medio) e corrisponde al valore quadratico medio del segnale. Per un segnale sinusoidale $x(t) = A\sin(2\pi ft)$, la potenza media è $$P_{signal} = \frac{A^2}{2}$$

#### *Potenza del rumore $P_{noise}$.*  

La ***potenza media del rumore*** (*potenza media dell'errore*) è calcolata in modo identico, ma applicata alla sequenza di errore $e(n) = x_{osservato}(n) - x_{utile}(n)$: 

$$P_{noise} = \frac{1}{N} \sum_{n = 0}^{N-1} e^2(n) = \frac{1}{N} \sum_{n = 0}^{N-1} [x_{osservato}(n) - x_{utile}(n)]$$

Questa formula corrisponde al ***Mean Square Error*** (*MSE*) tra il segnale osservato e il segnale utile: misura quanto in media i campioni si discostano quadraticamente dall'originale. 

### 6.12.3 Interpretazione del valore dell'SNR

L'SNR in decibel ha un'interpretazione immediata e intuitiva, basata sulla scala logaritmica:
- $SNR > 0\ \text{dB}$: la potenza del segnale è maggiore della potenza del rumore. Il segnale utile è protagonista, mentre il rumore è un disturbo minore (situazione desiderabile). Maggiore è l'SNR in dB, maggiore è la qualità del filtraggio del segnale utile: on $\text{SNR} = 40\ \text{dB}$, è diecimila volte ($10^4$)

- $SNR = 0\ \text{dB}$: il segnale e il rumore hanno la stessa potenza $P_{signal} = P_{noise}$. Il segnale è appena distinguibile dal rumore. In condizioni audio, un $SNR = 0\ \text{dB}$ corrisponde ad un audio inutilizzabile: il segnale utile è completamente sommersa dal disturbo di pari intensità

- $SNR < 0\ \text{dB}$: il rumore ha potenza maggiore del segnale. Il segnale è coperto completamente dal rumore e in molti casi è impossibile recuperare l'informazione originale. In contesti pratici, valori SNR negativi indicano una situazione critica che richiede una correzzione all'origine, prima ancora di intervenire con il filtraggio

#### Regola pratica di SNR

In ambito audio, un SNR di $40\ \text{dB}$ è considerato accettabile; $60\ \text{dB}$ è buono; $80$–$100\ \text{dB}$ corrisponde a qualità professionale. Gli standard CD definiscono un SNR minimo di circa $96\ \text{dB}$ per 16 bit (coerente con la formula SQNR $\approx 6{,}02n + 1{,}76$ dB, che per $n = 16$ dà circa $98\ \text{dB}$, come discusso nel Capitolo 4).

### 6.12.4 Relazione con il SQNR

Il rapporto segnale-rumore *SNR* è un concetto più generale del ***SQNR*** (*Signal-to-Quantization-Noise Ratio*) introdotto nel Capitolo 4. La struttura matematica è identica: entrambi sono definiti come $$\frac{P_{signal}}{P_{noise}} \equiv \frac{P_{signal}}{\text{MSE}}\;\text{ che in decibel equivale a }\; 10\log_{10}\left(\frac{P_{signal}}{P_{noise}}\right) \equiv 10\log_{10}\left(\frac{P_{signal}}{\text{MSE}}\right)$$  La differenza riguarda il ***tipo di rumore*** al denominatore:

- Nello SQNR il rumore è l'***errore di quantizzazione***: la differenza tra il campione quantizzato e il campione continuo originale, introdotto inevitabilmente dalla conversione analogico-digitale.
- Nello SNR dell'esercizio audio, il rumore è l'***errore di filtraggio***: la differenza tra il segnale filtrato (o disturbato) e il segnale di riferimento, introdotto dalle perturbazioni esterne o dal processo di filtraggio imperfetto.

In entrambi i casi, il valore in dB quantifica oggettivamente la distanza tra il segnale reale e l'ideale, su una scala logaritmica che comprime convenientemente rapporti di potenza che vanno da $1$ a $10^{10}$.

### 6.12.5 Calcolo dell'SNR in MATLAB

Per quantificare il miglioramento prodotto dalla catena di filtri dell'esercizio audio, si calcolano due valori di SNR: quello del segnale disturbato (prima del filtraggio) e quello del segnale filtrato (dopo il filtraggio). Il confronto mostra oggettivamente il miglioramento ottenuto.

```matlab
% Potenza del segnale di riferimento (la nota La pura a 440 Hz)
P_segnale = mean(nota_originale.^2);
% media(campioni^2): calcola la media dei quadrati di tutti i campioni.
% Per segnale_pulito = sin(2*pi*440*t), si aspetta P ≈ 0.5 (= A^2/2 con A=1).

% --- SNR del segnale disturbato (PRIMA del filtraggio) ---
rumore = segnale_disturbato - nota_originale;
% rumore = 0.5*sin(2*pi*50*t) + 0.2*randn(size(t)):
% la differenza tra il segnale corrotto e il riferimento è esattamente
% la somma dei due disturbi che sono stati aggiunti.
P_rumore = mean(rumore.^2);
snr_iniziale = 10 * log10(P_segnale / P_rumore);

% --- SNR finale (DOPO il filtraggio) ---
rumore_finale = y_filtrato - nota_originale;
% rumore_finale = differenza tra segnale filtrato e riferimento pulito:
% quantifica l'errore residuo dopo il filtraggio.
P_rumore_finale = mean(rumore_finale.^2);
snr_finale = 10 * log10(P_segnale / P_rumore_finale);

fprintf('SNR iniziale (segnale disturbato): %.2f dB\n', snr_iniziale);
fprintf('SNR finale   (segnale filtrato):   %.2f dB\n', snr_finale);
```

(vedi *Definizione MSE* per `mean(val.^2)`, *Capitolo 4 - Sezione 4.3*)

#### *Esempio numerico*

Per il segnale dell'esercizio con $f_s = 44100\ \text{Hz}$, $T = 2\ \text{s}$ e i parametri specificati, i valori tipici sono:

- $P_{signal} \approx 0{,}5$ (potenza di una sinusoide di ampiezza $1$: $A^2/2 = 1^2/2 = 0{,}5$).
- $P_{noise,iniziale}$: il rumore è composto dal ronzio ($0{,}5 \cdot \sin(2\pi \cdot 50 \cdot t)$, potenza $\approx 0{,}5^2/2 = 0{,}125$) più il rumore gaussiano ($0{,}2 \cdot \text{randn}$, potenza $\approx 0{,}2^2 = 0{,}04$). La potenza totale del rumore è circa $0{,}125 + 0{,}04 = 0{,}165$.
- $\text{SNR}_{iniziale} = 10\log_{10}(0{,}5/0{,}165) \approx 10\log_{10}(3{,}03) \approx 4{,}8\ \text{dB}$.

Un SNR di circa $5\ \text{dB}$ prima del filtraggio è basso: il rumore ha potenza quasi un terzo di quella del segnale utile, e il segnale è percettivamente degradato. Dopo l'applicazione della catena passa-alto + passa-basso:

- Il ronzio a $50\ \text{Hz}$ viene quasi completamente eliminato (riduzione di $30$–$40\ \text{dB}$); la sua potenza residua è trascurabile.
- Il rumore gaussiano viene ridotto nella potenza proporzionalmente alla larghezza della banda passante effettiva del sistema. La banda effettiva del filtro combinato (passa-alto a $150\ \text{Hz}$, passa-basso a $3000\ \text{Hz}$) è circa $2850\ \text{Hz}$, mentre il rumore è distribuito su $0$–$22050\ \text{Hz}$: la riduzione proporzionale della potenza del rumore gaussiano è circa $2850/22050 \approx 13\%$, pari a circa $-9\ \text{dB}$.

Il $\text{SNR}_{finale}$ atteso è dell'ordine di $15$–$20\ \text{dB}$: un miglioramento di circa $10$–$15\ \text{dB}$ rispetto al valore iniziale, percettibile chiaramente all'ascolto come eliminazione del ronzio e riduzione del fruscio di fondo.

### 6.12.6 Esempio numerico esplicito del calcolo SNR

Si illustra il calcolo dell'SNR su un esempio numerico semplificato, su una sequenza di $N = 8$ campioni.

***Dati di partenza:***

- Segnale di riferimento: $x = [1,\; 0,\; -1,\; 0,\; 1,\; 0,\; -1,\; 0]$ (sinusoide discreta a frequenza $f_s/4$).
- Segnale disturbato: $\tilde{x} = [1{,}5,\; 0{,}3,\; -0{,}8,\; 0{,}2,\; 1{,}2,\; -0{,}1,\; -1{,}3,\; 0{,}1]$.

***Passo 1 — Calcolo della potenza del segnale di riferimento:***

$$P_{signal} = \frac{1}{8}\sum_{n=0}^{7} \left|x(n)\right|^2 = \frac{1^2+0^2+(-1)^2+0^2+1^2+0^2+(-1)^2+0^2}{8} = \frac{4}{8} = 0{,}5$$

***Passo 2 — Calcolo dell'errore (rumore) e della sua potenza:***

$$e(n) = \tilde{x}(n) - x(n):$$

$$e = [0{,}5,\; 0{,}3,\; 0{,}2,\; 0{,}2,\; 0{,}2,\; -0{,}1,\; -0{,}3,\; 0{,}1]$$

$$P_{noise} = \frac{0{,}5^2+0{,}3^2+0{,}2^2+0{,}2^2+0{,}2^2+0{,}1^2+0{,}3^2+0{,}1^2}{8} = \frac{0{,}25+0{,}09+0{,}04+0{,}04+0{,}04+0{,}01+0{,}09+0{,}01}{8} = \frac{0{,}57}{8} = 0{,}07125$$

***Passo 3 — Calcolo dell'SNR:***

$$\text{SNR}_{dB} = 10\log_{10}\frac{P_{signal}}{P_{noise}} = 10\log_{10}\frac{0{,}5}{0{,}07125} = 10\log_{10}(7{,}02) \approx 10 \times 0{,}846 \approx 8{,}46\ \text{dB}$$

***Interpretazione.*** Un SNR di $8{,}46\ \text{dB}$ indica che la potenza del segnale utile è circa $7$ volte quella del rumore. Il segnale è predominante, ma il disturbo è ancora percettibile (la soglia di buona qualità audio è tipicamente intorno a $20$–$40\ \text{dB}$).

---

## Lezione 10

---

# Capitolo 7 — Affective Computing e Segnali fisiologici

---

## Introduzione al capitolo

I capitoli precedenti hanno costruito una solida base tecnica sull'elaborazione dei segnali: dalla conversione analogico-digitale al filtraggio nel dominio delle frequenze, fino alla valutazione qualitativa con l'SNR. Tutta quella catena di strumenti aveva un obiettivo implicito: estrarre informazione utile da un segnale acquisito da un sensore. Il presente capitolo sposta il fuoco su ***quale tipo di informazione*** si voglia estrarre in un contesto cruciare per le interfacce uomo-macchina: lo ***stato emotivo*** dell'utente.

Se un'interfaccia deve adattarsi all'utente — anticipare i bisogni, ridurre la frustrazione, rispondere in modo appropriato al suo stato cognitivo ed affettivo — occorre prima rispondere ad una domanda: come si rappresentano, misurano e riconoscono le emozioni in modo computazionalmente trattabile? È questa la domanda al centro dell'***Affective Computing***, il campo interdisciplinare che costituisce l'argomento di questo capitolo.

---

## 7.1 *Affective Computing: definizione, origine e obiettivi*

### 7.1.1 Origini e definizione del campo

Il termine ***Affective Computing*** — traducibile come *informatica affettiva* — è stato introdotto nel 1997 da *Risalind Picard*. 

Il nome stesso del campo rimanda a due aspetti: *affective* all'irritazione, al mondo delle emozioni e degli stati interiori; *computing* alla logica, alla computazione deterministica, al trattamento formale dell'informazione. L'***obiettivo*** dell'Affective Computing è, quindi, quello di *costruire un ponte tra questi due mondi*, sviluppando sistemi artificiali capaci di operare efficacemente in presenza di input emotivo.

> ***Definizione (Affective Computing).***  
L'***Affective Computing*** è il campo di ricerca e sviluppo che studia e costruisce sistemi computazionali in grado di:
> - ***riconoscere*** lo stato affettivo dell'utente (emozioni, sentimenti, stato d'animo)
> - ***esprimere*** emozioni in modo sintetico (ad esempio, attraverso un agente virtuale)
> - ***rispondere in modo intelligente*** alle emozioni umane
> - ***regolare e utilizzare*** le emozioni come parte del progesso di interazione

La motivazione profonda di questo interesse risiede nel ruolo centrale che le emozioni svolgono nella vita umana. Le emozioni sono fondamento per: 
- la ***cognizione*** (influenzano l'attenzione e la memoria) 
- la ***percezione*** (l'interpretazione degli stimoli) 
- l'***apprendimento*** (un utente frustrato apprende meno efficacemente)
- la ***comunicazione*** (gran parte del messaggio è veicolato dal tono emotivo)
- il ***processo decisionale*** (le decisioni razionali sono quasi sempre modulate da fattori affettivi)

Quando un sistema informatico ignora queste dimensioni, l'utente percepisce disagio — il sistema "non capisce" ciò che viene comunicato attraverso i canali verbali. 

È un campo ***interdisciplinare***: le competenze necessarie spaziano dall'informatica all'ingegneria (elaborazione dei segnali, machine learning, progettazione di sistemi) alla psicologia e alle scienze cognitive, alle neuroscienze e alla sociologia.

### 7.1.2 Aree applicative dell'Affective Computing in HCI

In relazione all'***Human-Computer Interaction*** (***HCI***), Picard indica quattro grandi aree di applicazione su cui l'*AC* si concentra:
1. ***ridurre la frustrazione dell'utente***: un sistema che rileva i segnali di frustrazione -  aumento frequenza cardiaca, tensione muscolare, deterioramento delle performance - può adottare il proprio comportamento per alleviare il disagio: semplificando l'interfaccia, offrendo aiuto, rallentando il ritmo di presentazione delle informazioni
2. ***consentire una comunicazione agevole delle emozioni***: le interfacce tradizionali trasmettono informazione cognitiva (testo, dati, comandi) ma escludono la componente emotiva. Sistemi affettivamente intelligenti possono creare canali di espressione emotiva implicita, rendendo l'interazione più naturale e ricca di significato
3. ***sviluppare infrastrutture e applicazioni per la gestione delle informazioni affettive***: include la costruzione di database emotivi annotati, sistemi di raccomandazione basati sullo stato d'umore, strumenti per l'analisi dei sentimenti, piattaforme per la sorveglianza affettiva in contesti clinici o educativi
4. ***realizzare strumenti che aiutino a sviluppare le competenze socio-emotive***: applicazioni per l'addestramento delle abilità di riconoscimento emotivo, supporto a persone con difficoltà nella lettura delle emozioni altrui, o sistemi di supporto psicologico mediati dalla tecnologia

### 7.1.3 Ciclo dell'Affective Computing

Il funzionamento di un sistema Affective Computing può essere schematizzato come un ***ciclo*** che inizia con uno stimolo esterno e termina con una risposta emotiva elaborata dal sistema artificiale. 

<div align = "center">

![alt text](ac_cicle-1.png)

</div>

> ***Stimolo.***  
Il processo prende avvio da uno stimolo esterno che colpisce l'utente: può essere un'immagine, un suono, un video, una situazione di vita reale, un evento inaspettato. Lo stimolo ha una componente ***oggettiva*** (le sue proprietà fisiche sono uguali per tutti) e una componente ***soggettiva*** (la risposta individuale allo stimolo dipende da influenze culturali, memoria personale, esperienze passate, tratti di personalità).

> ***Elicitazione emotiva (Emotion elicitation).***  
Lo stimolo provoca nell'utente una risposta emotiva - la cosiddetta *elicitazione* - che si manifesta attraverso due categorie di segnali:
- ***segnali fisici*** (*physical signals*, detti *behavioral*): sono ***intenzionali, controllati ed esterni***. Appartengono a questa categoria le espressioni facciali, il parlato (tono, cadenza, scelta delle parole), la postura, i gesti, i movimenti oculari
- ***segnali fisiologici*** (*physiological signals*): sono ***involontari, non controllati ed interni***. Originano dall'attivazione del sistema nervoso autonomo in risposta allo stato emotivo e non possono essere facilmente manipolati o repressi dalla persona. Appartengono a questa categoria i segnali elettrocardiografici (ECG), l'attività elettrodermica (EDA/GSR), la temperatura cutanea, la pressione sanguigna
>
> Questa distinzione ha importanti conseguenze pratiche: 
> - i segnali fisici sono più facili da acquisire e analizzare con tecnologia standard (videocamera, microfono), ma sono soggetti al ***mascheramento sociale*** - l'utente può 
nascondere o simulare le proprie emozioni reali
> - i segnali fisiologici riflettono lo stato interno in modo onesto e difficilmente controllabile, ma richiedono sensori specializzati a contatto con il corpo
>
>> A questi segnali si aggiunge il rumore (***NOISE***): interferenze di natura biologica o ambientale che si sovrappongono ai segnali di interesse e ne complicano l'interpretazione.

> ***Sistema artificiale.***  
I segnali acquisiti vengono elaborati da un sistema di intelligenza artificiale che svolge due funzioni: 
- il ***riconoscimento emotivo*** (emotion recognition), ovvero la classificazione dello stato affettivo corrente
- la generazione di una ***risposta emotiva*** (*emotional response*), che può consistere in un adattamento del comportamento dell'interfaccia, in una risposta verbale o gestuale da parte di un agente virtuale, o in un segnale di allarme in contesti critici

> ***Ground truth.***  
Affinché il sistema artificiale possa apprendere a riconoscere le emozioni, è necessario disporre di un riferimento certo su quale fosse lo stato emotivo dell'utente al momento dell'acquisizione. Questo riferimento viene chiamato ***ground truth*** e può essere ottenuto attraverso tre approcci:
1. ***questionari di autovalutazione*** (*self assessment questionnaires*): l'utente descrive il proprio stato emotivo utilizzando scale standardizzate
2. ***rapporti di osservatori*** (*observer reports*): persone esterne valutano l'espressione emotiva dell'utente
3. ***induzione sperimentale*** (*experimental induction*): lo stimolo viene progettato specificamente per evocare un'emozione nota (ed esempio, proiettare un filmato spaventoso per indurre paura)

## 7.2 *Modelli delle emozioni (modelli emotivi)*

Affinché un sistema computazionale possa riconoscere le emozioni, è necessario che le emozioni stesse siano rappresentate in forma ***formale e numerica***. Questo richiede la scelta di un modello delle emozioni: una struttura matematica che descriva lo spazio degli stati emotivi, li classifichi e ne misuri le relazioni. In letteratura esistono due grandi famiglie di modelli:
- ***modelli discreti*** (o categoriali): trattano le emozioni come categorie distinte
- ***modelli continui*** (o dimensionali): collocano le emozioni in un spazio geometrico multidimensionale

### 7.2.1 Modelli discreti (categoriali)

I modelli discreti si fondamo sull'idea che esista un insieme finito di emozioni fondamentali, biologicamente innate e universalmente condivise, distinte tra loro qualitativamente. Questo approccio è intuitivo e allineato al linguaggio naturale: nella vita quotidiana le emozioni vengono nominate come categorie ("sono arrabbiato", "ho paura", "sono felice")

---

#### *Modello di Ekman*  

Il modello categoriale più influente in letteratura è quello propostod a ***Paul Ekman*** nel 1971. Ekman ipotizza l'esistenza di ***sei emozioni fondamentali***, innate e indipendenti dall'apprendimento culturale:
1. ***rabbia***
2. ***disgusto***
3. ***paura***
4. ***gioia***
5. ***tristezza***
6. ***sorpresa***

Le proprietà centrali di questo modello sono le seguenti.

> ***Universalità transculturale.***  
Le sei emozioni fondamentali sono riconoscibili dalle espressioni facciali in tutte le culture umane, comprese quelle isolate che non avevano contatti con i media occidentali. 
>
> ***Gradualità.***  
Ciascuna emozione fondamentale non è "tutto o niente": può manifestarsi in misura variabile, da un'intensità minima quasi impercettibile fino a un massimo estremo.
>
> ***Composizionalità.***  
Tutte le emozioni più complesse che si sperimentano nella vita quotidiana (gelosia, nostalgia, orgoglio, imbarazzo, ecc.) possono essere concettualizzate come combinazioni delle sei emozioni di base, eventualmente con pesi diversi.

Le varianti del modello includono talvolta uno ***stato neutro*** (assenza di emozione significativa) oppure una lista ridotta a quattro emozioni fondamentali.

Ai fini del riconoscimento computazionale, il modello di Ekman è quello più largamente adottato, sia per la presenza di dataset annotati ben consolidati (come il *Facial Action Coding System*, FACS) sia per la sua semplicità: classificare un'espressione in una di sei categorie è un problema di classificazione standard.

#### *Modello di Plutchik*  

***Robert Plutchick*** ha proposto un modello discreto più articolato, denominato ***Ruota delle emozioni di Plutchick***. Il modello prevede otto emozioni fondamentali, organizzate strutturalmente:
1. ***gioia***
2. ***fiducia***
3. ***paura***
4. ***sorpresa***
5. ***tristezza***
6. ***disgusto***
7. ***rabbia***
8. ***anticipazione***

<div align = "center">

![alt text](plutchik-1.png)

</div>

La struttura della ruota incorpora tre elementi geometrici con preciso significato psicologico.

> ***Opposizione polare.***  
Ogni emozione ha un'emozione opposta, collocata dalla parte diametralmente opposta della ruota. Le coppie opposte sono: 
> - gioia–tristezza
> - paura–rabbia
> - anticipazione–sorpresa
> - disgusto–fiducia
>
> Questa struttura riflette la constatazione empirica che queste coppie difficilmente coesistono in modo intenso nello stesso momento (non si può essere intensamente felici e profondamente tristi simultaneamente).

> ***Gradazione dell'intensità dal bordo verso il centro.***  
L'intensità di ogni emozione aumenta spostandosi dall'esterno della ruota verso il centro, con una codifica visiva tramite la saturazione del colore: le tonalità più scure al centro indicano l'intensità più elevata, quelle più chiare ai bordi indicano l'intensità più bassa.

> ***Emozioni complesse per sovrapposizione.***  
Le emozioni complesse emergono dalla sovrapposizione di due emozioni adiacenti nella ruota. Ad esempio:
> - la sovrapposizione di gioia e fiducia genera amore (*love*)
> - la sovrapposizione di paura e sorpresa genera soggezione (*awe*) 
> - la sovrapposizione di disgusto e rabbia genera disprezzo (*contempt*)

---

### 7.2.2 Modelli continui (dimensionali)  

I modelli continui collocano ogni stato emotivo come un ***punto in uno spazio geometrico*** a due o tre dimensioni. Anziché assegnare un'etichetta discreta, questi modelli descrivono le emozioni con coordinate numeriche continue, permettendo di catturare sfumature e transizioni che i modelli categoriali non possono rappresentare.

---

#### *Modello Valence-Arousal* 

È il modello continuo bidimensionale più utilizzato e si basa su due dimensioni:
- ***dimensione del piacere*** (*valenza*): rappresenta l'***intensità dell'emozione*** (gioia) umana. Il suo asse va da sinistra (valenza negativa: angoscia, tristezza estrema) a destra (valenza molto positiva: estasi, euforia). Le emozioni con valenza neutra si collocano al centro dell'asse.
- ***dimensione dell'attivazione*** (*arousal*): rappresenta il ***livello dell'attività psicofisiologica*** - il livello di attività fisiologica del sistema nervoso e il livello di vigilanza psicologica e prontezza dell'inividuo. L'asse dell'arousal va verso il basso (arousal basso: sonnolenza, noia, rilassamento profondo) verso l'alto (arousal alto: eccitazione intensa, allerta, agitazione).

<div align = "center">

![alt text](va-1.png)

</div>

I sentimenti associati alle emozioni ***felici*** (gioia, euforia, soddisfazione) si concentrano nella metà destra del piano; i sentimenti associati alle emozioni ***tristi*** (tristezza, depressione, noia) si concentrano nella metà sinistra.

#### ***Modello Valance-Arousal-Dominance***  

Il modello 2D presenta un limite: non riesce a distinguere tra emozioni che condividono valenza e arousal simili ma differiscono per un'altra dimensione. Un esempio classico è la coppia rabbia–paura: entrambe hanno valenza negativa ed elevato arousal. Come si distinguono?

La soluzione proposta è l'aggiunta di una terza dimensione: la ***dominanza*** (*Dominance*).

> ***Definizione (dominanza).***  
La ***dominanza*** esprime la ***percezione di controllo sull'ambiente***: quanto l'individuo si sente in grado di influenzare la situazione e le persone che lo circondano, oppure di essere influenzato da esse. Un alto livello di dominanza corrisponde a una sensazione di controllo e padronanza della situazione; un basso livello corrisponde a una sensazione di impotenza, sopraffazione.

<div align = "center">

![alt text](vad-1.png)

</div>

La distinzione tra rabbia e paura diventa ora netta: la rabbia ha alta dominanza (chi è arrabbiato si sente — spesso in modo irrazionale — in posizione di forza, orientato all'azione offensiva), mentre la paura ha bassa dominanza (chi ha paura si sente sottomesso, vulnerabile, in stato difensivo).

Il modello 3D è adottato in molti dei principali dataset di segnali fisiologici per la valutazione delle emozioni, tra cui il dataset DEAP (*Sezione 7.8*).

---

## 7.3 *Dal modello continuo al riconoscimento: ground truth* 

### 7.3.1 Quantizzazione dello spazio emotivo per la classificazione

Lo spazio continuo descritto dai modelli dimensionali è matematicamente potente ma computazionalmente problematico: un sistema di riconoscimento non può produrre una coppia di numeri reali continui con la stessa facilità con cui produce un'etichetta categoriale. Per realizzare un compito di classificazione o di riconoscimento si rende necessaria una ***quantizzazione dello spazio emotivo continuo***: lo spazio viene suddiviso in *regioni*, e a ciascuna regione viene assegnata un'etichetta discreta.

> **Nota terminologica.** Il termine "*quantizzazione*" ha qui lo stesso significato che ha nella conversione analogico-digitale (si veda il Capitolo 3): trasformare valori continui in un insieme finito di valori discreti. La differenza è che qui la grandezza quantizzata non è l'ampiezza di un segnale elettrico, ma le coordinate di uno stato emotivo in uno spazio psicologico.

La maggior parte delle ricerche in Affective Computing adotta quantizzazioni binarie o ternarie dello spazio emotivo, scegliendo pochi stati emotivi facilmente distinguibili:
- ***positivo / neutro / negativo*** (tre classi)
- ***positivo / negativo*** (due classi)
- ***stress / rilassamento*** (due classi)
- ***triste / felice*** (due classi)

Questa scelta non è arbitraria: più classi si utilizzano, più difficile diventa costruire stimoli che inducano in modo affidabile stati emotivi ben separati nello spazio, e più difficile diventa per i partecipanti autovalutarsi con precisione. La riduzione a poche categorie ben distinte permette di costruire dataset più puliti e sistemi di classificazione più affidabili.

### 7.3.2 Etichettare le emozioni: metodi di ground truth

Ottenere la *ground truth* — sapere con certezza quale stato emotivo stava sperimentando un soggetto in un dato momento — è il problema centrale della ricerca in Affective Computing. I metodi principali si dividono in due grandi famiglie.

> ***Questionari di autovalutazione.***  
I questionari di autovalutazione chiedono al soggetto di descrivere il proprio stato emotivo utilizzando scale standardizzate. I principali strumenti sono:
> - ***scala binaria***: il soggetto indica una delle due polarità (ad esempio stress/rilassato, oppure positivo/negativo)
> - ***scala di likert***: scala ordinale (tipicamente a 5 o 7 punti) in cui il soggetto indica il proprio grado di accordo con un'affermazione (ad esempio "Mi sento rilassato": 1 = per niente, 5 = moltissimo).
> - ***SAM — Self-Assessment Manikin***: strumento per misurare le dimensioni del modello VAD (Valence, Arousal, Dominance) in modo non verbale.
> - ***STAI — State-Trait Anxiety Inventory***: questionario specifico per la misurazione dell'ansia, che distingue tra ansia di stato (la condizione emotiva attuale, transitoria) e ansia di tratto (la predisposizione stabile della personalità).
> - ***Big Five (BIG5)***: non misura uno stato emotivo momentaneo, ma i tratti stabili della personalità secondo il modello dei *Cinque Grandi Fattori*
>     1. *apertura all'esperienza* (Openness)
>     2. *coscienziosità* (Conscientiousness)
>     3. *estroversione* (Extraversion)
>     4. *amicalità* (Agreeableness)
>     5. *neuroticismo* (Neuroticism)

> ***Stimoli standardizzati: dataset con etichette soggettive.***  
Poiché il modo più diretto per indurre uno stato emotivo specifico è esporre il soggetto a uno ***stimolo affettivo*** di natura nota, la comunità scientifica ha sviluppato dataset standardizzati di stimoli (immagini, suoni, video, scene di realtà virtuale) accompagnati da etichette soggettive raccolte su ampie popolazioni di osservatori. I principali dataset di stimoli sono:
- ***IAPS — International Affective Picture System***: dataset di stimoli visivi più usato in psicofisiologia. Contiene centinaia di immagini fotografiche di vario contenuto, ciascuna accompagnata da valori medi di Valence e Arousal derivati da autovalutazioni di ampie popolazioni.
- ***NAPS — Nencki Affective Picture System***: database con immagini e altri contenuti, ognuno con una specifica valenza (intensità emotiva) associata
- ***GAPED — Geneva Affective Picture Database***
- ***IADS — International Affective Digital Sounds***: versione audio dell'IAPS
- ***DEAP — Database for Emotion Analysis using Physiological Signals***: dataset che utilizza video come stimoli e registra simultaneamente segnali EEG e periferici fisiologici, accompagnati da autovalutazioni su scala VAD e gradimento dei partecipanti
- ***AVRS — Affective Virtual Reality System***: dataset che utilizza la realtà virtuale come mezzo di elicitazione (per misurare la risposta emotiva)

## 7.4 *Misurare le emozioni: segnali fisici e fisiologici*  

Il riconoscimento automatico delle emozioni richiede la misurazione di segnali osservabili che forniscono informazione sullo stato affettivo (emozioni, parametri interni, ecc.) dell'utente. Come anticipato nel ciclo dell'Affective Computing (Sezione 9.1.3), questi segnali si suddividono in due grandi categorie.

### 7.4.1 Segnali fisici

I ***segnali fisici*** sono quelli che si manifestano all'***esterno del corpo*** come comportamento osservabile, e che l'individuo può — parte — controllare:
- ***espressione facciale***
- ***parlato***
- ***postura corporea***
- ***gesti***
- ***movimenti oculari***

Il vantaggio dei segnali fisici è l'*accessibilità* (possono essere acquisiti con telecamere e microfoni, senza richiedere contatto corporeo). Il loro principale limite è il ***mascheramento sociale***: l'utente può nascondere o simulare le proprie emozioni reali tramite questi segnali.

### 7.4.2 Segnali fisiologici

I ***segnali fisiologici***, originati dall'attività del sistema nervoso autonomo (ANS) e di altri sistemi interni del corpo non sotto un controllo volontario, riflettono lo stato emotivo interno in modo più diretto e difficilmente falsificabile. Le principali modalità fisiologiche per il riconoscimento emotivo sono:
- ***EEG — ElectroEncephaloGram***: misura l'attività elettrica del cervello tramite elettrodi posizionati sulla testa. Fornisce informazioni ad alta risoluzione temporale sull'attivazione cerebrale associata a stati emotivi.
- ***ECG — ElectroCardioGram***: misura l'attività elettrica del cuore; importante per l'arousal emotivo
- ***PPG — PhotoPlethysmoGraphy***: misura le variazioni di volume ematico (sangue circolante) sulla superficie cutanea; alternativa non invasiva all'ECG 
- ***EDA/GSR — ElectroDermal Activity / Galvanic Skin Response***: misura quanto cambia la capacità della pelle di condurre elettricità quando si suda; indicatore di arousal e carico cognitivo
- ***EMG — ElectroMyoGram***: misura l'attività elettrica muscolare; utile per rilevare tensione muscolare associata a stati emotivi negativi
- ***SKT — Skin Temperature***: temperatura cutanea periferica del corpo (parti più esterne, mani, piedi, ecc.); varia in risposta all'attivazione del sistema nervoso simpatico
    > ***Sistema nervoso simpatico (SNS)*** Branca del sistema nervoso autonomo che prepara l'organismo a situazioni di stress, emergenza o attività fisica.
- ***BVP — Blood Volume Pressure***: misura le variazioni della pressione del volume ematico (pressione sanguigna)
- ***Respirazione***: ritmo e profondità della respirazione variano con gli stati emotivi; la respirazione lenta è associata al rilassamento, la respirazione rapida e irregolare a stati di arousal elevato (paura, rabbia).

(arousal, *Sezione 7.2.2*)

### 7.4.3 Dataset unimodali e multimodali

In letteratura si distinguono due tipologie di dataset per il riconoscimento delle emozioni:
- ***Dataset unimodali***: raccolgono segnali in un modo solo (unica modalità). Tra questi possiamo trovare dataset tesuali, vocali, visivi e fisiologici (di una tipologia specifica)
- ***Dataset multimodali***: raccolgono segnali fisiologici in modi diversi (più modalità nella raccolta dei segnali)

La tabella seguente riepiloga i principali dataset multimodali di segnali fisiologici disponibili pubblicamente in letteratura:

| Dataset | N. soggetti | Stimoli | Modalità raccolta segnali fisiologici | Modello emotivo | Tipo di valutazione |
|---|---|---|---|---|---|
| AMIGOS | 40 / 37 | 16 video (51–150 s) + 4 video (14–24 min) | EEG, ECG, GSR | Discreto, Continuo | Self, Expert |
| ASCERTAIN | 58 | 36 video (51–127 s) | EEG, ECG, GSR | Continuo | Self |
| **DEAP** | **32** | **40 video (60 s)** | **EEG, ECG, GSR, RSP, SKT, BVP, EMG, EOG** | **Continuo** | **Self** |
| DECAF | 30 | 36 video (51–128 s) | MEG, ECG, EMG, EOG | Continuo | Self |
| DREAMER | 23 | 18 video (65–393 s) | EEG, ECG | Continuo | Self |
| MAHNOB-HCI | 27 | 20 video (35–117 s) | EEG, ECG, GSR, RSP, SKT | Discreto, Continuo | Self |
| SEED | 15 | 15 video (240 s) | EEG | Discreto | Self |

Il dataset DEAP è uno standard di riferimento nella comunità e illustra in modo completo le metodologie di acquisizione, annotazione e analisi dei segnali fisiologici per l'Affective Computing.

## 7.5 *Segnali fisiologici cardiaci: ECG e PPG*


I segnali originati dall'attività cardiaca sono tra i più utilizzati nel riconoscimento degli stati affettivi, in particolare per la loro stretta correlazione con la dimensione dell'arousal (*Sezione 7.2.2*). 

Esistono due modalità principali per misurare l'attività cardiaca: l'***elettrocardiogramma (ECG)*** e la ***fotopletismografia (PPG)***. Sebbene entrambe forniscano informazioni sull'attività cardiaca, differiscono per principio fisico, invasività, accuratezza e praticità.

> **Nota.** ECG e PPG insieme, permettono di analizzare frequenza cardiaca, stress e ritmo cardiaco in modo non invasivo.

### 7.5.1 Elettrocardiogramma (ECG)

---

#### *Principio fisico.*
Il cuore funziona come una pompa muscolare il cui *ciclo di contrazione e rilassamento* è governato da ***impulsi elettrici***. Questi impulsi generarno ***campi elettrici*** che si propagano attraverso i tessuti corporei e raggiungono la superficie cutanea, dove possono essere misurati come differenze di potenziale elettrico (tensione) nel tempo. 

<!-- spiegare meglio in maniera più chiara -->

L'***ECG*** è la registrazione di questa differenza di potenzale in funzione del tempo, acquisita tramite elettrodi posizionati sulla pelle.

<!-- arousol: ***livello dell'attività psicofisiologica*** - il livello di attività fisiologica del sistema nervoso e il livello di vigilanza psicologica e prontezza dell'inividuo. -->

#### *Mofologia del segnale ECG*

Il tracciato tipico di un ciclo cardiaco si compone di tre elementi, spesso indicati con lettere:
- ***onda P***: corrisponde alla *depolarizzazione atriale*, ovvero alla contrazione degli atri (camere superiori del cuore) che spingono il sangue nei ventricoli (dall'alto verso il basso). Si tratta di un'onda piccola e arrotondata
- ***complesso QRS***: componente più accettuanta, corrisponde alla *depolarizzazione ventricolare*, ovvero alla contrazione dei ventricoli (camere inferiori del cuore) che espellono il sangue verso l'aorta e l'arteria polmonare (dal basso verso l'alto). Il picco *R* è il punto di ampiezza massima del complesso QRS — battivo "visivo" del segnale
- ***onda T***: corrisponde alla *ripolarizzazione ventricolare*, ovvero il rilassamento del cuore

<div align = "center">

![alt text](morfologia_ecg.png)

</div>

<!-- [Descrizione del grafico: tracciato ECG di un ciclo cardiaco completo. Sull'asse orizzontale il tempo in secondi (scala 0–0,20 s per ciclo), sull'asse verticale la tensione in mV (scala 0–1 mV). Si distinguono chiaramente: l'onda P (piccola gobba positiva), il complesso QRS con la dip Q negativa, il picco R prominente verso 1 mV, la dip S negativa, e l'onda T (ampia gobba positiva). L'intervallo RR tra due picchi R successivi è indicato con una freccia bidirezionale. Gli intervalli PR, ST e QT sono annotati sotto il tracciato.] -->

#### *Contenuto in frequenza del segnale ECG*

L'ECG è un segnale che occupa un ampia banda di frequenze. Le frequenze di interesse diagnostico si concentrano nell'intervallo $[0.05 - 40]\ \text{Hz}$. Tuttavia, a causa della forma acuta e caratteristica del complesso QRS (con la sua salita ripida), il segnale contiene componenti a circa $150\ \text{Hz}$.

La frequenza fondamentale dell'ECG — corrispondente alla ***frequenza dei battiti cardiaci*** — si colloca nell'intervallo $[1 - 4]\ \text{Hz}$ per i valori tipici della frequenza cardiaca umana ($[60 - 220]\ \text{bps}$). L'intervallo di frequenze tipicamente considerato per l'acquisizione completa del segnale è $[0.5 - 100]\ \text{Hz}$.

> ***Frequenza cardiaca (frequenza dei battiti cardiaci).***  
La ***frequenza cardiaca*** è il numero di contrazioni o pulsazioni del cuore in un minuto, espresso in BPM (battiti per minuto). 

---

### 7.5.2 Fotopletismografia (PPG)

---

#### *Principio fisico*

La ***fotopletismografia (PPG)*** è una tecnica di misura del volume ematico circolante, non invasiva ed economica, basata su un principio ottico: la quantità di luce che attraversa — o viene riflessa — da un tessuto corporeo varia in funzione del ***volume ematico*** locale in quell'istante. Quando il cuore si contrae e spinge sangue nei capillari, il volume ematico aumenta; tra un battito e l'altro, il volume diminuisce. Queste variazioni di volume si traducono in variazioni nell'assorbimento della luce, rilevabili da un fotodetector.

Il sensore PPG è composto da due elementi fondamentali:
- un ***LED***: diodo ad emissione di luce, irradia il tessuto con luce a specifica lunghezza d'onda
- un ***fotodetector (PD)***: misura l'intesità della luce trasmessa o riflessa (quantità di luce che attraversa il tessuto)

Il rapporto tra luce emessa e luce rilevata varia con il valore ematico, producendo un segnale oscillante.

#### *Morfologia del segnale PPG*

Ogni pulsazione (arteriosa) si suddivide in due fasi, visibili come due picchi distinti nel tracciato PCG
- ***picco sistolico***: corrisponde alla contrazione ventricolare (sistole), che genera il massimo afflusso di sangue nei capillari (volume ematico aumenta, raggiunge il valore massimo); il picco sistolico è il massimo dell'onda PPG. Corrisponde, in altre parole, alla contrazione del cuore
- ***picco diastolico***: corrisponde alla fase di rilassamento (diastole), in cui le arterie si gonfiano; è un picco secondario, tipicamente menno prominente. 

<div align = "center">

![alt text](morfologia_ppg.png)

</div>

<!-- [Descrizione del grafico: forma d'onda PPG su un asse temporale in secondi. Si notano le oscillazioni ripetitive, con picchi sistolici chiaramente identificabili (cerchi vuoti) e picchi diastolici più bassi (triangoli). L'asse verticale è in mV.] -->

#### *Vantaggi del PPG rispetto all'ECG*

La PPG è preferita all'ECG per il monitorare un soggetto ***durante il movimento*** (ad esempio in attività fisica) e per la sua ***facilità di posizionamento***: un ossimetro da dito, un braccialetto indossabile o una fascia da polso integrano un sensore PPG con minima invasività, senza richiedere l'applicazione di elettrodi sul torace.

---

### 7.5.3 Heart Rate Variability (HRV) e feature cardiache

La frequenza cardiaca non è perfettamente costante nel tempo. Anche in condizioni di riposo, il cuore non batte come un metronomo ideale: gli intervalli tra un battito e il successivo presentano piccole variazioni fisiologiche. Questa proprietà prende il nome di ***Heart Rate Variability (HRV)***, cioè variabilità della frequenza cardiaca.

L’HRV è un indicatore importante perché riflette, almeno in parte, l’equilibrio tra i due rami del sistema nervoso autonomo:
- ***simpatico***, associato a stato di attivazione, stress, sforzo
- ***parasimpatico***, associato a rilassamento e recupero

In generale, una variabilità maggiore è spesso associata a una maggiore capacità di adattamento fisiologico, mentre una variabilità ridotta può essere indice di stress, affaticamento.

---

#### Definizioni fondamentali

> ***Intervalli NN / RR / IBI.***  
Per studiare la variabilità cardiaca (HRV) non si lavora direttamente sui battiti al minuto, ma sugli ***intervalli tra battiti consecutivi***. Questi battiti sono detti:
> - ***intervalli RR***: intervalli temporali tra picchi R dell'ECG
> - ***intervalli NN***: intervalli temporali tra battiti sinusali regolari (detti interalli "normali")
> - ***intervalli IBI*** (Inter-Beat Interval): termine più generale che indica l'intervallo tra due battiti successivi
>
> L'unità di misura tipica è il millisecondo (*ms*). 
>
> Se i picchi R avvengono ai tempi $t_1$, $t_2$, $t_3$, $\ldots$, allora gli intervalli sono: 
> $$RR_1 = t_2 - t_1 \qquad RR_2 = t_3 - t_2 \qquad RR_3 = t_4 - t_3 \qquad \ldots$$
>
> Questa scrittura esprime il fatto che ogni intervallo RR è la distanza temporale tra due picchi R consecutivi.
>
> Questi intervalli non sono tutti uguali; proprio questa non uniformità è ciò che l’HRV misura.

> ***Frequenza cardiaca.***  
La ***frequenza cardiaca*** (*Heart Rate*, HR) indica quanti battiti del cuore avvengono in un certo intervallo di tempo. Si esprime più spesso in ***battiti per minuto*** (*bpm*), ma può anche essere espressa in ***battiti per secondo*** (*bps*).
>
> Questa si calcola misurando il numero di picchi (battiti) rilevati in un intervallo di tempo $\Delta T$, diviso per la durata di quell'intervallo 
> $$HR = \frac{\text{N}}{\Delta T\ [s]} \times 60\quad [bpm]$$ 
> oppure in bps 
> $$HR = \frac{\text{N}}{\Delta T\ [s]}\quad [bps]$$ 
> dove:
> - $N$ è il numero di picchi R osservati, ovvero il numero di battiti
> - $\Delta T$ è la durata dell'invervallo di osservazione
>
>> ***Perché $1\ \text{bps} = 1\ \text{Hz}$.***  
>> - *Hz* significa al "secondo": $1\ \text{Hz}=1$ evento per secondo
>> - *bps* significa battiti al secondo: $1\ \text{bps}=1$ battito per secondo
>>
>> Poiché entrambe le unità misurano una frequenza, cioè un numero di eventi per unità di tempo, e il tempo di riferimento è il secondo, le due unità coincidono numericamente: 
>> $$1\ \text{Hz} = 1\ \text{bps}$$

> **Nota.** Numero di picchi (R in ECG o sistolici in PPG) coincide al numero di battiti.

#### *Feature statistiche HRV*

Per descrivere la variabilità cardiaca HRV si estraggono spesso feature statistiche calcolate sugli intervalli RR o NN.

> ***SDNN.***  
La ***SDNN*** (*Standard Deviation of all Normal-to-Normal intervals*) è la deviazione standard degli intervalli NN (o RR?) in una finestra temporale.
> $$\text{SDNN} = \sqrt{\frac{1}{N}\sum_{i=1}^{N}(RR_i - \overline{RR})^2}$$
> dove:
>   - $N$ è il numero di intervalli nella finestra
>   - $RR_i$ è l'$i$-esimo invervallo
>   - $\overline{RR}$ è la media degli intervalli
>
>> ***Interpretazione.***  
>> - $\overline{RR}$ è la media degli intervalli
>> - SDNN bassa: gli intervalli sono più regolari
>>
>> In termini fisiologici, una SDNN elevata è spesso associata a maggiore variabilità autonomica (associata a rilassamento e attività parasimpatica), mentre una SDNN bassa può indicare una regolazione meno flessibile (associata a stress o affaticamento).

> ***RMSSD.***  
La RMSSD (*Root Mean Square of Successive Differences*) misura la rapidità con cui cambiano gli intervalli consecutivi.
> $$\text{RMSSD} = \sqrt{\frac{1}{N-1}\sum_{i=1}^{N-1}(RR_{i+1} - RR_i)^2}$$
>
>> ***Interpretazione.***  
La RMSSD è particolarmente sensibile alle variazioni a breve termine e riflette in modo marcato l'attività parasimpatica. In pratica:
>> - se gli intervalli cambiano poco da un battito al successivo, la RMSSD è bassa
>> - se cambiano molto, la RMSSD è alta

---

### 7.5.4 Esempio: frequenza temporale del battito cardiaco

Per capire il legame tra frequenza cardiaca e banda spettrale del segnale ECG, consideriamo il seguente esempio.

> ***Domanda.*** Qual è la frequenza ECG fondamentale corrispondente a 120 battiti cardiaci al minuto?

> ***Soluzione.*** Considerando $120\ \text{bpm}$, abbiamo $$120 \text{ bpm} = \frac{120}{60} \text{ battiti al secondo} = 2 \text{ bps}$$
> Poiché, come visto, $1\ \text{Hz} = 1\ \text{bps}$, otteniamo: $$120 \text{ bpm} = 2 \text{ Hz}$$
>
>> ***Significato fisico.***  
Una frequenza di $2\ \text{Hz}$ corrisponde ad un periodo $$T = \frac{1}{f} = \frac{1}{2} = 0.5\ \text{s}$$ Questo significa che, tra un picco R e il successivo (tra un battito e l'altro) trascorre mezzo secondo.

---

#### *Intervallo fisiologico della frequenza cardiaca*  
In generale, la frequenza cardiaca umana può variare approssimativamente da:
- $60 \text{ bpm}$ a riposo, cioè $\frac{60}{60} = 1 \text{ Hz}$
- $220 \text{ bpm}$ in condizoni estreme di sforzo o tachicardia, cioè $\frac{220}{60} \approx 3.67 \text{ Hz}$

Quindi la frequenza cardica di base si colloca grossolanamente nella banda $$[1 – 4]\text{ Hz}$$ Questo però non significa che il segnale ECG abbia informazione solo in quella banda. La frequenza fondamentale del battito è una cosa; la ***forma del segnale ECG*** è un’altra.

#### *Perché l'ECG richiede frequenze più alte della sola frequenza cardiaca?*

Il segnale ECG non è una sinusoide semplice: è una forma d'onda complessa composta da onde P, complesso QRS e onda T. 

In particolare, il complesso QRS è molto rapido e contiene componenti ad alta frequenza. Per rappresentarlo bene, non basta campionare solo la frequenza del battito: servono frequenze ben più alte. Per questo, nella pratica, si considerano frequenze utili fino a circa $150\text{ Hz}$. 

Le principali informazioni diagnostiche dell'ECG, a differenza della frequenza cardiaca, si concentrano idealmente tra $$0.05\text{ Hz} \text{ e }40\text{ Hz}$$ Qui si trova ***quasi tutta l'informazione utile***:
- ritmo cardiaco
- morfologia delle onde P, QRS, T
- analisi HRV

La banda $[0.5, 100]\text{ Hz}$ dell'ECG, invece, è utilizzata per la progettazione del sistema di acquisizione ECG, in modo da preservare correttamente anche le componenti più rapide del segnale. Non sono alternative. ma due livelli complemetari dello stesso sistema.

> ***Implicazione per il campionamento.*** 
Secondo il teorema di Nyquist-Shannon (*Capitolo 3*), per rappresentare correttamente un segnale campionato la frequenza di campionamento deve essere almeno doppia della massima frequenza significativa presente nel segnale. $$f_s \geq 2\cdot f_{max}$$
>
> Se l’informazione utile arriva fino a 150 Hz, allora la frequenza di campionamento deve soddisfare almeno: $$f_s \geq 2\cdot 150 = 300\text{ Hz}$$ Nella pratica, però, i sistemi di acquisizione ECG utilizzano frequenze di campionamento $f_s$ tra $256\text{ Hz}$ e $1024\text{ Hz}$.

---

## Lezione 11

---

# Capitolo 7 — Affective Computing e Segnali fisiologici (continuazione)

---

## 7.6 *Attività elettrodermica (EDA/GSR)*

### 7.6.1 Principio fisico e misurazione

L'***attività elettrodermica*** (*ElectroDermal Activity*, EDA) — nota anche come ***risposta galvanica cutanea*** (*Galvanic Skin Response*, GSR) o ***conduttanza cutanea*** (*Skin Conductance*, SC) — misura le ***variazioni delle proprietà elettriche della pelle indotte dall'attivazione delle ghiandole sudoripare***, quindi indotte dalla sudorazione.

> ***Meccanismo biologico.***  
Le ghiandole sudoripare — distribuite su tutta la supercie cutanea, ma con concentrazione massima nelle zone palmari e plantari (mani e piedi) — sono innervate dal sistema nervoso simpatico. Quando il sistema nervoso simpatico si attiva in risposta a stimoli emotivi o cognitivi, le ghiandole secernono sudore che si accumula sullo stato più superficiale della pelle. Il sudore è un buon conduttore elettrico: il suo accumulo sulla pelle ne riduce la resistenza elettrica (aumenta la conduttanza). 
>
> Misurando questa conduttanza con due elettrodi posizionati sulla pelle (tipicamente sulle dita della mano), si ottiene il segnale EDA.

> ***Significato emotivo dell'EDA.***  
La conduttanza cutanea è particolarmente sensibile a due tipi di variazioni dello stato interno:
> - ***carico cognitivo ed eccitazione emotiva (arousal)***: l'attivazione del sistema simpatico in risposta a stimoli mentalmente impegnativi o emotivamente rilevanti produce un aumento della conduttanza. L'EDA è considerato uno dei migliori indicatori dell'aorusal
> - ***stress vs rilassamento***: la conduttanza tende ad essere più elevata in condizioni di stress e più bassa in condizioni di rilassamento

Un vantaggio dell'EDA rispetto ad altre misure fisiologiche come l'ECG e l'EEG è il maggior comfort per il soggetto: il posizionamento degli elettrodi per la misurazione dell'EDA è meno invasivo.

### 7.6.2 Componente tonica e fasica

Il segnale EDA non è omogeneo: è la sovrapposizione di due componenti con dinamiche temporali diverse, distinguibili sia per il loro contenuto in frequenza sia per il loro significato fisiologico.
- ***Componente tonica — SCL (Skin Conductance Level)***: rappresenta il *livello di base lento e constante* della conduttanza cutanea. Varia molto lentamente nel tempo, riflettendo lo stato di attivazione generale del sistema nervoso simpatico. In termini di frequenza, la componente tonica occupa la banda $[0,\,0.05]\ \text{Hz}$: è una quasi-costante che deriva nell'arco di minuti o ore
- ***Componente fasica — SCR (Skin Conductance Response)***: rappresenta le *variazioni rapide e transitorie* della conduttanza a specifici eventi o stimoli. Morfologicamente, ogni risposta fasica si presenta come un picco — un aumento rapido della conduttanza seguito da un recupero più lento — in risposta alla presentazione di uno stimolo rilevante. In termini di frequenza, la componente fasica occupa la banda $[0.05,\,1.5]\ \text{Hz}$

Le ***informazioni più significative per il riconoscimento emotivo*** sono contenute al di sotto di $1.5\text{ Hz}$: sia la *componente tonica* (che riflette lo stato di base) sia la *componente fasica* (che riflette la risposta a singoli stimoli) rientrano in questa banda.

<div align = "center">

![alt text](eda-1.png)

</div>

<!-- raw data: segnale grezzo -->

La separazione delle componenti — un processo analogo alla separazione di un segnale misto tramite filtraggio (*Capitolo 6, Sezione 6.8*) — avviene tipicamente applicando un filtro passa-basso molto stretto per estrarre la componente tonica, e sottraendola dal segnale originale per ottenere la componente fasica.

<div align = "center">

![alt text](eda_comp-1.png)

</div>

### 7.6.3 Feature dell'EDA per il riconoscimento emotivo

Dall'analisi del segnale EDA vengono estratte feature distinte per la componente fasica e per quella tonica, ciascuna con il proprio significato fisiologico.

---

#### *Feature della componente fasica (SCR)*

Queste feature quantificano la natura e l'entità delle risposte transitorie agli stimoli:
- ***Massimo, media e varianza*** dell'individuo fasico: descrivono l'ampiezza media e la distribuzione dell'attivazione del sistema nervoso simpatico
- ***Frequenza dei picchi***: numero medio di picchi SCR al secondo nella finestra di analisi. Un'alta frequenza di picchi indica una risposta simpatica vivace agli stimoli
- ***Area del picco e area del picco al secondo***: l'integrale dell'ampiezza (area media) sotto i picchi, che compina l'informazione l'informazione di ampiezza e durata della risposta; 
- ***Altezza del picco*** (*Amplitude*): l'ampiezza (altezza) media dei picchi rilevati, misurata dalla baseline al massimo di ciascun picco
- ***Tempo di salita*** (Rise time): tempo medio dall'inizio di una risposta SCR al suo vertice (picco). Tempi di salita brevi indicano risposte simpatiche più rapide e intense

<div align = "center">

![alt text](SCR-1.png)

</div>

con:
- asse orizzontale $\to$ ***tempo***
- asse verticale $\to$ ***conduttanza cutanea***
- ***picco SCR***, annotato con:
    1. ***Latency***: distanza tra inizio stimolo e inizio della risposta
    2. ***Rise time***: distanza orizzontale tra inizio della risposta e picco
    3. ***Amplitude***: distanza verticale dalla baseline al picco

<!-- [Descrizione del grafico: singola risposta SCR con annotazione delle feature principali. Sull'asse orizzontale il tempo, sull'asse verticale la conduttanza cutanea in μS. Il picco SCR è annotato con: "Latency" (distanza tra inizio stimolo e inizio della risposta), "Rise time" (distanza orizzontale tra inizio della risposta e picco), "Amplitude" (distanza verticale dalla baseline al picco).] -->

#### *Feature della componente tonica (SCL)*

La componente tonica viene descritta principalmente attraverso:
- ***coefficiente di regressione lineare***: stimando una retta che regredisce sul segnale tonico nella finestra di analisi, la pendenza della retta è considerata rappresentativa del trend dell'attivazione simpatica di base. Una pendenza positiva indica un aumento progressivo del livello di attivazione nel corso della finestra. In altre parole, questo coefficiente è considerato rappresentativo della pensenza del segnale

---

## 7.7 *Dispositivi wearable per l'acquisizione di segnali fisiologici*

### 7.7.1 Caratteristiche dei principali dispositivi

Nella ricerca sull'Affective Computing, due dispositivi indossabili sono particolarmente diffusi per l'acquisizione combinata di segnali cardiaci e EDA: l'***Empatica E4*** e lo ***Shimmer3 GSR+***. Questi dispositivi sono progettati per il monitoraggio continuo in condizioni semi-naturalistiche.

> ***Empatica E4***  
Braccialetto da polso che integra diversi sensori in un unico dispositivo portatile. Le specifiche tecniche rilevanti per l'Affective Computing sono:
> - ***PPG*** e ***BVP*** (*Blood Volume Pressure*): frequenza di campionamento $64\text{ Hz}$ con calcolo degli intervalli inter-battito (IBI), permette di derivare la frequenza cariaca e le feature HRV.
> - ***GSR (EDA)***: frequenza di campionamento $4\text{ Hz}$. La bassa frequenza di campionamento è giustificata dal fatto che le informazioni rilevanti dell'EDA sono sotto i $1.5\text{ Hz}$ (*Sezione 7.6.2*): $4\text{ Hz}$ è abbondantemente sufficiente per catturare sia la componente tonica sia quella fasica
> - ***Temperatura cutanea (SKT)***: frequenza di campionamento $4\text{ Hz}$, con valori in gradi Celsius
> - ***Accelerometro a 3 assi (XYZ)***: frequenza di campionamento $32\text{ Hz}$, usato per il monitoraggio del movimento

> **Ricorda.**  
> - ***intervalli IBI*** (Inter-Beat Interval): termine più generale che indica l'intervallo tra due battiti successivi

Il posizionamento al polso rende l'Empatica E4 comoda da indossare per sessioni prolungate, ma implica che la misurazione di PPG e GSR avvenga utilizzando un numero di informazioni inferiori rispetto ad aree più estese.

> ***Shimmer3 GSR+***
Dispositivo più orientato alla ricerca, con frequenze di campionamento significativamente più elevate:
> - ***PPG e BVP***: frequeza di campionamento $128\text{ Hz}$
> - ***GSR (EDA)***: frequenza di campionamento $128\text{ Hz}$ (trentadue volte superiore all'Empatica E4);
> - ***EMG***: 2 canali a $512\text{ Hz}$
> - ***ECG***: 4 canali a $1024\text{ Hz}$

> **Ricorda.**  
> - ***EMG — ElectroMyoGram***: misura l'attività elettrica muscolare; utile per rilevare tensione muscolare associata a stati emotivi negativi
> - ***ECG — ElectroCardioGram***: misura l'attività elettrica del cuore; importante per l'arousal emotivo

### 7.7.2 Frequenze di campionamento e considerazioni sull'analisi

La seguente tabella comparativa riassume le caratteristiche principali dei due dispositivi:

| Dispositivo | $f_s$ PPG (BVP) | $f_s$ GSR (EDA) | Range ampiezza | Sito di acquisizione |
|-------------|---------------|---------------|----------------|----------------------|
| Shimmer3 GSR+ | $128\text{ Hz}$ | $128\text{ Hz}$ | Dipende dal soggetto e dal dispositivo | Dito della mano o lobo orecchio |
| Empatica E4 | $64\text{ Hz}$ | $4\text{ Hz}$ | Dipende dal soggetto e dal dispositivo | Polso |

Notiamo come la "range ampiezza", ovvero l'ampiezza del segnale acquisito, dipende dal soggetto e dal dispositivo: l'ampiezza assoluta del segnale EDA varia notevolmente tra individui (chi suda molto ha valori di conduttanza più alti) e misurazioni (temperatura ambientale, l'umidità, stato di idratazione influenzano la conduttanza di base). 

Questo significa che, nelle frequenze di campionamento e nel sito di acquisizione del segnale, devono essere tenute in considerazione queste differenze durante l'analisi, in particolare nella fase di denoising (rimozione del rumore): un segnale EDA campionato a $128\text{ Hz}$ presenta artefatti di frequenza diversi rispetto ad uno campionato a $4\text{ Hz}$; le strategie di filtraggio devono essere adattate di conseguenza.

### 7.7.3 Normalizzazione dei segnali fisiologici

Poiché l'ampiezza assoluta dei segnali fisiologici varia fortemente tra soggetti diversi e tra sessioni diverse di misurazione sullo stesso soggetto, è necessario ***normalizzare*** i segnali fisiologici prima di procedere all'analisi. 

Nella pratica, due sono i metodi utilizzati per la normalizzazione di un segnale fisiologico

> ***Min-Max Normalization***  Trasforma i valori del segnale nell'intervallo $[0,\, 1]$: 
> $$x_{norm} = \frac{x - x_{min}}{x_{max} - x_{min}}$$
>
> dove $x$ è il ***valore grezzo del segnale***, $x_{min}$ e $x_{max}$ sono rispettivamente il ***valore minimo*** e ***massimo*** del segnale nella sessione di acquisizione. Il vantaggio è l'***interoperabilità***: il risultato è sempre compreso tra $0$ e $1$. Lo svantaggio è la ***sensibilità agli outlier*** (spike): un singolo valore anomalo può comprimere l'intero range.

> ***Z-score Normalization.***  Trasforma i valori del segnale in modo che abbiamo media nulla e deviazione standard unitaria:
> $$x_{norm} = \frac{x - \mu}{\sigma}$$
>
> dove $\mu$ è la ***media*** e $\sigma$ la ***deviazione standard*** del segnale nella sessione. Il vantaggio è la ***robustezza statistica***: i valori risultanti non hano un range fisso prestabilito.

## 7.8 *Normalizzazione dei segnali fisiologici*

### 7.8.1 Problema del range di ampiezza variabile

I dispositivi wearable per l'acquisizione dei segnali fisiologici — Empatica E4, Shimmer3 GSR+ e analoghi — registrano segnali il cui ***range di ampiezza*** dipende sia dal dispositivo sia dal soggetto: due sensori dello stesso tipo, posizionati su individui diversi nelle medesime condizioni, possono produrre ampiezze numericamente diverse a causa di fattori biologici individuali (spessore della pelle, densità delle ghiandole sudoripare, ecc.).

Questa variabilità nel segnale ha una conseguenza nell'analisi: confrontare direttamente valori grezzi di due soggetti — o di due acquisizioni successive dello stesso soggetto — produrrebbe conclusioni prive di significato, perché si starebbe mettendo a confronto grandezze non omogenee. 

La ***normalizzazione*** è l'operazione che riconduce il segnale a una scala di riferimento comune, rendendo i confronti significativi e le feature estratte confrontabili tra sessioni e soggetti.

### 7.8.2 Normalizzazione Min-Max

La ***normalizzazione Min-Max*** (o *rescaling*) trasforma ogni valore del segnale in un valore compreso nell'intervallo $[0,\, 1]$. La formula è:
$$x_{norm}(n) = \frac{x(n) - x_{\min}}{x_{\max} - x_{\min}}$$
dove:
- $x(n)$ è il segnale campionato (campione originale nella posizione $n$)
- $x_{\min} = \min_n x(n)$ è il valore minimo del segnale nell'intera registrazione
- $x_{\max} = \max_n x(n)$ è il valore massimo del segnale nell'intera registrazione
- $x_{norm}(n)$ è il valore del segnale normalizzato, che soddisfa $0 \leq x_{norm}(n) \leq 1$ per ogni $n$

> ***Significato intuitivo.***  
La formula calcola di quanto il valore corrente si discosta dal minimo, e divide questa distanza per l'ampiezza totale del segnale (distanza tra $\max$ e $\min$). Un valore pari al minimo produce $0$; un valore pari al massimo produce $1$; tutti gli altri valori si distribuiscono linearmente in mezzo. 

> ***Esempio.***  
Si consideri un segnmento di segnale EDA (segnale campionato) con valori grezzi (in $\mu S$): 
> $$x(n) = \{1.2, 1.8, 2.5, 3.1, 2.0\}$$
> 
> Si ha quindi che $$x_{\min} = 1.2 \quad x_{\max} = 3.1 \quad x_{\max} - x_{\min} = 1.9$$
>
> I valori normalizzati sono, per ogni campione del segnale $x(n)$:
> $$x_{norm} = \left\{\frac{1.2 - 1.2}{1.9}; \frac{1.8 - 1.2}{1.9}; \frac{2.5 - 1.2}{1.9}; \frac{3.1 - 1.2}{1.9}; \frac{2.0 - 1.2}{1.9};\right\} = \{0; 0.32; 0.68; 1; 0.42\}$$

> ***Limitazione.***  
La normalizzazione Min-Max è molto sensibile agli ***outlier***: un singolo valore anomalo estremo (ad esempio dovuto a un artefatto da movimento) può distorcere l'intera scala, comprimendo tutti i valori autentici in un intervallo ristretto.

### 7.8.3 Normalizzazione Z-score

La ***normalizzazione Z-score*** (o *standardizzazione*) trasforma un segnale in modo che abbia media nulla e deviazione standard unitaria. La formula è:
$$x_{norm} = \frac{x - \mu}{\sigma}$$
dove
- $\mu = \frac{1}{N} \sum_{n = 0}^{N-1} x(n)$ è la ***media del segnale*** su tutti gli $N$ campioni della registrazione
- $\sigma = \sqrt{\frac{1}{N} \sum_{n = 0}^{N-1} (x(n) - \mu)^2}$ è la ***deviazione standard del segnale***
- $x_{norm}(n)$ è il segnale normalizzato

> ***Significato intuitivo.***  
Il valore normalizzato $x_{norm}(n)$ esprime di quante deviazioni standard il campione $x(n)$ si discosta dalla media del segnale. Un valore $x_{norm} = +2$ significa che il campione è $2$ volte la deviazione standard al di sopra della media; un valore $x_{norm} = -1$ significa che è una deviazione standard sotto la media. Il segnale normalizzato con Z-score non ha un range fisso come il Min-Max: i valori si distribuiscono attorno allo zero con varianza unitaria, ma possono superare $\pm 3$ in presenza di picchi pronunciati.

> ***Esempio.***  
Si consideri un segnmento di segnale EDA (segnale campionato) con valori grezzi (in $\mu S$): 
> $$x(n) = \{1.2, 1.8, 2.5, 3.1, 2.0\}$$
>
> La media $\mu$  è:
>$\mu = \frac{1}{5}(1.2 + 1.8 + 2.5 + 3.1 + 2.0) = 2.12$
>
> La deviazione standard $\sigma$ è:
> $$\sigma = \sqrt{\frac{1}{5}[(1.2-2.12)^2 + (1.8-2.12)^2 + (2.5-2.12)^2 + (3.1-2.12)^2 + (2.0-2{,}12)^2]} \approx \sqrt{0.413} \approx 0.643$$
>
> I valori normalizzati sono, per ogni campione del segnale $x(n)$
> $$x_{norm} = \left\{\frac{1.2-2.12}{0.643}; \frac{1.8-2.12}{0.643}; \frac{2.5 - 2.12}{0.643}; \frac{3.1 - 2.12}{0.643}; \frac{2.0 - 2.12}{0.643};\right\} = \{-1.43; -0.497; 0.591; 1.524; -0.186\}$$

> ***Proprietà pratica.***  
La normalizzazione Z-score è meno sensibile agli outlier rispetto al Min-Max: un singolo valore anomalo aumenta $\sigma$, il che comprime tutti i valori normalizzati, ma non azzera la scala come avviene con il Min-Max.

### 7.8.4 Confronto e scelta della normalizzazione

| Caratteristica | Min-Max | Z-score |
|---|---|---|
| Range garantito | $[0, 1]$ | Non definito (tipicamente $[-3, +3]$) |
| Sensibilità agli outlier | Alta (un outlier distorce l'intera scala) | Moderata |
| Conservazione delle proporzioni | Sì (trasformazione lineare) | Sì (trasformazione lineare) |
| Interpretabilità del risultato | Intuitiva (0 = minimo, 1 = massimo) | Statistica (distanza in $\sigma$ dalla media) |
| Uso tipico | Confronti visivi, reti neurali con attivazione sigmoide | Machine learning, confronto tra soggetti diversi |

*In sintesi*: la normalizzazione Min-Max risponde alla domanda "dove si colloca questo campione rispetto all'intervallo del segnale?"; la normalizzazione Z-score risponde alla domanda "quanto è insolito questo campione rispetto al comportamento medio del segnale?".

## 7.9 *Esercitazione 1 — pre-processing e analisi di un segnale ECG rumoroso*  

### 7.9.1 Contesto e obiettivi

L'esercitazione utilizza il dataset MATLAB `noisyecg.mat`, che contiene un segnale ECG reale corretto da tre tipi di disturbo: un *drift della linea di base* detto ***trend*** (lento spostamento del livello medio del segnale, causato dai movimenti del paziente o dalla respirazione), ***rumore ad alta frequenza*** (interferenze elettriche, rumore da movimento degli elettrodi) e fluttuazioni residue nell'intervallo di frequenza clinicamente rilevante.

Gli obiettivi sono:
1. visualizzare il segnale nel dominio del tempo
2. rimuovere il drift (trend) con la funzione `detrend`
3. rilevare automaticamente i picchi R e calcolare la frequenza cardiaca in bpm
4. applicare un filtro passa-banda Butterworth per isolare la banda clinica utile
5. confrontare i risultati dei due approcci di pre-processing

> **Nota.** La ***baseline*** del segnale ECG rappresenta il valore medio attorno a cui l'ECG dovrebbe oscillare quando il cuore non sta generando attività elettrica significativa. Idealmente, l'ECG sarebbe composto da:
- una baseline orizzontale stabile
- sopra la baseline compaiono le onde P, QRS e T

### 7.9.2 Specifiche tecniche del segnale

Il segnale ECG è campionato a $f_s = 1000\text{ Hz}$, ovvero a un campione ogni millisecondo, quindi $T_s = \frac{1}{1000} = 0.001\text{ s} = 1\text{ ms}$. Ciò significa che l'asse temporale del segnale — etichettato come `t = 1:length(nECG)` nel codice — ha l'unità dei millisecondi. Il numero dei campioni corrisponde, dunque, alla durata in ms della registrazione.

Le comoponenti del segnale ECG rilevanti sono:
- ***drift della linea di base (trend)***: sotto i $0.5\text{ Hz}$ (variazioni molto lente)
- ***componenti cardiache utili***: tra $0.5\text{ Hz}$ e $25\text{ Hz}$, con le principali informazioni diagnostiche concentrate tra $0.05\text{ Hz}$ e $40\text{ Hz}$
- rumore ad alta frequenza: sopra i $25\text{ Hz}$ (artefatti da movimento, interferenze di rete, ecc.)

### 7.9.3 Funzione detrend e metodo dei minimi quadrati

In molti sistemi reali (ad es. segnali fisiologici come l'ECG) è presente una ***componente lenta di fondo***, detta ***trend***, che non appartiene all'informazione utile ma deriva da effetti indesiderati (deriva della linea di base, movimento, ecc.).

Si assume che il ***segnale osservato*** possa essere scritto come: $$x(k) = s(k) + b(k)$$ dove:
- $s(k)$ è la componente utile
- $b(k)$ è il trend (componente lenta)

> ***Funzione `detrend`.***  
La funzione `detrend(x, n)` di MATLAB rimuove il trend approssimandolo con un ***polinomio di grado $n$***. In particolare, si cerca un polinomio $p\in\mathcal{P}_n$ (insieme dei polinomi di grado $n$) che approssimi il segnale nel miglior modo possibile secondo il criterio dei minimi quadrati.

---

#### *Passo 1 — stima del trend (minimi quadrati)*

Si definisce il polinomio stimato come: 
$$\hat{p} = \arg\min_{p\in\mathcal{P}_n} \sum_{k = 1}^{N} (x(k) - p(k))^2$$
dove:
- $\hat{p}$ è il polinomio ottimo (soluzione del problema)
- $p(k)$ è un polinomio generico valutato nel punto $k$
- $N$ è il numero di campioni

> ***Interpretazione.***  
Tra tutti i polinomi di grado al più $n$, si sceglie quello che:
> - approssima meglio il segnale globale
> - minimizza la somma degli errori quadratici
>
> Il risultato è un polinomio esplicito della forma: $$\hat{p}(k) = c_0 + c_1 k + c_2 k^2 + \ldots + c_n k^n$$ dove i coefficienti $c_0, c_1, \ldots, c_n$ sono determinati dal metodo dei minimi quadrati.
>
>> ***Significato del parametro $n$.***  
Il parametro $n$ controlla la complessità del modello del trend:
>> - $n = 0$: rimozione della componente costante (media del segnale)
>> - $n = 1$: rimozione di un trend lineare
>> - $n\geq 2$: rimozione di andamenti più complessi
>>
>>> **Osservazione.** Un valore di $n$ troppo basso può non essere sufficiente a descrivere correttamente il trend. Un valore troppo alto può invece portare a una sovra-adattazione (*overfitting*), in cui il polinomio inizia a seguire anche la componente utile del segnale, alterandola.

#### *Passo 2 — sottrazione del trend*  

Una volta stimato il polinomio $\hat{p}(k)$, il segnale detrendizzato è definito come: $$x_{dt}(k) = x(k) - \hat{p}(k)$$

> ***Interpretazione.***  
> - $\hat{p}(k)$ rappresenta la componente lenta del segnale (il trend)
> - $x_{dt}(k)$ rappresenta il segnale privato del trend

> ***Esempio 1: detrend lineare.***  
Sia $x = [2,3,5,7,8]$. Si stima un polinomio di grado $1$: $\hat{p}(k) = c_0 + c_1 k$. Supponendo (dai minimi quadrati): $$\hat{p}(k) = 0.6 + 1.5k$$ si ottiene: $$x_{dt}(k) = x(k) - \hat{p}(k)$$ che produce un segnale oscillante attorno a zero, con la componente lineare rimossa.

> ***Esempio 2: segnale con deriva.***  
Consideriamo $$x(k) = \sin(0.5k) + 0.1k$$ con
> - $\sin(0.5k)$: componente utile
> - $0.1k$: trend lineare
> 
> Con $n = 1$, si ottiene $$\hat{p}(k) \approx 0.1k$$ e quindi $$x_{dt}(k) \approx \sin(0.5k)$$
> Il detrending elimina la deriva e manitene l'informazione oscillatoria.

#### *Applicazione al segnale ECG*  

Nel caso dell'ECG, il detrending è utilizzato per rimuovere la ***baseline wander***, cioè la variazione lenta della linea di base nel tempo, ad esempio a causa di: 
- restirazione
- moviemnto del paziente
- variazioni di contatto tra elettrodi della pelle
- derive lente del sistema di acquisizione 

L'obiettivo del detrend, quindi, è quello di:
- la componente "utile" del segnale
- dalla componente lenta di fondo, che si vuole eliminare

Un polinomio di grado basso (1 o 2) potrebbe non essere sufficiente a modellare la deriva. Un grado più alto (ad esempio $n = 5$) permette di seguire meglio le variazioni lente ma non lineari. Tuttavia:
- un grado troppo elevato può distorvere le componenti rapide (complessi QRS)
- la scelta di $n$ deve bilanciare flessibilità e preservazione del segnale utile

---

### 7.9.3 Codice MATLAB

---

#### *Segnale ECG con drift della baseline*

```matlab
% FASE 1: caricamento del segnale ECG
load('noisyecg.mat');
% Carica il file .mat che contiene la variabile noisyECG_withTrend
nECG = noisyECG_withTrend;

% FASE 2: rappresentazione del segnale ECG nel dominio del tempo
t = (0:length(nECG)-1)/1000; % costruzione del vettore temporale
```

<div align = "center">

![alt text](image-40.png)

</div>

Osservando il segnale `nECG` (rappresentato dal grafico qui sopra) notiamo come questo coincida cn il segnale *ECG grezzo con il drift baseline*. Possiamo, infatti, osservare chiaramente come i picchi R (le "punte" più alte del complesso QRS) siano sovrapposti ad un'ondulazione lenta che sposta la baseline del segnale verso l'alto e verso il basso: il valore medio del segnale ECG ***non si sviluppa attorno ad una baseline orizzontale stabile nel tempo***.

*In sintesi*, notiamo che la forma della baseline del segnale ECG subisce un drift, in quanto è spostata verso l'alto e verso il basso.

> ***Vettore `t`.***  
IL vettore `t` rappresenta il vettore temporale associato al segnale ECG (campionato). Questo viene valcolato a partire dalla formula (vista nel *Capitolo 3*): $$t = \frac{n}{f_s} = n\cdot \frac{1}{f_s} = n\cdot T_s$$ dove:
> - $n$ indica gli indici dei campioni $(0, 1, \ldots, N-1)$
> - $f_s$ rappresenta la frequenza di campionamento
> - $T_s$ rappresenta il periodo di campionamento 
> 
> In questo contesto, abbiamo che:
> - `(0:length(nECG)-1)` genera il dominio discreto dei campioni
> - la divisione per $f_s$ converte gli indici dei campioni in tempo fisico associando ogni campione al suo istante di tempo di acquisizione
>
> In questo modo, abbiamo che t rappresenta il vettore del tempo in cui viene rappresentato il segnale `nECG` (segnale ECG con trend).

#### *Detrending del segnale ECG*

```matlab
% FASE 3: rimozione del drift con detrend
dtECG = detrend(nECG, 5);

%% FASE 4: visualizzazione dei tre segnali sovrapposti
figure;

subplot(1,1,1);
plot(t, nECG); hold on;  % Segnale originale
plot(t, dtECG, 'r'); hold on; % Segnale detrended in rosso
plot(t, nECG - dtECG, 'g', LineWidth=2); % La differenza nECG - dtECG è il trend stimato.
xlabel('Tempo (ms)');
ylabel('mV');
legend('ECG originale', 'ECG detrended', 'trend');
grid on;
```

Come detto precedentemente, la funzione `detrend(x, n)` stima un polinomio $\hat{p}$ di grado $n$ che approssima l'andamento lento del segnale ECG con drift con il metodo dei minimi quadrati. Ottenuto questo polinomio, viene calcolato il ***segnale detrendizzato*** come segue: $$x_{dt}(k) = x(k) - \hat{p}(k)$$ ovvero $x_{dt}(k)$ rappresenta il segnale ECG senza il drift della baseline.

> ***Scelta di $n = 5$.***  
Il valore $n = 5$ è scelto perché: 
> - un ***polinomio di grado basso*** (1 o 2) non riuscirebbe a seguire le variazioni della baseline ECG, che non è perfettamente lineare
> - un ***polinomio di grado troppo alto*** potrebbe iniziare a "inseguire" anche i picchi del complesso QRS, distorcendoli e, quindi, compromettendo il segnale

<div align = "center">

![alt text](image-41.png)

</div>

#### *Rilevamento dei picchi R e della frequenza cardiaca*

```matlab
%% FASE 5: RILEVAMENTO DEI PICCHI R E FREQUENZA CARDIACA

ismax = islocalmax(dtECG, 'MinProminence', 0.9);
% Individua i massimi locali del segnale.
% La soglia di prominenza riduce i picchi dovuti a rumore o onde non R.

ecgPeak = find(ismax);
% Converte il vettore logico negli indici dei campioni corrispondenti ai picchi.

RRinterval = mean(diff(ecgPeak));
% Calcola la distanza media tra picchi consecutivi.
% Il risultato è espresso in campioni, non ancora in secondi.
```

> ***Funzione `islocalmax(...)`.***  
Funzione che trova i massimi locali del segnale ECG detrendizzato `dtECG`. Con `'MinProminence', 0.9`, la funzione conserva solo i massimi che sono abbastanza "sporgenti" rispetto al contesto locale: considera solo quei picchi che hanno un'altezza (prominenza) che supera almeno $0.9\text{ mV}$. Questo consente di escludere i picchi minori (onde $T$, rumore residuo) che hanno prominenza inferiore.
>
>> ***Importante.***  
Questa funzione non trova automaticamente i picchi R: significa che trova i possibili "candidati picci R". Questo filtro di prominenza serve a scartare molti falsi picchi, ma non garantisce da solo che ogni massimo trovato sia un picco R (quindi un battito).

> ***Funzione `find(ismax)`.***  
Funzione che trasforma il vettore logico `ismax`, contenente i *candidati picchi R*, in un vettore contenente gli indici dei campioni corrispondenti ai picchi R del segnale ECG detrendizzato. In altre parole, `ecgPeak` rappresenta il vettore dei picchi R all'interno del segnale ECG.
>
> Quindi, `ecgPeak` contiene posizioni come: 
> ```
> [120, 910, 1702, 2498, ...]
> ```
> ognuna delle quali corrisponde alla posizione del picco R all'interno di `dtECG`.

> ***Funzione `diff(ecgPeak)`.***  
Funzione che calcola la distanza tra picchi consecutivi: 
> ```
> ecgPeak(2)-ecgPeak(1), ecgPeak(3)-ecgPeak(2), ...
> ```
> 
> Se i picchi sono a 120, 910, 1702, 2498, allora:
> ```
> 790, 792, 796
> ```
>
> Questi corrispondono a ***intervalli RR*** in campioni, non in secondi.

> ***Funzione `mean(...)`.***
Funzione che effettua la media degli intervalli RR. Quindi, `RRinterval` è l'***intervallo RR medio*** espresso in campioni.

Nel linguaggio ECG, l'onda R del complesso QRS è usata come riferimento del battito cardiaco. Per questo, il ***tempo tra due picchi R consecutivi*** è chiamato ***intervallo RR***. Quindi:
- un picco R $\approx$ battito
- la distanza tra due picchi $\approx$ durata ciclo cardiaco

---

##### 1. *`RRinterval` non è un tempo in secondi*

Nel codice 
```
ismax = islocalmax(dtECG, 'MinProminence', 0.9);
ecgPeak = find(ismax);
RRinterval = mean(diff(ecgPeak));
```
si sta facendo una cosa diversa dalla formula basata su $\frac{N}{\Delta T}$: qui non si conta quanti battiti (picchi) ci sono in una finestra, ma si misura ***quanto distano tra loro i picchi R consecutivi***. Infatti:
- `ecgPeak` contiene gli indici dei campioni in cui sono stati trovati i picchi
- `diff(ecgPeak)` calcola la distanza tra un picco e il successivo
- `mean(...)` ne fa la media

In questo contesto, quindi, abbiamo che `RRinterval` è l'***intervallo medio tra picchi R espresso in campioni***, non è ancora un tempo in secondi.

> ***Importante.***  
L'***RR teorico***, visto come l'intervallo temporale tra due picchi R consecutivi dell'ECG, è diverso da *RRinterval*. ***RRinterval*** rappresenta un'***approssimazione dell'RR teorico nel dominio dei campioni***: è una rappresentazione dell'RR teorico nel codice, espresso in campioni e non in tempo. Perciò: $$\text{RR} \neq \text{RRinterval} $$

Per convertirlo in tempo, si definisce: $$T_{RR} = \text{RRinterval} \cdot T_s = \frac{\text{RRinterval}}{f_s}$$
- dove $T_{RR}$ è l'***intervallo RR in secondi***
- $\text{RRinterval}$ è l'*intervallo medio in campioni*
- $f_s$ è la *frequenza di campionamento*, in Hz

> ***Esempio.***  
Se $f_s = 1000\text{ Hz}$, il periodo di campionamento è $$T_s = \frac{1}{f_s} = \frac{1}{1000} = 1\text{ ms}$$ Quindi $$T_{RR} = \text{RRinterval} \cdot 1\text{ ms}$$


##### 2. *Periodo cardiaco*  

Il ***periodo cardiaco*** è l'***intervallo temporale tra due picchi R consecutivi dell'ECG***, ed è indicato con $T_{RR}$. Questo rappresenta la durata di un ciclo cardiaco e si ottiene convertendo la distanza tra due picchi `RRinterval` (espressa in campioni) nel dominio del tempo tramite la frequenza di campionamento.

$$T_{RR} = \frac{\text{RRinterval}}{f_s}$$

Come visto, l'intervallo RR è definito come l'intervallo temporale tra due picchi R consecutivi dell'ECG. Solo in questo contesto, RR rappresenta direttamente il ***periodo cardiaco***, indicato con $T_{RR}$. Quindi $$T_{RR} \equiv \text{RR}$$ dove RR è già espresso in unità di tempo (tipicamente secondi o millisecondi, non in campioni)


##### 2. *Come si calcola la frequenza cardica* 

La frequenza cardiaca *HR* è l'inverso del periodo cardiaco $T_{RR}$. Perciò:
- in ***battiti al secondo*** (*bps*): $$HR_{bps} = \frac{1}{T_{RR}} = \frac{f_s}{\text{RRinterval}} $$

- in battiti al minuto (bpm): $$HR_{bpm} = \frac{1}{T_{RR}} \cdot 60 = \frac{f_s\cdot 60}{\text{RRinterval}} $$

> ***Esempio.***  
Se $f_s = 1000\text{ Hz}$ e $\text{RRinterval} = 750$ campioni, allora: $$HR_{bpm} = \frac{1000\cdot 60}{\text{750}} = 80\text{ bpm}$$

##### 3. *Perché questa formula è compatibile con $\frac{N}{\Delta T}$* 

La formula $$HR = \frac{N}{\Delta T}\cdot 60$$ rappresenta la frequenza cardiaca basata su una ***finestra temporale*** ($\Delta T$ è il periodo temporale di osservazione dei battiti $N$). La formula utilizzata nel codice utilizza, invece, il ***tempo medio tra due istanti consecutivi***.

Le due idee sono coerenti perché, in un segnale regolare:
- se in una finestra di durata $\Delta T$ si osservano $N$ battiti, allora il periodo medio vale circa: $$T_{RR} \approx \frac{\Delta T}{N} $$
- quindi la frequenza cardiaca vale: $$HR \approx \frac{N}{\Delta T} $$

Si sta misurando, quindi, la stessa quantità da due punti di vista differenti: ***contando i battiti nel tempo***, oppure ***misurando il tempo tra i battiti***.

---

#### *Visualizzazione dei picchi R*

```matlab
figure;
plot(t, dtECG); hold on; % Segnale detrended in rosso
plot(t(ecgPeak), dtECG(ecgPeak), '^'); % Picchi R
xlabel('Tempo (ms)');
ylabel('mV');
title('Rilevamento picchi R nell''ECG Detrended');
legend('ECG detrended', 'Picchi R')
grid on;
```

<div align = "center">

![alt text](image-42.png)

</div>

#### *Filtraggio passa-banda del segnale  ECG con drift*

```matlab
f_pass = [0.5, 25];
Wn = f_pass / (fs/2);
[b, a] = butter(2, Wn, 'bandpass');

filt_ecg = filtfilt(b, a, nECG);
```

Il filtro passa-banda Butterworth utilizza le frequenze di taglio $f_{low} = 0.5\text{ Hz}$ e $f_{high} = 25\text{ Hz}$. Queste sono scelte in base alle proprietà del segnale ECG: la banda $[0.5, 100]\text{ Hz}$ dell'ECG è utilizzata per la progettazione del sistema di acquisizione ECG, in modo da preservare correttamente anche le componenti più rapide del segnale.
- ***Taglio a $0.5\ \text{Hz}$***: le variazioni di drift della linea di base si trovano sotto questa soglia; tagliarle rimuove il drift esattamente come fa `detrend`, ma in modo automatico e senza necessità di stimare un polinomio
- ***Taglio a $25\ \text{Hz}$***: le principali componenti del complesso QRS, in questo caso si trovano tra $5$ Hz e $25$ Hz; il rumore ad alta frequenza (interferenze di rete, artefatti da movimento) si trova sopra questa soglia

#### Confronto tra segnale originale, detrended e filtrato 

```matlab
figure;

subplot(1,1,1);
plot(t, nECG); hold on; % Segnale originale
plot(t, dtECG, 'g'); % Segnale detrended
plot(t, filt_ecg, 'r', LineWidth = 2); % Segnale filtrato 
xlabel('Tempo (ms)');
ylabel('mV');
legend('ECG originale', 'ECG detrended', 'ECG filtrato');
title('Confronto tra ECG origianle, detrended e filtrato');
grid on;
```

<div align = "center">

![alt text](image-43.png)

</div>

### 7.9.4 Risposta alle domande

---

#### *Domanda 1: qual è l'effetto del parametro MinProminence nella funzione islocalmax? Cosa succederebbe se fosse troppo bassa?*

Il parametro `MinProminence` specifica la ***prominenza minima*** che un massimo locale deve avere per essere riconosciuto come picco. La *prominenza* di un massimo locale è definita come la sua altezza rispetto alla più alta valle tra quel picco e il picco contiguo più alto: misura, in sintesi, quanto un picco "spicca" rispetto al terreno circostante.

Impostare `MinProminence = 0.9` (in mV) esclude tutte le oscillazioni con prominenza inferiore a questo valore: le onde T (prominenza tipicamente $< 0.5\text{ mV}$) e il rumore residuo non superano la soglia e non vengono contate come picchi R.

> ***MinProminence troppo basso.***  
Se `MinProminence` fosse impostato a un valore troppo basso (ad esempio `0.1`), la funzione restituirebbe un ***numero eccessivo di falsi positivi***: ogni piccola oscillazione del rumore verrebbe erroneamente contata come battito cardiaco, producendo una stima della frequenza cardiaca molto più alta di quella reale e priva di significato clinico.

> ***MinProminence troppo alto.***  
Se `MinProminence` fosse troppo alto (ad esempio 1.5), alcuni picchi R deboli (come quelli presenti nella parte del segnale affetta da drift) potrebbero non superare la soglia e verrebbero persi, portando a una ***sottostima della frequenza cardiaca***.

#### *Domanda 2: il filtro passa-banda applicato riesce a rimuovere sia il drift della linea di base che il rumore ad alta frequenza?*

Sì. Il filtro passa-banda $[0.5\ \text{Hz},\ 25\ \text{Hz}]$ agisce su entrambi i fronti simultaneamente:

- ***Drift della baseline*** (componenti sotto $0.5\ \text{Hz}$): vengono attenuate dalla sezione passa-alto del filtro, esattamente come fa `detrend`. La differenza è che `detrend` stima il trend con un modello polinomiale (approssimazione discreta), mentre il filtro lo elimina attenuando selettivamente le basse frequenze nel dominio spettrale.

- ***Rumore ad alta frequenza*** (componenti sopra $25\ \text{Hz}$): vengono attenuate dalla sezione passa-basso del filtro. Questa operazione `detrend` non la esegue: `detrend` rimuove solo il trend lento e lascia intatto il rumore ad alta frequenza.

Il filtro passa-banda è quindi un approccio ***più completo***: in un'unica operazione rimuove sia il drift sia il rumore di alta frequenza, producendo un segnale più pulito per le analisi successive (ad esempio il rilevamento automatico dei picchi R). `detrend`, invece, è più adatto come passo preliminare rapido quando si vuole semplicemente centralizzare il segnale prima di un'analisi che non richiede la pulizia dello spettro ad alta frequenza.

---

## Lezione 12

---

# Capitolo 7 — Affective Computing e Segnali fisiologici (continuazione)

---

## Introduzione al capitolo

La scorsa lezione ha affrontato la normalizzazione dei segnali fiosologici e ha avviato le esercitazioni pratiche in MATLAB, presentando il *pre-processing* per un segnale ECG rumoroso (Esercitazione 1).

La prima parte della lezione è l'***esercitazione sull'EDA/GSR***: si seguono le specifiche formulate dalla docente per decomporre un segnale di conduttanza nelle sue componenti tonica e fasica, estrarne le feature quantitativa e visualizzare i risultati tramite MATLAB. 

La seconda parte si concentra sull'introduzione alle ***Brain Computer Interfaces*** (*BCI*): dopo aver trattato i segnali periferici (ECG, EDA, PPG), ci avviciniamo ai segnali cerebrali, che rappresentano la frontiera più avanzata dell'interazione uomo-macchina.

---

## 7.10 *Esercitazione 2 — Decomposizione e analisi del segnale EDA/GSR*

### 7.10.1 Obiettivi e contesto fisiologico

L'obiettivo di questa esercitazione è analizzare un segnale elettrodermico (EDA), noto come GSR, per ***quantificare lo stato di attivazione del sistema nervoso autonomo***. 

> **Nota.** Come illustrato nella *Sezione 7.6*, il segnale EDA è prodotto dalle ghiandole sudoripare, la cui attività è regolata esclusivamente dal sistema nervoso simpatico: un incremento dell'arousal, dello stress o del carico cognitivo si traduce in un aumento misurabile della conduzzanza cutanea e, quindi, del segnale GSR.

### 7.10.2 Raccordo teorico: la decomposizione EDA

Il segnale EDA grezzo è la ***sovrapposizione di due componenti con bande di frequenza distinte***, che riflettono processi fisiologici diversi:
- ***componente tonica — SCL*** (*Skin Conductance Level*): è l'andamento lento e costante della conduttanza cutanea basale (livello base), contenuto nella banda $[0, 0.05]\text{ Hz}$. Questa componente varia molto lentamente nel tempo, riflettendo lo stato di attivazione generale del sistema nervoso simpatico. Il cambiamento della SCL è legato a cambiamenti prolungati dell'umore o del contesto ambientale
- ***componente fasica — SCR*** (*Skin Conductance Response*): rappesenta le variazioni rapide della conduttanza, dovute a specifici eventi emozionali o stimoli. Queste variazioni si manifestano come picchi brevi — un aumento rapido della conduttanza: ogni picco rappresenta rappresenta una singola risposta del sistema nervoso simpatico a uno stimolo rilevante e si esaurisce in pochi secondi. In termini di frequenza, la componente fasica occupa la banda $[0.05,\,1.5]\ \text{Hz}$

La ***separazione delle due componenti*** si basa sul fatto che SCL e SCR occupano bande di frequenza diverse. Ciò avviene utilizzando dei filtri passa-basso che, sfruttando queste bande di frequenza differenti, riescono ad isolare per differenza le varie componenti tonica e fasica dal segnale GSR.

### 7.10.3 Specifiche del segnale

Il segnale di conduttanza cutanea (EDA/GSR) è acquisito da un dispositivo wearable — tipicamente un dispositivo Empatica E4 — ad una ***frequenza di campionamento*** $f_s = 4\text{ Hz}$. Questa scelta è intenzionale: il segnale EDA è intrinsecamente lento e le informazioni fisiologicamente rilevanti si trovano al di sotto di $1.5\text{ Hz}$. Campionare più rapidamente non aggiungerebbe informazione utile al segnale fisiologico. 

> **Nota.** Con una frequenza di campionamento $f_s = 4\text{ Hz}$ viene rispettato il teorema di Nyquist: la *componente fasica* (con espansione maggiore) si estende fino a circa $1\text{ Hz}$, rispettando $f_s \leq 2\cdot 1$. La componente fasica è perfettamente rappresentabile a partire dai suoi campioni, senza aliasing.

L'esercitazione si divide in due parti:
- ***esercizio 2a***: pre-processing del segnale grezzo e decomposizione nelle componenti tonica (SCL) e fasica (SCR)
- ***esercizio 2b***: estrazione delle feature statistiche e fisiologiche da entrambe le componenti

> **Ricorda.**  $f_s = 4\text{ Hz}$ significa che ogni secondo vengono acquisiti $4$ campioni del segnale GSR, ovvero il segnale viene letto ogni $T_s = \frac{1}{f_s} = 0.25\text{ s}$. Se la registrazione dura $N$ campioni totali, la durata temporale totale è $\frac{N}{f_s}$ secondi.

### 7.10.4 Esercizio 2a — Procedura di pre-processing e decomposizione del segnale GSR

> ***Passo 1 — Caricamento e visualizzazione.***  
Si carica il file `gsr_signal.mat`, che contiene la variabile `gsr` con il segnale grezzo. Si definisce la frequenza di campionamento $f_s = 4\text{ Hz}$ e si costruisce il vettore dei tempi `t` in secondi. Si visualizza il segnale grezzo per avere una prima impressione della sua struttura.
>
> ```matlab
> load('grs_signal.mav');
> fs = 4;
> t = (0:length(gsr)-1)/fs;
> 
> figure;
> plot(t, gsr);
> xlabel('Tempo (s)'); ylabel('GSR (\muS)');
> title('Segnale GSR grezzo');
> ```
> 
> <div align = "center">
> 
> ![alt text](image-44.png)
>
> </div> 

> ***Passo 2 — Pre-processing: rimozione degli artefatti.***  
Prima di separare le componenti, il segnale GSR grezzo deve essere pulito dagli ***artefatti di movimento***: piccole variazioni di frequenza causate da movimenti del sensore durante la registrazione. Questi artefatti presentano componenti ad alta frequenza che si sovrappongono all'SCR e, quindi, potrebbero essere classificati come risposte fasiche.
>
> Per rimuovere questi artefatti, implementiamo un filtro passa-basso Butterworth del secondo ordine con frequenza di taglio $f_c = 1\text{ Hz}$.
> ```matlab
> % PRE-PROCESSING: FILTRO PASSA-BASSO - pulizia GSR grezzo
> fc_low = 1; 
> Wn = fc_low / (fs/2);             % Frequenza di taglio normalizzata sulla frequenza di Nyquist
> [b, a] = butter(2, Wn, 'low');
> 
> gsr_clean = filtfilt(b, a, gsr);
> ```

> ***Passo 3 e 4 — Estrazioni delle componenti tonica (SCL) e fasica (SCR).***  
Per isolare la ***componente tonica*** (SCL), si applica al segnale `gsr_clean` un secondo filtro passa-basso molto più restrittivo, con frequenza di taglio $f_c = 0.05\text{ Hz}$: tutto quello che varia più velocemente di $0.05\text{ Hz}$ viene eliminato, lasciando solo la lenta deriva della baseline. Il risultato è `scl`: la componente tonica, infatti, occupa solo la banda $[0, 0.05]\text{ Hz}$. 
>
> La ***componente fasica*** (SCR) è ottenuta per differenza: $\text{scr} = \text{gsr\_ clean} - \text{scl}$. 
> 
> ```matlab
> % FILTRO PASSA-BASSO: estrazione componente tonica SCL
> fc_tonic = 0.05;
> Wn = fc_tonic / (fs/2);
> [b_t, a_t] = butter(2, Wn, 'low');
> 
> scl = filtfilt(b_t, a_t, gsr_clean);
> scr = gsr_clean - scl;
> ```
> 
> <div align = "center">
> 
> ![alt text](image-45.png)
>
> </div> 


> ***Passo 5 — Visualizzazione.***  
Si tracciano `gsr_clean` e `scl` sullo stesso grafico (per mostrare come l'SCL segua la baseline dell'EDA pulito) e `scr` in un grafico separato (per mostrare i picchi fasici isolati).
> ```matlab
> % VISUALIZZAZIONE: componente tonica e fasica
> figure;
> 
> subplot(2,1,1);
> plot(t, gsr_clean, 'LineWidth', 2); hold on;
> plot(t, scl, 'r');
> title('Segnale GSR e componente tonica');
> xlabel('Tempo (s)'); ylabel('GSR (\muS)');
> legend('GSR pulito', 'SCL');
> grid on;
> 
> subplot(2,1,2);
> plot(t, scr, 'g');
> title('Componente fasica')
> xlabel('Tempo (s)'); ylabel('GSR (\muS)');
> legend('SCR');
> grid on;
> ```
> 
> <div align = "center">
> 
> ![alt text](image-46.png)
> ![alt text](image-47.png)
>
> </div> 

### 7.10.5 Esercizio 2b — Calcolo delle feature del segnale GSR

Questa seconda parte richiede di estrattere descrittori quantitativi dal segnale scomposto, operando su entrambe le componenti SCL e SCR. I passaggi sono:
1. ***Rilevamento dei picchi (SCR Peaks, risposte SCR)***: si utilizza la funzione `findpeaks` per identificare i massimi locali nella componente fasica SCR che soddisfano due vincoli fisiologici:
    - ***soglia di ampiezza minima***: $0.01\mu S$, per escludere le oscillazioni residue di rumore che non rappresentano risposte fisiologiche
    - ***distanza temporale minima tra picchi***: $1\text{ s}$, per evitare di contare più volte la stessa risposta complessa (una singola risposta SCR può presentare oscillazioni interne, ma deve essere contata una sola volta)
2. ***Metriche toniche***: descrivono lo *stato di base del sistema nervoso autonomo (simpatico)*. Dalla componente SCL si calcola 
    - la ***media***: livello medio di consuttanza basale, indicatore dell'arousal
    - la ***deviazione standard***: come varia la baseline nel tempo
3. ***Metriche fasiche***: dai picchi SCR rilevati si calcola 
    - il ***numero totale di picchi***: frequenza totale delle risposte, ovvero quante volte il soggetto ha reagito fiosologicamente ad uno stimolo
    - l'***ampiezza media dei picchi (amplitude)***: intensità tipica di ogni risposta
    - l'***ampiezza massima***: risposta più intensa registrata. È utile per rilevare eventi particolarmente stressanti o sorprendenti
    - la ***somma delle ampiezze***: indice di intensità cumulativa dell'intera sessione di misurazione. Viene utilizzata come indicatore complessivo dell'attivazione del sistema nervoso simpatico nell'arco della registrazione

---

#### *Codice MATLAB*  

> ***Rilevamento dei picchi fasici.***
> ```matlab
> % RILEVAMENTO PICCHI
> min_height = 0.01;
> [pks, locs] = findpeaks(scr, fs, 'MinPeakHeight', min_height, 'MinPeakDistance', 1);
> ```
> La dunzione findpeaks individua i massimi locali di un segnale. In questa chiamata, il secondo argomento è `fs` (la frequenza di campionamento): quando si passa la frequenza di campionamento come secondo argomento, MATLAB interpreta il segnale in scala temporale e restituisce `locs` in secondi. Il parametro `MinPeakDistance`, di conseguenza, è espresso anch'esso in secondi: il valore $1$ impone una distanza minima di $1$ secondo tra picchi consecutivi.
> 
>> ***Motivazione fisiologica dei parametri.***
>> - ***`MinPeakHeight = 0.01`***: le risposte genuine di conduttanza cutanea hanno un'ampiezza minima dell'ordine dei centesimi di $\mu S$. Il rumore residuo dopo il doppio filtraggio è tipicamente inferiore a questa soglia. Impostare `MinPeakHeight = 0.01` $\mu S$ garantisce che ogni picco conteggiato corrisponda a una vera risposta fisiologica, non a un'oscillazione di rumore.
>>
>> - ***`MinPeakDistance = 1`*** (secondo): dopo che il sistema nervoso simpatico ha prodotto una risposta SCR, il meccanismo fisiologico ha bisogno di alcuni secondi per completare la risposta e resettarsi prima di poterne generare un'altra indipendente. Due picchi separati da meno di un secondo sono molto probabilmente la stessa risposta con oscillazioni interne, non due risposte distinte. La distanza minima di 1 secondo protegge dal doppio conteggio.
>>
>> I vettori risultanti sono:
>> - `pks`: vettore delle ***ampiezze*** (altezze) dei picchi trovati, in $\mu S$
>> - `locs`: vettore delle ***posizioni*** temporali dei picchi, in secondi (grazie al passaggio di `fs`)

> ***Calcolo delle feature.***  
> ```matlab
> % 6. FEATURE SCL
> features = struct();
> % Si crea una struttura MATLAB per raccogliere le feature in un
> % unico oggetto organizzato. Una struct è un contenitore con campi
> % denominati: features.nome_campo = valore.
> 
> features.mean_SCL = mean(scl);   % Livello medio di conduttanza basale [μS]
> features.std_SCL = std(scl);    % Variabilità della componente tonica [μS]
> features.num_peaks = length(pks); % Numero totale di picchi SCR
> features.mean_amplitude = mean(pks);  % Ampiezza media delle risposte [μS]
> features.max_amplitude = max(pks);   % Picco massimo registrato [μS]
> features.sum_amplitude = sum(pks);   % Intensità cumulativa dello stimolo [μS]
> ```
>
>> ***Struttura `struct`.***  Utilizzare una struttura al posto di variabili separate ha due vantaggi:
>> - le feature sono raggruppate in un unico oggetto e possono essere stampate, salvate o passate a funzioni come un blocco unitario
>> - il comando `disp(features)` visualizza tutti i campi con i relativi valori in forma leggibile, senza dover listare ogni variabile singolarmente

> ***Visualizzazione.***  
> ```matlab
> figure;
> 
> subplot(2,1,1);
> plot(t, gsr_clean, t, scl);
> title('GSR e SCL')
> xlabel('Tempo (s)'); ylabel('GSR (\muS)');
> legend('GSR', 'SCL');
> grid on;
> 
> subplot(2,1,2);
> plot(t, scr); hold on;
> plot(locs, pks, 'ko', 'MarkerFaceColor', 'y');
> title('Componente fasica e picchi rilevati')
> xlabel('Tempo (s)'); ylabel('GSR (\muS)');
> legend('SCR', 'Picco');
> grid on;
> 
> disp('Feature calcolate: ');
> disp(features);
> ```
> 
> <div align = "center">
> 
> ![alt text](image-48.png)
> ![alt text](image-49.png)
> 
> </div>

### 7.10.6 Riepilogo della pipeline di analisi EDA

La tabella seguente riassume i passaggi della pipeline implementata, con la motivazione di ciascuna scelta.

| Passo | Operazione | Parametri | Motivazione |
|---|---|---|---|
| 1 | Caricamento e costruzione asse temporale | `fs = 4 Hz` | Frequenza di campionamento standard per GSR (Empatica E4) |
| 2 | Filtro passa-basso (pulizia) | `fc = 1 Hz`, Butterworth 2° ordine, `filtfilt` | Rimuove artefatti da movimento ($> 1$ Hz); fase nulla |
| 3 | Filtro passa-basso (SCL) | `fc = 0.05 Hz`, Butterworth 2° ordine, `filtfilt` | Isola la componente tonica ($< 0{,}05$ Hz) |
| 4 | Sottrazione (SCR) | `scr = gsr_clean − scl` | Isola la componente fasica per differenza |
| 5 | Rilevamento picchi | `MinPeakHeight = 0.01 μS`, `MinPeakDistance = 1 s` | Esclude rumore ($< 0{,}01$ μS) e doppi conteggi (distanza min. 1 s) |
| 6 | Feature toniche | `mean(scl)`, `std(scl)` | Descrivono il livello di arousal cronico |
| 7 | Feature fasiche | Conteggio, ampiezza media, max, somma | Descrivono frequenza e intensità delle risposte a stimoli |

### 7.10.7 Commenti all'Esercizio 2 — Interpretazione dei segnali EDA

I commenti all'Esercizio 2 riguardano il significato fisiologico e psicologico delle feature estratte dall'EDA, con particolare attenzione a due aspetti: il numero di picchi fasici (SCR) come indicatore di attivazione cognitivo-emotiva, e la deviazione standard dell'SCL come indicatore di stress a lungo termine.

---

#### Il numero di picchi fasici come indice di attivazione

Un **aumento del numero di picchi SCR** durante l'esecuzione di un compito indica un incremento dell'attivazione del sistema nervoso simpatico. Questo fenomeno può avere due origini distinte, che è importante saper distinguere:

> ***Carico cognitivo (mental workload).***  
Più un compito è difficile o richiede risorse attentive significative — ad esempio calcoli a mente, compiti di memoria di lavoro, risoluzione di problemi complessi — più il cervello attiva il sistema nervoso simpatico per far fronte alla domanda cognitiva. Ogni picco SCR rappresenta, in questo contesto, la reazione fisiologica a uno sforzo mentale. Il numero di picchi aumenta con l'aumentare della difficoltà del compito.

> ***Reattività emotiva.***  
Se il compito genera frustrazione, pressione temporale, senso di fallimento o aspettativa, la frequenza dei picchi SCR aumenta indipendentemente dalla difficoltà logica del compito in sé. In questo caso, i picchi non segnalano uno sforzo cognitivo ma uno stato di *stress*. La distinzione tra carico cognitivo e stress emotivo richiede informazioni contestuali aggiuntive (ad esempio, misure soggettive di frustrazione o monitoraggio parallelo di altri parametri fisiologici).

> ***Assenza di picchi.***  
Simmetricamente, un ***basso numero di picchi*** durante un task può indicare noia, disinteresse o distacco cognitivo. Se il compito non richiede risorse attentive (perché è troppo semplice o irrilevante), il sistema nervoso simpatico non viene attivato e le risposte fasiche sono rare o assenti. Questo è un segnale di ***sotto-attivazione*** che, nel contesto di un sistema HMI adattivo, potrebbe suggerire la necessità di aumentare la difficoltà del task o di variarne il formato per recuperare l'attenzione dell'utente.

> ***Sintesi interpretativa.***  
La feature `num_peaks` risponde alla domanda "quante volte il sistema nervoso simpatico ha risposto a uno stimolo?"; la feature `mean_amplitude` risponde alla domanda "con quale intensità tipica ha risposto?"; la feature `sum_amplitude` integra entrambe le dimensioni, catturando sia la frequenza sia l'intensità cumulativa delle risposte. Un soggetto con molti picchi di piccola ampiezza si distingue da uno con pochi picchi di grande ampiezza, anche se la somma totale potesse essere simile.

#### La deviazione standard dell'SCL come indice di stress cronico

Mentre il numero di picchi SCR riflette la reattività *istantanea* del sistema nervoso simpatico, la **deviazione standard della componente tonica (std_SCL)** è un parametro rilevante per l'analisi dello stress a **lungo termine**.

Un valore elevato di `std_SCL` indica che il livello di conduttanza basale non è rimasto stabile durante la registrazione, ma ha fluttuato in modo significativo. Questo può verificarsi in due scenari interpretativi distinti.

> ***Stress cronico e iper-reattività.***  
In condizioni di stress cronico prolungato, il sistema di regolazione autonomica può diventare iper-reattivo: non riesce a mantenere un livello basale stabile, e la componente tonica sale e scende continuamente in risposta a stimoli anche di bassa intensità. Una `std_SCL` elevata, in questo contesto, è un indicatore che il sistema di regolazione dello stress non funziona in modo ottimale.

> ***Adattamento naturale.***  
Al contrario, variazioni ordinate della componente tonica — ad esempio un calo progressivo durante una sessione di rilassamento, o un incremento graduale durante un task sempre più difficile — possono produrre una `std_SCL` elevata pur in assenza di stress patologico. Distinguere tra i due casi richiede di guardare non solo al valore numerico della deviazione standard, ma anche all'andamento temporale dell'SCL.

> ***Applicazione pratica.***  
Il monitoraggio della variabilità tonica su scale temporali ampie (ore o giorni) permette di distinguere tra adattamento naturale all'ambiente (variazioni ordinate e prevedibili della baseline) e stato di allerta persistente (fluttuazioni irregolari e aspecifiche). Nei sistemi di monitoraggio del benessere, la `std_SCL` può essere usata come indicatore complementare alle metriche fasiche per costruire un profilo più completo dello stato autonomico del soggetto.

---

# Capitolo 8 — Brain Computer Interfaces (BCI)

---

## 8.1 *Brain Computer Interfaces (BCI)*

### 8.1.1 Definizione e contesto storico

Nei capitoli precedenti abbiamo trattato i segnali *fisiologici periferici*: l'ECG regstra l'attività elettrica del cuore attraverso la pelle, l'EDA/GSR misura la conduttanza cutanea, il PPG rileva le variazioni di volume del sangue capillare. Tutti questi segnali sono prodotti da organi diversi dal cervello e acquisiscono punti differenti del corpo. Le ***Brain Computer Interface*** (BCI) rappresentano un passo ulteriore nell'acquisizione dei segnali: l'obiettivo è leggere direttamente l'attività cerebrale e usarla come canale di comunicazione o controllo, bypassando la via muscolare.

> ***Definizione (BCI).***  
Una ***Brain Computer Interface (BCI)*** è un sistema tecnologico che stabilisce una via di comunicazione diretta tra il cervello e un dispositivo esterno — un computer, un braccio robotico, un sintetizzatore vocale — bypassando i normali canali di periferici come muscoli e nervi. Una BCI permette di controllare oggetti o software usando esclusivamente l'attività cerebrale.

### 8.1.2 Funzionamento di una BCI: quattro fasi

Il processo standard di una BCI si articola in quattro fasi sequenziali, che trasformano l'attività cerebrale grezza in un comando utilizzabile da un dispositivo esterno. Queste fasi sono:
1. ***acquisizione del segnale***: si registrano i segnali elettrici (o magnetici, o metabolici) del cervello tramite sensori appositi applicati esternamente alla testa(solitamente tramite EEG), ma in alcuni casi possono essere impiantati direttamente nel cervello.  Il segnale acquisito è grezzo e contiene sia il segnale di interesse sia numerosi artefatti

2. ***pre-processing***: il segnale cerebrale grezzo viene pulito dai disturbi: movimenti oculari, battiti delle palpebre, attività muscolare, interferenze elettriche. Questa fase migliora il rapporto segnale rumore (SNR, qualità del segnale filtrato) e prepara il segnale per le fasi successive

3. ***estrazione delle caratteristiche (feature extraction)***: il sistema identifica pattern specifici nel segnale cerebrale che sono associati a determinate interazioni o stati cognitivi. Ad esempio, si possono estrarre le potenze nelle diverse bande di frequenza EEG (alfa, beta, gamma) o la forma di specifici potenziali evento-correlati

4. ***traduzione in comando***: un algoritmo di classificazione (basato su machine learning) trasforma il pattern cerebrale riconosciuto in un input per il computer: ad esempio, il riconoscimento di un'intenzione motoria di muovere la mano destra viene tradotto nel comando "muovi il cursore a destra" inviato allo schermo

A queste quattro fasi si aggiunge un elemento cruciale: il ***feedback***. L'utente percepisce il risultato del proprio comando (il cursore si muove, la lettera appare sullo schermo) e il cervello si adatta progressivamente, imparando a modulare i propri segnali in modo più efficace per ottenere prestazioni migliori. Questo processo di adattamento sfrutta la ***plasticità cerebrale***.

## 8.2 *Acquisizione segnali cerebrali*

Le tecniche di acquisizione del segnale cerebrale si suddivisono in due categorie: metodi invasivi e metodi non invasivi.

---

#### 1. *Metodi invasivi*  

Implicano un intervento chirurgico per posizionare sensori all'interno o sulla superficie del cervello. Forniscono segnali di qualità molto alta, con riduzione spaziale elevata e rumore ridotto. Le principali varianti sono:
- ***registrazione extracellulare di spike neuronali***: elettrodi minimizzati vengono inseriti direttamente nel tessuto cerebrale per registrare i potenziali d'azione (spike) di singoli neuroni. Consiste quindi nella registrazione dell'attività neuronale all'interno del cervello tramite elettrodi

- ***elettrocorticografia (ECoG)***: elettrodi piatti vengono posizionati sulla superficie della corteccia cerebrale. Consiste, quindi, nella registrazione dell'attività elettrica dalla superficie cerebrale

- ***impianti neurali e stimolazione***: array di elettrodi vengono impiantati nella corteccia motoria. Consiste, quindi, in impianti e stimolazione neurale negli animali e negli esseri umani 

#### 2. *Metodi non invasivi*

Non richiedono alcun intervento chirurgico: i sensori vengono applicati esternamente alla testa. Sopo più sicuri e pratici, ma il segnale è inevitabilmente attenuato e distorto dagli strati di tessuto tra i neuroni e i sensori. Le principali tecniche sono:
- ***fMRI — Risonanza Magnetica Funzionale***: misura variazioni del flusso sanguigno cerebrale dovute all'aumento dell'attività neuronale: i neuroni attivi consumano più ossigeno, richiamando sangue ossigenato nella zona attiva. Questo segnale *BOLD* (*Blood Oxygen Level Dependent*) ha un'***alta risoluzione spaziale*** (dell'ordine del millimetro), permettendo di localizzare l'attività cerebrale con grande precisione anatomica. Tuttavia, la risposta vascolare al segnale neurale è lenta, rendendo la fMRI troppo lenta per applicazioni BCI in tempo reale

- ***MEG — Magnetoencefalografia***: misura i debolissimi campi magnetici prodotti dalle correnti elettriche dei neuroni. In particolare, misura le variazioni dei campi magnetici dovute all'attività neurale. Questa tecnica ha un'***alta risoluzione spaziale*** (paragonabile all'ECG) ma è molto costoso a causa dei sensori utilizzati

- ***EEG — Elettroencefalografia***: misura le variazioni di tensione sulla superficie del cuoio capelluto prodotte all'attività neurale dei neuroni. Ha un'***elevata risoluzione temporale***, costo contenuto e praticità d'uso — caratteristiche che la rendono la ***tecnica più diffusa nelle attuali interfacce cervello-computer (BCI)***

---

## 8.3 *Processi neurali sottostanti al segnale BCI* 

Tutte le interfacce BCI devono basarsi su ***effetti osservabili dell'attività cerebrale***: senza un cambiamento misurabile nel segnale neurale, non esiste alcune informazione decodificabile.

La maggior parte delle BCI (con eccezzione della fMRI, che rileva un segnale metabolico) si basa sugli effetti dei ***processi di attivazione neurale***: correnti elettriche generate dai neuroni che si attivano (scaricano una potenza d'azione) durante l'attività cerebrale. L'EEG, la MEG e ECoG sono in grado di rilevare queste correnti, ma solo quando si verificano su ***larga scala***: è necessario che si attivino neuroni nell'ordine delle decine di migliaia affinché il segnale risultante sia sufficientemente forte da essere rilevabile attraverso il cranio.

### 8.3.1 Attivazione sincrona di molte migliaia di neuroni

Ci sono tre scenari principali che prevedono l'attivazione sincrona di molte migliaia di neuroni:
1. ***evento esterno con risposta a cascata***: uno stimolo sensoriale esterno (un suono, immagine, tocco) innesca una cascata di processi neurali nelle aree di elaborazione sensoriale. Tutti i neuroni che partecipano a questa elaborazione si attivano in un arco di tempo ristretto, producendo un segnale misurabile sincronizzato con lo stimolo
2. ***evento interno con risposta a cascata***: un processo cognitivo interno (una decisione, intuizione improvvisa, atto di attenzione volonaria) può innescare un'attivazione coordinata di reti neurali distribuite
3. ***oscillazioni di oppolazioni neurali***: in certi stati (riposo, sonno, attenzione sostenuta), ampie popolazioni di neuroni si sincronizzano spontaneamente in regimi oscillatori stabili, producendo ritmi cerebrali caratteristici

Da questi tre scenari derivano ***due principali fenomeni EEG rilevabili tramite BCI***
- i ***potenziali evento-correlati (ERP)***: sono le variazioni di tensione legate temporalmente a un evento specifico (interno o esteno)
- i ***processi oscillatori***: sono i ritmi cerebrali spontanei o indotti nella banda di frequenza caratteristica di certi stati cognitivi

## 8.4 *Segnale EEG*  

### 8.4.1 Definizione e caratteristiche

L'***elettroencefalogramma (EEG)*** è il segnale più complesso tra quelli fisiologici. Rappresenta le ***fluttuazioni di tensione a livello del cuoio capelluto*** (*scalp*) dovute all'*attività elettrica di ampie popolazioni di neurono nella corteccia cerebrale*.

Da un punto di vista fisico, le caratteristiche fondamentali del segnale EEG sono:
- ***ampiezza molto ridotta***: dell'ordine dei microvolt ($\mu V$), tipicamente tra 10 e 100 $\mu V$ per i ritmi di fondo, fino a qualche centinaio di $\mu V$ per le oscillazioni di grande ampiezza come le onde delta del sonno profondo. Questa scarsa ampiezza rende questo segnale estremamente sensibile ai disturbi

- ***alta risulozione temporale***: i segnale EEG riflettono dinamiche neuronali che si svolgono nell'arco di ***millisecondi***

- ***bassa risoluzione spaziale***: i neuroni della corteccia cerebrale sono separati dal sensore da diversi strati di tessuto (corteccia, liquor, meningi, cranio, cute)

### 8.4.2 Sistema Internazionale 10-20

Il posizionamento degli elettrodi sul cuoio capelluto è standardizzato internazionalmente secondo il ***Sistema Internazionale 10-20***: gli elettrodi sono collocati a distanze che corrispondono al $10\%$ o al $20\%$ della distanza totale tra i punti di riferimento anatomici.

Le zone del cuoio capelluto in cui gli elettrodi vengono posizionati sono rappresentate tramite una ***codifica alfanumerica*** rappresentativa dei siti di posizionamento:
- le ***lettere*** indicano la regione sottostante all'elettrodo: ***Fp*** (fronto-polare), ***F*** (frontale), ***T*** (temporale), ***C*** (centrale), ***P*** (parietale), ***O*** (occipitale)
- i ***numeri*** indicano la ***lateralità***, ovvero la posizione in cui viene posizionato l'elettrodo sul cranio (sinistra o destra): i numeri ***pari*** per l'emisfero destro, i numeri ***dispari*** per l'emisfero sinistro. La lettera $z$ (da "zero") indica gli elettrodi posizionati sulla linea mediana del cranio

<div align = "center">

![alt text](SI_10-20-1.png)

</div>

> ***Esempi.*** ***F3*** è un elettrodo frontale sinistro, ***T4*** è un elettrodo temporale destro, ***Cz*** è un elettrodo sulla linea mediana centrale, ***O1*** è un elettrodo occipitale sinistro.

### 8.4.3 Bande di frequenza dell'EEG

L'analisi del segnale EEG si basa sulla ***scoposizione del segnale in bande di frequenza***,  tramite la Trasformata di Fourier (vedi *Sezione 8.5*): ogni banda è associata a specifici stati cognitivi e fisiologici.

Le cinque bande fondamentali sono:
- ***Onde Delta*** ($\delta$) — $[0, 4]\text{ Hz}$: oscillazioni più lente, dominano durante il ***sonno profondo***. In un adulto sveglio, onde delta abbondanti nella veglia possono indicare stati patologici
- ***Onde Theta*** ($\theta$) — $[4, 8]\text{ Hz}$: associate alle ***fasi del sonno leggero*** e a stati di sonnolenza. Possono comparire in regioni frontali durante compiti cognitivi impegnativi
- ***Onde Alpha*** ($\alpha$) — $[8, 12]\text{ Hz}$: caratteristica di uno stato di ***riposo consapevole con occhi chiusi***. Si attenuano non appena il soggetto apre gli occhi o si impegna in un compito mentale attivo
- ***Onde Beta*** ($\beta$) — $[12, 30]\text{ Hz}$: associate a stati di ***attività mentale attiva*** come pensiero, concentrazione, problem solving, ansia. Un incremento della potenza beta è spesso associato a un aumento dell'impegno cognitivo
- ***Onde Gamma*** ($\gamma$) — $[30, 80]\text{ Hz}$: banda di frequenza ***cognitiva per eccellenza***, associata a processi di integrazione percettiva, memoria di lavoro e coscienza.  Le onde gamma sono particolarmente difficili da registrare con EEG da scalp perché la loro ampiezza è ridotta e sono facilmente contaminate da artefatti muscolari (EMG) che operano nelle stesse frequenze

<div align = "center">

| Banda | Range | Stato associato |
|---|---|---|
| ***Delta*** ($\delta$) | $0$–$4$ Hz | Sonno profondo |
| ***Theta*** ($\theta$) | $4$–$8$ Hz | Fasi del sonno, sonnolenza |
| ***Alpha*** ($\alpha$) | $8$–$12$ Hz | Riposo, occhi chiusi |
| ***Beta*** ($\beta$) | $12$–$30$ Hz | Attività mentale attiva |
| ***Gamma*** ($\gamma$) | $30$–$80$ Hz | Processi cognitivi complessi |

</div>

## 8.5 *Analisi del segnale EEG*

La natura multi-componente del segnale EEG (somma di oscillazioni a diverse frequenze, ecc.) richiede approcci di analisi specifici.

### 8.5.1 Analisi nel dominio delle frequenze (Power Spectral Density, PSD)

Il metodo fondamentale per analizzare l'EEG in frequenza è il ***calcolo della densità spettrale di potenza (PSD)*** tramite la Trasformata di Fourier. La PSD mostra ***quanta potenza del segnale è concentrata in ciascuna banda di frequenza***, permettendo di quantificare il contributo in potenza delle onde delta, theta, alfa, beta e gamma in un dato istante e in un dato elettrodo.

> ***Esempio.*** Confrontando la potenza nella banda alpha rispetto alla banda beta in un elettrodo parietale, è possibile stabilire se il soggetto è in stato di riposo (dominanza alpha) o in stato di elaborazione attiva (dominanza beta)

### 8.5.2 Potenziali Evento-Correlati (ERP, Event-Related Potensials)

Un ***ERP*** è la ***variazione di tensione del segnale EEG*** che è (temporalmente) correlata con un evento specifico (uno stimolo sensoriale, una decisione, un'azione). Per estrarre un ERP dal segnale EEG è necessario ***calcolare la media*** tra molti segmenti (epoche) di segnale allineati all'evento:

$$\text{ERP}(t) = \frac{1}{N} \sum_{i=1}^{N} x_i(t)$$
dove:
- $x_i(t)$ è l'$i$-esima epoca del segnale estratta attorno all'evento, allineata in modo che $t = 0$ corrisponda al momento dell'evento
- $N$ è il numero totale di epoche

> **Nota.** Un'***epoca*** è una sezione del segnale EEG centrata su uno stimolo esterno, che include un intervallo temporale prima e dopo di esso.

<!-- portare un esempio -->

### 8.5.3 Sorgenti di artefatti nel segnale EEG

Poiché il segnale EEG è ***molto debole*** (l'ampiezza del segnale EEG è dell'ordine dei microvolt), anche segnali elettrici di origine non cerebrale e molto più forti si sovrappongono alla sua registrazione, distorcendola. I principali segnali che disturbano EEG sono:
- ***EOG (Elettrooculogramma)***: il movimento degli occhi e il battito delle palpebre generano correnti elettriche molto più grandi del segnale EEG, producendo onde di grande ampiezza soprattutto negli elettrodi frontali
- ***EMG (Elettromiogramma)***: la contrazione dei muscoli mandibolari o del collo introduce rumore ad alta frequenza che contamina le bande beta e gamma
- ***ECG***: in alcuni soggetti, il segnale elettrico del battito cardiaco è visibile nel tracciato EEG se un elettrodo è posizionato vicino a un vaso sanguigno superficiale. Questo artefatto è periodico con la frequenza cardiaca (circa $1\text{ Hz}$) e può essere confuso con componenti lente del segnale cerebrale

La rimozione di questi artefatti è una parte essenziale del pre-processing EEG, analoga alla rimozione del drift e del rumore che abbiamo visto per l'ECG.

## 8.6 *Architettura completa di un sistema BCI*

Un sistema BCI completo è un sistema chiuso, con un ***ciclo di feedback*** che collega il *segnale in ingresso* (l'attività cerebrale dell'utente) con l'*output del sistema* (il comando inviato al dispositivo) e la *risposta visiva/audio* restituita all'utente. In particolare, questo ciclo è composto da:
1. ***acquisizione dei dati*** EEG tramite diversi dispositivi
2. ***elaborazione del segnale*** per consentirne la traduzione in comandi. Questa pratica è caratterizzata da:
     - *pre-processing*: miglioramento del rapporto segnale-rumore (SNR)
     - *feature engineering*: estrazione e selezione delle caratteristiche
     - *classificazione*: traduzione del segnale o delle sue caratteristiche in comandi leggibili dal sistema
3. ***output e feedback***

<div align = "center">

![alt text](ciclo_feedback-1.png)

</div>

### 8.6.1 Acquisizione dei dati EEG

I dispositivi di acquisizione EEG si suddividono in due categorie con caratteristiche molto diverse:
- ***EEG da laboratorio (clinico)***
- ***EEG wearable (consumer research)***

| Caratteristica | EEG da laboratorio | EEG wearable |
|---|---|---|
| Numero di canali | Elevato (32–1024) | Ridotto (1–16) |
| Risoluzione spaziale | Buona | Scarsa |
| Tempo di preparazione | Lento (30–60 min) | Rapido (5 min) |
| Artefatti | Controllati e minimizzati | Molto frequenti |
| Contesto d'uso | Clinica, ricerca | Consumer, gaming, mobilità |

---

## Lezione 13

---

# Capitolo 8 — BCI (continuazione)

---

## 8.7 *Elaborazione del segnale EEG e decodifica dell'intenzione*

### 8.7.1 Problema del segnale grezzo e la necessità del pre-processing

Il segnale EEG grezzo (segnale cerebrale) acquisito dagli elettrodi posizionati sul cuoio capelluto non rappresenta direttamente l'intenzione dell'utente (ciò che l'utente vuole fare): è un segnale molto debole ($\mu V$) costantemente disturbato da segnali molto più intesi (movimenti oculari - EOG, contrazioni muscolari - EMG, battito cardiaco - ECG). Prima di poter estrarre qualsiasi informazione utile da questo segnale, è necessario un passo di ***pre-processing*** (pre-elaborazione) che persegue due obiettivi:
- migliorare il rapporto segnale-rumore (SNR, Signal-to-Noise Ratio) eliminando le componenti di disturbo
- isolare le bande di frequenza o i pattern temporali di interesse per l'applicazione specifica

---

#### *Pre-processing BCI*

Il pre-processing in un sistema BCI prevede tipicamente due operazioni fondamentali:
- ***Filtraggio in banda***: il segnale EEG viene fatto passare attraverso filtri passa-banda (o coppie di filtri passa-alto/passa-basso) calibrati sulle bande di frequenza di interesse (alpha, beta, gamma)
- ***Rimozione degli artefatti***: una volta filtrato in banda, il segnale viene "pulito" dai residui di artefatto che non vengono eliminati dal semplice filtraggio. La tecnica più diffusa è l'*Analisi delle Componenti Indipendenti* (*ICA, Independent Component Analysis*)

Il risultato di questa fase è un segnale EEG "pulito" da cui è possibile estrarre le caratteristiche che codificano l'intenzione dell'utente.

---

### 8.7.2 Estrazione delle caratteristiche e decodifica tramite machine learning

Una volta pre-elaborato, il segnale EEG deve essere trasformato in un comando leggibile dalla macchina. Questa trasformazione avviene in due passi:
- ***estrazione delle caratteristiche*** del segnale (*feature extraction*), che riduce il segnale grezzo a un vettore di numeri informativi
- ***classificazione*** (*decoding*), che associa quel vettore a una classe di intenzione (cosa l'utente vuole fare) tramite un *algoritmo di machine learning*

Il modo in cui estrai le informazioni dal segnale cerebrale EEG e il modo in cui le interpreti dipendono dal tipo di BCI che stai usando, (paradigma BCI).

> **Ricorda.**
> - ***Estrazione delle caratteristiche (feature extraction)***: prendere il segnale grezzo del cervello (EEG, per esempio) e trasformarlo in qualcosa di più utile (es. frequenze, ampiezze, pattern).
> - ***Classificazione***: usare quelle caratteristiche per decidere cosa sta “facendo” il cervello (es. immaginare movimento, attenzione a uno stimolo, ecc.).
> - ***Paradigma BCI***: il tipo di interfaccia cervello-computer che stai usando (cioè come interagisci col cervello).

I due paradigmi principali utilizzati nei sistemi BCI basati su EEG sono il ***Motor Imagery*** e i ***Potenziali Evocati***

---

#### *Paradigma Motor Imagery*  

Il ***Motor Imagery*** (immaginazione motoria) è un paradigma BCI che sfrutta il fatto che la semplice *immaginazione mentale* di un movimento — senza che il movimento venga effettivamente eseguito — produce nel cervello un'attività neurale misurabile.

Il meccanismo alla base di questo paradigma è il fenomeno della ***desincronizzazione evento-correlata*** (*ERD, Event-Related Desynchronization*): quando un soggetto immagina di muovere, ad esempio, la mano destra, nella corteccia motoria sinistra (che controlla la mano destra) si verifica una *riduzione della potenza* del ritmo $\mu$. Questa riduzione di potenza nella banda $\mu$ — la *desincronizzazione* — è il segnale che il sistema BCI deve rilevare e classificare.

Il computer, addestrato su sessioni di calibrazione in cui il soggetto immagina movimenti specifici, impara a riconoscere il pattern di desincronizzazione associato a ciascun tipo di immaginazione motoria (mano destra, mano sinistra, piede, lingua). Successivamente, in tempo reale, classifica i nuovi segmenti di segnale e li traduce nel comando corrispondente.

<!-- immagine dopo -->

#### *Paradigma dei Potenziali Evocati: il P300*  

Il secondo paradigma principale è quello dei ***Potenziali Evocati***, in cui l'utente non produce attivamente un pattern motorio, ma *risponde passivamente a stimoli esterni*. Il sistema rileva la risposta cerebrale agli stimoli e la usa come segnale di controllo.

Il potenziale evocato più utilizzato in ambito BCI è il ***P300***: un'onda positiva che appare nell'EEG circa 300 millisecondi dopo la presentazione di uno stimolo che il soggetto considera rilevante o inatteso. 

A differenza del Motor Imagery — che richiede un training per imparare a modulare l'attività oscillatoria cerebrale — il P300 è una risposta involontaria e universale: non richiede nessun apprendimento da parte dell'utente, rendendolo particolarmente adatto a pazienti con compromissioni cognitive o con poco tempo per la calibrazione del sistema.

---

### 8.7.3 Output, feedback e plasticità cerebrale

Una volta che l'algoritmo di classificazione del segnale EEG (algoritmo di machine learning) ha tradotto il pattern cerebrale in un'intenzione dell'utente (es.  "muovi il cursore a destra" o "seleziona la lettera K"), il sistema BCI genera un ***output***: un comando inviato al dispositivo esterno collegato. I dispositivi target possono essere molto diversi a seconda dell'applicazione:
- una ***sedia a rotelle motorizzata***
- un ***braccio robotico*** o una ***protesi***
- un ***sintetizzatore vocale*** o una ***tastiera virtuale*** (come lo Speller P300)

Accanto all'output, un componente cruciale di qualsiasi sistema BCI è il ***feedback***: la restituzione del risultato del comando all'utente. L'utente vede il risultato del suo comando (es. il cursore che si muove) e il suo cervello si adatta, imparando a modulare meglio i propri segnali per ottenere prestazioni superiori (***plasticità cerebrale***).

### 8.7.4 Applicazioni cliniche e consumer delle BCI

Le applicazioni dei sistemi BCI abbracciano un ampio spettro, dalla riabilitazione clinica di pazienti con gravi disabilità alle applicazioni consumer nel gaming e nel neuromarketing. La tabella seguente riassume i principali contesti di utilizzo.

| Categoria di utenti | Applicazione |
|---|---|
| Pazienti con SLA | Comunicazione tramite P300 Speller (scrittura di parole usando il pensiero) |
| Pazienti paralizzati | Controllo di esoscheletri o protesi robotiche per il recupero della funzione motoria |
| Riabilitazione post-ictus | Giochi in VR controllati dall'attività cerebrale per stimolare la neuroplasticità e recuperare funzioni motorie compromesse |
| Gaming e interfacce digitali | Controllo di ambienti virtuali tramite segnali cerebrali |

## 8.8 *P300 Speller: scrivere parole tramite le onde cerebrali* 

### 8.8.1 Definizione

Il ***P300 Speller*** è una delle applicazioni BCI più celebri. Si tratta di un'***interfaccia che consente a un utente di comunicare*** selezionado lettere o caratteri su uno schermo: permette di ***scrivere parole su schermo*** usando solo l'attenzione visiva e un particolare segnale elettrico del cervello, il potenziale ***P300***.

> ***Definizione (P300).***  
La ***P300*** è un'onda cerebrale appartenente alla categoria degli ***ERP*** (*Event-Related Potentials*, *Potenziali Evento-Correlati*): si tratta di una ***risposta elettrica del cervello***, dovuta ad un evento esterno, che emerge nell'EEG circa ***300 millisecondi*** dopo uno stimolo visivo o uditivo che il soggetto considera ***importante o inatteso***. 
>
> Il prefisso "P" indica che si tratta di un'onda di polarità ***positiva*** (una *deflessione verso l'alto nel grafico dell'EEG*, cioè *movimento verso l'alto rispetto alla linea di base del segnale*), e il suffisso "300" indica la latenza approssimativa in millisecondi dalla presentazione dello stimolo.

---

#### *Perché questo segnale è utile per una BCI*  

Il cervello umano genera la P300 in modo involontario e automatico ogni volta che, tra una sequenza di stimoli ripetitivi e irrilevanti, ne compare uno ritenuto significativo — senza che il soggetto debba compiere alcuno sforzo consapevole. Questa proprietà rende la P300 un "segnale di riconoscimento" estremamente affidabile: se il sistema riesce a rilevare quando la P300 viene generata, sa che lo stimolo presentato in quel momento era quello che il soggetto stava cercando.

> ***Esempio.***  
Immaginiamo di guardare una sequenza di lettere: il cervello reagirà in modo "normale" a tutte, ma quando apparirà proprio la lettera che vogliamo scrivere, il cervello produrrà un picco di tensione positiva (la P300).

---

### 8.8.2 Architettura del sistema: griglia $6\times 6$

Il sistema *P300 Speller* presenta all'utente una griglia (solitamente una matrice $6\times 6$) contenente l'alfabeto, i numeri e alcuni caratteri speciali. 

<div align = "center">

![alt text](<P300 Speller-1.png>)

</div>

### 8.8.3 Meccanismo di funzionamento: paradigma Oddball

Il funzionamento del P300 Speller si basa su un principio denominato ***paradigma Oddball***: la comparsa infrequente di uno stimolo "raro" (o "oddball", fuori posto) all'interno di una sequenza di stimoli "standard" provoca nel cervello una ***risposta di sorpresa*** — la ***P300*** — che non si verifica per gli stimoli standard.

Il funzionamento della P300 Speller si articola in quattro passi:

> ***Passo 1 — Concentrazione dell'utente.***  
L'utente fissa visivamente (o porta l'attenzione mentale) su una singola lettera della griglia. Supponiamo che l'utente voglia scrivere la lettera "K".

> ***Passo 2 — Flash delle righe e delle colonne.***  
Il sistema informatico fa illuminare casualmente, in rapida successione, le righe e le colonne della griglia, una alla volta.

> ***Passo 3 — Effetto Oddball: distinzione tra flash rilevanti e irrilevanti.***  
I flash delle righe e delle colonne non sono tutti equivalenti:
> - quando si illumina una riga o una colonna che **non contiene** la lettera "K", si tratta di uno ***stimolo irrilevante***. Il cervello lo elabora come "standard" e non genera alcuna risposta straordinaria
> 
> - quando si illumina la ***riga o la colonna che contiene*** "K", lo stimolo è ***improvvisamente rilevante***: il cervello riconosce che "*la lettera che voglio selezionare è in questo flash*" e genera la ***P300***, circa 300 ms dopo l'inizio del flash

> ***Passo 4 — Decodifica per intersezione.***  
Il sistema registra il segnale EEG durante tutta la sequenza di flash. Dopo aver ripetuto i primi tre passi un numero sufficiente di volte, il sistema identifica in quale momento è avvenuta la P300, identifica la riga e la colonna corrispondenti alla lettera e "scrive" la lettera

### 8.8.4 Attenzione focale e attenzione nascosta

> ***Attenzione focale.***  
Nella versione standard del P300 Speller, l'utente ***guarda direttamente*** la lettera desiderata. Quando la riga o la colonna contenente quella lettera si illumina, si verifica un meccanismo di "*sorpresa cognitiva*": anche se l'utente sa che la sua lettera si illuminerà prima o poi, il momento esatto è imprevedibile, perché l'ordine dei flash è casuale. Questa imprevedibilità temporale è sufficiente a innescare la P300 ad ogni flash rilevante.

> ***Attenzione nascosta (covert attention).***  
Una caratteristica distintiva e clinicamente fondamentale del P300 Speller è che il sistema ***funziona anche senza movimenti oculari***. Se un utente fissa il centro dello schermo ma concentra la propria attenzione mentale su una lettera posta in un angolo della griglia, il cervello genererà comunque la P300 quando il flash raggiungerà quella lettera — anche se gli occhi non si sono mossi verso di essa.

## 8.9 *Problema del rapporto segnale-rumore nell'EEG*

### 8.9.1 Modello additivo del segnale EEG

Il principio di funzionamento del P300 Speller può sembrare semplice nella sua logica: "rileva quando appare la P300 e trova la lettera". La difficoltà pratica, tuttavia, è enorme, e deriva da un problema fondamentale: il ***rapporto segnale-rumore dell'EEG è bassissimo***.

Per comprendere questo problema in modo preciso, introduciamo il seguente ***modello additivo del segnale EEG***:

$$\text{EEG}(t) = \text{ERP}(t) + \text{Rumore}(t)$$

dove:
- $\text{EEG}(t)$ è il segnale totale misurato dall'elettrodo in funzione del tempo $t$;
- $\text{ERP}(t)$ è il potenziale evento-correlato (Event-Related Potential), ovvero il componente neurale che ci interessa, come la P300. Questo segnale è ***deterministico e sincronizzato con lo stimolo***: ogni volta che si presenta la stessa categoria di stimolo (ad esempio, un flash rilevante), l'ERP appare nella stessa finestra temporale relativa all'inizio dello stimolo;
- $\text{Rumore}(t)$ è la somma di tutto il resto: l'attività cerebrale "di fondo" non correlata al compito (pensieri, oscillazioni spontanee), gli artefatti residui di EOG, EMG, ECG, e il rumore elettronico degli amplificatori. Questo componente è ***casuale*** e ***non correlato*** con la presentazione degli stimoli.

Il problema pratico è che, in un singolo trial (una singola presentazione dello stimolo), l'ampiezza della P300 è dell'ordine di pochi microvolt, mentre il rumore ha un'ampiezza comparabile o anche maggiore. Su un singolo flash, la P300 è virtualmente invisibile nel segnale grezzo.

### 8.9.2 Tecnica della media su N epoche

La soluzione a questo problema è una tecnica classica del processamento dei segnali biomedici: la media asincrona (o grand average) su più epoche dello stesso tipo di stimolo.

> ***Definizione (epoca).***  
Un'***epoca*** (o trial) è un segmento del segnale EEG estratto attorno ad uno stimolo specifico, allineato in modo che $t = 0$ corrisponda all'inizio di quello stimolo. 
>
> In altre parole è una sezione del segnale EEG centrata su uno stimolo, che include un intervallo temporale prima e dopo di esso.
>
>> ***Esempio.*** Per il P300 si estrae tipicamente un'epoca che va da $−200\text{ ms}$ ($200\text{ ms}$ prima dello stimolo, usati come baseline) a $+800\text{ ms}$ ($800\text{ ms}$ dopo lo stimolo, per catturare l'intera forma d'onda della P300 e dei componenti successivi).

> ***Il meccanismo della media.***  
Se si presentano $N$ ripetizioni dello stesso stimolo (ad esempio, la riga contenente la lettera K viene illuminata N volte), si ottengono $N$ epoche $x_1(t), x_2(t), \ldots, x_N(t)$. La media su queste $N$ epoche produce il segnale:
>
> $$\hat{\text{ERP}}(t) = \frac{1}{N} \sum_{i=1}^{N} x_i(t)$$
>
> Questa operazione produce due effetti opposti sui due termini del modello additivo.
>
> 1. ***L'onda P300 si somma a se stessa***: in ogni ripetzione dello stesso stimolo, la P300 ha la stessa forma e appare nella stessa posizione temporale, allora la media delle P300 di ogni epoca mantiene la sua forma e ampiezza. Formalmente, se $\text{ERP}(t)$ (componente neurale di interesse, in questo caso la P300) è identico in ogni epoca, la media di $N$ copie identiche è ancora $\text{ERP}(t)$: il componente neurale di interesse viene preservato integralmente.
>
> 2. ***Il rumore si annulla***: poiché il rumore $\text{Rumore}_i(t)$ nelle diverse epoche è ***casuale***, la media di molti valori positivi e negativi tende a zero per $N\to\infty$ (con $N$ epoche). Quantitativamente, se il rumore ha deviazione standard $\sigma$, la deviazione standard del rumore mediato è:
>
>$$\sigma_{\text{mediato}} = \frac{\sigma}{\sqrt{N}}$$
>
> L'ampiezza del rumore residuo si riduce proporzionalmente a $1/\sqrt{N}$: raddoppiare il numero di epoche riduce il rumore di un fattore $\sqrt{2} \approx 1{,}41$; passare a 4 volte le epoche riduce il rumore della metà; e così via.
>
>> ***Esempio.***  
>> - Con ***1 flash*** ($N = 1$ epoche): il rumore domina, la P300 è invisibile
>> - Con ***25 flash*** ($N = 25$ epoche): il rumore è ridotto di 5 volte
>> - Con ***100 flash*** ($N = 100$ epoche): il rumore è ridotto di 10-volte e l'onda P300 emerge chiaramente

## 8.10 *Strumenti software per l'elaborazione dei dati EEG*

### 8.10.1 EEGLAB

***EEGLAB*** è un toolbox open source interattivo per MATLAB destinato per l'elaborazione di segnali EEG ad alta densità. EEGLAB fornisce sia un'interfaccia grafica interattiva sia funzioni MATLAB richiamabili da script, permettendo sia un utilizzo esplorativo sia l'automazione di pipeline di analisi su grandi dataset.

EEGLAB è progettato per integrare due metodologie di analisi complementari:
- l'***analisi tempo-frequenza*** (*Time-Frequency Analysis*), per esaminare come la distribuzione della potenza nelle diverse bande di frequenza evolve nel tempo 
- l'***Analisi delle Componenti Indipendenti*** (*ICA*, *Independent Component Analysis*), per separare le sorgenti di segnale indipendenti (neurali e artefattuali) registrate sui diversi elettrodi

<!-- trovare analisi tempo/frequenza negli appunti -->

---

#### *Pre-processing in EEGLAB*

Le attività di pre-processing standard raccomandate da EEGLAB sono articolate in una sequenza ordinata di dodici passi, che seguono la logica "*da segnale grezzo a segnale pronto per l'analisi*".

I dodici passi, nell'ordine, sono:
1. ***Raccolta dei dati EEG***: acquisizione del segnale grezzo con il dispositivo
2. ***Importazione in EEGLAB***: lettura del file dati nel toolbox, che crea la struttura dati `EEG`
3. ***Importazione dei marker di evento e delle posizioni degli elettrodi***: associazione degli eventi sperimentali (es. "flash della lettera K") alla riga temporale del segnale, e caricamento delle coordinate spaziali degli elettrodi secondo il sistema 10-20
4. ***Re-referenziazione e down-sampling*** (se necessario): cambio del riferimento elettrico (da singolo elettrodo a media dei canali, ad esempio) e riduzione della frequenza di campionamento per alleggerire il carico computazionale
5. ***Filtro passa-alto*** (circa 0,5–1 Hz): rimozione delle derive di baseline a frequenza molto bassa, che possono distorcere la forma d'onda degli ERP e compromettere la convergenza dell'ICA
6. ***Esame visivo dei dati grezzi***: ispezione manuale o automatica del tracciato per identificare canali anomali o segmenti con artefatti di grande ampiezza
7. ***Identificazione e rigetto dei canali difettosi***: i canali con attività costantemente piatta o costantemente rumorosa vengono marcati come "bad" e interpolati dai canali vicini
8. ***Rigetto dei segmenti temporali con artefatti di grande ampiezza***: i tratti del segnale in cui un artefatto (es. movimento improvviso del soggetto) ha prodotto un'escursione di ampiezza molto elevata vengono rimossi prima di applicare l'ICA, perché distorcerebbero la decomposizione.
9. ***Esecuzione dell'ICA*** (Independent Component Analysis): decompone il segnale EEG in un insieme di componenti statisticamente indipendenti
10. ***Selezione e rigetto delle componenti ICA artefattuali***: le componenti identificate come EOG, EMG o ECG (riconoscibili dalla loro topografia scalare caratteristica e dalla loro forma d'onda) vengono rimosse e il segnale viene ricostruito senza di esse
11. ***Fit dei dipoli equivalenti*** (opzionale): stima della sorgente neurale sottostante a ciascuna componente ICA, modellandola come un dipolo di corrente nel cervello
12. ***Salvataggio dei dati puliti***: esportazione del dataset pre-processato per le analisi successive

### 8.10.2 OpenViBE

OpenViBE è una piattaforma software open source progettata specificamente per la realizzazione di sistemi BCI in ***tempo reale***. A differenza di EEGLAB — che è uno strumento di analisi offline, progettato per elaborare dati già acquisiti — OpenViBE è concepito per operare durante la sessione di acquisizione, leggendo il segnale EEG in streaming e producendo comandi o visualizzazioni in diretta.

---

## Lezione 14

---

# Capitolo 9 — Machine Learning: introduzione, apprendimento supervisionato e non supervisionato

---

## 9.1 Cos'*è il machine learning*  

### 9.1.1 Definizione e collocazione nel panorama dell'AI

Il ***machine learning*** (apprendimento automatico, *ML*) è una sottocategoria dell'***intelligenza artificiale*** (*AI*). Per orientarsi, introduciamo la gerarchia che lega AI e ML.

> ***Intelligenza Artificiale (AI)***  
Il termine più ampio, indica qualsiasi tecnica che consenta a un sistema informatico di simulare comportamenti tipicamente associati all'intelligenza umana — ragionare, pianificare, riconoscere pattern, comprendere il linguaggio naturale.
>
>> ***Machine Learning (ML)***  
È un sottoinsieme dell'AI che si distingue per un principio specifico: la capacità di ***apprendere senza essere esplicitamente programmato***. Anziché seguire istruzioni scritte da un programmatore per ogni possibile situazione, un sistema ML ricava autonomamente le regole necessarie a risolvere un problema analizzando esempi di dati.
>>
>>> ***Deep Learning (DL)***  
È un sottoinsieme del machine learning che si caratterizza per l'utilizzo di ***reti neurali artificiali*** con molteplici strati: queste architetture sono particolarmente adatte a estrarre pattern e rappresentazioni gerarchiche da dati complessi come immagini, audio e testo tramite le reti neurali.

In termini operativi, il ***ML*** è il ***processo di addestramento di un software — chiamato modello — per effettuare previsioni utili o generare contenuti a partire dai dati***. Il modello non viene programmato con regole esplicite: viene esposto a grandi quantità di dati e, attraverso un processo iterativo di ottimizzazione, ricava autonomamente la relazione matematica che lega gli input agli output desiderati.

> ***Definizione (modello).***  
Un ***modello*** di apprendimento è una funzione matematica parametrizzata che descrive come gli input vengono trasformati in output: $$f_{\theta}:\mathcal{X}\to\mathcal{Y}$$ dove:
> - $\mathcal{X}$ è lo spazio degli input
> - $\mathcal{Y}$ è lo spazio degli output
> - $\theta$ è il vettore dei parametri del modello
>
> Questa funzione, una volta addestrata, consente di effettuare previsioni o generare contenuti a partire dai dati.

> **Nota.** Le applicazioni del ML sono pervasive nella tecnologia moderna: app di traduzione automatica, veicoli a guida autonoma, previsioni meteorologiche, sistemi di raccomandazione musicale, completamento automatico del testo, riassunti di articoli, generazione di immagini. Nel contesto specifico del corso HMI, il ML è lo strumento che consente ai sistemi BCI di decodificare l'intenzione dall'attività cerebrale, e più in generale è il motore di molte interfacce intelligenti uomo-macchina.

### 9.1.2 Approccio ML vs approccio algoritmico tradizionale

Per comprendere in cosa il ML differisce dalla programmazione tradizionale, è utile confrontare i due approcci su un esempio specifico: la previsione delle precipitazioni.

> ***Approccio tradizionale (basato sulla fisica).***  
Un sistema classico per la previsione delle precipitazioni richiederebbe di costruire un modello matematico dell'atmosfera e della superficie terrestre, scrivendo esplicitamente enormi quantità di equazioni di fluidodinamica, termodinamica e altre equazioni che governano i fenomeno meteorologici. 
>
> In questo approccio, ogni regola e ogni relazione tra variabili deve essere codificata manualmente dal programmatore. 

> ***Approccio ML.***  
Con un approccio basato sul ML, invece, si fornisce al modello una grande quantità di ***dati storici meteorologici*** — migliaia o milioni di osservazioni passat. Il modello analizza questi dati e impara autonomamente la relazione matematica tra i pattern meteorologici (temperatura, umidità, pressione, copertura nuvolosa, direzione del vento, ecc.) e la quantità di pioggia. Una volta completato l'addestramento, il modello è in grado di prevedere le precipitazioni future a partire dalle condizioni meteorologiche attuali, senza che nessuna regola fisica sia stata scritta esplicitamente.

La distinzione concettuale fondamentale è questa: nell'approccio tradizionale il programmatore codifica le ***regole***, e il sistema le applica ai dati; nell'approccio ML il programmatore fornisce i ***dati*** (con i risultati corretti), e il sistema ricava le regole da solo.

## 9.2 Tecniche del machine learning

Il machine learning non è un'unica tecnica, ma una famiglia di approcci distinti. Le due tecniche principali (paradigmi) sono l'***apprendimento supervisionato*** e l'***apprendimento non supervisionato***. Esiste anche un terzo paradigma — l'***apprendimento per rinforzo*** — ma che non andremo ad approfondire.

<div align = "center">

![alt text](ML_paradigmi-1.png)

</div>

### 9.2.1 Apprendimento supervisionato

L'***apprendimento supervisionato*** (*supervisioned learning*) è il paradigma in cui il modello viene addestrato su un insieme di dati che contengono ***sia gli input (caratteristiche) sia gli output corretti (etichette)***. Il termine "supervisionato" riflette il fatto che l'addestramento è guidato da una "supervisione esterna": qualcuno — un essere umano — ha fornito al modello dei dati con i la loro relativa risposta corretta. Questo fornisce al modello un riferimento preciso rispetto al quale misurare e migliorare le proprie previsioni.

> ***Per comprendere meglio.***  
È come uno studente che si prepara per un esame studiando dagli esami degli anni precedenti, ciascuno corredato sia delle domande sia delle risposte. Dopo aver visto un numero sufficiente di esempi risolti, lo studente è in grado di affrontare domande nuove mai viste prima.

I due casi d'uso più comuni per l'apprendimento supervisionato sono la ***regressione*** e la ***classificazione***.

---

#### *Regressione*

Un ***modello di regressione*** prevede, da dati forniti in input, un valore numerico continuo (prevede un numero futuro). L'output è un numero che può in teoria assumere qualsiasi valore in un intervallo.

> ***Esempio di modello di regressione.***  
Un modello di previsione meteorologica è un esempio di modello di regressione: il modello riceve in ***input*** le *condizioni atmosferiche* (temperatura, umidità, pressione, ecc.) e restituisce in ***output*** la *quantità di pioggia* prevista espressa in millimetri.

<div align = "center">

![alt text](regressione-1.png)

</div>

#### *Classificazione*  

Un ***modello di classificazione*** restituisce un valore discreto che indica l'appartenenza di un input ad una categoria specifica (categoria di dati). L'output non è un numero continuo, ma una classe. 

> ***Esempio di modello di classificazione.***  
Un modello di classificazione può essere usato per prevedere se una mail è spam / non spam, per riconoscere le lettere A / B / C / ... / Z, riconoscimento vocale voce maschile / femminile, ecc.

Si distinguono due varianti del modello di classificazione:
- ***classificazione binaria***: le classi a cui può appartenere un input sono esattamente due (es. spam / non spam)
- ***classificazione multiclasse***: le classi a cui può appartenere un input sono tre o più (es riconoscimento di 26 lettere dell'alfabeto)

<div align = "center">

![alt text](classificazione-1.png)

</div>

---

### 9.2.2 Apprendimento non supervisionato

L'***apprendimento non supervisionato*** (*unsupervised learning*) è il paradigma in cui il modello viene addestrato su dati che ***contengono solo gli input, senza alcun output corretto (etichetta)***. Non esiste nessuna "risposta corretta" fornita in anticipo: il modello deve trovare autonomamente strutture, pattern o raggruppamenti nascosti nei dati, basandosi unicamente sulle proprietà intrinseche degli input stessi. 

Questo approccio è utile in tutti quei contesti in cui etichettare i dati (avere gli output corretti) sarebbe troppo costoso, impossibile, o semplicemente non pertinente — perché l'obiettivo è scoprire la struttura dei dati, non prevedere una variabile.

La tecnica di apprendimento non supervisionato più diffusa è il ***clustering*** (raggruppamento): il modello analizza gli esempi di input e li raggruppa in ***cluster*** (gruppi), in modo che gli elementi all'interno dello stesso cluster siano il più possibile simili tra loro, rispetto agli elementi degli altri cluster. Il clustering è fondamentale nell'***analisi esplorativa*** dei dati, quando si vuole capire se esistono sottogruppi naturali tra i dati presenti in un dataset. 

<div align = "center">

![alt text](clustering-1.png)

</div>

> ***Esempi di utilizzo del clustering.***  
Applicazioni tipiche del clustering comprendono l'analisi delle sequenze genetiche (raggruppare geni con comportamenti simili), il marketing (raggruppare clienti in base ai comportamenti d'acquisto), e l'analisi dei social network (identificare gruppi di utenti con interessi comuni).

### 9.2.3 Sintesi comparativa: supervisionato vs non supervisionato

La distinzione fondamentale tra i due paradigmi riguarda la presenza o assenza delle etichette (output corretti) nei dati di addestramento, e di conseguenza il tipo di obiettivo perseguito.

| | Apprendimento supervisionato | Apprendimento non supervisionato |
|-|------------------------------|----------------------------------|
| ***Dati in input***          | Caratteristiche + etichette (risposte corrette) | Solo caratteristiche (nessuna etichetta) |
| ***Obiettivo***              | Prevedere l'etichetta di nuovi esempi | Scoprire strutture o raggruppamenti nei dati |
| ***Output***                 | Valore numerico (regressione) o classe di appartenenza (classificazione) | Cluster, dimensioni ridotte
| ***Esempi di applicazione*** | Previsione pioggia, rilevazione spam, riconoscimento immagini | Segmentazione clienti, analisi genetica |
| ***Prerequisito***           | Disponibilità di dati etichettati (costosa) | Disponibilità di soli dati grezzi | 

In sintesi: l'apprendimento supervisionato risponde alla domanda "dato questo input, qual è l'output corretto?"; l'apprendimento non supervisionato risponde alla domanda "quali strutture o raggruppamenti esistono in questi dati?".

<div align = "center">

![alt text](modelli_apprendimento-1.png)

</div>

## 9.3 *Apprendimento supervisionato: i cinque componenti fondamentali*

Il funzionamento di un sistema di apprendimento supervisionato si basa su cinque concetti fondamentali, strettamente interdipendenti: ***dati***, ***modello***, ***addestramento***, ***valutazione*** e ***inferenza***. 

### 9.3.1 Dati

I dati sono la forza trainante del machine learning: senza dati di buona qualità, nessun algoritmo di apprendimento, per quanto soddisfatto, può produrre un modello affidabile.

> ***Definizione (algoritmo di apprendimento).***  
Un ***algoritmo di apprendimento*** è la procedura computazionale che, a partire da un dataset supervisionato $\mathcal{D}$, determina i parametri $\theta$ ottimali di un modello $f_{\theta}$, in modo da ridurre l'errore nell'approssimazione della funzione $\hat{f}: \mathcal{X}\to\mathcal{Y}$.
>
> L'algoritmo produce quindi la funzione $\hat{f}$, che rappresenta un'approssimazione della relazione sconosciuta $f: \mathcal{X}\to\mathcal{Y}$ che lega input e output.
>
>> ***Differenze tra modello e algoritmo***  
>> | Concetto | Significato | Ruolo |
>> |----------|-------------|-------|
>> | ***Modello*** | Famiglia di funzioni $f_{\theta}$ | Definisce le relazioni input-output |
>> | ***Algoritmo*** | Procedura di ottimizzazione | Stima i parametri $\theta$ del modello $f_{\theta}$ a partire dai dati disponibili | 


I dati per l'apprendimento supervisionato si presentano come ***esempi*** organizzati in un dataset. Ciascun esempio è composto da due parti:
- le ***caratteristiche*** (features): le ***variabili di input*** che descrivono l'esempio. Nell'app meteo, le caratteristiche di un singolo giorno sono data, latitudine, longitudine, temperatura, umidità, copertura nuvolosa, direzione del vento, pressione atmosferic
- l'***etichetta*** (label): il ***valore di output*** corretto associato a quell'esempio. Nell'app meteo, l'etichetta è la quantità di pioggia effettivamente caduta quel giorno (es. `rainfall = 0.01 mm` oppure `rainfall = 0.23 mm`)

Un esempio corredato di etichetta è chiamato ***esempio etichettato*** (*labeled example*); un esempio privo di etichetta è un ***esempio non etichettato*** (*unlabeled example*). Il modello viene addestrato su esempi etichettati; una volta addestrato, viene usato per prevedere l'etichetta di esempi non etichettati.

<div align = "center">

![alt text](in_etichetta-1.png)
![alt text](in_no_etichetta-1.png)

</div>

---

#### *Dimensioni e diversità del dataset*  

La qualità di un dataset si misura su due aspetti:
- ***dimensioni*** (*size*): il ***numero di esempi presenti nel dataset***. Un dataset di grandi dimensioni consente al modello di vedere molte situazioni diverse durante l'addestramento, riducendo il rischio che si adatti in modo eccessivo a pattern specifici non generalizzabili
- ***diversità*** (*diversity*): la ***gamma di valori e situazioni coperta dagli esempi***. Un dataset altamente diversificato garantisce che il modello venga esposto a tutte le variazioni rilevanti del fenomeno da modellare

Un dataset di qualità deve essere ***sia di grandi dimensioni sia altamente diversificato***. Nonostante ciò, un dataset di grandi dimensioni non garantisce una diversità sufficiente, ed un dataset altamente diversificato non garantisce un numero sufficiente di esempi.

> ***Esempio.***  
Un dataset meteorologico potrebbe contenere dati su 100 anni, ma solo per il mese di luglio: avrebbe grandi dimensioni ma scarsa diversità stagionale, producendo previsioni inaffidabili per gennaio. Al contrario, un dataset che copre tutti i mesi dell'anno ma solo per tre anni recenti avrebbe elevata diversità ma dimensioni insufficienti, risultando vulnerabile alla variabilità inter-annuale del clima.

### 9.3.2 Modello 

Nell'apprendimento supervisionato, un ***modello*** è una funzione matematica che trasforma i dati di input in un output. Questa funzione è controllata da alcunti parametri (numeri) che vengono regolati durante l'addestramento per far si che le previsioni del modello siano il più possibile vicine ai valori corretti. 

In altre parole, il modello è la ***"regola" che il sistema ML ha imparato a costruire, a partire dai dati, per passare da input a output***. I parametri sono i valori che determinano come funziona questa regola.

> ***Definizione (parametri).***  
I ***parametri*** sono i numeri interni al modello che ne determinano il comportamento e che vengono modificati durante l’addestramento per migliorare le previsioni.

Prima di qualsiasi addestramento, i parametri del modello sono inizializzati in modo arbitrario (tipicamente casuale): in questa fase iniziale il modello non sa ancora nulla del problema. Sarà il processo di ***addestramento*** a far emergere i parametri corretti che permetteranno al modello, a partire dai dati, di passare da input (caratteristica) al suo output corretto (etichetta).

### 9.3.3 Addestramento

L'***addestramento*** (*training*) è il processo iterativo attraverso cui il modello impara a fare previsioni corrette a partire da un insieme di dati, aggiornando progressivamente i propri parametri sulla base degli errori commessi. 

Per addestrare un modello, gli forniamo un set di dati contenente esempi etichettati e, da questo dataset, si ripete il ciclo di apprendimento per ogni esempio etichettato presente al suo interno. Questo ciclo di addestramento è caratterizzato da tre passi.

> ***Passo 1 — Previsione.***  
Il modello, con i parametri corretti, riceve in input le caratteristiche di un singolo esempio (già etichettato) e produce una previsione del valore dell'etichetta

> ***Passo 2 — Calcolo della perdità e confronto.***  
Il modello confronta il valore previsto con il valore effettivo dell'etichetta. La differenza tra i due valori viene misurata attraverso una grandezza chiamata ***perdita*** (*loss*): più la previsione è lontana dal valore reale, maggiore è la perdita. La perdita è la ***misura quantitativa dell'errore commesso dal modello su quell'esempio***.

> ***Passo 3 — Aggiornamento.***  
Sulla base del valore della perdita, il modello ***aggiorna gradualmente la propria soluzione***: i parametri vengono modificati in una direzione che riduce la perdita. Questo aggiornamento è guidato da un algoritmo di ottimizzazione (tipicamente la discesa del gradiente), che calcola in quale direzione modificare ciascun parametro per ottenere una previsione migliore sulla prossima iterazione.

<div align = "center">

![alt text](addestramento_ML-1.png)

</div>

### 9.3.4 Valutazione 

Una volta completato l'addestramento, il modello deve essere ***valutato*** per determinare quanto ha effettivamente appreso: un modello che ha semplicemente memorizzato i dati di addestramento senza generalizzare non è utile in produzione.

La valutazione si esegue su un ***set di valutazione*** (o set di test) separato dai dati di addestramento: si tratta di un insieme di dati (esempi) etichettati che il modello non ha mai visto durante l'addestramento. Il protocollo è il seguente:
1. si forniscono al modello solo le ***caratteristiche*** degli esempi di valutazione (nascondendo le etichette)
2. il modello produce le proprie ***previsioni*** per ciascun esempio
3. si confrontano le previsioni del modello con i ***valori reali delle etichette***

<div align = "center">

![alt text](valutazione_ML-1.png)

</div>

Il risultato di questa comparazione viene sintetizzato in metriche di valutazione che quantificano la qualità del modello: 
- per i modelli di regressione si usano tipicamente l'errore quadratico medio (MSE, *Capitolo 4*) o l'errore assoluto medio (MAE)
- per i modelli di classificazione si usano l'accuratezza (percentu
ale di esempi classificati correttamente), la precisione, il recall e la matrice di confusione

> **Nota.**  La separazione tra set di addestramento e set di valutazione è fondamentale: valutare il modello sugli stessi dati usati per addestrarlo produrrebbe una stima ottimistica e ingannevole delle sue prestazioni reali, perché il modello avrebbe semplicemente memorizzato le risposte corrette anziché generalizzare a nuovi esempi.

### 9.3.5 Inferenza

Quando il modello ha superato la valutazione e i suoi risultati sono ritenuti soddisfacenti, può essere utilizzato per fare ***previsioni*** — chiamate ***inferenze*** — su nuovi esempi non etichettati, ovvero dati mai visti in nessuna fase precedente. 

> ***Definizione (inferenza).***  
L'***inferenza*** è il momento in cui il modello viene effettivamente utilizzato per lo scopo per cui è stato costruito.

> ***Esempio.***  
Nell'app meteo, l'inferenza consiste nel fornire al modello le condizioni meteorologiche attuali (temperatura, pressione atmosferica, umidità relativa del giorno corrente) e ottenere in output la previsione della quantità di pioggia per le prossime ore.

### 9.3.6 Sintesi: componenti dell'apprensimento supervisionato

I cinque componenti del machine learning supervisionato si dispongono quindi in una sequenza logica: 
- i ***dati*** alimentano l'***addestramento*** del modello
- la ***valutazione*** certifica la qualità del modello addestrato
- l'***inferenza*** impiega il modello su nuovi dati nel contesto applicativo reale

---

## Lezione 15

---

# Capitolo 10 — Machine Learning: apprendimento supervisionato, dati, metriche di valutazione e alberi decisionali

---

## 10.1 Tassonomia del machine learning supervisionato

È utile fissare la ***tassonomia completa degli algoritmi di machine learning supervisionato***, che organizza gli approcci in base al tipo di output prodotto.

> **Nota.** La ***tassonomia*** indica la classificazione, l'organizzazione e la nomeclatura di elementi all'interno di un sistema gerarchico.

<div align = "center">

![alt text](tassonomia_ML-1.png)

</div>

<!-- Il criterio di suddivisione delle tecniche (modelli) di apprendimento supervisionato utilizzati nel machine learning è basato sul tipo della ***variabile target*** $y$:
- se $y\in\mathbb{R}$ (numero reale, continuo) \to ***regressione***
- se $y\in\{C_1, \ldots, C_g\}$ (valore categorico, insieme finito di classi) \to ***classificazione***

I compiti dei modelli apprendimento supervisionati sono contesti in cui si ipotizza l'esistenza di una relazione funzionale (regola che lega gli input agli output) tra gli input (feature, caratteristiche $\mathbf{x}$) e l'output (target $y$), e si vuole individuare tramite inferenza tale regola a partire dagli esempi etichettati. -->

## 10.2 *Apprendimento supervisionato*

L'***apprendimento supervisionato*** è un paradigma (tecnica) del machine learning, in cui si dispone di un'insieme di esempi etichettati, ossia di coppie costituite da un input e dal corrispondente output corretto. 

Ogni esempio etichettato è una coppia — detta ***osservazione*** — formata da:
- un ***input*** $\mathbf{x}$, un vettore di feature (caratteristiche)
- un ***output corretto*** $y$, il target, cioè il valore da prevedere

L’obiettivo consiste nell’addestrare un modello: a partire da tali esempi, stabilire una regola capace di associare nuovi input ai relativi output.

> **Ricorda.** Un ***modello*** è un software addestrato per effettuare previsioni utili o generare contenuti a partire dai dati.

### 10.2.1 Osservazione

Una singola ***osservazione*** nel contesto dell'apprendimento supervisionato è una coppia del tipo: $$(\mathbf{x}^{(i)}, y^{(i)})\in(\mathcal{X}\times\mathcal{Y}) \qquad i = 1,\ldots,n$$
dove:
- $\mathbf{x}^{(i)}$ è l'***input*** (il vettore delle feature) dell'$i$-esima osservazione
- $y^{(i)}$ è il ***target*** (associato a quell'input) dell'$i$-esima osservazione

L'obiettivo è costruire un modello in grado di apprendere, a partire da questi esempi, una relazione tra input e output — chiamata ***regola*** — in modo da effettuare inferenze (previsioni) su nuovi dati non visti durante l'addestramento.

> ***Importante.***  
Dobbiamo distinguere tre livelli concettuali:
> - $\mathbf{x}^{(i)}$ è il dato in ingresso (input) al modello
> - $y^{(i)}$ è il valore corretto da prevedere (output)
> - $(\mathbf{x}^{(i)}, y^{(i)})$ è l'i-esima osservazione supervisionata completa presente in un dataset
>
> Il modello, durante l'addestramento, utilizza $\mathbf{x}^{(i)}$ come input e confronta la propria predizione con $y^{(i)}$

### 10.2.1 Input, feature e target

> ***Input di un'osservazione e feature.***  
L'***input di un'osservazione*** è caratterizzato da un ***vettore di feature*** (caratteristiche): $$\mathbf{x} =(x_1, x_2, \ldots, x_p)$$ dove $p$ indica il numero di caratteristiche con cui l'osservazione è descritta. In questo contesto, le ***feature*** sono le ***variabili*** $x_j$ che ***descrivono un'osservazione***.
> 
>> ***Esempio.*** Nel caso di 
>> - una ***casa***, le feature possono essere: superficie, numero di stanze, zona, anno di costruzione
>> - un ***segnale EEG***, le feature possono essere: potenza in specifiche bande di frequenza, ampiezze medie, misure estratte da finestre temporali
>
<!-- > In altre parole, se un'osservazione è descritta da $p$ caratteristiche, allora l'input può essere rappresentato come un vettore $\mathbf{x} =(x_1, x_2, \ldots, x_p)$ dove ogni componente $x_j$ è una feature. -->

> ***Target.***  
Il ***target*** $y$ è la variabile che si vuole prevedere con il modello. È il valore "giusto" che il modello deve imparare ad associare agli input $\mathbf{x}$. Il target può essere:
> - un ***numero reale continuo***
> - una ***categoria finita***
>
> Questa distinzione è fondamentale in quanto determina il tipo di problema supervisionato (tecnica di apprendimento supervisionato).

> **Nota.** ***Problema*** indica il ***modello di apprendimento supervisionato utilizzato***, quindi regressione o classificazione.

### 10.2.2 Spazio degli input e spazio degli output

Per formalizzare il problema supervisionato, si introducono due insiemi:
- lo ***spazio degli input*** $\mathcal{X}$
- lo ***spazio degli output*** $\mathcal{Y}$

---

#### *Spazio degli input $\mathcal{X}$*

Lo ***spazio degli input*** è l'insieme di tutti i possibili valori che l'input $\mathbf{x}$ può assumere, cioè l'insieme di tutti i possibili vettori di feature che un'osservazione può assumerr. Formalmente $$\mathbf{x}\in\mathcal{X}$$

Nel caso più semplice, se ogni input è un vettore costituito da $p$ numeri reali, allora: $\mathcal{X} = \mathbb{R^p}$, cioè ogni osservazione è un punto in uno spazio a $p$ dimensioni.

> ***Esempio.***  
Se un problema supervisionato usa tre feature numeriche, allora: $$\mathbf{x} = (x_1, x_2, x_3)\in\mathbb{R^3}$$

#### *Spazio degli output $\mathcal{Y}$*

Lo ***spazio degli output*** è l'insieme di tutti i possibili valori del target. Formalmente $$y\in\mathcal{Y}$$

La forma di $\mathcal{Y}$ (ovvero, il tipo di valore) dipende dal tipo di problema supervisionato.

> ***Caso 1: regressione***  
Se il target è un numero reale continuo $$\mathcal{Y} = \mathbb{R} \;\text{ quindi }\; y\in\mathbb{R}$$
>
> allora il modello di apprendimento supervisionato è la ***regressione***.

> ***Caso 2: classificazione***  
Se il target è un valore categorico $$\mathcal{Y} = \{C_1, \ldots, C_g\} \;\text{ quindi }\; y\in\{C_1, \ldots, C_g\}$$
>
> allora il modello di apprendimento supervisionato è la ***classificazione***, dove $C_1, \ldots, C_g$ sono le classi possibili a cui può appartenere il target.

---

### 10.2.3 Modello come funzione

Nel machine learning supervisionato, il ***modello*** viene visto come una funzione che collega lo spazio degli input allo spazio degli output: $$f: \mathcal{X} \to \mathcal{Y}$$

Poiché la regola (la funzione) che lega input e output non è nota a priori, il modello di apprendimento ha il compito di ***stimare*** una sua approssimazione a partire dai dati etichettati disponibili. Si indica pertanto con $$\hat{f}: \mathcal{X}\to\mathcal{Y}$$ la ***regola approssimata*** che lega input e output.

<!-- Questa regola (la funzione) non è nota a priori: il compito dell'modello è ***stimarla*** a partire dai dati etichettati.  -->

In altre parole, il modello cerca di apprendere una regola che permetta di passare dagli input ai suoi output corretti. 

> **Ricorda.** L'apprendimento consiste nel determinare una funzione che, data una nuovo input $\mathbf{x}$, produca una predizione $\hat{y} = \hat{f}$ il più possibile coerente con i valori reali.

### 10.2.4 Regressione e classificazione

Il criterio principale per distinguere i modelli (problemi) di apprendimento supervisionato è il tipo della variabile target $y$, ovvero la sua natura.

---

#### *Regressione*

Si parla di ***regressione*** quando il target è una variabile reale continua: $$y\in\mathbb{R}$$ In questo caso il modello deve prevedere un valore numerico (una stima numerica), quindi assegnare l'input ad un valore numerico.

> ***Esempi di previsioni.***  Prezzo di una casa, temperatura, consumo energetico, livello di glicemia, intesità di un segnale.

> ***Interpretazione.***  
Il modello apprende una funzione del tipo $$f: \mathbb{R^p}\to\mathbb{R}$$ cioè prende in input un vettore di feature $\mathbf{x}$ e restituisce un numero reale: associa ogni input ad una numero reale.

#### *Classificazione*

Si parla di ***classificazione*** quando il target appartiene ad un insieme finito di classi: $$y\in\{C_1, \ldots, C_g\}$$ In queso caso il modello deve prevedere una classe di appartenenza, quindi assegnare l'input ad una categoria (classe).

> ***Esempi di previsioni.*** Spam / no spam, malato / sano, gatto / cane, classe A / classe B / classe C.

> ***Interpretazione.***  
Il modello apprende una funzione del tipo $$f: \mathbb{R^p}\to\{C_1, \ldots, C_g\}$$ cioè prende in input un vettore di feature $\mathbf{x}$ e restituisce una classe: associa ogni input ad una classe. 

---

### 10.2.5 Relazione funzionale tra input e output

L'idea centrale dell'apprendimento supervisionato è che tra input e output esista una relazione (regola), almeno approssimabile, che il modello può ipotizzare a partire da esempi etichettati. Spesso questa relazione viene espressa in forma astratta come: $$y = f(\mathbf{x}) + \epsilon$$ 
dove:
- $f(\mathbf{x})$ rappresenta la relazione tra input e output
- \$epsilon$ rappresenta il ***rumore***, cioè tutte le componenti casuali non osservate

Questa scrittura è importante perché nella realtà i dati ***non*** sono mai perfettamente deterministici: non sono mai noti con certezza e sono influenzati da eventi casuali. Infatti ci sono sempre:
- rumore di misura 
- variabilità naturale
- fattori non osservati
- errori sperimentali

Il modello non scopre una verità assoluta, ma cerca una buona approssimazione della relazione tra input e output.

### 10.2.6 Modello e parametri

Un ***modello*** non è solo una formula astratta: è una funzione matematica dotata di parametri. I ***parametri*** sono i numeri interni al modello che determinano il suo comportamento. Essi vengono modificati durante l’addestramento.

> ***Esempio.***  Nella retta $y = mx + b$ i parametri sono $m$ e $b$. Cambiandoli, cambia completamente la funzione. Nei modelli più complessi, come le reti neurali, i parametri possono essere moltissimi e difficili da interpretare singolarmente, ma il principio rimane lo stesso: sono i valori che il modello impara dai dati per trasformare input in output.

### 10.2.7 Addestramento e generalizzazione

> ***Addestramento.***  
L’***addestramento*** è il processo con cui il modello osserva i dati etichettati (esempi) e modifica i propri parametri per migliorare le predizioni. 
>
> Durante questa fase, il modello cerca di minimizzare l’errore tra predizioni e valori reali.

> ***Generalizzazione.***  
L’obiettivo finale non è ricordare gli esempi di addestramento, ma imparare una regola capace di funzionare anche su nuovi dati. Questa capacità si chiama ***generalizzazione***. Un buon modello supervisionato non memorizza soltanto i dati:
> - apprende una struttura utile del problema
> - produce buone predizioni anche su osservazioni mai viste prima

## 10.3 *Dataset Iris: un caso di studio*

### 10.3.1 Descrizione del dataset

Il ***dataset Iris*** è l'esempio didattico di riferimento per la ***classificazione*** supervisionata, introdotto da Ronald Fisher nel 1936. Il problema affrontato da questo dataset è il seguente: classificare i fiori di iris in una delle tre ***sottospecie*** (setosa, versicolor, virginica) in base alle misure del fiore. 

Il dataset contiene ***150 fiori*** in totale — 50 per sottospecie — ciascuno descritto da ***quattro feature numeriche*** misurate in centimetri: 
- lunghezza del sepalo (`Sepal.Length`)
- larghezza del sepalo (`Sepal.Width`) 
- lunghezza del petalo (`Petal.Length`)
- larghezza del petalo (`Petal.Width`)

In MATLAB, il dataset è disponibile direttamente con il comando:
```matlab
>> load fisheriris
```

> **Nota.** Il dataset Iris è piccolo (150 esempi), pulito (nessun dato mancante o rumoroso) e a bassa dimensionalità (4 feature). Le classi sono relativamente ben separabili nello spazio delle feature. Per questi motivi, la classificazione su Iris risulta molto più semplice rispetto alla maggior parte dei problemi reali, dove i dataset sono di dimensioni molto maggiori, rumorosi, sbilanciati e ad alta dimensionalità.

### 10.3.2 Struttura formale dei dati

La struttura del dataset Iris nel linguaggio del machine learning supervisionato è la seguente:
- ***input*** $\mathcal{X}$: una matrice di dimensione $150\times 4$. Ci sono $n = 150$ osservazioni (fiori), ciascuna descritta da $p = 4$ feature. La $i$-esima riga della matrice è il vettore delle feature $\mathcal{x}_i$ dell'$i$-esimo fiore
- ***target*** $y$: un vettore di $150$ etichette categoriche, una per fiore, indicante la specie di appartenenza (setosa, versicolor, o virginica)

> ***Esempio.***  
Il ***vettore delle feature*** per la prima osservazione di *Iris Setosa* è: 
> $$\mathbf{x^{(1)}} = (4.3, 3.0, 1.1, 0.1)$$
> 
> dove i quattro valori rappresentano nell'ordine `Sepal.Length`, `Sepal.Width`, `Petal.Length`, `Petal.Width`.

<!-- immagine tabella dopo -->

## 10.4 *Struttura formale dei dati nell'apprendimento supervisionato*

### 10.4.1 Notazione matematica del dataset

L'apprendimento supervisionato si basa su un insieme di dati di apprendimento, che compongono un ***dataset*** di $n$ osservazioni: 

$$\mathcal{D} = \left\{\left(\mathbf{x}^{(1)}, y^{(1)}\right),\,\left(\mathbf{x}^{(2)}, y^{(2)}\right),\,\ldots,\,\left(\mathbf{x}^{(n)}, y^{(n)}\right)\right\} \;\text{ cioè }\; \mathcal{D} = \left\{\left(\mathbf{x}^{(i)}, y^{(i)}\right)\right\}_{i = 1}^{n}$$

dove:
- $\mathcal{X}$ è lo ***spazio di input***: l'insieme di tutti i possibili vettori di feature. In generale, $\mathcal{X} \subset \mathbb{R}^p$, dove $p$ è il numero di feature
- $\mathcal{Y}$ è lo ***spazio di output*** (o spazio target)
- $\left(\mathbf{x}^{(i)}, y^{(i)}\right)$ e la ***$i$-esima osservazione*** del fenomeno in studio, descritta da un vettore di feature $\mathbf{x}^{(i)}\in\mathcal{X}$ (appartenente allo spazio degli input) e dal corrispondente target (etichetta) $y^{(i)}\in\mathcal{Y}$ (appartenente allo spazio degli output). Pertanto: $\left(\mathbf{x}^{(i)}, y^{(i)}\right)\in(\mathcal{X}\times\mathcal{Y})$

> ***Importante.***  
Il dataset supervisionato è un insieme finito di osservazioni $\left(\mathbf{x}^{(i)}, y^{(i)}\right)$, dove $\mathbf{x}^{(i)}\in\mathcal{X}$ rappresenta il vettore delle feature, e $y^{(i)}\in\mathcal{Y}$ rappresenta il target associato.

### 10.4.2 Rappresentazione matriciale degli input

Gli input del dataset possono essere organizzati in una matrice del tipo $$X\in\mathbb{R^{n\times p}}$$ dove $n$ è il numero di osservazioni e $p$ il numero di feature. In questo contesto:

$$X = \begin{pmatrix} \mathbf{x}^{(1)} \\ \mathbf{x}^{(2)} \\ \vdots \\ \vdots \\ \mathbf{x}^{(n)} \end{pmatrix} = \begin{pmatrix} x_1^{(1)} \quad x_2^{(1)} \quad \cdots \quad x_p^{(1)} \\ x_1^{(2)} \quad x_2^{(2)} \quad \cdots \quad x_p^{(2)} \\ \vdots \qquad \vdots \qquad \ddots \qquad \vdots \\ x_1^{(n)} \quad x_2^{(n)} \quad \cdots \quad x_p^{(n)} \\\end{pmatrix} \in\mathbb{R}^{n \times p}$$

- la riga $i$-esima della matrice $X$ corrisponde al vettore $\mathbf{x}$ delle feature (input osservazione) dell'i-esima osservazione: $$\mathbf{x}^{(i)} = \left(x_1^{(i)},\ldots,x_p^{(i)}\right)$$
- la colonna $j$-esima rappresenta la $j$-esima feature osservata su tutte le $n$ osservazioni: 
$$\mathbf{x}_j = \begin{pmatrix} x_j^{(1)} \\ \vdots \\ x_j^{(n)} \end{pmatrix}$$

Quindi, abbiamo che:
- $\mathbf{x}^{(i)}$ indica il ***vettore delle feature*** (input) dell'$i$-esima osservazione, cioè la riga di $X$
- $\mathbf{x}_j$ indica la ***$j$-esima feature*** su tutte le $n$ osservazioni, cioè la colonna di $X$

> **Ricorda.** Nella matrice $X\in\mathbb{R^{n\times p}}$
> - l'$i$-esima riga rappresenta il vettore delle feature $\mathbf{x}^{(i)}$, cioè l'input associato all'$i$-esima osservazione
> - la $j$-esima colonna rappresenta la $j$-esima feature osservata su tutte le $n$ osservazioni

### 10.4.3 Rappresentazione vettoriale del target 

Nel caso standard, il target associato al dataset viene organizzato in un vettore del tipo: 
$$y = \begin{pmatrix} y^{(1)} \\ y^{(2)} \\ \vdots \\ y^{(n)} \end{pmatrix}$$
dove:
- $y^{(i)}$ è il target dell'$i$-esima osservazione
- l'$i$-esima componente del vettore $y$ è associata all'$i$-esima riga della matrice $X$

Pertanto, il vettore $y$ raccoglie tutti i target del dataset in corrispondenza degli input contenuti in $X$.

### 10.4.4 Relazione tra osservazione, input e target

Un'***osservazione supervisionata*** è la coppia: $$\left(\mathbf{x}^{(i)}, y^{(i)}\right)$$ Essa non coincide con il solo input $\mathbf{x}^{(i)}$, né con il solo target $y^{(i)}$, ma comprende entrambi. In particolare:
- $\mathbf{x}^{(i)}$ è l'input dell'$i$-esima osservazione
- $y^{(i)}$ è il target dell'$i$-esima osservazione
- $(\mathbf{x}^{(i)}, y^{(i)})$ è l'i-esima osservazione supervisionata completa 

Di conseguenza, il dataset supervisionato è l’insieme finito di tutte le osservazioni disponibili: $$\mathcal{D} = \left\{\left(\mathbf{x}^{(i)}, y^{(i)}\right)\right\}_{i = 1}^{n}$$

### 10.4.5 Dataset in forma compatta 

Definiti i vettori $X$ e $y$, il dataset può essere espresso in forma compatta come: $$\mathcal{D} = (X, y)$$ Questa scrittura non sostituisce la definizione insiemistica, ma rappresenta una forma operativa e sintetica del dataset, particolarmente utile per l’implementazione computazionale. In tal senso:
- $\mathcal{D} = \left\{\left(\mathbf{x}^{(i)}, y^{(i)}\right)\right\}_{i = 1}^{n}$ è la rappresentazione concettuale e teorica
- $\mathcal{D} = (X, y)$ è la rappresentazione matriciale e computazionale

### 10.4.6 Funzione appresa dal modello

A partire dal dataset $\mathcal{D}$, il modello costruisce una funzione $$\hat{f}:\mathcal{X}\to\mathcal{Y}$$ che approssima la relazione reale tra input e output (sconosciuta a priori).

Se il problema è di regressione, la funzione appresa restituisce un valore reale; se è di classificazione, restituisce una classe. In entrambi i casi, l’obiettivo è quello di far produrre al modello predizioni corrette su nuovi input privi di etichetta: ***generalizzazione*** di nuovi dati. 

### 10.4.7 Esempio: dataset Iris

Nel dataset di Iris si hanno:
- $n = 150$ osservazioni
- $p = 4$ feature

La matrice degli input è quindi $X\in\mathbb{R^{150\times 4}}$ e il vettore dei target è $y = (y^{(1)}, y^{(2)}, \ldots, y^{(150)})$, dove ogni $y^{(i)}\in\mathcal{Y} = \{\text{setosa, versicolor, virginica}\}$. 

In questo caso, il problema di apprendimento supervisionato è di ***classificazione***, perché il target assume valori appartenenti ad un insieme finito di classi. Una possibile osservazione presente nel dataset è: $$\left(\mathbf{x}^{(i)}, y^{(i)}\right) = ((5.1,\,3.5,\,1.4,\,0.2), \text{setosa})$$
Qui:
- $\mathbf{x}^{(i)}$ è il vettore delle misure del fiore
- $y^{(i)}$ è la specie corretta
- la coppia completa rappresenta un'osserazione supervisionata presente nel dataset

## 10.5 *Tipi di dati per le feature e per il target*

Le feature e la variabile target possono appartenere a diversi tipi di dato. Conoscere il tipo di dato di ciascuna variabile è fondamentale perché determina quali operazioni matematiche sono lecite su di essa e quali algoritmi di apprendimento possono essere applicati direttamente o richiedono una pre-elaborazione.

I tipi di dato principali sono quattro:
- ***variabili numeriche reali*** ($x\in\mathbb{R}$)
- ***variabili intere*** ($x\in\mathbb{Z}$)
- ***variabili categoriche*** ($x\in\{C_1,\ldots,C_g\}$)
- ***variabili binarie*** ($x\in\{0,\,1\}$)

> ***Implicazioni per il tipo di modello.***  
Il tipo della variabile target determina il modello di apprendimento: 
> - se il target è numerico, si fa ***regressione***: $y\in\mathbb{R}$ 
> - se il target è categorico, si fa ***classificazione***: $y\in\{C_1, ldots, C_g\}$

> ***Implicazione per gli algoritmi.*** 
La maggior parte degli algoritmi di apprendimento automatico è progettata per lavorare su feature numeriche, poiché i loro meccanismi interni richiedono che i valori siano numeri. 
>
> Per questa ragione, le variabili categoriche devono essere ***convertite in una rappresentazione numerica prima di essere fornite a questi algoritmi*** — con un'eccezione degna di nota: gli alberi decisionali possono gestire direttamente variabili categoriche, senza necessità di codifica.

### 10.5.1 Codifica di variabili categoriche: il one-hot encoding

Per convertire una variabile categorica in una rappresentazione numerica adatta alla maggior parte degli algoritmi di machine learning, si utilizza una tecnica di ***codifica***. Una delle più diffuse è il ***one-hot encoding***.

---

#### *Problema della codifica intera*

Supponiamo di voler codificare le tre specie di Iris come:
$$\text{setosa} = 0, \text{versicolor} = 1 \text{virginica} = 2$$

Questa scelta introduce implicitamente un ordinamento numerico che non ha significato reale per categorie nominali. Infatti, il valore $2$ non è “più grande” di $0$ in senso semantico: le categorie non sono quantità misurabili.

Per evitare questa distorsione, si utilizza una rappresentazione alternativa.

#### *Soluzione: one-hot encoding.* 
Sia $x_j^{(i)}$ una variabile categorica (la $j$-esima feature) della $i$-esima osservazione, e sia $$x_j^{(i)}\in\{C_1,\ldots,C_k\}$$ (ha k categorie mutualmente esclusive). La codifica ***one-hot*** rappresenta la variabile $x_j^{(i)}$ mediante un vettore binario di lunghezza $k$, in cui:
- una sola componente vale $1$
- tutte le altre componenti valgono $0$

Se le categorie della variabile sono numerate da $1$ a $k$, la codifica one-hot della categoria $m$-esima si scrive come: $$o\left(x_j^{(i)}\right)_m = \mathbb{I}\left(x_j^{(i)} = m\right)\in\{0,1\} \qquad m = 1,\ldots,k$$

dove $\mathbb{I}(\cdot)$ è la ***funzione indicatrice***: 
$$
    \mathbb{I}(A) = 
    \begin{cases} 1 & \text{ se la condizione A è vera} \\ 
    0 & \text{ altrimenti}
    \end{cases}
$$

> ***Esempio.***  
Sia $x_j^{(i)}\in\{a,b,c\}$ una variabile con tre categorie. La codifica one-hot associa a ciascuna categoria un vettore di dimensione $k = 3$: 
> $$a \to (1,0,0) \quad b \to (0,1,0) \quad c \to (0,0,1)$$
>
> In particolare, se per l'$i$-esima osservazione la $j$-esima feature $\left(\text{la variabile } x_j^{(i)}\right)$ assume il valore $c$, allora: 
> $$x_j^{(i)} = c \rightarrow o(c) = (0,0,1)$$
>
> In questo modo nessuna categoria è "maggiore" o "minore" di un'altra: ciascuna occupa una dimensione indipendente dello spazio delle feature.

---

### 10.5.2 Dati etichettati e non etichettati

Un'ultima distinzione fondamentale riguarda lo stato dell'etichetta:
- ***dati etichettati*** (*labeled data*): il valore del target $y$ è osservato e disponibile. Gli esempi che presentano il target vengono usati per l'addestramento e la valutazione del modello
- ***dati non etichettati*** (*unlabeled data*): il valore del target è sconosciuto. Sugli esempi che non presentano il target viene applicata l'*inferenza*: il modello addestrato produce una previsione dell'etichetta

## 10.6 *Classificazione: definizione, approccio e valutazione* 

### 10.6.1 Definizione e applicazioni

La ***classificazione*** è un modello di apprendimento supervisionato il cui obiettivo è prevedere a quale ***categoria*** o ***classe*** appartenga un determinato dato, sulla base di esempi etichettati forniti in precedenza. A differenza della regressione — che produce un valore numerico (continuo) — la classificazione produce un'etichetta (target) discreta: la classe di appartenenza del dato in input al modello.

Le applicazioni della classificazione riguardano diversi ambiti:
- diagnosi medica (cellule tumorali benigne o maligne)
- rilevazione di frodi (transazioni con carta di credito legittime o fraudolente)
- categorizzazione di contenuti (notizie in categorie: finanza, meteo, sport, intrattenimento)
- filtraggio dello spam (email legittima vs. email indesiderata);
- riconoscimento di oggetti, lettere o numeri all'interno di immagini
- riconoscimento dello stato emotivo di una persona (nel contesto HMI: riconoscimento delle emozioni dai segnali fisiologici)

### 10.6.2 Approccio generale alla classificazione

Il processo standard per costruire un sistema di classificazione si articola in cinque passi, di cui uno — la scelta delle feature (caratteristiche) — è particolarmente critico e spesso sottovalutato.

1. ***Costruire il set di addestramento - database \mathcal{D}***: si raccoglie un insieme di dati (esempi, composti da input e etichette) con etichette (output) di classe note, ovvero si raccoglie un insieme di osservazioni con target corrispondenti a classi conosciute. La qualità e la rappresentatività di questo set determina le prestazioni massime raggiungibili dal modello

2. ***Costruire il modello di classificazione***: il set di addestramento viene usato per addestrare l'algoritmo di classificazone scelto (albero decisionale, rete neurale, k-NN, ecc.). L'obiettivo dell'algoritmo è costruire il modello di classificazione: una funzine $\hat{f}:\mathcal{X}\to\mathcal{Y}$ ($\hat{y} = \hat{f}$) che mette in relazione vettori di feature $\mathbf{x}^{(i)}$ (input) e etichette $y^{(i)}$ corrispondenti alle classi (output, target). Questa funzione, quindi, associa un input ad un output corrispondente ad una classe specifica

3. ***Valutare il modello***: un set di valutazione (o set di test) viene utilizzato per misurare la qualità del modello. Il set di test è un insieme di dati (esempi) etichettati che il modello ***non ha mai visto*** durante l'addestramento. La valutazione su esempi mai visti (e non su dati di addestramento) è essenziale per stimare la capacità di generalizzazione del modello: partendo da dati non etichettati, la sua capacità di generare un output in relazione all'input con il minimo errore

    > **Ricorda.** Il protocollo di valutazione segue questi passi, a partire dal set di test:
    > 1. si forniscono al modello solo le ***caratteristiche*** (feature) degli esempi di valutazione (nascondendo le etichette)
    > 2. il modello produce le proprie ***previsioni*** per ciascun esempio
    > 3. si confrontano le previsioni del modello con i ***valori reali delle etichette***

4. ***Selezione delle feature***: è fondamentale decidere quali feature (appartenenti ad un vettore $\mathbf{x}$, le caratteristiche che descrivono un'osservazione) utilizzare tra quelle disponibili. Feature irrilevanti o ridondanti possono degradare le prestazioni e aumetare la complessità del modello; feature informativamente ricche migliorano sia l'accuratezza dia l'interpretabilità

5. ***Applicare il modello a nuovi dati***: una volta validato, il modello di classificazione viene applicato a dati con etichette sconosciute per produrre previsioni (inferenze) operative

### 10.6.3 Matrice di confusione 

Per valutare la qualità di un ***classificatore binario*** — cioè un classificatore con esattamente due classi, denominate ***Positivo (P)*** e ***Negativo (N)*** — viene utilizzato lo strumento chiamato ***matrice di confusione*** (confusion matrix). 

> ***Matrice di confusione.***  
La ***matrice di confusione*** è una tabella $2\times 2$ che incrocia le ***condizioni effettive*** (il valore reale delle etichette — gli output, target) con le ***previsioni del modello*** (il valore previsto dall'algoritmo). 
>
> <div align = "center"> 
> 
> | | Positivo effettivo | Negativo effettivo |
> |-|--------------------|--------------------|
> | ***Positivo previsto*** | Vero positivo (TP) | Falso positivo (FP) |
> | ***Negativo previsto*** | Falso negativo (FN) | Vero negativo (TN) |
> 
> </div>
>
>> ***Convenzione standard***: le colonne rappresentano il risultato effettivo, le righe il risultato previsto.

Per comprendere questo strumento, prendiamo in esempio un classificatore di spam per email, dove:
- ***Positivo = spam***
- ***Negativo = non spam***

<!-- in una classificazione, ci possono essere positi effettivi e negativi effettivi. Con il modello, però positivi e negativi possono essere classificati erroneamente in falsi negativi e falsi positivi. Bisogna calcolare la percentuale del modello nel commettere questo errore -->

In questo contesto, la matrice di confusione assume questo significato:

| | Positivo effettivo | Negativo effettivo |
|-|--------------------|--------------------|
| ***Positivo previsto*** | ***Vero positivo (TP)***: un'email di spam classificata correttamente come spam. Il modello ha rilevato correttamente un caso positivo. Questi messaggi vengono automaticamente inviati alla cartella dei messaggi spam | ***Falso positivo (FP)***: un'email legittima viene classificata come spam. Si tratta di un ***falso positivo***: il modello segnala un'email come positiva, ovvero come spam, anche se non lo è. Questo tipo di errore può essere molto dannoso | 
| ***Negativo previsto*** | ***Falso negativo (FN)***: un'email di spam viene classificata erroneamente come non spam. Il modello ***non rileva*** un positivo esistente, ovvero che l'email è uno spam. Email di spam sfuggono al filtro e finiscono nella posta in arrivo. | ***Vero negativo (TN)***: un'email legittima classificata correttamente come non spam. Il modello ha correttamente riconosciuto un caso negativo. Email legittime vengono recapitate direttamente alla posta in arrivo. |

### 10.6.4 Accuratezza

L'***accuratezza*** (*accuracy*) è la metrica di valutazione più utilizzata per verificare la qualità di un modello, che analizza l'accuratezza della previsione prodotta dal modello, in funzione ad un input, rispetto al valore reale di output atteso. In particolare, l'accuratezza è la proporzione di tutte le classificazioni corrette sul totale:

$$\text{Accuracy} = \frac{\text{classificazioni corrette}}{\text{classificazioni totali}} = \frac{TP + TN}{TP + TN + FP + FN}$$

dove:
- $TP + TN$ è il numero totale di classificazioni corrette (sia positivi sia negativi)
- $TP + TN + FP+ FN$ è il numero totale di esempi (dati) classificati

Nell'esempio di classificazione dello spam, l'accuratezza misura la frazione di *tutte le email* (spam e legittime) classificate correttamente. In altri termini, misura la percentuale di classificazione corretta di tutte le email (email spam come spam e email legittime come legittime). 

> **Nota.** Un modello di classificazione perfetto avrebbe $FP = 0$ e $FN = 0$, producendo $\text{Accuracy} = 1$ ($100\%$)

> ***Limiti dell'accuratezza: problema dei dataset sbilanciati.***  
L'accuratezza è una metrica affidabile solo quando il dataset è ***bilanciato***, ovvero quando le classi al suo interno compaiono in proporzioni simili (es. 50 e 50) rispetto al totale di classi. Quando il dataset è ***sbilanciato*** (*class imbalance*), l'accuratezza diventa una metrica ingannevole. 
>
>> ***Esempio.*** Consideriamo un dataset sbilanciato composto da due tipologie di classi: una classe ***positiva*** e una classe ***negativa***. In questo dataset, la classe positiva compare come target solo nell'$1\%$ degli esempi, mentre nel restante $99\%$ degli esempi il target è la classe negativa. In questo caso, un modello che prevede sempre la classe negativa (senza mai rilevare un positivo) otterrebbe accuratezza del $99\%$, ma sarebbe completamente inutile in quanto non rileverebbe mai i casi reali di interesse. 
>
> In questo tipo di situazioni, occorre utilizzare altre metriche di valutazione per valutare la qualità del modello.

### 10.6.5 Recall (Tasso di Veri Positivi, TPR)

Il ***recall*** — noto anche come ***tasso di veri positivi*** (*TPR, True Positive Rate*) — ***misura la percentuale dei veri positivi***, ovvero misura la capacità del modello di identificare correttamente, tra i positivi effettivi, tutti i veri positivi a partire dai dati forniti.

$$\text{Recall (o TPR)} = \frac{\text{positivi effettivi classificati correttamente}}{\text{tutti i positivi effettivi}} = \frac{TP}{TP + FN}$$
dove:
- $TP$ è il numero di positivi effettivi classificati come veri positivi (correttamente classificati come positivi)
- $TP + FN$ è il numero totale di positivi effettivi (quanti positivi reali esistono nel dataset)

> **Nota.** Il denominatore $TP + FN$ vale perché ogni positivo effettivo finisce necessariamente o tra i veri positivi (TP, correttamente rilevati) o tra i falsi negativi (FN, non rilevati)

Nell'esempio di classificazione dello spam, il recal misura la *frazione di email spam classificate correttamente come spam*. In altri termini, misura la percentuale di classificazione corretta delle email spam (email spam classificate come tali). 

> **Nota.** Un modello di classificazione perfetto ha $FN = 0$, quindi $\text{Recall} = \frac{TP}{TP + 0} = 1$.

> ***Quando usare il recall.***  
Il recall è la metrica più importante nelle applicazioni in cui ***non rilevare un caso positivo ha conseguenze gravi*** — cioè il peso del falso negativo è alto (qualcosa di positivo erroneamente considerato negativo). Ad esempio, per applicazioni come la previsione di malattie, l'identificazione corretta dei casi potivi a malattie gravi è fondamentale: un test per una malattia che non rileva quasi pazienti malati (alto $FN$) può avere gravi conseguenze. 
>
> In questi contesti, è preferibile accettare qualche $FP$ (falso positivo) pur di non perdere nessun caso positivo reale.

Questa metrica di valutazione è molto utile soprattutto in un dataset sbilanciato (classi al suo interno compaiono in modo sbilanciato), risultando più significativa dell'accuratezza in quanto misura la capacità del modello tutti i dati realmente positivi (positivi effettivi come veri positivi)

### 10.6.6 Tasso di Falsi Positivi (FPR)

Il ***tasso di falsi positivi*** (*FPR, False Positive Rate*) — noto come probabilità di falso allarme — misura la ***percentuale di negativi effettivi classificati erroneamente come positivi***: calcola la percentuale di falsi positivi tra i negativi effettivi.

$$\text{FPR} = \frac{\text{negativi effettivi classificati erroneamente come positivi}}{\text{tutti i negativi effettivi}} = \frac{FP}{FP + TN}$$
dove:
- $FP$ è il numero di negativi effettivi classificati come falsi positivi (falsi allarmi)
- $FP + TN$ è il numero totale di negativi effettivi (quanti negativi reali esistono nel dataset)

Nell'esempio di classificazione dello spam, l'FPR misura la *frazione di email legittime classificate erroneamente come spam*. In altri termini, misura la percentuale di classificazione erronea delle email legittime (email legittime classificate come spam). 

> **Nota.**  Un modello perfetto ha $FP = 0$, quindi $\text{FPR} = 0$ (nessun falso allarme).

> ***Limiti del FPR.***  
Se il numero di negativi effettivi nel dataset è molto basso, il FPR può diventare instabile

### 10.6.7 Precisione

La ***precisione*** (*precision*) misura la percentuale di tutte le classificazioni positive che sono effettivamente positive.

$$\text{Precision} = \frac{\text{positivi effettivi classificati correttamente}}{\text{tutto ciò classificato come positivo}} = \frac{TP}{TP + FP}$$
dove:
- $TP$ è il numero di veri positivi (classificati correttamente come positivi);
- $TP + FP$ è il numero totale di esempi classificati come positivi dal modello (quanti il modello ha detto "positivo", a prescindere dalla loro classe reale).

Nell'esempio dello spam, la precisione misura la frazione di email classificate come spam che erano *effettivamente* spam. Un'alta precisione significa che quando il filtro dice "è spam", quasi sempre ha ragione.

**Nota.** Un modello perfetto ha $FP = 0$, quindi $\text{Precision} = 1$.  

> ***Relazione inversa tra precisione e recall.***
La precisione migliora man mano che i falsi positivi diminuiscono, mentre il recall migliora quando i falsi negativi diminuiscono. Queste due mostrano spesso una relazione inversa, in cui il miglioramento di uno peggiora l'altro.

### 10.6.8 Punteggio F1

Il **punteggio F1** (F1 score) è la **media armonica** di precisione e recall, e fornisce un'unica metrica che bilancia entrambe le grandezze:

$$F1 = 2 \cdot \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}} = \frac{2 \cdot TP}{2 \cdot TP + FP + FN}$$

> ***Perché la media armonica?*** La media armonica, a differenza della media aritmetica, penalizza fortemente le asimmetrie: se una delle due metriche è bassa, la media armonica si avvicina al valore della metrica peggiore — molto più di quanto farebbe la media aritmetica. Questo significa che per ottenere un F1 alto è necessario che ***entrambe*** precisione e recall siano alte; un valore alto di una sola delle due non è sufficiente.

Le proprietà principali dell'F1 sono:
- se $\text{Precision} = 1$ e $\text{Recall} = 1$ (modello perfetto), allora $F1 = 1$
- quando precisione e recall hanno valori simili tra loro, F1 è simile a questi valori
- quando precisione e recall sono molto distanti, F1 è più vicino alla metrica peggiore

### 10.6.9 Cross-Validation: valutazione robusta del modello

La valutazione di un modello di classificazione ha lo scopo di stimare la capacità di generalizzazione, cioè la capacità del modello di produrre previsioni corrette su esempi mai visti durante l'addestramento. 

Per fare ciò, non è sufficiente addestrare il modello sui dati disponibili: occorre riservare una parte dei dati alla valutazione. La tecnica più semplice per farlo è l'***holdout***, mentre la tecnica più robusta è la ***cross-validation***.

---

#### *Problema del semplice split Train/Test*

Abbiamo visto come il principio di valutazione di un modello si basa sul valutare la qualità (prestazioni) del modello su un set di test separato dal set di addestramento. La forma più semplice di questa separazione è l'***holdout*** (o split Train/Test): si divide il dataset di osservazioni in due parti, tipicamente $80\%$ per l'addestramento e il $20\%$ per il test. 

> ***Metodo holdout.***  
Nel metodo holdout, il dataset viene suddiviso in due sottoinsiemi:
> - un ***set di addestramento***, utilizzato per addestrare il modello
> - un ***set di test***, utilizzato per valutarne le prestazioni finali
> 
> Una suddivisione tipica è:
> - $80\%$ dei dati per l'addestramento
> - $20\%$ dei dati per il test
>
> <div align = "center">
>
> ![alt text](train_test-1.png)
>
> </div>
>
> L'idea è semplice: il modello viene addestrato solo sui dati del set di addestramento e successivamente valutato su esempi che non ha mai visto.

Il problema dell'holdout è che la stima delle prestazioni del modello (la valutazione della qualità del modello) dipende molto da ***quali esempi sono finiti nel set di test per effetto della casualità della divisione del dataset***. Se nel set di test sono finiti esempi particolarmente facili (o difficili), la valutazione sarà ottimistica (o pessimistica) rispetto alle prestazioni reali del modello su dati nuovi. Il risultato è una ***stima distorta*** della performance.

#### *Cross-Validation k-fold*

La ***cross-validation*** (*validazione incrociata*) è una tecnica standard per ottenere una stima più robusta della qualità (performance) di un modello. La variante più comune è la ***k-fold cross-validation***.

L'idea fondamentale è la seguente: invece di effettuare una sola divisione training/test, ***si effettuano più valutazioni successive cambiando ogni volta i dati usati per la valutazione (temporanea)***.

> ***Procedura di cross-validation.***  
Il procedimento si articola nei seguenti passi:
> 1. il dataset viene diviso in $k$ ***gruppi di uguali dimensioni***, chiamati ***fold***
> 2. il modello viene ***addestrato $k$ volte***
> 3. in ciascuna iterazione $i$ ($i$-esimo addestramento) ($i = 1,\ldots,k$)
>     - il fold $i$ viene usato come ***set di validazione temporaneo*** (ovvero set di test temporanei)
>     - i rimanenti $k-1$ fold vengono usati per l'***addestramento*** del modello
> 4. al termine delle $k$ iterazioni, si calcola la ***media delle performance*** del modello (es. accuratezza, F1) ottenute nelle $k$ iterazioni. 
>
> Questa media è la stima della qualità del modello

<!-- immagine dopo  -->

> ***Perché è più robusta.***  
Nella cross-validation, ogni esempio del dataset viene usato:
> - una volta come dato di validazione temporaneo
> - $k - 1$ volte come dato di addestramento
>
> La stima delle prestazioni è, quindi, più affidabile in quanto il set di test è meno sensibile alla casualità rispetto all'holdout.

> ***Set di validazione e set di test.***  
È importante distinguere tra:
> - ***set di validazione***: serve per scegliere configurazioni e iperparametri del modello
> - ***set di test***: serve per la valutazione finale imparziale
>
> Nella cross-validation, i fold esclusi di volta in volta dall’addestramento svolgono il ruolo di ***validazione temporanea***, non di test finale. Il test set vero e proprio, se presente, deve restare separato e viene usato solo alla fine.

<!-- 
> **Nota.**  Nella $k$-fold cross-validation, i fold non usati per l'addestramento nella singola iterazione sono spesso chiamati "fold di test", ma in senso rigoroso svolgono il ruolo di ***validazione***, perché il loro uso serve a stimare temporaneamente le prestazioni del modello e confrontare configurazioni diverse, Il ***set di test*** vero e proprio, se presente, resta separato e viene utilizzato solo alla fine per la valutazione finale. -->

#### *Errore di classificazione*

Per valutare il modello si usa spesso l'***errore di classificazione***. Sia:
- $N$ il numero totale di esempi del dataset (di validazione)
- $\hat{y}^{(i)}$ la classe predetta dal classificatore per l'$i$-esimo esempio
- $y^{(i)}$ la classe reale

L'errore di classificazione è: $$\text{Errore} = \frac{\text{numero di classificazioni errate}}{\text{numero totale di esempi}}$$ oppure, in forma matematica: $$\text{Errore} = \frac{1}{N} \sum_{i = 1}^{N} \mathbb{I}\left(\hat{y}^{(i)} \neq y^{(i)}\right)$$

dove $\mathbb{I}(\cdot)$ è la ***funzione indicatrice***: 
$$
    \mathbb{I}(A) = 
    \begin{cases} 1 & \text{ se la condizione A è vera} \\ 
    0 & \text{ altrimenti}
    \end{cases}
$$

Quindi:
- se il modello sbaglia una classificazione, contribuisce con $1$
- se classifica correttamente, contribuisce con $0$

La somma totale conta gli errori, e dividendo per $N$ si ottiene la percentuale di errori.

> ***Esempio.***  
Supponiamo di avere un set di validazione con $10$ record:
> 
> <div align = "center">
>
> | Record | Classe reale | Classe predetta |
> | ------ | ------------ | --------------- |
> | 1      | A            | A               |
> | 2      | A            | A               |
> | 3      | B            | B               |
> | 4      | B            | A               |
> | 5      | A            | A               |
> | 6      | B            | B               |
> | 7      | A            | B               |
> | 8      | B            | B               |
> | 9      | A            | A               |
> | 10     | B            | B               |
> 
> </div>
>
> Il classificatore commette due errori. L'errore di classificazione è: $$\text{Errore} = \frac{2}{10} = 0.2 = 20\%$$

#### *Relazione tra errore di classificazione e accuratezza*  

L'errore di classificazione è complementare all'accuratezza. Infatti: 
$$\text{Accuratezza} = \frac{\text{numero di classificazioni corrette}}{N} \quad N = \text{numero totale di esempi del dataset di validazione}$$ e vale $$\text{Errore} = 1 - \text{Accuratezza} $$

---

### 10.6.10 Overfitting e Underfitting

Due dei problemi più importanti nell'apprendimento supervisionato sono l'***overfitting*** e l'***underfitting***, che rappresentano i due estremi opposti del bilanciamento tra complessità del modello e capacità di generalizzazione.

<!-- immagine dopo -->

---

#### *Overfitting*

L'***overfitting*** è un comportamento del ML che si verifica quando il modello è troppo (strettamente) allineato ai dati di addestramento, così allineato che ***il modello non sa come rispondere ai nuovi dati***: anziché imparare a generalizzare a partire dal set di addestramento, ha solo memorizzato.

Le cause principali dell'overfitting sono:
- il ***modello di ML è troppo complesso*** rispetto alla quantità dei dati disponibili: ha troppi parametri per così pochi esempi, e li usa per memorizare ogni dettaglio dei dati di addestramento 
- i dati nel set di addestramento sono ***troppo pochi*** o contiene grandi quantità di informazioni irrilenvanti (rumore)

> ***Soluzione.***  
È possibile evitare l'overfitting gestendo la complessità del modello e migliorando il set di dati di addestramento.

#### *Underfitting*

L'***underfitting*** è un comportamento del ML che si verifica quando il ***modello è troppo semplice*** per catturare la struttura reale dei dati: non riesce ad apprendere neanche i pattern fondamentali. Un modello in underfitting ottiene prestazioni scarse sia sul set di addestramento sia sul set di test.

La causa principale dell'underfitting è la scarsa capacità di parametri del modello rispetto alla complessità del fenomeno da analizzare e modellare.

---

### 10.6.11 Squilibrio tra le classi (Class Imbalance)

Lo ***squilibrio tra le classi*** (*class imbalance*) è una condizione in cui le classi nel dataset di addestramento sono rappresentate in proporzioni molto diverse tra loro: il numero di classi: le classi al suo interno compaiono in proporzioni molto diverse (es. 90 e 10) rispetto al totale di classi.

> ***Perché è un problema.***  
Consideriamo un problema (addestramento supervisionato con modello di classificazione) a due classi con 9990 esempi di classe 0 e 10 esempi di classe 1. Un modello che prevede *sempre* classe 0 ottiene un'accuratezza del $99.9\%$, nonostante non rilevi mai un solo esempio di classe 1 — che è tipicamente quella di interesse. L'accuratezza è completamente ingannevole; in questo caso, precisione e recall sono le metriche appropriate.

Lo squilibrio tra le classi è un problema di grande impatto durante l'addestramento di un modello: se una classe (che ci interessa) è molto rara (compare molto poco nel dataset di addestramento), il classificatore la ignorerà, in quanto è dominato dagli esempi della classe maggioritaria.

> ***Strategie di gestione del calss imbalance.***  
Il problema si può affrontare con tecniche di ***resamplig*** (ricampionamento del dataset):
> - ***oversampling della classe minoritaria***: si duplicano casualmente esempi della classe meno numerosa, aumentandone la rappresentazione nel set di addestramento fino a raggiungere un bilanciamento con la classe maggioritaria. Il rischio è l'overfitting: il modello può imparare a memoria quegli specifici esempi duplicati, senza generalizzare
> - ***undersamplig della classe maggioritaria***: si eliminano casualmente esempi dalla classe pi+ numerosa, riducendone la rappresentazione. È efficace quando il dataset è molto grande (milioni di esempi), ma comporta perdita di informazione potenzialmente preziosa
> - ***SMOTE (Synthetic Minority Over-sampling Technique)***: invece di duplicare esempi esistenti, SMOTE *crea nuovi esempi sintetici*, iterpolando tra i vicini più prossimi della classe minoritaria le feature che le descrivono
>
>> ***Nota.*** Interpolare significa ***stimare valori sconosciuti all'interno dell'intervallo di un insieme di dati noti***.

## 10.7 *Alberi decisionali*  

Nell'apprendimento supervisionato, il problema della classificazione consiste nel costruire una funzione $$\hat{f}:\mathcal{X}\to\mathcal{Y}, \qquad \hat{y} = \hat{f}(\mathbf{x})$$ capace di associare ad ogni input $\mathbf{x}\in\mathcal{X}$ una classe $\hat{y}\in\mathcal{Y}$. 

In generale, esistono diversi modelli per farlo, come k-NN, SVM, regressione logistica, Naïve Bayes, reti neurali, Random Forest, metodi ensemble e analisi discriminante. Un altro modello fondamentale è l'***albero decisionale***, che costruisce la classificazione attraverso una sequenza di domande elementari organizzate gerarchicamente. 

L'idea di base è semplice: l'input viene sottoposto ad una successione di domande — dette condizioni — ciascuna delle quali restringe progressivamente l'insieme delle possibili classi, fino a raggiungere una previsione finale.

### 10.7.1 Alberi decisionali: definizione e struttura

--- 

#### *Idea generale*  

Un ***albero decisionle*** (*decision tree*) è un modello di classificazione composto da una raccolta di "domande" organizzate gerarchicamente in forma di albero. Ogni domanda è una ***condizione***, detta anche ***regola di divisione*** o ***split***.

L'idea è che, invece di classificare direttamente un esempio con una formula unica, il modello lo fa passare attraverso una serie di condizioni successive. In base al risultato di ciascuna condizione, l'esempio segue un certo ramo dell'albero.

> ***Ricorda.***  
Nel linguaggio del ML, l'input è un vettore di feature $$\mathbf{x} = (x_1, \ldots, x_p)$$ dove le componenti $x_1, \ldots, x_p$ sono le ***feature*** (o ***variabili***) del problema. Ogni osservazione del dataset è, quindi, una coppia $$\left(\mathbf{x}^{(i)}, y^{(i)}\right)$$ dove $\mathbf{x}^{(i)}$ è l'input e $y^{(i)}$ è il target.
>
> Un albero decisionale usa le feature per porre domande successive del tipo:
> - $x_j < t$
> - $x_j \in \{a,b,c\}$
> - $x_j \leq t$
>
> e, in base all'esito della condizione, inoltra l'input lungo un ramo diverso dell'albero.

#### *Tipi di nodo*

La struttura dell'albero comprende tre tipi di nodo.

> ***Nodo radice (root).***  
È il nodo più alto dell'albero, da cui parte la classificazione. Contiene la prima condizione da valutare, cioè quella che l'algoritmo considera più informativa.

> ***Nodi interni (internal nodes).***  
Sono tutti i nodi che non sono né radice né foglie. Ogni nodo inerno contiene una ***condizione (split)*** da verificare sul vettore delle feature dell'input in esame, cioè su $\mathbf{x}$. 
>
> Se la condizione è vera, l'esempio viene instradato a un figlio della condizione appena valutata; se è falsa, viene instradato all'altro figlio, o a uno dei vari figli nel caso di split più generali.

> ***Nodi foglia (leaf nodes).***  
Sono i nodi terminali dell'albero, cioè i nodi senza figli. Ogni foglia contiene una ***previsione***, cioè l'etichetta della classe assegnata agli esempi che arrivano a quella foglia seguendo il percorso dalla radice.
> 
> È importante specificare come la foglia assume un significato diverso a seconda dell'operazione effettuata utilizzando l'albero decisionale:
> - durante l'***apprendimento supervisionato del modello***(addestramento), cioè ***durante la costruzione dell'albero***, una foglia corrisponde ad un insieme di esempi del dataset che finiscono lì 
> - durante la ***predizione***, quella stessa foglia restituisce una classe
>
> Quindi la foglia ha due aspetti: nell'addestramento è legata agli esempi che vi ricadono in seguito alla valutazione delle condizioni, mentre in uscita fornisce la classe predetta.

<div align = "center">

![alt text](struttura_alb_dec-1.png)

</div>

#### *Interpretazione formale*

Formalmente, un albero decisionale implementa una funzione $$\hat{f}:\mathcal{X}\to\mathcal{Y}$$ cioè una funzione che associa ad ogni input $\mathbf{x}$ una classe $\hat{y}$, quindi, $\hat{y} = \hat{f}(\mathbf{x})$.

Questa funzione è costruita in modo gerarchico a forma di albero:
- ogni ***nodo interno*** applica una regola di divisione (split) che manda l'input $\mathbf{x}$ (del modello) a uno specifico ramo (ovvero ad uno dei suoi figli)
- ogni ***foglia*** restituisce una previsione, cioè l'etichetta della classe

Quindi, l'albero è allo stesso tempo sia una struttura di decisione sia una funzione di classificazione.

---

### 10.7.2 Meccanismo di predizione: percorso di inferenza

Quando un nuovo input $\mathbf{x}\in\mathcal{X}$ deve essere classificato, l'albero esegue un procedimento deterministico detto ***percorso di inferenza*** (*inference path*). 

> ***Passaggi inference path.***  
> 1. Si parte dal ***nodo radice***
> 2. In ogni nodo interno si valuta la condizione del nodo rispetto a $\mathbf{x}$.
>     - se la condizione è vera, si segue il ramo previsto per quel caso (per convenzione, il ramo sinistro)
>     - se è falsa, si segue l'altro ramo (per convenzione, il ramo destro)
> 3. Si ripete il processo descritto nel passo 2 fino a raggiungere una ***foglia***
> 4. La classe memorizzata nella foglia raggiunta è la previsione dell'albero sull'input $\mathbf{x}$
>
> L'insieme di nodi visitati in questa fase di discesa dalla radice alla fogli costituisce il ***percorso di inferenza*** di quell'input. Percorsi diversi portano a foglie diverse, e foglie diverse corrispondono a previsioni diverse. 
>
>> ***Esempio.***  
Si consideri l'albero decisionale per il dataset Iris mostrato qui sotto, con le seguenti condizioni:
>> - radice: `Petal.Length < 2.45`
>> - nodo intermedio (destra): `Petal.Width < 1.75`
>> - nodo di terzo livello (sinistra): `Petal.Length < 4.95`
>> - nodo di quarto livello (destra): `Petal.Width ≥ 1.55`
>> 
>> <div align = "center">
>>
>> ![alt text](es_alb_Iris-1.png)
>> 
>> </div>
>>
>>  Supponiamo di classificare l'input $$\mathbf{x} = (Petal.length = 6, Petal.Width = 1.6)$$ Il percorso è il seguete:
>>  1. nodo radice: `Petal.Length = 6 < 2.45`? ***Falso*** $\to$ si va a destra
>> 2. nodo successivo: `Petal.Width = 1.6 < 1.75`? ***Vero*** $\to$ si va a sinistra
>> 3. nodo successivo: `Petal.Length = 6 < 4.95`? ***Falso*** $\to$ si va a destra
>> 4. nodo successivo: `Petal.Width = 1.6 ≥ 1.55`? ***Vero*** $\to$ si va a sinistra
>> 5. si raggiunge la foglia: ***previsione = virginica***
>>
>> Questo esempio mostra bene che la classe non viene calcolata con un’unica formula globale, ma viene ottenuta attraversando una sequenza di condizioni fino a una foglia.

### 10.7.3 Equivalenza con un insieme di regole congiunte

Ogni ramo dell'albero decisionale, cioè ogni percorso dalla radice a una specifica foglia, può essere riscritto come una ***regola congiunta***. La forma generale è: 
$$\text{se cond}_1(\mathbf{x})\; \text{AND}\; \text{cond}_2(\mathbf{x})\; \text{AND}\; \ldots\; \text{AND}\; \text{cond}_k(\mathbf{x}), \quad \text{allora } y = \text{etichetta della foglia}$$

<!-- k indica il k-esimo nodo non foglia, prima del nodo foglia -->

Questo significa che il percordo radice-foglia può essere letto come una regola "se-allora" composta da più condizioni collegate da AND.

---

#### *Significato*  

Se un albero decisionale ha $L$ foglie, allora è equivalente a un ***insieme di $L$ regole congiunte***, una per ciascuna foglia. Questo rende gli alberi decisionali modelli di machine learning molto interpretabili, perché le loro previsioni possono essere espresse in linguaggio naturale come una lista di regole.

#### *Esempio*  

Per l'albero di Iris, l'insieme di regole corrispondenti ai cinque rami sono:

| Condizioni (AND) | Classe |
|---|---|
| $\text{Petal.Length} < 2.45$ | setosa |
| $\text{Petal.Length} \in [2.45, 4.95)\; \text{ AND }\; \text{Petal.Width} < 1.75$ | versicolor |
| $\text{Petal.Length} \leq 4.95\; \text{ AND }\; \text{Petal.Width} \in [1.55, 1.75)$ | versicolor |
| $\text{Petal.Length} \leq 4.95\; \text{ AND }\; \text{Petal.Width} < 1.55$ | virginica |
| $\text{Petal.Length} \leq 2.45\; \text{ AND }\; \text{Petal.Width} \leq 1.75$ | virginica |

---

### 10.7.4 Tipi di suddivisione (split)

L'efficacia e la struttura di un albero decisionale dipendono dai tipi di split ammessi nei nodi interni, ovvero dipendono dal tipo di condizioni (regole di divisione). 

L'idea di fondo è che ogni nodo debba contenere una decisione (condizioni) ***semplice***, mentre la complessità complessiva deve emergere dalla combinazione delle condizioni (regole) dei nodi lungo il percorso nell'albero. Ammettere regole troppo complesse nei nodi interni dell'albero non ha, quindi, molto senso, rendendo l'albero di decisione troppo complesso da comprendere.

> **Nota.** Una ***variabile*** è la componente di una condizione usata per valutare l'input $\mathbf{x}$. Per esempio, `Petal.Width` è una variabile.
>
> Le variabili sono dunque le *feature dell’input*; i nodi non possiedono feature proprie: durante l'addestramento ogni nodo è associato a un sottoinsieme di esempi, ciascuno descritto dalle stesse feature originali.

L'insieme dei possibili split si restringe imponendo tre vincoli.

---

#### *Vincolo 1: numero di variabili per split*

> ***Split univariato.***  
Uno split (condizione, divisione) è ***univariato*** se utilizza una sola variabile.
>> ***Esempio.***  `Petal.Width < 1.75`. In questo split compare solo `Petal.Width`.

> ***Split multivariato.***  
Uno split è ***multivariato*** se utilizza più di una variabile.
>> ***Esempio.*** `Petal.Width < 1.75 AND Petal.Length < 4.95`, coinvolge due variabili

> ***Osservazione.***  
Se uno split multivariato è solo una congiunzione (AND) di split univariati, allora può essere rappresentato in modo più naturale tramite più livelli dell'albero, ciascuno con uno split univariato. 
>
> Esistono però split che non si riducono a una semplice congiunzione di condizioni singole. Per esempio, $$\frac{\text{Petal.Width}}{\text{Petal.Length}} < 1$$ coinvolge un rapporto tra due feature e non è esprimibile come congiunzione di variabili singole.

#### *Vincolo 2: numero di nodi figli per split*

> ***Split binario.***  
Uno split è ***binario*** se produce due figli. È il caso più comune: la condizione divide gli input in due gruppi, quelli per cui la condizione è vera e quelli per cui la condizione è falsa.
>
>> ***Esempio.*** `Petal.Length < 1.75` è una divisione binaria.

> ***Split $n$-ario.***  
Uno split è $n$-ario se produce $n$ figli. Per esempio, una variabile categoriale `Home.University` con tre valori possibili (Hildesheim, Gottinger, \{Hannover, Braunschweig\}), può generare un nodo con tre figli, uno per ciascun gruppo di valori.
>
> <div align = "center">
>
> ![alt text](split_ternario-1.png)
>
> </div> 

> ***Perché si preferiscono gli alberi binari.***  
Una proprietà importante è che ***ogni split $n$-ario può essere sempre rappresentato come un albero di split binari equivalente***. 
>
> Per questo, nella pratica, gli alberi binari sono preferiti: sono più semplici da leggere e non perdono espressività rispetto agli alberi n-ari.
>
>> ***Esempio.***  
Il ternario su `Home.University` può essere riscritto come: 
>> - prima uno split binario "Hildwsheim vs \{Hannover, Braunschweig\}"
>> - poi un secondo splic binario "Gottingen vs \{Hannover, Braunschweig\}"
>>
>> <div align = "center">
>>
>> ![alt text](split_ternario_to_binario-1.png)
>>
>> </div>

#### *Vincolo 3: tipo di partizione dei valori*

Per una variabile univariata, si distinguono due modi di assegnare valori ai figli:

> ***Divisione completa.***  
Una divisione (split) si dice ***completa*** se ogni valore della variabile è assegnato a un figlio specifico, con corrispondenza biunivoca tra valori e figli.

> ***Divisione a intervallo.***  
Una divisione (split) di dice ***a intervallo*** (*interval split*) se, per ciascun figlio, i valori ad essi assegnati formano un intervallo continuo.
>
>> ***Esempi.***  
Suddivisioni a intervallo sulla variabile `Petal.Width`:
>> - `Petal.Width < 1.75`: split binario, divide in $(-\infty, 1.75) e [1.75, +\infty)$
>> - `Pedal.Width < 1.45 OR Pedal.Width ≥ 1.45 AND Petal.Width < 1.75 OR Petal.Width ≥ 1.75 `: split ternario, divide in $(-\infty, 1.45)$, $[1.45, 1.75)$ e $[1.75, +\infty)$
>>
>> La condizione `Petal.Width < 1.75 OR Petal.Width ≥ 2.4` non è uno split a intervallo, in quanto i valori assegnati ai figli di tale condizione non formano un intervallo contiguo: $(-\infty, 1.75) \cup [2.4, +\infty)$

### 10.7.5 Problema dell'apprendimento dell'albero decisionale

Ora passiamo alla ***costruzione dell'albero a partire dai dati presenti in un dataset***, ovvero alla fase di ***apprendimento supervisionato di un modello***. 

Dato il ***dataset di addestramento***: 

$$\mathcal{D} = \left\{\left(\mathbf{x}^{(1)}, y^{(1)}\right),\,\left(\mathbf{x}^{(2)}, y^{(2)}\right),\,\ldots,\,\left(\mathbf{x}^{(n)}, y^{(n)}\right)\right\}$$

il problema consiste nel trovare una funzione di classificazione $$\hat{f}:\mathcal{X}\to\mathcal{Y}$$ rappresentata da un albero decisionale, che soddisfi alcuni vincoli. L'albero deve essere:
- ***binario***, ***univariato*** e con ***divisioni a intervallo***
- contenere in ogni foglia un numero minimo $m$ di esempi

Tra tutti gli alberi che soddisfano questi vincoli, si desidera selezionare quello che presenta il ***tasso di errore di classificazione minimo*** sul dataset. Questo problema viene detto ***problema di costruzione di un albero decisionale ottimale***.

---

#### *Significato della costruzione dell'albero*

> ***Definizione.*** Sia $t$ un nodo dell'albero, allora al nodo $t$ è associato un sottoinsieme di esempi del dataset $\mathcal{D}$: 
> $$\mathcal{D}_t = \left\{(\mathbf{x}^{(i)}, y)\in\mathcal{D} : \; \mathbf{x}^{(i)}\; \text{ raggiunge il nodo }\; t\right\}$$
>
> Questa definizione vale per:
> - ***nodo radice***: contiene ***tutto il dataset***
> - ***nodi interni***: contengono un ***sottoinsieme***
> - ***nodo foglia***: contiene un ***sottoinsieme finale***
>
>> ***Esempio.***  
Consideriamo il dataset di addestramento: $\mathcal{D} = \{(2,A),(3,A),(5,B),(6,B)\}$. Allora:
>> - il nodo radice contiene tutto il dataset: $$\mathcal{D}_{root} = \{(2,A),(3,A),(5,B),(6,B)\}$$
>> - split $x < 4$, otteniamo:
>>     - il nodo destro contiene: $$\mathcal{D}_{left} = \{(2,A),(3,A)\}$$
>>     - il nodo sinistro contiene: $$\mathcal{D}_{right} = \{(5,B),(6,B)\}$$

La costruzione dell'albero non consiste soltanto nell'assegnare una classe finale a una foglia, ma nel ***partizionare ricorsivamente il dataset*** tramite una sequenza di split.

Durante l’apprendimento:
- la ***radice*** contiene inizialmente tutti gli esempi del dataset, 
- ogni ***nodo interno*** è associato a un sottoinsieme degli esempi che raggiungono quel nodo
- ogni ***split*** divide tali esempi in sottoinsiemi più piccoli
- ogni ***foglia*** raccoglie gli esempi che, dopo aver attraversato i vari split, arrivano fino a quel punto dell’albero

Quindi, nel corso dell'addestramento, ***ogni nodo dell'albero rappresenta un insieme di esempi del dataset***, non solo le foglie.
La differenza è che:
- nei ***nodi interni*** l’insieme di esempi viene ancora suddiviso
- nelle ***foglie*** il processo di suddivisione termina e si assegna la previsione finale

#### *Osservazione: problema NP-hard*

La formulazione precedente definisce un problema di ottimizzazione: trovare tra tutte le possibili strutture ad albero ammissibili quella che minimizza l'errore di classificazione.

Tuttavia, questo problema non è risolvibile in modo efficiente, perché:
- lo spazio delle possibili strutture ad albero che soddisfano i vincoli è troppo grande
- il numero di possibili divisioni candidate in ciascun nodo è elevato e crescono in modo conbinatorio con il numero di esempi $n$, di feature $p$ e la profondità dell'albero
- le scelte effettuate in un nodo influenzano tutte le divisioni successive

Per questo motivo, il problema di determinare l'albero di decisione ottimale è ***NP-hard***.

> ***Conseguenza***  
Poiché la ricerca esatta dell’albero ottimo globale è troppo costosa, nella pratica si utilizzano metodi approssimati. La soluzione standard è utilizzare ***algoritmi greedy*** con strategia di ***divide et impera***.

#### *Soluzione: algoritmo di greedy*  

Un ***algoritmo greedy*** costruisce l'albero decisionale un nodo alla volta, scegliendo in ciascun nodo la divisione (split) che appare migliore localmente. L’algoritmo viene applicato in modo ricorsivo:
1. si considera l'insieme di tutti gli esempi nel nodo corrente
2. si cerca la divisione che produce la massuma riduzione dell'***impurità*** del nodo
3. si applica quella divisione, creando i nodi figli
4. si ripete ricorsivamente la procedura sui figli

L'obiettivo, a ogni nodo, è trovare suddivisioni che producano ***sotto-gruppi il più possibile omogenei***, cioè composti prevalentemente da ***esempi della stessa classe***.

> **Nota.** Questa strategia è detta ***divide et impera*** perché il problema globale viene suddiviso in sottoproblemi più piccoli, uno per ogni nodo dell’albero.

#### *Interpretazione dell'impurità*  

La misura dell'omogeneità di un nodo è l'***impurità***. Un nodo è tanto più buono quanto gli esempi che contiene al suo interno appartengono, in prevalenza, alla stessa classe (in questo caso, il nodo è soggetto ad una bassa impurità). Per questo motivo, in ogni passo dell'algoritmo greedy si sceglie lo split che rende i nodi figli più "puri" possibile rispetto al nodo padre.

<!-- Poiché non è possibile determinare in modo efficiente l'albero ottimo globale, nella pratica si utilizzano metodi approssimati. In particolare, si addottano algoritmi di greedy, che costruiscono l'albero di decisione in modo incrementale, scegliendo a ogni nodo la divisione che produce la maggior riduzione locale dell'***impurità***. -->

#### *Conslusione*  

In sintesi, l’apprendimento di un albero decisionale è un problema di ottimizzazione sul dataset di addestramento:
- si vuole costruire un albero che rispetti determinati vincoli strutturali
- ogni nodo dell’albero corrisponde, durante il training, a un sottoinsieme di esempi
- l’obiettivo è minimizzare l’errore di classificazione
- il problema è NP-hard, quindi non si risolve esattamente in modo efficiente
- per questo si usa un algoritmo greedy, che costruisce l’albero in modo incrementale scegliendo a ogni nodo la divisione localmente migliore

---

### 10.7.6 Considerazione sulle foglie

Una foglia è un nodo terminale di un albero decisionale. Ogni foglia, in particolare, corrisponde all'insieme degli input $\mathbf{x}$ che soddisfano tutte le condizioni lungo il percorso dalla radice fino a quella foglia. Quindi, una foglia ha due facce:
1. ***strutturale***: è un nodo terminale dell'albero
2. ***geometrica/statistica***: rappresenta una zona dello spazio delle feature a ciascun nodo figlio, fino a quando non si raggiunge una condizione di arresto

> ***Cosa succede durante l'addestramento di un modello.***  
Supponiamo di avere un dataset di addestramento $$\mathcal{D} = \left\{\left(\mathbf{x}^{(1)}, y^{(1)}\right),\,\left(\mathbf{x}^{(2)}, y^{(2)}\right),\,\ldots,\,\left(\mathbf{x}^{(n)}, y^{(n)}\right)\right\}$$
>
> L'algoritmo costruisce l'albero dividendo gli esempi di cui è composto il dataset in gruppi sempre più piccoli. Quindi, quando l'albero è costruiro, ogni foglia contiene 
> $$\mathcal{D}_t = \left\{\left(\mathbf{x}^{(i)},\;y^{(i)}\right)\in\mathcal{D} :\;\mathbf{x}^{(i)}\;\text{ arriva alla foglia }\; t\right\}$$
>
> Questo significa che la foglia contiene gli esempi dell'addestramento che finiscono lì.

> ***Cosa succede durante la predizione***  
Quando arriva un nuovo input $\mathbf{x}$, il modello non "impara" dal nulla. Effettua questi passaggi:
> - parte dalla radice
> - controlla le condizioni dei nodi
> - scende lungo il percorso
> - arriva a una foglia
> - legge l'etichetta associata a quella foglia
> 
> Quella etichetta è la previsione. Quindi:
> - ***addestramento***: la foglia è associata a un insieme di esempi
> - ***predizione***: la foglia restituisce una classe

> ***Esempio.***  
Prendiamo un caso con una sola feature $\mathbf{x} = (x)$ e due classi $\mathcal{Y} = \{A, B\}$. Consideriamo il seguente dataset di addestramento:
>
> <div align = "center">
> 
> | Esempio | $\mathbf{x} = \{x\}$ | $y$ |
> | ------- | --- | --- |
> | 1       |   1 | A   |
> | 2       |   2 | A   |
> | 3       |   3 | A   |
> | 4       |   4 | A   |
> | 5       |   5 | B   |
> | 6       |   6 | B   |
> | 7       |   7 | B   |
> | 8       |   8 | A   |
> | 9       |   9 | B   |
> 
> </div>
> 
>>  ***Albero.***  
Costruiamo un albero:
>>  - radice: $x\leq 4.5$
>>      - se vero, si va a sinistra
>>      - se falso, si va a destra
>>  - nodo destro: $x\leq 6.5$
>>      - se vero, si va a sinistra
>>      - se falso, si va a destra
> 
>> ***Foglie.***  
>> ***Foglia 1: ramo sinistro della radice.***  
Qui arrivano gli esempi del dataset aventi input con le feature $x = 1,2,3,4$. La foglia risultante è la seguente: $$\mathcal{D}_1 = \{(1,A),(2,A),(3,A),(4,A)\}$$ Tutte le etichette sono $A$, quindi la foglia predice $$\hat{y}_1 = A$$
>
>> ***Foglia 2: ramo sinistro del nodo destro.***
Qui arrivano gli esempi del dataset aventi input con le feature $x = 5,6$. La foglia risultante è la seguente: $$\mathcal{D}_2 = \{(5,B),(6,B)\}$$ Le etichette sono tutte $B$, quindi la foglia predice: $$\hat{y}_2 = B$$
>
>> ***Foglia 3: ramo destro del nodo destro.***  
Qui arrivano gli esempi del dataset aventi input con le feature $x = 7,8,9$. La foglia risultante è la seguente: $$\mathcal{D}_3 = \{(7,B),(8,A),(9,B)\}$$ Questa foglia ***non è pura***, perché contiene sia $A$ sia $B$. Però la classe predetta può essere la ***classe più frequente***, quindi $B$. Per questa ragione, la foglia predice: $$\hat{y}_3 = B$$
>
> Questo esempio mostre tre cose:
> 1. ***la foglia contiene esempi dell'addestramento***: la foglia 3 contiene tre osservazioni, ovvero $(7,B),(8,A),(9,B)$. La foglia è associata ad un gruppo di esempi
> 2. ***la foglia produce una classe***: anche se si tratta di un insieme di esempi, la foglia restituisce una sola previsione, qui $B$
> 3. ***un nuovo input non crea la foglia***: se arriva $x = 8.2$, esso segue
>     - $8.2 > 4.5 \to$ destra  
>     - $8.2 > 6.5 \to$ destra
>
> Quindi finisce nella foglia 3 e viene classificato come $B$. La foglia esiste già: l'input si limita a cadere dentro una foglia già costruita.

> ***Vincolo "almeno m esempi per foglia".***  
Quando si dice che una foglia deve contenere almeno $m$ esempi, non si intende che la foglia sia un esempio, né che sia soltanto un'etichetta. Si intende che, durante l'addestramento, alla foglia arrivano alcuni esempi del dataset, cioè alcune osservazioni $(\mathbf{x}, y)$ che, seguendo lo split dell'albero, finiscono proprio in quella foglia. Quindi, ogni foglia è associata ad un insieme del tipo:
> $$\mathcal{D}_t = \left\{\left(\mathbf{x}^{(i)},\;y^{(i)}\right)\right\}$$ ovvero l'insieme delle osservazioni dell'addestramento che arrivano alla foglia $t$. Il vincolo significa allora: $$|\mathcal{D}_t| \geq m$$
>
> In altre parole, ogni foglia deve raccogliere almeno $m$ osservazioni dell'addestramento.
>
>> ***Esempio.*** Considerando l'esempio precedente, con $D_1 = 4$, $D_2 = 2$ e $D_3 = 3$, se imponessimo $m = 3$, la foglia $D_2$ non andrebbe bene perché contiene solo due esempi. Questo vincoli serve ad evitare foglie troppo piccole, cioè troppo "fragili."

> ***Ricorda.*** La foglia predice la classe che compare più spesso tra gli esempi che vi arrivano.

---

#### *Collegamento tra addestramento e predizione.*

Durante l'addestramento:
- l'albero viene costruito dividendo il dataset attraverso delle condizioni (regole di divisione)
- ogni foglia raccoglie un sottoinsieme di osservazioni
- la classe della foglia viene assegnata a partire da quegli esempi

Durante la predizione:
- arriva un nuovo input $\mathbf{x}$
- l'input percorre l'albero
- raggiunge una foglia già costruira
- la classe della foglia è la previsione finale

Quindi, la foglia non è “solo un’etichetta”: è il risultato finale di una regione dell’albero che, durante l’addestramento, raccoglie esempi e, durante l’uso, restituisce una classe.

---

## Lezione 16

---

# Capitolo 10 — Machine Learning: alberi decisionali (continuazione)

---

### 10.8 *Misure di impurità*  

### 10.8.1 Concetto di impurità

L'algoritmo greedy per la costruzione di alberi decisionali cerca, a ogni nodo, la suddivisione che produce nodi figli il più possibile ***omogenei*** rispetto alle classi presenti negli esempi del nodo stesso (ovvero, figli contenenti classi il più possibili simili tra loro). 

> ***Definizione (nodo puro e impuro).***  
Un nodo si dice 
> - ***puro*** se contiene esempi di una sola classe
> - ***impuro*** se contiene esempi di più classi mescolate

L'***obiettivo*** della suddivisione tramite questo algoritmo è ***ridurre progressivamente l'impurità*** scendendo verso le foglie.

---

#### *Misura numerica dell'impurità*

Per concretizzare la ***riduzione dell'impurità***, è necessario stabilire una ***misura numerica di impurità***: una funzione che, dato un nodo contenente esempi di $c$ classi diverse, restituisce un numero tanto più alto quanto più le classi sono mischiate, e zero quando il nodo è puro. Esistono diverse misure di impurità, ma le due più usate nella pratica sono l'***entropia*** e l'***indice di Gini***.

---

### 10.8.2 Notazione: proporzione di classe del nodo

Prima di definire le misure, si introduce la notazione comune a entrambe. Sia $\mathcal{D}_t$ un nodo, dell'albero di decisione, che contiene $n$ esempi appartenenti a $c$ classi diverse, etichettate $\{1,2,\ldots, c\}$. Si definisce:

$$p(i \mid t) = \frac{\text{numero di esempi del nodo}\; \mathcal{D}_t\; \text{appartenenti alla classe }\; i}{\text{numero totale di esempi del nodo}\; \mathcal{D}_t}$$

In altre parole, $p(i\mid t)$ è la ***frazione*** (o proporzione) degli esempi nel nodo $\mathcal{D}_t$ che appartengono alla classe $i$. Per definizione, si ha che:

$$\sum_{i = 1}^{c} p(i\mid t) = 1$$

<!-- p(i | t) è il numero di esempi appartenenti alla classe i sul numero totale di esempi appartenenti al nodo D_t -->

> ***Esempio.***  
Se un nodo contiene 10 esempi, di cui $7$ della classe $A$ e $3$ della classe $B$ (con $c = 2$), allora $$p(A \mid t) = \frac{7}{10} = 0.7 \qquad p(B \mid t) = \frac{3}{10} = 0.3$$.

### 10.8.3 Entropia

L'***entropia*** di un nodo $\mathcal{D}_t$ è definita come: 
$$\text{Entropia}(\mathcal{D}_t) = - \sum_{i = 1}^{c} p(i \mid t) \cdot \log_2 p(i\mid t)$$
dove:
- $c$ è il numero di classi
- $p(i\mid t)$ è la proporzione degli esempi di classe $i$ nel nodo $\mathcal{D}_t$
- il logaritmo in base 2 è convenzionale (l'entropia si misura in *bit*). Convenzionalmente si pone $0 \cdot \log_2 0 = 0$ per evitare l'indeterminazione quando una classe è assente

> ***Interpretazione.***  
L'entropia misura il grado di disordine o incertezza della distribuzione delle classi in un nodoç
> - raggiunge il suo valore massimo quando le classi sono equamente distribuite (massima incertezza)
> - vale $0$ quando tutti gli esempi appartengono ad una sola classe (certezza assoluta, ***nodo puro***). 
>
>> ***Esempio.*** Con $c = 2$ classi, il valore massimo dell'entropia è 1 bit, raggiunto quando $p (1\mid t) = p(2 \mid t) = 0.5$

L'entropia viene usata negli algoritmi ***ID3*** e ***C4.5***, due dei più noti algoritmi di costruzione degli alberi decisionali.

### 10.8.3 Indice di Gini

L'***indice di Gini*** di un nodo $\mathcal{D}_t$ è definito come: 
$$\text{Gini}(\mathcal{D}_t) = 1 - \sum_{i = 1}^{c} p(i\mid t)^2$$

dove i simboli hanno lo stesso significato della sezione precedente.

> ***Intepretazione.***  
L'indice di Gini misura la probabilità che un esempio scelto casualmente dal nodo venga classificato in modo errato se gli si assegna una classe estratta casualmente dalla distribuzione delle classi nel nodo. Vale $0$ quando il nodo è puro: 
> - un solo $p(i \mid t) = 1$, tutti gli altri zero, e quindi $\sum_i p(i\mid t)^2 = 1$, da cui $\text{Gini} = 0$ 
>
> e raggiunge il massimo quando le classi sono equamente distribuite.
>
>> ***Esempio.***  Con $c = 2$ classi, se le proporzioni $p_1$ e $p_2 = 1 - p_1$: 
>> $$\text{Gini}(\mathcal{D}_t) = 1 - (p_1^2 + p_2^2) = 1 - (p_1^2 + (1 - p_1)^2)$$
>> - Se $p_1 = 0.5$ (massima incertezza): $\text{Gini} = 1 - (0.25 +0.25) = 0.5$
>> - Se $p_1 = 1$ (nodo puro): $\text{Gini} = 1 - (1 + 0) = 0$

> ***Ricorda.***  
> - $Gini = 0$: purezza massima (tutti gli elementi appartengono ad una sola classe)
> - $Gini = 0.5$: impurezza massima (le classe sono distribuite equamente)

L'indice di Gini è usato nell'algoritmo ***CART***. 

### 10.8.4 Confronto tra Entropia e Gini

Entropia e Gini hanno proprietà analoghe (entrambe sono nulle per nodi puri e massime per classi equamente distribuite) e producono alberi di qualità simile nella pratica.

La differenza principale è computazionale: il Gini evita il calcolo del logaritmo e risulta leggermente più rapido da calcolare. Per questo motivo, CART adotta il Gini come criterio predefinito.

## 10.9 *Algoritmo CART*  

### 10.9.1 Struttura generale

***CART*** (*Classification and Regression Trees*) è uno degli algoritmi più diffusi per la costruzione di alberi decisionali. È un algoritmo greedy, ricorsivo e di tipo divide et impera, che costruisce l'albero dall'alto verso il basso, nodo per nodo. Ad ogni nodo non foglia, CART cerca la ***suddivisione binaria*** che minimizza l'***impurità ponderata*** dei due nodi figli risultanti dalla suddivisione del nodo corrente. La misura di impurtià usata da CART è l'***indice di Gini***.

L'algoritmo produce sempre ***alberi binari*** (ogni nodo interni ha esattamente due figli) e ***univariati*** (ogni split utilizza una sola variabile).

---

#### *Procedura ricorsiva CART*

La procedura ad ogni nodo è la seguente: 
1. per ogni variabile del dataset, genera tutti i possibili split candidati (le modalità di generazione dipendono dal tipo della variabile, ovvero se si tratta di una variabile categorica o numerica)
2. per ogni split candidato, calcola l'***impurità Gini ponderata*** dei due nodi figli risultanti dallo split
3. seleziona lo split candidato con l'impurità ponderata più bassa (cioè quello che produce figli più omogenei)
4. applica quello split, creando i due nodi figli, e ripete ricorsivamente la procedura su ciascuno di essi

Il processi si arresta quando si raggiunge un ***criterio di arresto***. 

> **Nota.** Le ***variabili*** del dataset sono le feature e le variabili target, le quali possono essere di due tipi: categorici o numerici.

---

### 10.8.5 Generazione degli split candidati per variabili categoriche

Sia $x$ una variabile categorica con $K$ valori distinti (le categorie). CART prova tutte le possibili ***bipartizioni*** (***sotto-partizioni binarie***, ovvero gli split candicati) delle categorie in due sottoinsiemi non vuori. Il numero di bipartizioni distinte è $$2^{K - 1} - 1$$

> ***Esempio.***  
Per una variabile con tre categorie $\{A, B, C\}$, si hanno $2^{3 - 1} - 1 = 3$ bipartizioni distinte:
> - $\{A\}$ vs $\{B, C\}$
> - $\{B\}$ vs $\{A, C\}$
> - $\{C\}$ vs $\{A, B\}$

Per ciascuna bipartizione, CART calcola il Gini ponderato e sceglie la bipartizione migliore (quella con il Gini ponderato più basso).

### 10.8.6 Generazione degli split candidati per variabili numeriche

Sia $x$ una variabile continua che assume $N$ valori distinti (i numeri) nel nodo corrente. Gli split candidati sono al più $N - 1$: per ogni coppia di valori adiacenti (ordinati in senso crescente) $v_j$ e $v_{j+1}$, si considera il punto medio (***soglia***) tra i due valori $$s_j = \frac{(v_j + v_{j+1})}{2}$$ Lo ***split candidato*** è $$x < s_j\; \text{ vs } \;x \geq s_j$$

> ***Esempio.***  
Se una variabile numerica assume i valori distinti ordinati $2, 5, 8, 10$, i candidati sono tre soglie:
> - $s_1 = \frac{2 + 5}{2} = 3.5$
> - $s_2 = \frac{5 + 8}{2} = 6.5$
> - $s_3 = \frac{8 + 10}{2} = 9$

Per ciascuna soglia, CART calcola il Gini ponderato e sceglie la soglia migliore.

### 10.8.7 Calcolo dell'impurità ponderata dei nodi figli

Dopo aver identificato uno split candidato che divide il nodo $\mathcal{D}_t$ in due nodi $\mathcal{D}_L$ (figlio sinistro) e $\mathcal{D}_R$ (figlio destro), CART calcola l'***impurità Gini ponderata*** dello split come: 

$$\text{Gini}_{split}(\mathcal{D}_t) = \frac{|\mathcal{D}_L|}{|\mathcal{D}_t|} \cdot \text{Gini}(\mathcal{D}_L) + \frac{|\mathcal{D}_R|}{|\mathcal{D}_t|} \cdot \text{Gini}(\mathcal{D}_R)$$

dove $|\mathcal{D}_t|$, $|\mathcal{D}_L|$ e $|\mathcal{D}_R|$ indicano rispettivamente il numero di esempi nel nodo padre, nel nodo figlio sinistro e nel nodo figlio destro.

> ***Significato della ponderazione.***  
Il Gini ponderato non è semplicemente la media aritmetica delle impurità dei due figli: ogni figlio costribuisce in proporzione alla sua dimensione relativa (in termini di numero di esempi posseduti) rispetto al padre. Questo è corretto perché un figlio grande con impurità moderata è peggio di un figlio piccolo con la stessa impurità.

CART sceglie, tra tutti i candidati esaminati su tutte le variabili, il ***candidato con il Gini ponderato minimo***: quello che rende i figli il più possibile omogenei rispetto al padre.

### 10.8.8 Esempio numerico completo

Si considera un dataset con 12 osservazioni, target binario (classe 1 o classe 2, quindi il target è una variabile categorica) e una variabile categorica (feature) con tre valori $\{A, B, C\}$:
- $A$: ***4 osservazioni*** — 3 di *classe 1*, 1 di *classe 2* ($\mathcal{D}_A = 4$)
- $B$: ***4 osservazioni*** — 1 di *classe 1*, 3 di *classe 2* ($\mathcal{D}_B = 4$)
- $C$: ***4 osservazioni*** — 2 di *classe 1*, 2 di *classe 2* ($\mathcal{D}_C = 4$)

Un'osservazione ha, quindi, la seguente struttura: $$\left(\mathbf{x}^{(i)}, y^{(i)}\right)$$
dove:
- l'input $\mathbf{x} = \{x\in{A, B, C}\}$
- il target $y\in \{\text{classe 1}, \text{classe 2}\}$

In questo contesto, dato che si sta lavorando con variabili categoriche, abbiamo $2^{3 - 1} - 1 = 3$ bipartizioni distinte:
- $\{A\}$ vs $\{B, C\}$
- $\{B\}$ vs $\{A, C\}$
- $\{C\}$ vs $\{A, B\}$

> ***Passo 0: impurità del nodo padre.***  
Il nodo radice contiene tutte le 12 osservazioni: 6 di classe 1 ($p_1(1\mid t) = \frac{6}{12} = 0.5$) e 6 di classe 2 ($p_2(2\mid t) = \frac{6}{12} = 0.5$). Allora:
> $$\text{Gini}_{padre} = 1 - \sum_{i = 1}^{2} p(i\mid t)^2 = 1 - (0.5^2 + 0.5^2) = 1 - 0.5 = 0.5$$

> ***Passo 1: split $\{A\}$ vs $\{B, C\}$***
> - ***Nodo sinistro ($A$)***: 4 osservazioni, $p_1 = \frac{3}{4}$, $p_2 = {1}{4}$
>
> $$\text{Gini}_{A} = 1 - \sum_{i = 1}^{2} p(i\mid t)^2 = 1 - \left(\left(\frac{3}{4}\right)^2 + \left(\frac{3}{4}\right)^2\right) = 1 - (0.5625 + 0.0625) = 0.375$$
>
> - ***Nodo destro ($B,C$)***: 8 osservazioni — da B: 1 classe 1, 3 classe 2; da C: 2 classe 1, 2 classe 2 → totale 3 classe 1, 5 classe 2. Quindi $p_1 = \frac{3}{8}$ e $p_2 = \frac{5}{8}$
>
> $$\text{Gini}_{BC} = 1 - \sum_{i = 1}^{2} p(i\mid t)^2 = 1 - \left(\left(\frac{3}{8}\right)^2 + \left(\frac{5}{8}\right)^2\right) = 1 - (0.140625 + 0.390625) = 0.46875$$
>
> - ***Impurtià Gini ponderata dello split 1***: 
>
> $$\text{Gini}_{split1}(\mathcal{D}_{padre}) = \frac{4}{12} \cdot 0.375 + \frac{8}{12} \cdot 0.46875 = 0.125 + 0.3125 = 0.4375$$
>
> Si procede analogamente per gli altri due candidati ($\{B\}$ vs $\{A, C\}$ e $\{C\}$ vs $\{A, B\}$). Supponendo che il confronto tra tutti e tre i candidati mostri che lo ***split $\{A\}$ vs $\{B, C\}$*** (con Gini ponderato $= 0.4375$) sia il migliore (cioè il più basso), CART lo seleziona come primo split della radice.
>
>> ***Interpretazione della prima suddivisione.***  
Dopo questo split, il nodo sinistro (contenente le osservazioni con $A$) è relativamente puro (Gini $= 0.375$, maggioranza di *classe 1*) e viene etichettato con previsione dominante ***classe 1***. Il nodo destro (contenente $B$ e $C$) rimane impuro (Gini $= 0.46875$) e richiede un ulteriore split.

> ***Passo 2: split nel nodo destro.*** Il nodo $\{B, C\}$ contiene 8 osservazioni. Questo viene diviso in una partizione, ovvero $\{B\}$ vs $\{C\}$. CART prova ora lo split su questa partizione:
> - ***Nodo sinistro ($B$)***: 4 osservazioni, $p_1 = \frac{1}{4}$, $p_2 = {3}{4}$
>
> $$\text{Gini}_{B} = 1 - \sum_{i = 1}^{2} p(i\mid t)^2 = 1 - \left(\left(\frac{1}{4}\right)^2 + \left(\frac{3}{4}\right)^2\right) = 1 - (0.0625 + 0.5625) = 0.375$$
>
> Quindi la previsione dominante è la *classe 2* (su 4 variabili, 3 sono della classe 2)
>
> - ***Nodo destro ($C$)***: 4 osservazioni, $p_1 = \frac{2}{4}$, $p_2 = {2}{4}$
>
> $$\text{Gini}_{BC} = 1 - \sum_{i = 1}^{2} p(i\mid t)^2 = 1 - \left(\left(\frac{2}{4}\right)^2 + \left(\frac{2}{4}\right)^2\right) = 1 - (0.25 + 0.25) = 0.5$$
>
> Quindi la previsione è la *bilanciata* (su 4 variabili, 2 sono della classe 1 e 2 della classe 2)
>
> - ***Impurtià Gini ponderata dello split 2***: dato che oltre a questo split non ce ne sono altri, possiamo non calcolarla. È necessario calcolarla quando ci sono più split su bipartizioni diverse, in modo tale poi da scegliere lo split con minor impurità di Gini ponderata.
>

La struttura dell'albero risultante è riassunta di seguito:

<div align = "center">

![alt text](CART-1.png)

</div>

Questo esempio mostra il funzionamento step-by-step di CART: a ogni nodo si valutano tutti i candidati, si sceglie quello con il Gini ponderato minore, e si procede ricorsivamente finché non si raggiunge un criterio di arresto.

## 10.9 *Criteri di arresto dell'albero decisionale*

### 10.9.1 Problema della crescita incontrollata

Un albero decisionale costruito senza limitazioni tende a crescere fino a creare foglie con un singolo esempio. In tal caso l'errore di classificazione sul set di addestramento è zero, ma il modello ha memorizzato i dati invece di apprendere la regola generale. Si tratta del fenomeno di ***overfitting***: il modello è eccessivamente complesso, si adatta al rumore dei dati di addestrameno e generalizza male a nuovi esempi.

Per prevenire l'overfitting, sono disponibili due strategie: 
- ***criteri di arresto*** (*pre-pruning*), che limitano la crescita dell'albero durante la sua costruzione
- ***pruning*** (*post-pruning*), che consente all'albero di crescere completamente e poi lo riduce a posteriori

### 10.9.2 Criterio di arresto (pre-pruning)

I criteri di arresto più comuni, direttamente gestibili come parametri (iperparametri) dell'algoritmo, sono i seguenti:
- ***profondità massima dell'albero***: si imposta il numero massimo di livelli (livello 0 = radice, livello 1 = figli della radice, ecc.) che l'albero può avere. Una volta raggiunta questa profondità, il nodo corrente diventa automaticamente una foglia, indipendentemente dalla sua impurità. Un valore più piccolo produce alberi più semplici (rischio underfitting), mentre un valore più grande produce alberi più complessi (rischio overfitting)

- ***numero minimo di campioni per split***: un nodo viene diviso solo se contiene un numero di esempi superiore a una soglia minima

- ***numero minimo di campioni per foglia***: ogni foglia deve contenere almeno un certo numero di osservazioni (esempi). Questo impedisce che l'albero prenda decisioni basate su un singolo esempio o su un piccolo gruppo di esempi

- ***diminuzione minima dell'impurità***: un nodo viene diviso solo se la riduzione dell'impurità (misurata con Gini) prodotta dal miglior split supera una soglia minima predefinita. Se nessuno split produce una riduzione sufficiente, il nodo diventa foglia

- ***numero massimo di foglie***: si limita il numero totale di nodi foglia dell'albero. L'algoritmo sceglie i nodi da espandere secondo un criterio "best-first" (prima quelli che producono la maggior riduzione di impurità), fino a raggiungere il limite

### 10.9.3 Pruning (post-pruning)

Un'alternativa ai criteri di arresto è la strategia di ***pruning***: si lascia crescere l'albero completamente (o quasi), e successivamente si eliminano i rami che non offrono un potere predittivo significativo rispetto ad un insieme di ***validazione*** separato. I rami rimossi vengono sostituiti da foglie etichettate con la classe maggioritaria nel nodo corrispondente (la classe che compare di più).

Il pruning consente di evitare il problema dei criteri di arresto anticipati, che possono non fermare la crescita nel momento giusto, poiché lavora su una visione globale dell'albero già costruito.

## 10.10 *Random forest*  

### 10.10.1 Problema degli alberi singoli e la soluzione ensemble

Un singolo albero decisionale, per quanto costruito con criteri di impurità e criteri di arresto, presenta una fragilità: è molto ***sensibile alle variazioni del set di addestramento***. Un piccolo cambiamento nei dati di addestramento (es. rimuovere o aggiungere poche osservazioni) può portare ad un albero con una struttura radicalmente diversa. Questo comportamento è noto come ***alta varianza*** del modello.

La soluzione a questo problema è l'***ensemble learning***: invece di addestrare un singolo modello, si addestrano molti modelli su versioni diverse del dataset e si combinano le loro predizioni. In questo modo, gli errori di singoli modelli tendono a essere risolti: se i modelli commettono errori, la media delle loro predizioni sarà più stabile e accurata di quella di qualunque singolo modello.

### 10.10.2 Definizione di Random Forest

Il ***Random Forest*** è un algoritmo di apprendimento supervisionato che costruisce una collezione ("foresta") di alberi *combinando alberi decisionali* — ciascuno addestrato su una versione diversa del dataset — e *aggrega le loro predizioni* per ottenere un risultato più robusto. 

<!-- Il ***Random Forest*** è un algoritmo di apprendimento supervisionato che costruisce una collezione ("foresta") di alberi decisionali — ciascuno addestrato su una versione diversa del dataset — e aggrega le loro predizioni tramite ***voto di maggioranza***: per classificare un nuovo esempio, ogni albero emette la propria previsione di calsse, e la classe predetta dall'algoritmo è quella che ha ricevuto il maggior numero di voti.  -->

La foresta contiene tipicamente molti alberi. Per rendere tutti gli alberi il più possibile ***diversi*** tra loro (evitando che tutti commettano gli stessi errori), il Random Forest introduce due meccanismi di casualità durante la costruzione degli alberi: 
- ***bagging***
- ***selezione casuale delle feature***.

### 10.10.3 Bagging (Bootstrap Aggregating)

Il primo meccanismo alla base delle foreste è il ***bagging*** (*Bootstrap Aggregating*). L'idea fondamentale dell'algoritmo è costruire più albero decisionali, facendo in modo che ciascuno di essi venga addestrato su una versione leggermente diversa del dataset originale.

<!-- Il bagging consiste nel costruire più alberi decisionali, facendo in modo che ciascuno venga addestrato su un campione bootstrap estratto dal dataset originale. -->

In particolare, ogni albero della foresta non viene addestrato sull'intero dataset di addestramento, ma su un ***campione bootstrap*** estratto dal dataset stesso.

> ***Definizione (campione bootstrap).***  
Un ***campione di bootstrap*** è un insieme di osservazioni ottenuto estrando dal dataset originale un numero di esempi pari alla dimensione del dataset stesso, ***con reinserimento***.
>
> La presenza del reinserimento significa che:
> - una stessa osservazione può camparire più volte nel campione
> - altre osservazioni possono non comparire affatto
>
> Quindi, il *campione bootstrap* ha la stessa cardinalità del dataset originale (stesso numero di osservazioni), ma non coincide necessariamente con esso, perché la selezione avviene in modo casuale e con ripetizione.

In altre parole, invece di addestrare ogni albero della foresta sull'intero dataset di addestramento, si costruisce per ciascun albero un sottoinsieme casuale del dataset, ottenuto tramite campionamento bootstrap.
<!-- - alcuni esempi vengono "visti" più volte dallo stesso albero
- altri esempi non vengono usati in quel particolare addestramento
- ogni albero riceve una versione leggermente diversa dei dati -->

Il risultato è che i diversi alberi della foresta vengono addestrati su campioni bootstrap diversi, ovvero su dati parzialmente diversi. Questa differenza nei dati osservati dai vari alberi della foresta, li porta a sviluppare strutture diverse e a commettere errori diversi.

### 10.10.4 Feature Randomness (Random Subspace Method)

Il secondo meccanismo alla base delle foreste è la ***selezione casuale delle feature***, detta anche *Random Subspace Method*. 

L'idea è la seguente: in un albero decisionale standard, quando si deve scegliere il miglior split in un nodo, l'algoritmo valuta i possibili candidati utilizzando ***tutte le feature (variabili) disponibili*** su quel nodo. In un Random Forest, invece, questa scelta è resa casuale: ***a ogni nodo si considera soltanto un sottoinsieme casuale delle feature (variabili)*** disponibili.

---

#### *Chiarimenti su feature, variabili e nodi*

- Una ***feature*** è una componende dell'input $\mathbf{x}$, ciop una variabile osservata per ogni esempio del dataset
- Un ***nodo*** dell'albero non contiene feature proprie: durante l'addestramento contiene un ***sottoinsieme di esempi*** del dataset
- Ogni esempio che arriva a quel nodo è descritto da ***tutte le feature originali***

Quando si deve scegliere lo split del nodo, però, non tutte le feature vengono considerate come candidate: nella Random Forest se ne seleziona solo una parte in modo casuale.

Quindi il nodo non perde feature degli esempi che contiene; semplicemente, nella fase di scelta dello split, l'algoritmo ***limita il set di feature candidate***.

---

#### *Meccanismo operativo*

Se il dataset contiene $p$ feature, allora in ciascun nodo non si confrontano tutti gli split su tutte le $p$ variabili (feature), ma solo quegli split costruiti a partire da un ***sottoinsieme casuale di feature***. Nel caso più comune, il numero di feature considerate in ogni nodo è pari a 
> $$\lfloor \sqrt{p} \rfloor$$
> anche se il principio generale resta quello della selezione casuale delle variabili disponibili.

> ***Esempio.***  Se il dataset ha $p = 16$ feature, in ciascun nodo si considerano tipicamente $$ \lfloor \sqrt{16} \rfloor = 4$$ feature scelte casualmente tra le 16 disponibili. Lo split migliore verrà quindi cercato solo tra queste 4 e non tra tutte le 16.

> ***Significato del meccanismo.***  
Questa scelta introduce una forma di casualità nella costruzione della foresta, diversa da quella introdotta dal bagging.
> - Il ***bagging*** rende diversi gli alberi perché ciascuno viene addestrato su un ***campione bootstrap diverso*** del dataset di addestramento
> - La ***feature randomness*** rende diversi gli alberi perché, in ciascun nodo, ogni albero può considerare un ***insieme diverso di feature candidate*** per lo split
>
> In questo modo, non solo cambiano i dati osseravti dai singoli alberi, ma cambia anche l'insieme delle variabili su cui essi possono prendere decisioni.

<div align = "center">

![alt text](forest_feature_randomness-1.png)

</div>

> ***Perché questa casualità è utile.***  
In molti problemi reali, alcune feature sono molto più predittive di altre. Se un albero decisionale standard avesse accesso a tutte le variabili in ogni nodo, tenderebbe spesso a scegliere, ai livelli più alti dell'albero, la feature più informativa o più dominante.
>
> Questo comporterebbe un effetto indesiderato: molti alberi della foresta finirebbero per avere strutture molto simili tra loro, perché sceglierebbero gli stessi split o split molto simili, In altre parole, gli alberi sarebbero ***fortemente correlati***.
>
>> ***Alberi fortemente correlati.***  
Dire che gli alberi sono fortemente correlati significa che:
>> - tendono a prendere decisioni simili
>> - costruiscono strutture molto simili
>> - commettono errori simili sugli stessi esempi
>>
>> Se tutti i modelli commettono errori simili, combinarli migliora poco le predizioni rispetto all'usare un singolo albero.

> ***Effetto della selezione casuale delle feature***  
Forzando ogni nodo a scegliere lo split migliore solo tra un sottoinsieme casuale di feature, si ottiene il seguente effetto:
> - la feature dominante non è sempre disponibile
> - l’albero è costretto a considerare anche feature meno ovvie
> - i diversi alberi della foresta costruiscono strutture più variate
> - gli errori dei modelli diventano meno simili tra loro
>
> In questo modo la foresta guadagna in ***diversità***, e la diversità tra i modelli è proprio ciò che rende efficace l’approccio ensemble.

> ***Esempio.***  
Supponiamo che un dataset abbia $p = 4$ feature: 
> $$x_1, x_2, x_3, x_4$$
> e che $x_1$ sia la feature più predittiva.
>
>> ***In un albero standard.***  
A ogni nodo l’algoritmo potrebbe scegliere quasi sempre uno split su $x_1$, perché è la variabile che separa meglio le classi.
>
>> ***In una Random Forest***  
Se, in un certo nodo, il sottoinsieme casuale estratto è 
> $$\{x_2, x_4\}$$
> allora l’albero non può usare $x_1$ in quel nodo, anche se $x_1$ è la feature migliore in assoluto. Deve quindi scegliere lo split migliore tra $x_2$ e $x_4$. Questo costringe gli alberi a differenziarsi tra loro.

---

### 10.10.5 In sintesi

La diversità della foresta è garantita da due fonti di casualità ortogonali: 
- il ***bagging***, che introduce diversità sui dati, perché ogni albero vede un campione diverso delle osservazioni
- la ***selezione casuale delle feature***, che introduce diversità sulle variabili, perché ogni nodo di ogni albero sceglie il miglior split tra un sottoinsieme casuale di variabili

## 10.11 *Classificatore K-Nearest Neighbours (k-NN)*

### 10.11.1 Paradigma alternativo: classificatori instance-based

Tutti i modelli visti fino ad ora — alberi decisionali, Random Forest — appartengono alla categoria degli ***eager learners***: durante la fase di addestramento costruiscono un modello esplicito (struttura ad albero, insieme di regole) che sintetizza la conoscenza estratta dal set di addestramento. Una volta costruito il modello, i dati originali non sono più necessari per fare previsioni.

Esiste una famiglia di classificatori radicalmente diversa, detta dei ***lazy learners*** o ***classificatori instance-based***. Questi classificatori ***non costruiscono alcun modello*** durante la fase di addestramento: memorizzano l'intero set di addestramento. Una volta che arriva un nuovo esempio da classificare, il classificatore ***confronta il nuovo esempio con quelli memorizzati*** e gli assegna una classe in base alla sua somiglianza con gli esempi del set di addestramento. 

In sostanza, i classificatori lazy learners classificano nuoi esempi sulla base della loro somiglianza rispetto agli esempi presenti nel set di addestramento.

---

#### *Varianti classificatore instance-based*

Esistono due varianti principali di classificatori instance-based:
- ***Rote-learner***: classifica un nuovo esempio solo se questo coincide esattamente con uno già presente nel set di addestramento. Questo approccio è eccessivamente rigido è di scarsa utilità
- ***Nearest-Neighbor***: classifica un nuovo esempio in base agli esempi più simili presenti nel set di addestramento, anche se non coincide con nessuno di essi

<div align = "center">

![alt text](leasy_learners-1.png)

</div>

#### *Confronto tra eager learners e lazy learners*  

- Gli ***eager learners*** sono efficienti nella fase di inferenza (il modello è già costruito) ma richiedono una fase di addestramento potenzialmente lunga. 
- I ***lazy learners*** hanno una fase di "addestramento" praticamente nulla (solo memorizzazione) ma sono computazionalmente più onerosi (dispendioso) durante l'inferenza, poiché devono confrontare il nuovo esempio con tutti gli esempi del set di addestramento.

--- 

### 10.11.2 Classificatore Nearest Neighbor: idea di base

Il classificatore ***k-Nearest Neighbor*** (*k-NN*) si basa su un'idea molto semplice: se un nuovo esempio è molto simile  — nello spazio delle feature — a esempi di una certa classe, allora è ragionevole predire che appartenga a quella classe. 

> Intuitivamente: *"If it walks like a duck, quacks like a duck, then it's probably a duck."*

Formalmente, il classificatore k-NN opera come segue.

> ***Definizione.***  
Dato un nuovo esempio (record) $\mathbf{x}$ da classificare e un intero $k$, i $k$ ***nearest neighbors*** di $\mathbf{x}$ sono i $k$ record del set di addestramento che hanno la distanza più piccola da $\mathbf{x}$, secondo una metrica di distanza scelta.
>
>> **Nota.** Nel contesto del k-NN, un ***record*** è un ***esempio*** del dataset di addestramento.

Il classificatore k-NN richiede tre elementi fondamentali:
- un ***set di addestramento*** (esempi/casi memorizzati, con le loro etichette di classe)
- una ***metrica di distanza*** per calcolare la "vicinanza" tra record nello spazio delle feature
- il ***valore di $k$***, cioè il numero di vicini da considerare per la classificazione

<div align = "center">

![alt text](k-NN-1.png)

</div>

> **Ricorda.**  Nel classificatore k-NN, un ***record*** è un'***osservazione del dataset di addestramento***, cioè $$\left(\mathbf{x}^{(i)},y^{(i)}\right)$$ dove:
> - $\mathbf{x}^{(i)}$ è il vettore delle feature
> - $y^{(i)}$ è l'etichetta, il target (classe)
>
> Quindi, nel contesto del k-NN: ***record***, ***esempio***, ***osservazione***, ***dato*** e ***istanza*** sono tutti modi per indicare un'osservazione del dataset di addestramento.

### 10.11.3 Metrica di distanza: distanza euclidea

La misura (metrica) di distanza più comunemente usata per il k-NN è la ***distanza euclidea***. 

Nel k-NN, ogni record viene rappresentato come un punto nello spazio delle feature. In particolare, dati due record descritti da vettori di feature $$\mathbf{p} = (p_1, p_2, \ldots, p_d)\;\text{ e }\;\mathbf{q} = (q_1, q_2, \ldots, q_d)$$ dove $d$ è il numero di feature numeriche, la distanza euclidea tra questi due punti è definita come: 

$$d(\mathbf{p, d}) = \sqrt{\sum_{i=1}^{d} (p_i - q_i)^2} $$

dove:
- $d$ è il numero di feature (la dimensione dello spazio delle feature)
- $p_i$ e $q_i$ sono i valori dell'$i$-esima feature nei due record
- la somma scorre su tutte le $d$ feature

> ***Interpretazione geometrica.***  
La distanza euclidea è la ***lungheza del segmento*** che congiunge i due punti $\mathbf{p}$ e $\mathbf{q}$ nello spazio $\mathbb{R}^d$. 
>
> In due dimensioni corrisponde al teorema di Pitagora; in $d$ dimensioni ne è la generalizzazione naturale.

> ***Esempio.***  
Con $d = 2$ feature e due record $\mathbf{p} = (1,3)$ e $\mathbf{q} = (4,7)$. La distanza euclidea è:
>
> $$d(\mathbf{p, d}) = \sqrt{(1 - 4)^2 + (3 - 7)^2} = \sqrt{9 + 16} = \sqrt{25} = 5$$
>
> Quindi, i due record, visti come punti nello spazio $\mathbb{R}^2$  — ovvero in un piano bidimensionale  — distano di 5 unità

### 10.11.4 Processo di classificazione

Una volta definita una metrica di distanza, il processo di classificazione di un nuovo record $\mathbf{x}$ si articola nei seguenti passi:
1. si ***calcola la distanza*** tra $\mathbf{x}$ e ogni record nel set di addestramento
2. si ***identificano i $k$ nearest neighbors***: i $k$ record del set di addestramento con distanza minore da $\mathbf{x}$
3. si effettua un ***voto di maggioranza***: tra le etichette di classe dei $k$ nearest neighbors, assegna a $\mathbf{x}$ la classe che compare con maggiore frequenza (trai i $k$ neighbors)

<div align = "center">

![alt text](k-NN_classificazione-1.png)

</div>

In caso di parità nel voto di maggioranza (classi diverse compaiono con la stessa frequenza), si adottano strategie come la riduzione di $k$ di uno, oppure la pesatura dei voti in base alla distanza da $\mathbf{x}$.

> ***Variante pesata.***  
Una versione più sofisticata del voto di maggioranza pondera il costributo di ciascun vicino in base alla sua distanza da $\mathbf{x}$: i vicini più prossimi hanno un peso maggiore, quelli più lontani hanno un peso minore. Un peso comune è: $$w = \frac{1}{d^2}$$ dove $d$ è la distanza del vicino da $\mathbf{x}$. 
>
>> ***Esempio.***  
Un vicino a distanza $0.5$ contribuisce con peso $$\frac{1}{0.25} = 4$$ mentre un vicino a distanza $2$ contribuisce con peso $$\frac{1}{4} = 0.25$$ Abbiamo che, il primo, è 16 volte più influente del secondo.

<div align = "center">

![alt text](k_nearest_neighbors-1.png)

</div>

### 10.11.5 Esempio di classificazione e diagramma di Voronoi

Si consideri un dataset con due classi:
- quadrati blu: simbolo $\square$
- triangoli rossi: simbool $\triangle$

Deve essere classificato un nuovo punto — un record (in verse, simbolo $\bullet$). Attorno al punto verde di traccia un cerchio centrato su di esso, con raggio che cresce fino ad includere esattamente $k$ vicini.

<div align = "center">

![alt text](es_k-NN-1.png)

</div>

Consideriamo due valori di $k$, $3$ e $5$:
- con $k = 3$: il cerchio più piccolo include include 2 triangoli rossi e 1 quadrato blu $\to$ voto di maggioranza: ***triangolo rosso***
- con $k = 5$: il cerchio più grande include 3 quadrati blu e 2 triangoli rossi $\to$ voto di maggioranza: ***quadrato blu***

Questo esempio illustra un aspetto importante: la classe predetta può cambiare radicalmente al variare di $k$. La scelta di $k$ è, quindi, un iperparametro critico dell'algoritmo.

> ***Diagramma di Voronoi per $k = 1$.***  
Il caso speciale $k = 1$ (1-NN) ha una rappresentazione geometrica specifica: il ***diagramma di Voronoi***. Dato un insieme di punti (insieme di record) del set di addestramento, il diagramma di Voronoi suddivide lo spazio $\mathbb{R}^d$ (con $d$ numero di feature numeriche per ogni record) in regioni (celle) tali che ogni punto dello spazio appartiene alla cella del campione del set di addestramento a cui è più vicino. Il confine tra due celle adiacenti è equidistante dai due campioni che le definiscono.
>
> In altre parole, il classificatore 1-NN classifica ogni punto dello spazio con la stessa classe del campione del training set più vicino. Il confine decisionale è esattamente il bordo delle celle di Voronoi.
>
> <div align = "center">
> 
> ![alt text](k-NN_voronoi-1.png)
>
> </div>

### 10.11.6 Scelta di $k$: overfitting e underfitting

Il valore $k$ è un parametro molto importante per il classificatore k-NN, in quanto definisce come viene classificato un nuovo record a seconda dei suoi $k$ vicini.
- Se $k$ è ***troppo piccolo (rischio di overfitting)***: con $k = 1$, il classificatore si basa su un singolo vicino. Un errore di etichettatura nel set di addestrameno può determinare classificazioni errate per una zona intera dello spazio $\mathbb{R}^d$ ($d$ numero di feature numeriche) considerato
- Se $k$ è ***troppo grande (rischio di underfitting)***: con $k$ molto grande, il "vicinato" di ogni punto include esempi molto lontani, potenzialmente appartenenti a classi diverse. Il classificatore tende a essere dominato dalla classe maggioritaria all'interno del dataset di addestramento, ignorando le strutture locali dello spazio delle feature

In pratica, si cerca un valore intermedio di $k$.

### 10.11.7 Necessità di normalizzazione degli attributi

Per funzionare correttamente, il classificatore k-NN richiede che gli ***attributi***, cioè le ***feature numeriche***, abbiano la stessa scala di valori o comunque scale confrontabili.

Questo non è un dettaglio tecnico marginale, ma una conseguenza diretta del modo in cui k-NN misura la vicinanza tra due record: tramite la distanza euclidea. Poiché la distanza euclidea somma i contributi di tutte le feature, una feature con valori molto grandi (con un range di variazione molto grande) può dominare completamente il calcolo, rendendo le altre feature quasi irrilevanti.

---

#### *Cosa significa "attributo"*  

Nel linguaggio dei dataset, un ***attributo*** è una variabile che descrive un'osservazione, ovvero una feature. 

> ***Esempio.***  
In un dataset su persone, gli attributi potrebbero essere: altezza, peso, stipendio.
>
> Ogni ***record*** del dataset è, invece, una singola persona descritta da questi tre attributi, come: $$\mathbf{x} = (1.75,\;68,\;2400)$$ dove $1.75$ è l'altezza, $68$ è il peso e $2400$ lo stipendio.

In altre parole, gli attributi sono le componenti del vettore $\mathbf{x}$.

#### *Perché la scala delle feature è importante*  

La distanza euclidea tra due record $\mathbf{p}$ e $\mathbf{q}$ è $$d(\mathbf{p},\mathbf{q}) = \sqrt{\sum_{i = 1}^{d} (p_i - q_i)^2}$$

Questa formula tratta tutte le componenti in modo uniforme dal punto di vista matematico, ma ***non*** dal punto di vista pratico: se una feature ha un intervallo di valori molto più ampio delle altre, la sua differenza numerica tende a pesare molto di più sulla distanza finale.

> ***Differenza assoluta e differenza relativa.***  
Distinguiamo due concetti:
> - ***differenza assoluta***: lo scarto numerico grezzo tra due valori di una feature
> - ***differenza relativa***: lo stesso scarto, confrontato con l'ampiezza totale del range di valori di una feature
>> ***Esempio.***  
Si consideri un dataset con tre feature:
>> - altezza: range $[1.5,\; 2.1]\;m$, quindi ampiezza $0.6\;m$
>> - peso: range $[40,\; 150]\;kg$, quindi ampiezza $110\;kg$
>> - stipendio: range $[10K,\;1M]\;€$, quindi ampiezza $990K\;€$
>>
>> Se prendiamo una differenza di $0.5$, otteniamo:
>> - per il peso: $\frac{0.5}{0.6} \approx 0.83 = 83\%$ del range dell'altezza $\to$ differenza enorme
>> - per il peso: $\frac{0.5}{110} \approx 0.45 = 45\%$ del range del peso $\to$ differenza trascurabile
>> - per lo stipendio: $\frac{0.5}{990\,000} \approx 0.00005 = 0.005\%$ del range dello stipendio $\to$ differenza irrisoria
>>
>> Questo esempio mostra un fatto essenziale: ***la stessa differenza assoluta può avere significati completamente diversi a seconda della scala dell’attributo***.
>
>> ***Conseguenza nel k-NN.***  
Poiché il k-NN basa la classificazione sulla distanza, una feature con range molto più ampio delle altre tende a influenzare in modo sproporzionato il calcolo della distanza.

Quindi, senza normalizzazione, una feature come lo stipendio può dominare il calcolo della distanza anche se, dal punto di vista del problema, non è necessariamente la più importante. Per evitare questo problema, le feature devono essere ***normalizzate*** in fase di pre-processing, riportandole tutte alla stessa scala di valori.

#### *Cosa succede se non si normalizza*  

Se le feature non sono normalizzate:
- le variabili (feature) con range più grande influenzano di più la distanza
- le variabili con range più piccolo contano poco
- i vinici trovati da k-NN possono essere vicini solo perché simili su una feature dominante, anche se differiscono molto sulle altre

Questo può alterare completamente la classificazione di un nuovo record.

> ***Esempio.***  
Consideriamo due record: $$\mathbf{p} = (1.70,\;70,\;2000) \quad \mathbf{q} = (1.72,\;71,\;900\,000)$$
>
> Senza normalizzazione, la differenza sullo stipendio pesa enormemente rispetto alle altre due feature. Il k-NN potrebbe, quindi, considerare i due record molto lontani quasi esclusivamente per lo stipendio, anche se altezza e peso sono molto simili. 
>
> Questo significa che la distanza non sta più misurando una "somiglianza glibale" tra due feature, ma la differenza sulla feature con scala maggiore.

#### *Normalizzare gli attributi: normalizzazione min-max*  

La ***normalizzazione*** serve a portare tutte le feature di un record su una scala comparabile, in modo che nessuna di esse domini artificialmente la distanza. Una normalizzazione utilizzata è la ***normalizzazione min-max***: $$x' = \frac{x - x_{\min}}{x_{\max} - x_{\min}}$$

Questa trasformazione porta ogni valore nell'intervallo $[0,\;1]$. In questo contesto, quindi:
- $x_{\min} =$ valore minimo assunto dalla feature nel dataset 
- $x_{\max} =$ valore massimo assunto dalla feature nel dataset
- tutti gli altri valori vengono riposizionati proporzionalmente tra $0 e $1$

> ***Esempio.***  
Supponiamo che l'attributo "altezza" vari tra $x_{\min} = 1.5$ e $x_{\max} = 2.1$. Se una persona ha altezza $x = 1.8$, allora: $$x' = \frac{1.8 - 1.5}{2.1 - 1.5} \frac{0.3}{0.6} = 0.5$$
> Quindi:
> - $1.5 \to 0$
> - $2.1 \to 1$
> - $1.8 \to 0.5$
>
> In altre parole, $1.8$ si trova esattamente a metà del range $[1.5,\;2.1]$, e per questo viene trasformato nel valore normalizzato $0.5$.

#### *Normalizzazione e k-NN*

La normalizzazione è essenziale nel k-NN in quanto il classificatore sceglie i vicini in ***base alla distanza***. La normalizzaizone è una condizione pratica per far si che il criterio di vicinanza sia corretto.

---

### 10.11.8 Come scegliere il valore ottimale di $k$

Non esiste un valore universale ottimale di $k$: dipende dal dataset, dalla distribuzione (numero) delle classi al suo interno e dal rumore. Due metodi pratici per la scelta di $k$ sono:
- ***Metodo del Gomito (Elbow Method)***
- ***Cross-Validation***

> ***Metodo del Gomito (Elbow Method).***  
Consiste nel valutare le performance del classificatore su diversi valori di $k$ e scegliere quello corrispondente al "gomito" della curva dell'errore. La procedura è:
> 1. Addestrare il modello per $k = 1,\;2,\;\ldots,\;K_{max}$ (es. $K_{max} = 20$)
> 2. Per ogni $k$, calcolare l'errore di classificazione su un insieme di validazione
> 3. Tracciare il grafico: asse $x =$ valore di $k$, asse $y =$ errore di validazione
> 4. Scegliere il valore di $k$ in corrispondenza del "gomito": il punto in cui l'errore smette di decrescere rapidamente e inizia a calare molto lendamente (o risalire)
>
> Questo punto di gomito indica il miglior compromesso tra varianza (errore alto per $k$ piccolo) e distorsione (errore alto per $k$ grande).

> ***Cross-Validation.***  
In alternativa, si può applicare la cross-validation $k$-fold. Per selezionare il valore ottimale di $k$.
>
>> **Nota.** Non confondere la $k$ della cross-validation con la $k$ del k-NN: sono due parametri distinti.

---

### *Set di validazione*  

Il ***set di validazione*** (*validation set*) è un sottoinsieme del dataset utilizzato per valutare temporaneamente le prestazioni del modello durante la fase di sviluppo.

Nel machine learning, infatti, non è sufficiente addestrare un classificatore sui dati disponibili: è necessario anche verificare se il modello sia in grado di ***generalizzare*** correttamente, cioè di produrre previsioni accurate su esempi nuovi, non utilizzati durante l’addestramento.

Per questo motivo, il dataset viene suddiviso in insiemi distinti con ruoli differenti.

<!-- Nel caso del ***k-NN***, il set di validazione serve per confrontare diversi valori di $k$ e scegliere quello che fornisce il comportamento migliore sul problema considerato. -->

> ***Suddivisione del dataset.***  
In generale, si distinguono tre insiemi:
> - ***set di addestramento (training set)***: utilizzato per addestrare il modello
> - ***set di validazione (validation set)***: utilizzato durante lo sviluppo per confrontare diverse configurazioni del modello e scegliere gli iperparametri migliori
> - ***set di valutazione (test set)***: utilizzato per la valutazione finale delle prestazioni del modello
>
> Nel caso del k-NN:
> - il training set contiene i record memorizzati dal classificatore
> - il validation set viene utilizzato per confrontare diversi valori di $k$
> - il test set serve per stimare la capacità di generalizzazione finale del modello
>

> ***Ruolo del set di validazione.***  
Il set di validazione contiene esempi etichettati che:
> - non appartengono al training set
> - non vengono utilizzati per addestrare il classificatore
> - vengono usati per misurare la qualità delle diverse configurazioni del modello
>
> Nel k-NN, ad esempio, il valore di $k$ influenza direttamente il comportamento del classificatore:
> - valori piccoli di $k$ possono causare overfitting;
>- valori grandi di $k$ possono causare underfitting.
>
> Il validation set permette quindi di confrontare diversi valori di $k$ e scegliere quello che minimizza l’errore di classificazione su dati non usati durante l’addestramento.

---


### 10.11.9 Vantaggi e svantaggi del k-NN

---

#### *Vantaggi*  

1. ***Semplicità concettuale e implementazione***: il k-NN non richiede alcuna fase di costruzione del moedello, si addatta naturalmente a problemi multi-classe, e la sua logica è immediatamente comprensibile
2. ***Flessibilità dei confini di decisione***: rispetto agli alberi decisionali (confini rettangolari) o della regressione logistica, il k-NN può approssimare confini di classe di qualunque forma geometrica

#### *Svantaggi*  

1. ***Necessità di una metrica di distanza***: l'algoritmo non funziona senza una misura di similarità o distanza tra record, e la scelta di questa metrica non è sempre ovvia
2. ***Necessità di normalizzare***: la mancata normalizzazione porta a risultati incorretti
3. ***Sensibilità al rumore locale***: poiché la classificazione è determinata localmente (dai $k$ vicini più prossimi), un singolo punto rumoroso o mal etichettato nel set di addestramento può influenzare le previsioni in una zona dello spazio
4. ***Sensibilità agli attributi irrilevanti o correlati***: è sensibile alla presenza di attributi (feature) irrilevanti o correlati che falsificano le distanze tra i record
5. ***Complessità computazionale all'inferenza***: per classificare un nuovo esempio, il k-NN deve calcolare la distanza rispetto a tutti gli $N$ esempi del set di addestramento. Per dataset di grandi dimensioni (grandi $N$ o grande $d$, numero feature), questo può essere molto oneroso

---

### 10.11.10 Implementazione MATLAB: classificazione del dataset Iris con k-NN

```matlab
% Carica il dataset Iris (150 osservazioni, 4 feature, 3 classi)
load fisheriris
% Dopo questo comando sono disponibili:
%   meas   → matrice 150×4 delle misurazioni (le feature)
%   species → vettore 150×1 delle etichette di specie (il target)

% Creiamo un classificatore k-NN con k = 5 vicini
k = 5;
mdl = fitcknn(meas, species, ...
    'NumNeighbors', k, ...       % numero di vicini k
    'Standardize', true);         % normalizza le feature (Z-score, Lezione 11, Sezione 7.8.3)
% 'Standardize', true → ogni feature viene trasformata in modo che
% abbia media 0 e varianza 1 sul training set; questo risolve il
% problema della scala diversa tra le feature descritto in 10.11.7

% Applica una cross-validation a 10 fold
cv_mdl = crossval(mdl, 'KFold', 10);
% cv_mdl è un oggetto che contiene i 10 modelli addestrati su fold diversi

% Calcola l'errore di misclassificazione medio sui 10 fold
cv_loss = kfoldLoss(cv_mdl);
% cv_loss è la frazione di esempi classificati erroneamente
% (valore tra 0 e 1; 0 = nessun errore, 1 = tutti sbagliati)

% Calcola l'accuratezza percentuale
accuracy = (1 - cv_loss) * 100;
% Esempio: se cv_loss = 0.04, l'accuratezza è 96%

% Per errore di calssificazione e accuratezza, vedi 10.6.9

% Calcola la matrice di confusione
predicted_species = kfoldPredict(cv_mdl);
% kfoldPredict restituisce le predizioni per ogni osservazione,
% ottenute dal fold in cui quell'osservazione era nel test set

figure;
confusionchart(species, predicted_species);
% Visualizza la matrice di confusione:
%   righe → classi reali (ground truth)
%   colonne → classi predette
%   diagonale principale → predizioni corrette
%   fuori diagonale → errori di classificazione
```

> ***Ricorda.***
La procedura di cross-validation (vedi *Sezione 10.6.9*) si articola nei seguenti passi:
> 1. il dataset viene diviso in $k$ ***gruppi di uguali dimensioni***, chiamati ***fold***
> 2. il modello viene ***addestrato $k$ volte***
> 3. in ciascuna iterazione $i$ ($i$-esimo addestramento) ($i = 1,\ldots,k$)
>     - il fold $i$ viene usato come ***set di validazione temporaneo*** (ovvero set di test temporanei)
>     - i rimanenti $k-1$ fold vengono usati per l'***addestramento*** del modello
> 4. al termine delle $k$ iterazioni, si calcola la ***media delle performance*** del modello (es. accuratezza, F1) ottenute nelle $k$ iterazioni. 
>
> Questa media è la stima della qualità del modello

---

#### *Analisi del codice*  

Il codice mostra come utilizzare MATLAB per:
1. caricare il database Iris
2. costruire un classificatore ***k-NN***
3. applicare una ***cross-validation a 10 fold***
4. calcolare l'***errore di classificazione medio***
5. ricavare l'***accuratezza***
6. costruire una ***matrice di confusione***

L'esempio è utile perché mette insieme, in un'unica implementazione, i concetti teorici di: ***record / osservazione / esempio***, ***feature***, ***distanza euclidea***, ***normalizzazione***, ***validazione***, ***errore di classificazione***, ***cross-validation***.

> ***1. Caricamento del dataset Iris.***  
> ```matlab
> load fisheriris 
> ```
> Questo comando carica il dataset Iris, che contiene:
> - 150 ***osservazioni***
> - 4 ***feature numeriche*** 
> - 3 ***classi***
> 
> Dopo il caricamento, MATLAB rende disponibili due variabili:
> - `meas`, la matrice $150\times 4$ contenente le misurazioni, cioè le feature. Corrisponde, quindi, alla matrice $X\in\mathbb{R}^{150\times 4}$ degli input $\mathbf{x}^{(i)}$ delle 150 osservazioni, dove $i$ è l'$i$-esima osservazione 
> 
> $$X = \begin{pmatrix} \mathbf{x}^{(1)} \\ \mathbf{x}^{(2)} \\ \vdots \\ \vdots \\ \mathbf{x}^{(150)} \end{pmatrix} = \begin{pmatrix} x_1^{(1)} \quad x_2^{(1)} \quad x_3^{(1)} \quad x_4^{(1)} \\ x_1^{(2)} \quad x_2^{(2)} \quad x_3^{(2)} \quad x_4^{(2)} \\ \vdots \qquad \vdots \qquad \ddots \qquad \vdots \\ x_1^{(150)} \quad x_2^{(150)} \quad x_3^{(150)} \quad x_4^{(150)} \\\end{pmatrix} \in\mathbb{R}^{150 \times 4}$$
> 
> - `species` è il vettore $150\times 1$ contenente le etichette di classe, cioè i target. Corrisponde, quindi, al vettore dei target $y\in\mathbb{R}^{150\times 1}$ dei target $y^{(i)}$ delle 150 osservazioni, dove $i$ è l'$i$-esima osservazione. In questo contesto, quindi, l'$i$-esima componente del vettore $y$ è associata all'$i$-esima riga della matrice $X$. Pertanto, il vettore $y$ raccoglie tutti i target del dataset in corrispondenza degli input contenuti in $X$
> 
> $$y = \begin{pmatrix} y^{(1)} \\ y^{(2)} \\ \vdots \\ y^{(150)} \end{pmatrix} \in\mathbb{R}^{150\times 1}$$
> 
>> ***Interpretazione del dataset.***  
Ogni riga di `meas` rappresenta un ***record***, cioè un'osservazione del dataset. Ogni record p un vettore di feature $$\mathbf{x}^{(i)}\in\mathbb{R}^4$$ e la corrispondente etichetta in `species` rappresenta la specie dell'Iris associata a quel record. In altre parole, ogni osservazione ha la forma $$\left(\mathbf{x}^{(i)}, y^{(i)}\right)$$

> ***2. Costruzione del classificatore k-NN.***  
> ```matlab
> k = 5;
> mdl = fitcknn(meas, species, 'NumNeighbors', k, 'Standardize', true); 
> ```
>
>> ***Significato di `k = 5`.***  
Qui si fissa il valore di $k$ del classificatore k-NN: $k = 5$. Questa è una scelta dell'iperparametro del modello. 
>>
>> Ricorda che questa $k$ non ha nulla a che vedere con la $k$ della ***k-fold cross-validation***: sono due parametri diversi.
>> - `k = 5` nel k-NN: ***numero di vicini usati per classificare un nuovo esempio***
>> - `KFold = 10` nella cross-validation: ***numero di fold in cui è diviso il dataset, usati per stimare la qualità del modello***
>
>> ***Funzione `fitcknn`.***  
La funzione
>> ```matlab
>> fitcknn(meas, species, ...)
>> ```
>> costruisce un classificatore k-NN sui dati (set) di addestramento:
>> - `meas` è la matrice delle feature
>> - `species` è il vettore delle etichette
>>
>> Quindi il modello apprende direttamente dagli esempi del dataset.
>
>> ***Parametro `'NumNeighbors', k`.***  
Questo parametro imposta il numero di vicini da considerare: $$k = 5$$
>>
>> Quando un nuovo record dovrà essere classificato, il modello confronterà quel record con i $5$ punti più vicini nel set set di addestramento e gli assegnerà la classe più frequente tra loro.
>
>> ***Parametro `'Standardize', true`.***  
Questo parametro attiva la ***normalizzazione*** delle feature. 
>>
>> Nel k-NN è essenziale che le feature siano confrontabili, perché la classificazione dipende dalla distanza tra i punti nello spazio delle feature. Se le feature hanno scale diverse, una variabile può dominare la distanza e rendere le altre quasi irrilevanti. Con:
>> ```matlab
>> 'Standardize', true
>> ```
>> MATLAB applica una ***normalizzazione Z-score***, cioè trasforma ogni feature in modo che, sul set di addestramento, abbia:
>> - media $0$
>> - deviazione standard $1$
>> 
>> Questa operazione è una forma di normalizzazione utile per rendere le feature confrontabili, eliminando il problema della scala.
>>
>>> ***Osservazione.***  La normalizzazione viene calcolata ***sui dati di addestramento*** del modello che sta venendo costruito. Nel contesto della cross-validation, questo significa che la normalizzazione viene ***eseguita separatamente in ciascun fold***, usando solo i dati di addestramento di quel fold.
>
> In altre parole, l'oggetto `mdl` rappresenta il classificatore k-NN costruito da MATLAB tramite la funzione `fitcknn`. In particolare, `mdl` contiene:
> - il set di addestramento memorizzato dal classificatore
> - il valore di $k$, cioè il ***numero di nearest neighbors*** da considerare durante la classificazione di un nuovo record
> - le informazioni necessarie per calcolare la distanza tra i record
> - i parametri di normalizzazione (normalizzazione Z-score) delle feature
>
> Quando viene fornito un nuovo record $\mathbf{x}$, il classificatore:
> 1. normalizza il record usando gli stessi parametri (feature) calcolati sul training set
> 2. calcola la distanza tra $\mathbf{x}$ e tutti i record memorizzati
> 3. individua i $k$ record più vicini
> 4. assegna a $\mathbf{x}$ la classe ottenuta tramite voto di maggioranza
>
>> ***Ricorda.*** `mdl` corrisponde, in pratica, al classificatore k-NN: questo memorizza tutto il set di addestrameno e specifica che, questi dati, devono essere normalizzati. Inoltre, specifica il valore numerico k, ovvero il numero di vicini da considerare per la classificazione di un nuovo record.

> ***3. Cross-Validation a 10 fold.***
> ```matlab
> cv_mdl = crossval(mdl, 'KFold', 10);
> ```
> La funzione `crossval(...)` applica una ***cross-validation a 10 fold*** al classificatore `mdl`.
>
>> ***Cosa produce.***  
`cv_mdl` è un oggetto che rappresenta un modello validato tramite cross-validation. In pratica, MATLAB:
>> 1. divide il dataset in 10 fold
>> 2. addestra il modello 10 volte
>> 3. ad ogni iterazione (addestramento), usa 9 fold per l'addestramento e 1 fold per la validazione
>> 4. ripete il processo per tutti i fold
>> 5. conserva le informazioni necessarie per calcolare prestazioni medie e predizioni cross-validate
>
>> ***Collegamento con la teoria.***  
Questo corrisponde alla procedura teorica della k-fold cross-validation:
>> - ogni fold viene usato una volta come ***set di validazione temporaneo***
>> - gli altri $k - 1$ fold vengono usati per l'addestramento
>> - alla fine, si media la qualità ottenuta nelle varie iterazioni
>>
>> In questo caso:
>> - $k = 10$ fold per la cross-validation
>> - $k = 5$ vicini per il classificatore k-NN

> ***4. Calcolo dell'errore medio di classificazione.***  
> ```matlab
> cv_loss = kfoldLoss(cv_mdl);
> ```
> Questa funzione calcola la ***loss media*** della cross-validation. Nel caso della classificazione, `kfoldloss` restituisce la ***frazione di esempi classificati erroneamente***, cioè l'errore medio di classificazione sui fold. Quindi:
> - `cv_loss = 0` significa nessun errore
> - `cv_loss = 1` significa che tutti gli esempi sono stati classificati in modo errato
> 
> In termini teorici, questo corrisponde alla definizione di errore di classificazione come proporzione di predizioni sbagliate: 
> $$\text{Errore} = \frac{\text{numero di classificazioni errate}}{\text{numero totale di esempi}}$$ 
> oppure, in forma matematica: 
> $$\text{Errore} = \frac{1}{N} \sum_{i = 1}^{N} \mathbb{I}\left(\hat{y}^{(i)} \neq y^{(i)}\right)$$ 
> dove:
> - $N$ è il numero totale di esempi
> - $\hat{y}^{(i)}$ è la classe predetta
> - $y^{(i)}$ è la classe reale

> ***5. Calcolo dell’accuratezza***  
> ```matlab
> accuracy = (1 - cv_loss) * 100;
> ```
> L'accuratezza è il complemento dell'errore: 
> $$\text{Accuratezza} = 1 - \text{Errore}$$ 
> Moltiplicando per 100 si ottiene la percentuale.
>
>> ***Interpretazione.***  
Se, per esempio, `cv_loss = 0.04`, allora: 
> $$\text{accuracy} = (1 - 0.04)\; \cdot 100 = 96\%$$
>> 
>> Questo significa che, in media, il classificatore ha classificato correttamente il $96\%$ degli esempi durante la cross-validation.

> ***6. Predizione cross-validata***
> ```matlab
> predicted_species = kfoldPredict(cv_mdl);
> ```
> Questa funzione restituisce la classe predetta per ciascuna osservazione del dataset, utilizzando il fold in cui quell'osservazione era nel ruolo di validazione temporanea.
>
>> ***Significato.***  
Per ogni record del dataset:
>> - MATLAB prende il modello addestrato senza quel record
>> - usa quel modello per predire la sua classe
>> - raccoglie tutte le predizioni in `predicted_species`
>> 
>> Questo è molto utile perché permette di confrontare, osservazione per osservazione, la classe predetta con la classe reale.

> ***7. Matrice di confusione***
> ```matlab
> figure;
> confusionchart(species, predicted_species);
> ```
> Questa funzione visualizza la matrice di confusione tra le etichette reali `species` e le etichette predette `predicted_species`.
>
> <div align = "center">
>
> ![alt text](matrice_confusione-1.png)
>
> </div>
>
>> ***Interpretazione della matrice di confusione.***  
>> - le ***righe*** rappresentano le classi reali
>> - le ***colonne*** rappresentano le classi predette
>> - gli elementi sulla ***diagonale principale*** sono le classificazioni corrette
>> - gli elementi ***fuori diagonale*** rappresentano gli errori
>
>> ***Perché è utile.***  
La matrice di confusione non mostra soltanto "quanto" il modello sbaglia, ma anche ***in che modo*** sbaglia. Per esempio, può rivelare che:
>> - una classe viene confusa spesso con un’altra;
>> - una specie è riconosciuta quasi sempre correttamente;
>> - gli errori sono concentrati su una particolare coppia di classi.




<!-- ## *Approccio generale alla classificazione*

Il processo standard per costruire un sistema di classificazione si articola in cinque passi fondamentali, dalla costruzione del dataset fino all’applicazione del modello a nuovi dati. Tra questi passi, la scelta delle feature (caratteristiche) riveste un ruolo particolarmente critico, poiché influenza direttamente la qualità delle previsioni.

###  -->