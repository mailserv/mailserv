<?php
/* Author : Matteo Cisilino http://matteo.cisilino.com/ */

$labels = array();
$labels['sauserprefs']  = 'Spam';
$labels['sauserprefssettings']  = 'Impostazioni spam';
$labels['spamgeneralsettings']  = 'Impostazioni generali';
$labels['spamthres']  = 'Punteggio valutazione';
$labels['spamsubject']  = 'Tag oggetto';
$labels['spamsubjectblank']  = '(lasciare in bianco se niente)';
$labels['spamlang']  = 'Lingue del messaggio';
$labels['enabled']  = 'Abilitato';
$labels['disabled']  = 'Disabilitato';
$labels['headers'] = 'Intestazioni messaggio';
$labels['foldheaders'] = 'Consenti più linee nell\'intestazione';
$labels['spamlevelstars'] = 'Usa instazione \'Spam Level\'';
$labels['spamlevelchar'] = 'carattere \'Spam level\'';
$labels['spamtests'] = 'Test spam su internet';
$labels['userazor1'] = 'Usa Razor v1';
$labels['userazor2'] = 'Usa Razor v2';
$labels['usepyzor'] = 'Usa Pyzor';
$labels['usebayes'] = 'Usa stile classificazione ingenua Bayesiana';
$labels['usedcc'] = 'Usa DCC';
$labels['skiprblchecks'] = 'Usa RBL (Realtime Blackhole List)';
$labels['spamreportsettings']  = 'Impostazioni dei rapporti';
$labels['spamreport0']  = 'Includi report nelle intestazioni del messaggio originale';
$labels['spamreport1']  = 'Includi il messaggio originale come allegato MIME al raporto';
$labels['spamreport2']  = 'Includi il messeggio originale come allegato TXT al rapporto';
$labels['spamaddressrules']  = 'Regole su indirizzi';
$labels['whitelist_from']  = 'Consenti DA ( From: )';
$labels['blacklist_from']  = 'Nega DA ( From: )';
$labels['whitelist_to']  = 'Consenti destinatiari ( To: )';
$labels['addrule']  = 'Aggiungi regola';
$labels['rule']  = 'Regola';
$labels['importfromaddressbook'] = 'Importa indirizzi dalla rubrica online';
$labels['deleteall'] = 'Cancella tutto';
$labels['autoscore'] = 'Automatico';
$labels['defaultscore'] = 'Punteggio standard';
$labels['otherscore'] = 'Altro (%s)';
$labels['usedefault'] = 'Ripristina le impostazioni iniziali';
$labels['langoptions'] = 'Opzioni Lingua';
$labels['help']  = 'Aiuto';

$messages = array();
$messages['sauserprefchanged'] = 'Cambiamenti applicati con successo';
$messages['sauserpreffailed'] = 'Errore: imposibile salvare i cambiamenti';
$messages['spamthresexp'] = 'Tutto quello che oltre passa il punteggio verrà segnalato come spam. Aumentare il punteggio significa aumentare i messaggi di spam non segnalati, ma riduce il richio di falsi positivi.';
$messages['spamlangexp'] = 'Selezionare tutte le lingue in cui ci si aspetta possa arrivare un messaggio. Tutti i messaggi che arriveranno in una lingua non selezionata saranno segnalati come spam.';
$messages['headersexp'] = 'SpamAssassin aggiunge delle intestazioni al messaggioriguardante il risultato dell\'analisi. Usare questa opzione per configurare queste intestazioni.';
$messages['spamtestssexp'] = 'Certi controlli utilizzano dei servizi internet per analizzare il messaggio. Selezionare quello che si vuole utilizzare:';
$messages['spamreport']  = 'Quando un messaggio viene identificato come spam viene creato un rapporto dei test ed il punteggio questo rapporto viene creato...';
$messages['autowhitelist'] = 'Gli indirizzi Email della Rubrica della Webmail vengono caricati automaticamente ed inseriti nella lista \'Consenti mail DA\'.';
$messages['whitelistexp'] = 'Un asterisco (*) può essere usato come carattere \'jolly\' per aumentare la flessibilità della regola. Ad esempio: *@dominio.com o *@*.dominio.com.';
$messages['spamaddressexists'] = 'Esiste già una regola per questo indirizzo';
$messages['spamenteraddress'] = 'Inserire un indirizzo da aggiungere';
$messages['spamaddresserror'] = 'Errore: Indirizzo invalido';
$messages['spamaddressdelete'] = 'Sicuro di voler CANCELLARE questa regola?';
$messages['spamaddressdeleteall'] = 'Sicuro di voler CANCELLARE TUTTI gli indirizzi della lista??';
$messages['noaddressrules'] = 'Nessuna regola trovata.';
$messages['importingaddresses'] = 'Importazione indirizzi...';
$messages['usedefaultconfirm'] = 'Sicuro di voler ripristinare le impostazioni iniziali ? Questa operazione CANCELLERA TUTTE LE IMPOSTAZIONI, incluse le regole per i messaggi!.';

?>