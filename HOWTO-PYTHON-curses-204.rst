.. highlight:: python
        :linenothreshold: 4

.. _curses-howto:

**********************************
  Curses Programming with Python
**********************************

:Authore: A.M. Kuchling, Eric S. Raymond
:Release: 2.04
:Testo originale: `https://docs.python.org/3.8/howto/curses.html <https://docs.python.org/3.8/howto/curses.html>`_
:Traduzione: `Lewis <https://leucalipto.blogspot.com>`_
:Data: 7 Agosto 2020

.. topic:: Oggetto

   Questo documento descrive come usare il modulo curses per controllare
   interfacce in modalità testuale.
      

Che cosa è la libreria curses ? 
===============================

La libreria :mod:curses fornisce una struttura per disegnare e gestire mediante tastiera interfacce testuali su terminali basati su testo; questi terminali includono VT100s, la console linux e vari simulatori di terminali forniti da vari software.
I terminali a schermo supportano vari codici di controllo per svolgere operazioni usuali come muovere il cursore, scorrere lo schermo e cancellare i campi. Terminali differenti usano codici di controllo molto diversi fra loro, e spesso hanno il loro piccole stranezze.

In un mondo di display grafici, uno potrebbe domandare “Perchè disturbarsi ?” È vero che terminali con display a caratteri sono tecnologia obsoleta, ma ci sono nicchie nelle quali avere la capacità di fare delle belle cose con questi strumenti ha ancora un valore. Una di queste nicchie sono gli Unix embedded sui quali non gira un server X. Un'altra nicchia sono i tools per l'installazione dei sistemi operativi oppure i software di configurazione del kernel che devono girare prima che il sistema grafico sia disponibile.

La libreria `curses <https://docs.python.org/3.8/library/curses.html#module-curses>`_ ha funzionalità abbastanza spartane e fornisce al programmatore l'astrazione di un display che puo' contenere finestre di testo multiple e non sovrapponibili. Il contenuto di una finestra puo' essere cambiato in vari modi - aggiungendo testo, cancellandolo o cambiandone l'aspetto - e la libreria curses deciderà quali codici di controllo dovranno essere inviati al terminale per produrre il giusto output. La curses non fornisce molti concetti delle interfacce utenti come bottoni, checkboxes o finestre di dialogo. Se hai bisogno di queste caratteristiche considera l'uso della libreria `Urwid <https://pypi.org/project/urwid/>`_.

La libreria curses è stata originariamente scritta per gli `Unix BSD <https://it.wikipedia.org/wiki/Berkeley_Software_Distribution>`_, successivamente le versioni `System V <https://leucalipto.blogspot.com/>`_ di `Unix <https://it.wikipedia.org/wiki/Unix>`_ dell'AT&T hanno aggiunto molte nuove funzioni e miglioramenti. La versione BSD delle curses non è più mantenuta ed è stata rimpiazzata dalle ncurses, che sono un'implementazione open-source della vecchia versione di AT&T. Se stai usando uno unix open-source come `Linux <https://it.wikipedia.org/wiki/Linux>`_ o `FreeBSD <https://it.wikipedia.org/wiki/FreeBSD>`_ il tuo sistema ha quasi sicuramente le nCurses. Da quando la maggior parte degli UNIX commerciali correnti sono basati sul codice di SYSTEM V, tutte le funzioni descritte qui saranno disponibili. Le vecchie versioni delle curses che sono a bordo di UNIX proprietari possono comunque non supportare tutte le caratteristiche.

La versione WINDOWS di Python non include il modulo :mod:curses.  C'è comunque un porting disponibile di curses chiamato `UniCurses <https://sourceforge.net/projects/pyunicurses/>`_. Potresti anche provare `“The Console Module” <http://effbot.org/zone/console-index.htm>`_ scritto da Fredrik Lundh, il quale non usa le stessi API delle curses ma fornisce un output di testo indirizzabile in base al cursore e un pieno supporto a mouse e tastiera per l'input. 


Il modulo curses di Python
--------------------------

