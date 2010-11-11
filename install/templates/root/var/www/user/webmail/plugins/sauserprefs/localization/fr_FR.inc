<?php
/* Author: magik_cypress */

$labels = array();
$labels['sauserprefs']  = 'Spam';
$labels['sauserprefssettings']  = 'Configuration des Spams';
$labels['spamgeneralsettings']  = 'Configuration principale';
$labels['spamthres']  = 'Seuil du score';
$labels['spamsubject']  = 'Tag sur le sujet';
$labels['spamsubjectblank']  = '(Laisser vide le champ)';
$labels['spamlang']  = 'Langue du message';
$labels['enabled']  = 'Activer';
$labels['disabled']  = 'Desactiver';
$labels['headers'] = 'Entete du message';
$labels['foldheaders'] = 'Autoriser plusieurs lignes dans les en-tetes';
$labels['spamlevelstars'] = 'Utiliser \'Niveau de Spam\' dans les en-tetes';
$labels['spamlevelchar'] = 'Caractere du niveau de spam';
$labels['spamtests'] = 'Service de spam externe';
$labels['userazor1'] = 'Utiliser Razor v1';
$labels['userazor2'] = 'Utiliser Razor v2';
$labels['usepyzor'] = 'Utiliser Pyzor';
$labels['usebayes'] = 'Utiliser naive Bayesian style classifier';
$labels['usedcc'] = 'Utiliser DCC';
$labels['skiprblchecks'] = 'Utiliser Realtime Blackhole List';
$labels['spamreportsettings']  = 'Rapport de configuration';
$labels['spamreport0']  = 'Inclure le rapport dans l\'en-tete du message original';
$labels['spamreport1']  = 'Inclure MIME Attachment dans l\'en-tete du message original';
$labels['spamreport2']  = 'Inclure le texte original dans le rapport';
$labels['spamaddressrules']  = 'Regels des adresses';
$labels['whitelist_from']  = 'Accepter les messages de';
$labels['blacklist_from']  = 'Rejeter les messages de';
$labels['whitelist_to']  = 'Accepter les messages envoye a';
$labels['addrule']  = 'Ajouter une regle';
$labels['rule']  = 'Regle';

$messages = array();
$messages['sauserprefchanged'] = 'Succes : modification de la configuration des spams';
$messages['sauserpreffailed'] = 'Erreur: aucun changement de la configuration des spams';
$messages['spamthresexp'] = 'Tout au-dessus du seuil est marque comme spam. L\'augmentation de ce seuil va augmenter la quantite de spam manquer, mais reduire le risque de faux positifs.';
$messages['spamlangexp'] = 'Selectionnez toutes les langues, tous les messages reçus qui sont ecrits dans des langues sélectionnees seront traites comme spam possible.';
$messages['headersexp'] = 'Les en-tetes des messages produit par SpamAssassin fournissent des informations sur les resultats. Utilisez les options ci-dessous pour configurer ces en-tetes.';
$messages['spamtestssexp'] = 'Certains controles de l\'utilisation des services bases sur Internet peuvent aider a identifier le spam. Selectionnez ceux que vous souhaitez utiliser:';
$messages['spamreport']  = 'Quand un message est identifie comme spam, un rapport de tous les essais et les évaluations attribuées est cree ...';
$messages['autowhitelist'] = 'Les adresses e-mail dans votre carnet d\'adresses sont automatiquement ajoutees a la liste \'accepter le courrier provenant de\'.';
$messages['whitelistexp'] = 'Un asterisque (*) peut être utilise comme un joker pour une plus grande flexibilite. Par exemple: *@example.com or *@*.example.com.';
$messages['spamaddressexists'] = 'Une regle qui existe deja pour cette adresse';
$messages['spamenteraddress'] = 'S\'il vous plait entrer une adresse a ajouter';
$messages['spamaddresserror'] = 'Erreur: L\'adresse semble invalide';
$messages['spamaddressdelete'] = 'Etes vous sur de vouloir supprimer cette regle?';
$messages['noaddressrules'] = 'Pas de regle pour cette d\'adresse trouvee.';

?>