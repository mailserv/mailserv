create database spamcontrol;
use spamcontrol

#
# Bayes control
#
CREATE TABLE bayes_expire (
  id int(11) NOT NULL default '0',
  runtime int(11) NOT NULL default '0',
  KEY bayes_expire_idx1 (id)
) TYPE=MyISAM;

CREATE TABLE bayes_global_vars (
  variable varchar(30) NOT NULL default '',
  value varchar(200) NOT NULL default '',
  PRIMARY KEY  (variable)
) TYPE=MyISAM;

INSERT INTO bayes_global_vars VALUES ('VERSION','3');

CREATE TABLE bayes_seen (
  id int(11) NOT NULL default '0',
  msgid varchar(200) binary NOT NULL default '',
  flag char(1) NOT NULL default '',
  PRIMARY KEY  (id,msgid)
) TYPE=MyISAM;

CREATE TABLE bayes_token (
  id int(11) NOT NULL default '0',
  token char(5) NOT NULL default '',
  spam_count int(11) NOT NULL default '0',
  ham_count int(11) NOT NULL default '0',
  atime int(11) NOT NULL default '0',
  PRIMARY KEY  (id, token),
  INDEX bayes_token_idx1 (token),
  INDEX bayes_token_idx2 (id, atime)
) TYPE=MyISAM;

CREATE TABLE bayes_vars (
  id int(11) NOT NULL AUTO_INCREMENT,
  username varchar(200) NOT NULL default '',
  spam_count int(11) NOT NULL default '0',
  ham_count int(11) NOT NULL default '0',
  token_count int(11) NOT NULL default '0',
  last_expire int(11) NOT NULL default '0',
  last_atime_delta int(11) NOT NULL default '0',
  last_expire_reduce int(11) NOT NULL default '0',
  oldest_token_age int(11) NOT NULL default '2147483647',
  newest_token_age int(11) NOT NULL default '0',
  PRIMARY KEY (id),
  UNIQUE bayes_vars_idx1 (username)
) TYPE=MyISAM;

#
# Auto White List
#
CREATE TABLE awl (
  username varchar(100) NOT NULL default '',
  email varchar(200) NOT NULL default '',
  ip varchar(10) NOT NULL default '',
  count int(11) default '0',
  totscore float default '0',
  PRIMARY KEY  (username,email,ip)
) TYPE=MyISAM;

grant SELECT on spamcontrol.* to 'spamassassin'@'localhost' identified by 'spamassassin';
GRANT SELECT, UPDATE, DELETE, INSERT ON spamcontrol.bayes_token TO 'spamassassin'@'localhost' ;
GRANT SELECT, UPDATE, DELETE, INSERT ON spamcontrol.bayes_vars TO 'spamassassin'@'localhost';
GRANT SELECT, DELETE, INSERT ON spamcontrol.bayes_seen TO 'spamassassin'@'localhost';
GRANT SELECT, DELETE, INSERT ON spamcontrol.bayes_expire TO 'spamassassin'@'localhost';
GRANT SELECT, UPDATE, DELETE, INSERT ON spamcontrol.awl TO 'spamassassin'@'localhost' ;