Le curses di Python è semplicemente un wrapper  delle funzioni C fornite dalla curses; se hai già familiarità con le curses del C sarà abbastanza semplice trasferire quella conoscenza a Python. La maggior differenza è che Python rende le cose più semplici unendo differenti funzioni C come per esempio :c:func:`addstr`, :c:func:`mvaddstr` e :c:func:`mvwaddstr` nel semplice metodo :meth:`~curses.window.addstr`.  Vedremo questo in dettaglio più avanti.

Questo HOWTO è un'introduzione alla scrittura di programmi con le curses in Python. Non è una guida completa alle API delle curses, per questo devi vedere la sezione della guida alle librerie di ncurses e le man page delle ncurses in C (qui un howto in Italiano). Ti darà comunque delle idee di base.


Avviare e chiudere un applicazione con le curses
================================================

Prima di fare qualsisasi cosa, le curses devono essere inizializzate. Questo viene fatto chiamando la funzione :func:`curses.initscr`  la quale determinerà il tipo di terminale, invierà il codice di setup richiesto al terminale e creerà varie strutture di dati interne. Se l'inizializzazione con :func:`initscr` viene completata con successo ritorna un oggetto finestra che rappresenta l'intero schermo, questo è solitamente chiamato ``stdscr`` dopo il nome della corrispondente variabile C. ::

   import curses
   stdscr = curses.initscr()

Di solito le applicazioni curses disabilitano l'echo a schermo dei tasti in modo da rendere possibile la lettura di tasti e visualizzarli solo in certe circostanze. Questo richiede di richiamara la funzione :func:`~curses.noecho` ::

   curses.noecho()

Le applicazioni di solito hanno bisogno di reagire istantaneamente alla pressione dei tasti senza che ci sia la necessità di premere il Enter, questo è chiamata la modalità cbreak, che è il contrario della usuale modalità di input a buffer. ::

   curses.cbreak()

I terminali di solito ritornano tasti speciali, come per esempio i tasti per spostare il cursore oppure i tasti di navigazione Pg UP e HOME così come sequenze di escape multibyte. Tu potresti scrivere la tua applicazione che si aspetta queste sequenze di tasti e li processa di consueguenza, ma le curses possono farlo per te, ritornando valori speciali come :const:`curses.KEY_LEFT`. Per fare questo devi abilitare la modalità keypad:  ::

   stdscr.keypad(True)

Terminare un'applicazione curses è più facile che farla partire, ti basta
chiamare: ::

   curses.nocbreak()
   stdscr.keypad(False)
   curses.echo()

Per diabilitare la configurazione curses-friendly del terminale. Quindi chiamare la funzione :func:`~curses.endwin` per riportare il terminale alla sua modalità originale. ::

   curses.endwin()

Un problema comune quando si fa debugging di un'applicazione scritta in curses è che quando muore non riesce a ripristinare il terminale al suo stato originale lasciandolo piuttosto incasinato. In Python questo succede comunemente quando il to codice è buggato e solleva un'eccezione non gestita. I tasti, per esempio, avendo l'echo disattivato non vengono visualizzati sullo schermo il che rende l'uso della shell difficoltoso.
In Python puoi evitare questo tipo di problemi e fare debugging più semplice importando la funzione :func:`~curses.wrapper`, usandola così: ::

   from curses import wrapper
   
   # NDT ho aggiunto uno sleep rispetto all'originale
   # perché il ciclo for è troppo veloce e non si riesce a vedere l'output
   from time import sleep 
   
   def main(stdscr):
      # Pulisce lo schermo
      stdscr.clear()

      # Questo emette un'eccezione ZeroDivisionError quando i == 10.
      for i in range(0, 11):
         sleep(1)
         v = i-10
         stdscr.addstr(i, 0, '10 divided by {} is {}'.format(v, 10/v))

      stdscr.refresh()
      stdscr.getkey()

   wrapper(main)



La funzione :func:`~curses.wrapper` prende come argomento un oggetto chiamabile e fa le inizializzazioni appena descritte, inoltre inizializza i colori se il supporto ai colori è presente. :func:`wrapper` quindi lancia l'oggetto chiamabile che gli hai passato. Una volta che l'oggetto chiamato ritorna, :func:`wrapper` ripristinerà lo stato originale del terminale. La chiamata viene effettuata mediante il costrutto :keyword:`try`... :keyword:`except`  che intercetta le eccezioni, ripristina lo stato del terminale e quindi emette le eccezioni. Quindi il tuo terminale non rimane in uno stato di inconsistenza e puoi leggere eccezioni e traceback. 


