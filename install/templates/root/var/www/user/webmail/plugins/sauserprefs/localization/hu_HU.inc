<?php
/* Author: Zoltan Nagy (nzolt|at|dotweb|dot|hu) */

$labels = array();
$labels['sauserprefs'] = 'Spam';
$labels['sauserprefssettings'] = 'Spam beállítás';
$labels['spamgeneralsettings'] = 'Általános beállítás';
$labels['spamthres'] = 'Küszöb szám';
$labels['spamsubject'] = 'Tárgy cimke';
$labels['spamsubjectblank'] = '(hagyja üressen ha egyik sem)';
$labels['spamlang'] = 'Üzenetek nyelve';
$labels['enabled'] = 'Bekapcsolva';
$labels['disabled'] = 'Kikapcsolva';
$labels['headers'] = 'Üzenet fejléc';
$labels['foldheaders'] = 'Több sor engedélyezése a fejlécben';
$labels['spamlevelstars'] = '\'Spam szint\' fejléc használata';
$labels['spamlevelchar'] = 'Spam szint karakter';
$labels['spamtests'] = 'Inernet Alapu Spam Tesztek';
$labels['userazor1'] = 'Razor v1 használata';
$labels['userazor2'] = 'Razor v2 használata';
$labels['usepyzor'] = 'Pyzor használata';
$labels['usebayes'] = 'Nyílt (naiv) Bayesian stílusú besorolás használata';
$labels['usedcc'] = 'DCC használata';
$labels['skiprblchecks'] = 'Valós idejű Feketelyuk Lista használata';
$labels['spamreportsettings'] = 'Beállítások jelentése';
$labels['spamreport0'] = 'A riport beágyazása az eredeti fejlécbe';
$labels['spamreport1'] = 'az eredeti MIME-ként csatolása a ripothoz';
$labels['spamreport2'] = 'az eredeti csak szöveg-ként csatolása a ripothoz';
$labels['spamaddressrules'] = 'Cím szabályok';
$labels['whitelist_from'] = 'Mailek elfogadása küldőtől';
$labels['blacklist_from'] = 'Mailek visszautasítása küldőtől';
$labels['whitelist_to'] = 'Címzettnek küldött mailek elfogadása';
$labels['addrule'] = 'Szabály hozzáadása';
$labels['rule'] = 'Szabály';
$labels['importfromaddressbook'] = 'Címek importálása a Címjegyzékből';
$labels['deleteall'] = 'Mindent törli';
$labels['autoscore'] = 'Auto';
$labels['defaultscore'] = 'Alapérték';
$labels['otherscore'] = 'Egyéb (%s)';
$labels['usedefault'] = 'Alabértékek visszaállítása';

$messages = array();
$messages['sauserprefchanged'] = 'Sikeresen megváltoztatta a spam beállításokat';
$messages['sauserpreffailed'] = 'Hiba: nem sikerült a spam beállítások megváltoztatása';
$messages['spamthresexp'] = 'Minden ami a küszöb alatti érték, spam-ként lesz jelölve. A küszöb értékének a növelése, növeli a bejutó spameket, de csökkenti a hamis spam jelölést';
$messages['spamlangexp'] = 'Válassza ki a nyelveket amilyen nyelvü leveleket vár. Minden érkező levél amely a nem megjelölt nyelven íródott, lehetséges spamként lesz kezelve.';
$messages['headersexp'] = 'A SpamAssassin fejlécet ad a levélhez mely információval szolgál az eredményről. Az alábbi beállításokkal konfigurálhatja ezeket a fejléceket.';
$messages['spamtestssexp'] = 'Néhány beállítás internet alapu szolgáltatást használ a spamek azonosítására. Válassza ki a használni kivántakat.';
$messages['spamreport'] = 'Mikor egy üzenet spamként kerül azonosításra, létrejön egy csatolt riport a tesztek és eredményeikből.';
$messages['autowhitelist'] = 'A Címjegyzékben található e-mail címek automatikusan hozzáadódnak a \'Mail Elfogadás -tól\'';
$messages['whitelistexp'] = 'A csillag karakter (*) használható helyettesítő karakterként a nagyobb rugalmasságért. pl. *@example.com vagy *@*.example.com';
$messages['spamaddressexists'] = 'Ehhez a címhez már létezik szabály';
$messages['spamenteraddress'] = 'Írja be a címet melyet szeretne hozzáadni';
$messages['spamaddresserror'] = 'Hiba: a cím érvénytelen';
$messages['spamaddressdelete'] = 'Biztosan törölni szeretné ezt a szabályt?';
$messages['spamaddressdeleteall'] = 'Biztosan törölni szeretné az összes cím szabályt?';
$messages['noaddressrules'] = 'Nem található cím szabály.';
$messages['importingaddresses'] = 'Címek importálása...';
$messages['usedefaultconfirm'] = 'Biztos, hogy vissza szeretné állítani az alapbeállítást? Ez törli az összes beállítást, ideértve a cím szabályokat is.';

?>