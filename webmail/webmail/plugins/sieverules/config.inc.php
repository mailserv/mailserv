<?php

/*
 +-----------------------------------------------------------------------+
 | SieveRules configuration file                                         |
 |                                                                       |
 | This file is part of the RoundCube Webmail client                     |
 | Copyright (C) 2005-2009, RoundCube Dev. - Switzerland                 |
 | Licensed under the GNU GPL                                            |
 |                                                                       |
 +-----------------------------------------------------------------------+

*/

// managesieve server address, use %h for user's IMAP hostname
$rcmail_config['sieverules_host'] = 'localhost';

// managesieve server port
$rcmail_config['sieverules_port'] = 2000;

// enable TLS for managesieve server connection
$rcmail_config['sieverules_usetls'] = FALSE;

// folder delimiter - if your sieve system uses a different folder delimiter to
// your IMAP server set it here, otherwise leave as null to use IMAP delimiter
$rcmail_config['sieverules_folder_delimiter'] = null;

// Sieve RFC says that we should use UTF-8 endcoding for mailbox names,
// but some implementations does not covert UTF-8 to modified UTF-7.
// set to null for default behaviour
$rcmail_config['sieverules_folder_encoding'] = null;

// include the IMAP root in the folder path when creating the rules
$rcmail_config['sieverules_include_imap_root'] = FALSE;

// ruleset name
$rcmail_config['sieverules_ruleset_name'] = 'dovecot';

// allow multiple actions
$rcmail_config['sieverules_multiple_actions'] = TRUE;

// allowed actions
$rcmail_config['sieverules_allowed_actions'] = array(
                      'fileinto'  => TRUE,
                      'vacation'  => TRUE,
                      'reject'    => TRUE,
                      'redirect'  => TRUE,
                      'keep'      => TRUE,
                      'discard'   => TRUE,
                      'imapflags' => TRUE,
                      'notify'    => FALSE,
                      'stop'      => TRUE
                      );

// headers listed as examples of "Other headers"
$rcmail_config['sieverules_other_headers'] = array(
                      'Reply-To', 'List-Id', 'MailingList', 'Mailing-List',
                      'X-Original-To', 'X-List', 'X-List-Name', 'X-Mailing-List',
                      'Resent-From', 'Resent-To', 'X-Mailer', 'X-MailingList',
                      'X-Spam-Status', 'X-Priority', 'Importance', 'X-MSMail-Priority',
                      'Precedence', 'Return-Path', 'Received', 'Auto-Submitted',
                      'X-Spam-Flag', 'X-Spam-Level'
                      );

// Predefined rules
// each rule should be in it own array - examples provided in README
// 'name' => name of the rule, displayed in the rule type select box
// 'type' => one of: header, address, envelope, size
// 'header' => name of the header to test
// 'operator' => operator to use, for all possible values please see README
// 'extra' => extra information needed for the rule in some cases
// 'target' => value that the header is tested against
$rcmail_config['sieverules_predefined_rules'] = array(
  array(
    'name' => 'Is Spam',
    'type' => 'header',
    'header' => 'X-Spam-Flag',
    'operator' => 'is',
    'extra' => '',
    'target' => 'YES'
  )
);

// Advanced editor
// allows the user to edit the sieve file directly, without the restrictions of the normal UI
// 0 - Disabled, option not shown in the UI
// 1 - Enabled, option shown in the UI
// 2 - Option shown in the UI and used by default
$rcmail_config['sieverules_adveditor'] = 0;

// Allow users to use multiple rulesets
$rcmail_config['sieverules_multiplerules'] = FALSE;

// Default (or global) sieve rule file
$rcmail_config['sieverules_default_file'] = '/etc/dovecot/sieve/default';

// Auto load default sieve rule file if no rules exist and no import filters match
$rcmail_config['sieverules_auto_load_default'] = FALSE;

// Example sieve rule file
$rcmail_config['sieverules_example_file'] = '/etc/dovecot/sieve/example';

?>