Finestre e pad
==============

Le finestre sono la base dello strato di astrazione nelle curses. Un oggetto finestra è rappresentato da un'area rettangolare dello schermo e supporta metodi per stampare testo, cancellarlo, permettere all'utente di inserire stringhe e così via.
L'oggetto ``stdscr`` ritornato dalla funzione :func:`~curses.initscr` è un oggetto finestra che copre l'intero schermo. Molti programmi possono aver bisogno solo di una singola finestra ma il programmatore potrebbe voler dividere lo schermo in finestre più piccole in modo da ridisegnare o ripulirle separatamente. La funzione :func:`~curses.newwin` crea una nuova finestra di una data misura ritornando il nuovo oggetto finestra. ::


   begin_x = 20; begin_y = 7
   height = 5; width = 40
   win = curses.newwin(height, width, begin_y, begin_x)

Nota bene la stranezza del sistema di coordinate usato dalle curses. Infatti le coordinate sono sempre passate nell'ordine Y,X e l'angolo della finestra in alto a sinistra corrisponde alle coordinate (0,0). Questo rompe la normale convenzione di delle coordinate dove la X solitamente è il primo valore. Questa è la maggiore differenza che le curses hanno rispetto ad altre applicazioni. Ma purtroppo è quella parte delle curses che è stata scritta per prima ed ora è troppo tardi per cambiare le cose. 

La tua applicazione può determinare la misura dello schermo mediante l'uso delle variabili :data:`curses.LINES` e :data:`curses.COLS` in modo da avere la misura degli assi Y e X. Quindi le coordinate si estenderanno da ``(0,0)`` a ``(curses.LINE - 1, curses.COLS - 1)``.
Quando usi un metodo per mostrare o cancellare testo, esso non verrà mostrato immediatamente sullo schermo. Infatti dovrai chiamare il metodo :meth:`~curses.window.refresh` per aggiornare l'oggetto finestra sullo schermo.

Questo perché le curses originariamente sono state scritte per terminali che erano connessi a 300-baud; con questi terminali era molto importante minimizzare il tempo richiesto per rinfrescare lo schermo. Infatti le curses accumulano i cambiamenti dello schermo ma li mostrano nel modo più efficente possibile quando viene chiamata la :meth:`refresh`. Per esempio il tuo software può mostrare del testo sullo schermo e successivamente cancellare la finestra, ma non c'è nessun bisogno di inviare il testo originale visto che non verrà mai mostrato.

In pratica, dicendo esplicitamente alle curses di ridisegnare la finestra non rende molto più complicata la programmazione con le curses. Molti programmi entrano in un vortice di attività e quindi in pausa in attesa di qualche genere di azione da parte dell'utente o della pressione di un tasto. Tutto ciò che devi fare è essere sicuro è stato rinfrescato prima della pausa per aspettare l'input dell'utente prima chiamando ``stdscr.refresh()`` o o il metodo :meth:`refresh` sulla finestra rilevante.

Un pad è un caso speciale di finestra il quale può essere più largo della dimensione dello schermo mostrato quindi solo una parte del pad puo' essere mostrato per volta. Creare un pad richiede l'altezza e la larghezza del pad stesso, mentre rinfrescare sullo schermo un pad richiede dare le coordinate dell'area sullo schermo dove la sottosezione del pad verrà mostrata. ::

   pad = curses.newpad(100, 100)
   # Questi cicli riempiono il pad di lettere; addch()
   # è spiegata nella prossima sezione
   for y in range(0, 99):
       for x in range(0, 99):
           pad.addch(y,x, ord('a') + (x*x+y*y) % 26)

   #  Mostra una sezione di un pad in mezzo allo schermo
   # (0,0) : coordinate dell'angolo in alto a sinistra dell'area del pad da mostrare
   # (5,5) : coordinate dell'angolo in alto a sinistra dell'area della finestra che 
   #            deve essere riempita
   # (20, 75) : coordinate of dell'angolo in basso a destra dell'area della finestre 
   #          : riepmpita riempita col contenuto di un pad
   pad.refresh( 0,0, 5,5, 20,75)

