<?php

$rcmail_config = array();
$rcmail_config['db_dsnw'] = 'mysql://webmail:webmail@localhost/webmail';
$rcmail_config['db_backend'] = 'db';

// PEAR database DSN for read only operations (if empty write database will be used)
// useful for database replication
$rcmail_config['db_dsnr'] = '';

// maximum length of a query in bytes
$rcmail_config['db_max_length'] = 512000;  // 500K

// use persistent db-connections
// beware this will not "always" work as expected
// see: http://www.php.net/manual/en/features.persistent-connections.php
$rcmail_config['db_persistent'] = FALSE;

// you can define specific table names used to store webmail data
$rcmail_config['db_table_users']                = 'users';
$rcmail_config['db_table_identities']           = 'identities';
$rcmail_config['db_table_contacts']             = 'contacts';
$rcmail_config['db_table_contactgroups']        = 'contactgroups';
$rcmail_config['db_table_contactgroupmembers']  = 'contactgroupmembers';
$rcmail_config['db_table_session']              = 'session';
$rcmail_config['db_table_cache']                = 'cache';
$rcmail_config['db_table_messages']             = 'messages';

// you can define specific sequence names used in PostgreSQL
$rcmail_config['db_sequence_users']      = 'user_ids';
$rcmail_config['db_sequence_identities'] = 'identity_ids';
$rcmail_config['db_sequence_contacts']   = 'contact_ids';
$rcmail_config['db_sequence_cache']      = 'cache_ids';
$rcmail_config['db_sequence_messages']   = 'message_ids';


// end db config file
?>
