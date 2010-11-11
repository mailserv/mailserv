create database mail DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
use mail

# Dump of table admins
# ------------------------------------------------------------

CREATE TABLE admins (
  id int(11) NOT NULL auto_increment,
  username varchar(32) NOT NULL default '',
  password varchar(32) NOT NULL default '',
  email varchar(128) default NULL,
  created_at datetime default NULL,
  updated_at datetime default NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY admins_uniq (username)
) ENGINE=MyISAM;



# Dump of table domains
# ------------------------------------------------------------

CREATE TABLE domains (
  id int(11) NOT NULL auto_increment,
  domain varchar(128) default NULL,
  created_at datetime default NULL,
  updated_at datetime default NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY domain_uniq (domain)
) TYPE=MyISAM;



# Dump of table forwardings
# ------------------------------------------------------------

CREATE TABLE forwardings (
  id int(11) NOT NULL auto_increment,
  domain_id int(11) NOT NULL default 0,
  source varchar(128) NOT NULL default '',
  destination text NOT NULL default '',
  created_at datetime default NULL,
  updated_at datetime default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;



# Dump of table users
# ------------------------------------------------------------

CREATE TABLE users (
  id int(11) NOT NULL auto_increment,
  domain_id int(11) default NULL,
  email varchar(128) NOT NULL default '',
  name varchar(128) default NULL,
  fullname varchar(128) default NULL,
  password varchar(32) NOT NULL default '',
  home varchar(255) NOT NULL default '',
  priority integer NOT NULL DEFAULT '7',  -- sort field, 0 is low prior.
  policy_id  integer unsigned NOT NULL DEFAULT '1',  -- JOINs with policy.id
  created_at datetime default NULL,
  updated_at datetime default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

CREATE TABLE `vacations` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `user_id` int(10) unsigned NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text,
  `expire` date default NULL,
  `created_at` date default NULL,
  `updated_at` date default NULL,
  PRIMARY KEY  (`id`)
) TYPE=MyISAM;

#
# User Preferences
#
CREATE TABLE userpref (
  username varchar(100) NOT NULL default '',
  preference varchar(50) NOT NULL default '',
  value varchar(100) NOT NULL default '',
  prefid int(11) NOT NULL auto_increment,
  PRIMARY KEY  (prefid),
  KEY username (username)
) TYPE=MyISAM;

INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'required_score', '5.0', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'rewrite_header Subject', '[SPAM _SCORE_]', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'report_safe', '0', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'trusted_networks', '10.0.0.0/8', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'trusted_networks', '172.16.0.0/12', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'trusted_networks', '192.168.0.0/16', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'use_bayes', '1', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'bayes_auto_learn', '1', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'skip_rbl_checks', '0', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'use_razor2', '0', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'use_pyzor', '0', NULL);
INSERT INTO userpref (username, preference, value, prefid) VALUES ('@GLOBAL',  'ok_locales', '1', NULL);

#INSERT INTO greylists (position, action, clause, value, description) VALUES (1,  'whitelist', 'addr', "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16", "My Networks");

#
# Add hooks for the rake db:migration system
#
CREATE TABLE schema_info (version int(11) default NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO  schema_info VALUES (1);

#
# Make sure that userid's start at uid 2000
#
ALTER TABLE users AUTO_INCREMENT = 2000;

grant select on mail.* to 'postfix'@'localhost' identified by 'postfix';
grant all privileges on mail.* to 'mailadmin'@'localhost' identified by 'mailadmin';
grant all privileges on sqlgrey.* to 'sqlgrey'@'localhost' identified by 'sqlgrey';