La chiamata a :meth:`refresh` mostra una sezione del pad in un rettangolo che
sullo schermo si
estende dalle coordinate (5,5) alle coordinate (20,75); l'angolo in alto a
sinistra della sezione mostrata ha le coordinate (0,0) del pad. Aldilà di questa
differenza, i pads sono esattamente come normali finestre e supportano gli
estessi metodi.  

Se hai pads e finestre multiple c'è un modo più efficiente di aggiornare lo schermo così da evitare lo sfarffallio ed ogni sua parte è aggiornata correttamente. :meth:`refresh` attualmente fa due cose:

1) Chiama il metodo :meth:`~curses.window.noutrefresh` di ogni finestra per aggiornare la sottostante struttura dati che rappresenta lo stato dello schermo desiderato.
2) Chiama la funzione :func:`~curses.doupdate` in modo che lo schermo fisico possa cambiare per adattarsi allo stato desiderata contenuto nella struttura dati.

Piuttosto puoi chiamare :meth:`noutrefresh` su un numero di finestre per aggiornare la struttura dati, e quindi chiamare :func:`doupdate` per aggiornare lo schermo.


Stampare del testo sullo schermo
================================

La libreria curses Dal punto di vista di un programmatore C puo' apparire come un groviglio incasinato di funzioni, non è proprio così. Per esempio :c:func:`addstr` mostra una stringa alla posizione attuale del cursore nella finestra ``stdscr``, mentre :c:func:`mvaddstr` prima si sposta a date coordinate y,x e poi stampa la stringa. :c:func:`waddstr` è come :c:func:`addstr`, ma permette di specificare una finestra da usare al posto di usare ``stdscr`` di default. :c:func:`mvwaddstr` permette di specificare sia la finestra che le coordinate.

Fortunatamente in Python tutti questi dettagli sono nascosti. ``stdscr`` è un oggetto finestra come ogni altro, e metodi come :meth:`~curses.window.addstr` accettano multiple forme di argomenti. Di solito ci sono quattro differenti forme.

+---------------------------------+-----------------------------------------------+
| Forma                           | Descrizione                                   |
+=================================+===============================================+
| *str* o  *ch*                   | Stampa la stringa *str* or il carattere *ch*  |
|                                 | alla posizione corrente                       |
+---------------------------------+-----------------------------------------------+
| *str* o  *ch*, *attr*           | Stampa la stringa *str* o il carattere *ch*,  |
|                                 | usando l'attrobuto *ottr* alla poszione       |
|                                 | corrent                                       |
+---------------------------------+-----------------------------------------------+
| *y*, *x*, *str* o  *ch*         | Si muove alla posizione *y,x* all'interno     |
|                                 | della finestra e stampa *str* o *ch*          |
+---------------------------------+-----------------------------------------------+
| *y*, *x*, *str* o *ch*, *attr*  | Si muove alla poszione *y,x* all'interno della|
|                                 | finestra e stampa *str* o *ch* usando         |
|                                 | l'attributo *ottr*                            |
+---------------------------------+-----------------------------------------------+

Gli attributi permettono di stampare testo in forma evidenziata come per esempio grassetto, sottlineato, reverse code, o a colori. Questi verranno spiegati più in dettaglio nella prossima sotto sezione. 

Il metodo :meth:`~curses.window.addstr` prende una stringa o una stringa di byte come valore da stampare. Il contenuto delle stringhe di byte vengono inviate al terminale così come sono. Le stringhe sono codificate in bytes usando il valore dell'attributo :attr:`encoding` della finestra; questo tralascia il sistema di encoding di default  ritornato dalla funzione :func:`locale.getpreferredencoding`.

I metodi :meth:`~curses.window.addch` prendono un carattere, che può essere una stringa di lunghezza 1, un stringa di byte di lunghezza 1, o un intero.

Le costansti sono fornite per estensione dei caratteri, queste costanti sono interi più grandi di 255. Per esempio, :const:`ACS_PLMINUS` è un simbolo +/-, e :const:`ACS_ULCORNER` è l'angolo in alto a sinistra di un quadrato (pratico per disegnare bordi). Ovviamente puoi anche usare i caratteri unicode appropriati.

