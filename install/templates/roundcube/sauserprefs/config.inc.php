<?php

/*
 +-----------------------------------------------------------------------+
 | SAUserPrefs configuration file                                        |
 |                                                                       |
 | This file is part of the RoundCube Webmail client                     |
 | Copyright (C) 2005-2009, RoundCube Dev. - Switzerland                 |
 | Licensed under the GNU GPL                                            |
 |                                                                       |
 +-----------------------------------------------------------------------+

*/

// spamassassin database settings
$rcmail_config['sauserprefs_db_dsnw'] = 'mysql://mailadmin:mailadmin@localhost/mail';

// PEAR database DSN for read only operations (if empty write database will be used)
// useful for database replication
$rcmail_config['sauserprefs_db_dsnr'] = '';

// use persistent db-connections
// beware this will not "always" work as expected
// see: http://www.php.net/manual/en/features.persistent-connections.php
$rcmail_config['sauserprefs_db_persistent'] = FALSE;

// table that holds user prefs
$rcmail_config['sauserprefs_sql_table_name'] = "userpref";

// name of the username field in the user prefs table
$rcmail_config['sauserprefs_sql_username_field'] = "username";

// name of the preference field in the user prefs table, holds the name of the preference
$rcmail_config['sauserprefs_sql_preference_field'] = "preference";

// name of the value field in the user prefs table, holds the value of the preference
$rcmail_config['sauserprefs_sql_value_field'] = "value";

// username of the "global" or default settings user in the database, normaly $GLOBAL or @GLOBAL
$rcmail_config['sauserprefs_global_userid'] = "@GLOBAL";

// enable the whitelists synchronisation, check README for more information
$rcmail_config['sauserprefs_whitelist_sync'] = FALSE;

// id of the address book to synchronise the whitelist with, null for default RoundCube address book
$rcmail_config['sauserprefs_whitelist_abook_id'] = null;

// don't allow these settings to be overriden by the user
// eg. $rcmail_config['sauserprefs_dont_override'] = array('required_score','rewrite_header Subject');
// to disable entire sections enter the secion name surrounded by braces. Sections are: general,tests,bayes,headers,report,addresses
// eg. $rcmail_config['sauserprefs_dont_override'] = array('{tests}');
$rcmail_config['sauserprefs_dont_override'] = array('{bayes}', '{tests}', '{headers}');

// default settings
// these are overridden by $GLOBAL and user settings from the database
$rcmail_config['sauserprefs_default_prefs'] = array(
									"required_score" => "5",
									"rewrite_header Subject" => "[SPAM _SCORE_]",
									"ok_languages" => "all",
									"ok_locales" => "all",
									"fold_headers" => "1",
									"add_header all Level" => "_STARS(*)_",
									"use_razor1" => "0",
									"use_razor2" => "0",
									"use_pyzor" => "0",
									"use_dcc" => "0",
									"use_bayes" => "1",
									"skip_rbl_checks" => "0",
									"report_safe" => "0",
									"bayes_auto_learn" => "1",
									"bayes_auto_learn_threshold_nonspam" => "0.1",
									"bayes_auto_learn_threshold_spam" => "12.0",
									"use_bayes_rules" => "1"
								);

// spam score increment - increment values in the the score threshold drop down by this, from 0 to 10
$rcmail_config['sauserprefs_score_inc'] = 1;

// delete user bayesian data stored in database
// the query can contain the following macros that will be expanded as follows:
//      %u is replaced with the username (from the session info)
// use an array to run multiple queries
// eg. $rcmail_config['sauserprefs_bayes_delete_query'] = array(
//												'DELETE FROM bayes_seen WHERE id IN (SELECT id FROM bayes_vars WHERE username = %u);',
//												'DELETE FROM bayes_token WHERE id IN (SELECT id FROM bayes_vars WHERE username = %u);',
//												'DELETE FROM bayes_vars WHERE username = %u;',
//												);
$rcmail_config['sauserprefs_bayes_delete_query'] = '';

// Override old or deprecated preferences: 'old name' => 'new name'
$rcmail_config['sauserprefs_deprecated_prefs'] = array(
												'required_hits' => 'required_score'
											);

// define languages
$rcmail_config['sauserprefs_languages'] = array(
									"af" => "Afrikaans",
									"sq" => "Albanian",
									"am" => "Amharic",
									"ar" => "Arabic",
									"hy" => "Armenian",
									"eu" => "Basque",
									"bs" => "Bosnian",
									"bg" => "Bulgarian",
									"be" => "Byelorussian",
									"ca" => "Catalan",
									"zh" => "Chinese",
									"hr" => "Croatian",
									"cs" => "Czech",
									"da" => "Danish",
									"nl" => "Dutch",
									"en" => "English",
									"eo" => "Esperanto",
									"et" => "Estonian",
									"fi" => "Finnish",
									"fr" => "French",
									"fy" => "Frisian",
									"ka" => "Georgian",
									"de" => "German",
									"el" => "Greek",
									"he" => "Hebrew",
									"hi" => "Hindi",
									"hu" => "Hungarian",
									"is" => "Icelandic",
									"id" => "Indonesian",
									"ga" => "Irish Gaelic",
									"it" => "Italian",
									"ja" => "Japanese",
									"ko" => "Korean",
									"la" => "Latin",
									"lv" => "Latvian",
									"lt" => "Lithuanian",
									"ms" => "Malay",
									"mr" => "Marathi",
									"ne" => "Nepali",
									"no" => "Norwegian",
									"fa" => "Persian",
									"pl" => "Polish",
									"pt" => "Portuguese",
									"qu" => "Quechua",
									"rm" => "Rhaeto-Romance",
									"ro" => "Romanian",
									"ru" => "Russian",
									"sa" => "Sanskrit",
									"sco" => "Scots",
									"gd" => "Scottish Gaelic",
									"sr" => "Serbian",
									"sk" => "Slovak",
									"sl" => "Slovenian",
									"es" => "Spanish",
									"sw" => "Swahili",
									"sv" => "Swedish",
									"tl" => "Tagalog",
									"ta" => "Tamil",
									"th" => "Thai",
									"tr" => "Turkish",
									"uk" => "Ukrainian",
									"vi" => "Vietnamese",
									"cy" => "Welsh",
									"yi" => "Yiddish"
								);
?>
