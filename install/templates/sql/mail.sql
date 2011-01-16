
ALTER TABLE users AUTO_INCREMENT = 2000;

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