Le finestre ricordano dove il cursore è rimasto dall'ultima operazione, così se non indichi le coordinate *y,x*, la stringa o il carattere saranno stampati ovunque sia terminata l'ultima operazione. Puoi anche spostare il cursore con il metodo ``move(y,x)``. Dato che alcuni terminali mostrano sempre il cursore lampeggiante, potresti volerlo spostare in una poszione che non distrae l'utente;  potrebbe essere elemento di confusione vedere il cursore lampeggiante in una poszione casuale sullo schermo.

Se il tuo software non ha per nulla bisogno del cursore che lampeggia puoi chiamare ``curs_set(False)`` per renderlo invisibile. Per compatibilità con altre versioni di curses c'è la funzione ``leaveok(bool)`` che è un alias di :func:`~curses.curs_set`. Se *bool* è true le curses proveranno a disabilitare il lampeggìo del cursore e non ti dovrai preoccupare di lasciarlo in posizioni strane.


Attributi e colori
------------------


I caratteri si possono stampate in modi diversi. Le linee di status in un'applicazione testuale sono solitamente mostrate in "reverse video", o un visualizzatere di testo può aver bisogno di evidenziare certe parole. Le curses supportano tutto questo permettendoti di specificare un attributo per ogni cella dello schermo.

Un attributo è un intero e ogni bit rappresenta un differente attirbuto. Puoi provare a stampare testo impostando multipli bit attributi, ma le curses non ti garantiscono che tutte le possibili combinazioni siano disponibili, o che esse siano differenti da un punto di vista visivo. Ciò dipende dall'abilità nell'usare il terminale, quindi è meglio definire con chiarezza gli attributi più comunemente disponibili, ecco la lista.

+----------------------+--------------------------------------+
| Attributo            | Descrizione                          |
+======================+======================================+
| :const:`A_BLINK`     | Testo lampeggiante                   |
+----------------------+--------------------------------------+
| :const:`A_BOLD`      | Testo in grassetto                   |
+----------------------+--------------------------------------+
| :const:`A_DIM`       | Testo mezzo in grassetto             |
+----------------------+--------------------------------------+
| :const:`A_REVERSE`   | Testo in modalità reverse-video      |
+----------------------+--------------------------------------+
| :const:`A_STANDOUT`  | La modalità migliore disponibile     |
+----------------------+--------------------------------------+
| :const:`A_UNDERLINE` | Testo sottolineato                   |
+----------------------+--------------------------------------+

Quindi, per stampare una status line in reverse-video sulla prima linea in alto sullo schermo questo è il codice::

   stdscr.addstr(0, 0, "Modalità corrente: modo scrittura",
                 curses.A_REVERSE)
   stdscr.refresh()

La libreria curses supporta anche i colori nei terminali che li hanno. Il terminale più comune è probabilmente la console Linux, seguita da color xterms.
Per usare i colori bisogna chiamare la funziona :func:`~curses.start_color` e subito dopo chiamare :func:`~curses.initscr`, per inizializzare il set di colori di default (la funzione :func:`curses.wrapper` lo fa automaticamente). Una volta fatto la funzione :func:`~curses.has_colors` ritornerà TRUE se il terminale in uso è in grado di stampare i colori. (Nota: le curses usano la parola americana 'color' anzichè quella Britannica Canadese 'colour'. Se sei abituato ad usare la parola Inglese Britannica dovrai rassegnarti a fare errori per questo insieme di funzioni.)

La libreria curses mantiene un numero finito di coppie di colori, contenenti un colore per il testo (foreground color) e uno per lo sfondo del testo (background color). Per avere il valore dell'attributo corrispondente alla coppia di colori devi chiamare la funzione :func:`~curses.color_pair`; ciò puo' essere a livello di bit con altri attributi come per esempio :const:`A_REVERSE`, ma di nuovo, queste combinazioni non sono garantite come funzionanti su tutti i terminali.

Questo esempio mostra un linea di testo che usa una coppia di colori 1::

   stdscr.addstr("Bel testo", curses.color_pair(1))
   stdscr.refresh()

Come già detto, una coppia di colori consiste di un colore testo (foreground) e di un colore di sfondo (background). La funzione ``init_pair(n, f, b)`` cambia la definizione di coppia di colori *n* in colore del testo f (foreground ndt) e colore di sfondo b (background ndt). La coppia di colore 0 è hard-wired (codificata nei chip ndt) a bianco su nero e non può essere cambiata. 

I colori sono numerati e la funzione :func:`start_color` inizializza gli 8 colori di base quando viene attivata la modalità colore. I colori sono: 0:nero, 1:rosso, 2:verde, 3:giallo, 4:blu, 5:magenta, 6:azzurro e 7:bianco. Il modulo :mod:`curses` definisce delle costanti per ognuno di questi colori: :const:`curses.COLOR_BLACK` (nero ndt), :const:`curses.COLOR_RED` (rosso ndt) e così via. 
Adesso mettiamo tutto insieme. Per cambiare dal colore 1 a colore rosso per il testo e bianco per lo sfondo il codice è: ::

   curses.init_pair(1, curses.COLOR_RED, curses.COLOR_WHITE)

Quando cambi un coppia di colori, qualsiasi testo già stampato che usa quella coppia di colori cambierà nei nuovi colori. Puoi anche cambiare il nuovo testo in questo colore con::

   stdscr.addstr(0,0, "RED ALERT!", curses.color_pair(1))

Terminali particolarmente evoluti possono cambiare le definizioni dei colori in un dato volore RGB. Questo ti permetterà di cambiare il colore 1, che di solito è rosso, in porpora o blue o qualsiasi altro colore ti piaccia. Sfortunatamente la console linux non supporta questa caratteristica quindi non possiamo provare o darti degli esempi di codice. Comunque puoi fare un test per vedere se il tuo terminale supporta questa caratteristica puoi chiamare la funzionae :func:`~curses.can_change_color`, la quale ritorna ``True`` se il terminale è compatibile. Se sei abbastanza fortunato da avere un terminale così figo, consulta la man pager di sistema per avere maggiori informazioni.


Input da utente
===============

Le librerie curses del C offrono un meccanismo di input molto semplice. Il modulo :mod:`curses` di Python aggiunge un widget per l'input testuale di base. (Altre librerie come per esempio `Urwid <https://pypi.org/project/urwid/>`_ hanno una collezione di widget più estesa.)

Ci sono due metodi per ottenere input da una finestra:

* :meth:`~curses.window.getch` aggiorna lo schermo e quindi aspetta che l'utente prema un tasto.  Se precedentemente è stata chiama la funzione :func:`~curses.echo` allora stampa a schermo il tasto premuto. In alternativa puoi anche spostare il cursore verso una coordinata specifica prima della pausa.

* :meth:`~curses.window.getkey` fa la stessa cosa ma converte l'intero in stringa. Singoli caratteri vengono restituiti come stringhe da 1 solo carattere, e tasti speciali come i tasti funzione restituiscono stringhe più lunghe contenenti nomi dei tasti come ``KEY_UP`` o ``^G``.

É possibile evitare di aspettare l'input dell'utente usando il metodo window :meth:`~curses.window.nodelay`. Dopo ``nodelay(True)``, :meth:`getch` e :meth:`getkey` per rendere la finestra non bloccante (non-blocking). Al segnale di nessun input si rende disponibile, il metodo :meth:`getch` restituisce ``curses.ERR`` (un valore di -1) e il metodo :meth:`getkey` emette un'eccezzione. C'è anche la funzione :func:`~curses.halfdelay`, che infatti puo' essere usata per impostare un timer per ogni metodo :meth:`getch`; se nessun input diventa disponibile all'interno di uno specifico ritardo (misurato in decimi di secondo), le curses emetteno un'eccezzione.

Il metodo :meth:`getch` restituisce un intero; se è tra 0 e 255, rappresenta il codice asci di un tasto premuto. Valori più grandi di 255 sono tasti speciali come Page Up, Home, o tasti per lo spostamento del cursore. Puoi confrontare i valori di ritorno a costanti come :const:`curses.KEY_PPAGE`, :const:`curses.KEY_HOME`, oppure :const:`curses.KEY_LEFT`. Il ciclio principale del tuo programma sarà qualcosa come questo::

   while True:
       c = stdscr.getch()
       if c == ord('p'):
           PrintDocument()
       elif c == ord('q'):
           break  # ESce dal ciclo while
       elif c == curses.KEY_HOME:
           x = y = 0

Il modulo :mod:`curses.ascii`  fornisce funzioni appartenenti alla classe ASCII che prendono come argomento o un intero on un carattere stringa; queste possono essere utili nello scrivere test più leggibili in questo genere di cicli. Esso fornisce anche funzioni di conversione per prendono come argomento o un intero o una stringa di 1 carattere e restituire lo stesso tipo. Per esempio, :func:`curses.ascii.ctrl` ritornano il carattere di controllo corrispondente al suo argomento.

C'è anche un metodo per ottenere un'intera stringa, :meth:`~curses.window.getstr`. Non è molto usato perché la sua funzionalità è abbastanza limitata; gli unici tasti editabili disponibili sono il backspace e l'invio, che sono alla fine della stringa. In alternativa può essere limitato ad un numero fisso di caratteri. ::

   curses.echo()            # Enable echoing of characters

   # ottiene una stringa di 15 caratteri col cursore sulla linea in cima
   s = stdscr.getstr(0,0, 15)


Il modulo :mod:`curses.textpad` fornisce un riquadro di testo che supporta un insieme di keybinding simile a quelli usati in Emacs. Vari metodi della classe :class:`curses.textpad.Textbox` supportano l'editing con la validazione dell'insierimento dati e la raccolta dei risultati con o senza i trailing spaces (ndt i trailing spaces sono gli spazi in cima o in fondo ad una parola, possono però anche essere tabs \t, ritorni di carello \r e altri). Ecco un esempio:: 

   import curses
   from curses.textpad import Textbox, rectangle

   def main(stdscr):
       stdscr.addstr(0, 0, "Inserisci un messaggio IM: (poi Ctrl-G per inviare)")

       editwin = curses.newwin(5,30, 2,1)
       rectangle(stdscr, 1,0, 1+5+1, 1+30+1)
       stdscr.refresh()

       box = Textbox(editwin)

       # permette all'utente di inserire i dati fino a quando non preme Ctrl-G
       box.edit()

       # ottiene il contenuto risultante
       message = box.gather()

Per maggiori dettagli leggi la documentazione ufficiale :mod:`curses.textpad` 


Per maggiori informazioni
=========================

Questo HOWTO non copre concetti avanzati, come per esempio leggere i contenuti dello schermo o catturare gli eventi del mouse all'interno di un xterm, ma la pagina :mod:`curses` della libreria di Python è ragionevolmente completa. Faresti bene a dargli un occhio.

Se hai qualche dubbio sui dettagli del comportamento delle funzioni del modulo curses consulta la pagina del manuale dell'implementazione curses che stai usando. chesia la ncurses o di qualche unix proprietario. La pagina del manuale copre tutte le stranezze che possano venirti in mente, oltre che fornirti una completa lista di tutte le funzioni, attributi, e i caratteri :const:`ACS_\*` disponibili. 

Dato che le API delle librerie curses sono troppo ampie alcune funzioni non sono supportate in ambiente Python. Spesso non perché sia difficile l'implementazione ma piuttosto perchè nessuno ne ha mai avuto bisogno fino ad oggi. Inoltre Python ancora non supporta il menu libreria associato con le ncurses. 
Patch che aggiungono questo tipo di supporto sono molto apprezzate; vedi `the Python Developer's Guide <https://devguide.python.org/>`_ per saperne di più so come inviare patch a Python.

* `Scrivere programmi con le NCURRSES (in Inglese) <http://invisible-island.net/ncurses/ncurses-intro.html>`_:
  un tutorial un po' prolisso per programmatori in C.
* `La pagine di manuale nCurses in Inglese  <https://linux.die.net/man/3/ncurses>`_
* `Le FAQ in inglese  <http://invisible-island.net/ncurses/ncurses.faq.html>`_
* `"Usa le curses... senza sbattersi" <https://www.youtube.com/watch?v=eN1eZtjLEnU>`_:
  il video in Inglese del PyCon 2013 sul controllo dei terminali usando le curses oppure Urwid.
* `"Console Applications with Urwid" <http://www.pyvideo.org/video/1568/console-applications-with-urwid>`_:
  Video in Inglese di un PyCon CA 2012 che mostra alcune applicazioni scritte usando Urwid.
