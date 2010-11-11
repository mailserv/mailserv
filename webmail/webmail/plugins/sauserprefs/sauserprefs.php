<?php

/**
 * SAUserprefs
 *
 * Plugin to allow the user to manage their SpamAssassin settings using an SQL database
 *
 * @version 1.3
 * @author Philip Weir
 * @url http://roundcube.net/plugins/sauserprefs
 */
class sauserprefs extends rcube_plugin
{
	public $task = 'mail|addressbook|settings';
	private $db;
	private $sections = array();
	private $cur_section;
	private $global_prefs;
	private $user_prefs;
	private $addressbook = '0';

	function init()
	{
		$rcmail = rcmail::get_instance();
		$this->load_config();

		if ($rcmail->config->get('sauserprefs_whitelist_abook_id', false))
			$this->addressbook = $rcmail->config->get('sauserprefs_whitelist_abook_id');

		if ($rcmail->task == 'settings') {
			$this->add_texts('localization/', array('sauserprefs'));

			$this->sections = array(
				'general' => array('id' => 'general', 'section' => $this->gettext('spamgeneralsettings')),
				'tests' => array('id' => 'tests', 'section' => $this->gettext('spamtests')),
				'bayes' => array('id' => 'bayes', 'section' => $this->gettext('bayes')),
				'headers' => array('id' => 'headers', 'section' => $this->gettext('headers')),
				'report' => array('id' => 'report','section' => $this->gettext('spamreportsettings')),
				'addresses' => array('id' => 'addresses', 'section' => $this->gettext('spamaddressrules')),
			);
			$this->cur_section = get_input_value('_section', RCUBE_INPUT_GPC);

			$this->register_action('plugin.sauserprefs', array($this, 'init_html'));
			$this->register_action('plugin.sauserprefs.edit', array($this, 'init_html'));
			$this->register_action('plugin.sauserprefs.save', array($this, 'save'));
			$this->register_action('plugin.sauserprefs.whitelist_import', array($this, 'whitelist_import'));
			$this->register_action('plugin.sauserprefs.purge_bayes', array($this, 'purge_bayes'));
			$this->include_script('sauserprefs.js');
		}
		elseif ($rcmail->config->get('sauserprefs_whitelist_sync')) {
			$this->add_hook('create_contact', array($this, 'contact_add'));
			$this->add_hook('save_contact', array($this, 'contact_save'));
			$this->add_hook('delete_contact', array($this, 'contact_delete'));
		}
	}

	function init_html()
	{
		$this->_db_connect('r');
		$this->_load_global_prefs();
		$this->_load_user_prefs();

		$this->api->output->set_pagetitle($this->gettext('sauserprefssettings'));

		if (rcmail::get_instance()->action == 'plugin.sauserprefs.edit') {
			$this->user_prefs = array_merge($this->global_prefs, $this->user_prefs);
			$this->api->output->add_handler('userprefs', array($this, 'gen_form'));
			$this->api->output->add_handler('sectionname', array($this, 'prefs_section_name'));
			$this->api->output->send('sauserprefs.settingsedit');
		}
		else {
			$this->api->output->add_handler('sasectionslist', array($this, 'section_list'));
			$this->api->output->add_handler('saprefsframe', array($this, 'preference_frame'));
			$this->api->output->send('sauserprefs.sauserprefs');
		}
	}

	function section_list($attrib)
	{
		$no_override = array_flip(rcmail::get_instance()->config->get('sauserprefs_dont_override'));

		// add id to message list table if not specified
		if (!strlen($attrib['id']))
			$attrib['id'] = 'rcmsectionslist';

		$sections = array();
		$blocks = $attrib['sections'] ? preg_split('/[\s,;]+/', strip_quotes($attrib['sections'])) : array_keys($this->sections);
		foreach ($blocks as $block) {
			if (!isset($no_override['{' . $block . '}']))
				$sections[$block] = $this->sections[$block];
		}

		// create XHTML table
		$out = rcube_table_output($attrib, $sections, array('section'), 'id');

		// set client env
		$this->api->output->add_gui_object('sectionslist', $attrib['id']);
		$this->api->output->include_script('list.js');

		return $out;
	}

	function preference_frame($attrib)
	{
		if (!$attrib['id'])
			$attrib['id'] = 'rcmprefsframe';

		$attrib['name'] = $attrib['id'];

		$this->api->output->set_env('contentframe', $attrib['name']);
		$this->api->output->set_env('blankpage', $attrib['src'] ? $this->api->output->abs_url($attrib['src']) : 'program/blank.gif');

		return html::iframe($attrib);
	}

	function gen_form($attrib)
	{
		$this->api->output->add_label(
			'sauserprefs.spamaddressexists', 'sauserprefs.spamenteraddress',
			'sauserprefs.spamaddresserror', 'sauserprefs.spamaddressdelete',
			'sauserprefs.spamaddressdeleteall', 'sauserprefs.enabled', 'sauserprefs.disabled',
			'sauserprefs.importingaddresses', 'sauserprefs.usedefaultconfirm', 'sauserprefs.purgebayesconfirm',
			'sauserprefs.whitelist_from');

		// output global prefs as default in env
		foreach($this->global_prefs as $key => $val)
			$this->api->output->set_env(str_replace(" ", "_", $key), $val);

		unset($attrib['form']);

		list($form_start, $form_end) = get_form_tags($attrib, 'plugin.sauserprefs.save', null,
			array('name' => '_section', 'value' => $this->cur_section));

		$out = $form_start;

		$out .= $this->_prefs_block($this->cur_section, $attrib);

		return $out . $form_end;
	}

	function prefs_section_name()
	{
		return $this->sections[$this->cur_section]['section'];
	}

	function save()
	{
		$rcmail = rcmail::get_instance();
		$this->_db_connect('r');
		$this->_load_global_prefs();
		$this->_load_user_prefs();

		$no_override = array_flip($rcmail->config->get('sauserprefs_dont_override'));
		$new_prefs = array();
		$result = true;

  		switch ($this->cur_section)
		{
			case 'general':
				if (!isset($no_override['required_hits']))
					$new_prefs['required_hits'] = $_POST['_spamthres'];

				if (!isset($no_override['rewrite_header Subject']))
					$new_prefs['rewrite_header Subject'] = $_POST['_spamsubject'];

				if (!isset($no_override['ok_locales']) && !isset($no_override['ok_languages'])) {
					$new_prefs['ok_locales'] = is_array($_POST['_spamlang']) ? implode(" ", $_POST['_spamlang']) : '';
					$new_prefs['ok_languages'] = $new_prefs['ok_locales'];
				}

				break;

			case 'headers':
				if (!isset($no_override['fold_headers']))
					$new_prefs['fold_headers'] = empty($_POST['_spamfoldheaders']) ? "0" : $_POST['_spamfoldheaders'];

				if (!isset($no_override['add_header all Level'])) {
					$spamchar = empty($_POST['_spamlevelchar']) ? "*" : $_POST['_spamlevelchar'];
					if ($_POST['_spamlevelstars'] == "1") {
						$new_prefs['add_header all Level'] = "_STARS(". $spamchar .")_";
						$new_prefs['remove_header all'] = "0";
					}
					else {
						$new_prefs['add_header all Level'] = "";
						$new_prefs['remove_header all'] = "Level";
					}
				}

				break;

			case 'tests':
				if (!isset($no_override['use_razor1']))
					$new_prefs['use_razor1'] = empty($_POST['_spamuserazor1']) ? "0" : $_POST['_spamuserazor1'];

				if (!isset($no_override['use_razor2']))
					$new_prefs['use_razor2'] = empty($_POST['_spamuserazor2']) ? "0" : $_POST['_spamuserazor2'];

				if (!isset($no_override['use_pyzor']))
					$new_prefs['use_pyzor'] = empty($_POST['_spamusepyzor']) ? "0" : $_POST['_spamusepyzor'];

				if (!isset($no_override['use_dcc']))
					$new_prefs['use_dcc'] = empty($_POST['_spamusedcc']) ? "0" : $_POST['_spamusedcc'];

				if (!isset($no_override['skip_rbl_checks'])) {
					if ($_POST['_spamskiprblchecks'] == "1")
						$new_prefs['skip_rbl_checks'] = "";
					else
						$new_prefs['skip_rbl_checks'] = "1";
				}

				break;

			case 'bayes':
				if (!isset($no_override['use_bayes']))
					$new_prefs['use_bayes'] = empty($_POST['_spamusebayes']) ? "0" : $_POST['_spamusebayes'];

				if (!isset($no_override['bayes_auto_learn']))
					$new_prefs['bayes_auto_learn'] = empty($_POST['_spambayesautolearn']) ? "0" : $_POST['_spambayesautolearn'];

				if (!isset($no_override['bayes_auto_learn_threshold_nonspam']))
					$new_prefs['bayes_auto_learn_threshold_nonspam'] = $_POST['_bayesnonspam'];

				if (!isset($no_override['bayes_auto_learn_threshold_spam']))
					$new_prefs['bayes_auto_learn_threshold_spam'] = $_POST['_bayesspam'];

				if (!isset($no_override['use_bayes_rules']))
					$new_prefs['use_bayes_rules'] = empty($_POST['_spambayesrules']) ? "0" : $_POST['_spambayesrules'];

				break;

			case 'report':
				if (!isset($no_override['report_safe']))
					$new_prefs['report_safe'] = $_POST['_spamreport'];

				break;

			case 'addresses':
				$acts = $_POST['_address_rule_act'];
				$prefs = $_POST['_address_rule_field'];
				$vals = $_POST['_address_rule_value'];

				foreach ($acts as $idx => $act){
					if ($act == "DELETE") {
						$result = false;

						$this->db->query(
						  "DELETE FROM ". $rcmail->config->get('sauserprefs_sql_table_name') ."
						   WHERE  ". $rcmail->config->get('sauserprefs_sql_username_field') ." = '". $_SESSION['username'] ."'
						   AND    ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = '". $this->_map_pref_name($prefs[$idx]) ."'
						   AND    ". $rcmail->config->get('sauserprefs_sql_value_field') ." = '". $vals[$idx] . "';"
						  );

						$result = $this->db->affected_rows();

						if (!$result)
							break;
					}
					elseif ($act == "INSERT") {
						$result = false;

						$this->db->query(
						  "INSERT INTO ". $rcmail->config->get('sauserprefs_sql_table_name') ."
						   (".$rcmail->config->get('sauserprefs_sql_username_field').", ".$rcmail->config->get('sauserprefs_sql_preference_field').", ".$rcmail->config->get('sauserprefs_sql_value_field').")
						   VALUES ('". $_SESSION['username']. "', '". $this->_map_pref_name($prefs[$idx]) . "', '". $vals[$idx] ."')"
						  );

						$result = $this->db->affected_rows();

						if (!$result)
							break;
					}
				}

				break;
		}

		// save prefs (other than address rules to db)
		foreach ($new_prefs as $preference => $value) {
			if (array_key_exists($preference, $this->user_prefs) && ($value == "" || $value == $this->global_prefs[$preference])) {
				$result = false;

				$this->db->query(
				  "DELETE FROM ". $rcmail->config->get('sauserprefs_sql_table_name') ."
				   WHERE  ". $rcmail->config->get('sauserprefs_sql_username_field') ." = '". $_SESSION['username'] ."'
				   AND    ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = '". $this->_map_pref_name($preference) ."';"
				  );

				$result = $this->db->affected_rows();

				if (!$result)
					break;
			}
			elseif (array_key_exists($preference, $this->user_prefs) && $value != $this->user_prefs[$preference]) {
				$result = false;

				$this->db->query(
				  "UPDATE ". $rcmail->config->get('sauserprefs_sql_table_name') ."
				   SET    ". $rcmail->config->get('sauserprefs_sql_value_field') ." = '". $value ."'
				   WHERE  ". $rcmail->config->get('sauserprefs_sql_username_field') ." = '". $_SESSION['username'] ."'
				   AND    ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = '". $this->_map_pref_name($preference) ."';"
				  );

				$result = $this->db->affected_rows();

				if (!$result)
					break;
			}
			elseif (!array_key_exists($preference, $this->user_prefs) && $value != $this->global_prefs[$preference]) {
				$result = false;

				$this->db->query(
				  "INSERT INTO ". $rcmail->config->get('sauserprefs_sql_table_name') ."
				   (".$rcmail->config->get('sauserprefs_sql_username_field').", ".$rcmail->config->get('sauserprefs_sql_preference_field').", ".$rcmail->config->get('sauserprefs_sql_value_field').")
				   VALUES ('". $_SESSION['username'] ."', '". $this->_map_pref_name($preference) ."', '". $value ."')"
				  );

				$result = $this->db->affected_rows();

				if (!$result)
					break;
			}
		}

		if ($result)
			$this->api->output->command('display_message', $this->gettext('sauserprefchanged'), 'confirmation');
		else
			$this->api->output->command('display_message', $this->gettext('sauserpreffailed'), 'error');

		// go to next step
		rcmail_overwrite_action('plugin.sauserprefs.edit');
		$this->_load_user_prefs();
		$this->init_html();
	}

	function whitelist_import()
	{
		$contacts = rcmail::get_instance()->get_address_book($this->addressbook);
		$contacts->page_size = 99;
		$result = $contacts->list_records();

		if (empty($result) || $result->count == 0)
			return;

		$records = $result->records;
	    foreach ($records as $row_data)
			$this->api->output->command('sauserprefs_addressrule_import', $row_data['email'], '', '');

		$contacts->close();
	}

	function purge_bayes()
	{
		$rcmail = rcmail::get_instance();

		if ($rcmail->config->get('sauserprefs_bayes_delete_query', true)) {
			$this->api->output->command('display_message', $this->gettext('servererror'), 'error');
			return;
		}

		$this->_db_connect('w');
		$queries = !is_array($rcmail->config->get('sauserprefs_bayes_delete_query')) ? array($rcmail->config->get('sauserprefs_bayes_delete_query')) : $rcmail->config->get('sauserprefs_bayes_delete_query');

		foreach ($queries as $sql) {
			$sql = str_replace('%u', $this->db->quote($_SESSION['username'],'text'), $sql);
			$this->db->query($sql);

			if ($this->db->is_error())
				break;
		}

		if ($this->db->is_error())
			$this->api->output->command('display_message', $this->gettext('servererror'), 'error');
		else
			$this->api->output->command('display_message', $this->gettext('done'), 'confirmation');
	}

	function contact_add($args)
	{
		$rcmail = rcmail::get_instance();

 		// only works with specified address book
 		if ($args['source'] != $this->addressbook && $args['source'] != null)
 			return;

		$this->_db_connect('w');
		$email = $args['record']['email'];

		// check address is not already whitelisted
		$sql_result = $this->db->query("SELECT value FROM ". $rcmail->config->get('sauserprefs_sql_table_name') ." WHERE ". $rcmail->config->get('sauserprefs_sql_username_field') ." = '". $_SESSION['username'] ."' AND ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = 'whitelist_from' AND ". $rcmail->config->get('sauserprefs_sql_value_field') ." = '". $email ."';");
		if ($this->db->num_rows($sql_result) == 0)
			$this->db->query("INSERT INTO ". $rcmail->config->get('sauserprefs_sql_table_name') ." (". $rcmail->config->get('sauserprefs_sql_username_field') .", ". $rcmail->config->get('sauserprefs_sql_preference_field') .", ". $rcmail->config->get('sauserprefs_sql_value_field') .") VALUES ('". $_SESSION['username'] ."', 'whitelist_from', '". $email ."');");
	}

	function contact_save($args)
	{
		$rcmail = rcmail::get_instance();

		// only works with specified address book
		if ($args['source'] != $this->addressbook && $args['source'] != null)
			return;

		$this->_db_connect('w');
		$contacts = $rcmail->get_address_book($this->addressbook);
		$old_email = $contacts->get_record($args['id'], true);
		$old_email = $old_email['email'];
		$email = $args['record']['email'];

		// check address is not already whitelisted
		$sql_result = $this->db->query("SELECT value FROM ". $rcmail->config->get('sauserprefs_sql_table_name') ." WHERE ". $rcmail->config->get('sauserprefs_sql_username_field') ." = '". $_SESSION['username'] ."' AND ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = 'whitelist_from' AND ". $rcmail->config->get('sauserprefs_sql_value_field') ." = '". $email ."';");
		if ($this->db->num_rows($sql_result) == 0)
			$this->db->query("UPDATE ". $rcmail->config->get('sauserprefs_sql_table_name') ." SET ". $rcmail->config->get('sauserprefs_sql_value_field') ." = '". $email ."' WHERE ". $rcmail->config->get('sauserprefs_sql_username_field') ." = '". $_SESSION['username'] ."' AND ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = 'whitelist_from' AND ". $rcmail->config->get('sauserprefs_sql_value_field') ." = '". $old_email ."';");

		$contacts->close();
	}

	function contact_delete($args)
	{
		$rcmail = rcmail::get_instance();

		// only works with specified address book
		if ($args['source'] != $this->addressbook && $args['source'] != null)
			return;

		$this->_db_connect('w');
		$contacts = $rcmail->get_address_book($this->addressbook);
		$email = $contacts->get_record($args['id'], true);
		$email = $email['email'];

		$this->db->query("DELETE FROM ". $rcmail->config->get('sauserprefs_sql_table_name') ." WHERE ". $rcmail->config->get('sauserprefs_sql_username_field') ." = '". $_SESSION['username'] ."' AND ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = 'whitelist_from' AND ". $rcmail->config->get('sauserprefs_sql_value_field') ." = '". $email ."';");
		$contacts->close();
	}

	private function _db_connect($mode)
	{
		$rcmail = rcmail::get_instance();
		$this->db = new rcube_mdb2($rcmail->config->get('sauserprefs_db_dsnw'), $rcmail->config->get('sauserprefs_db_dsnr'), $rcmail->config->get('sauserprefs_db_persistent'));
		$this->db->db_connect($mode);

		// check DB connections and exit on failure
		if ($err_str = $this->db->is_error()) {
		  raise_error(array(
		    'code' => 603,
		    'type' => 'db',
		    'message' => $err_str), FALSE, TRUE);
		}
	}

	private function _load_global_prefs()
	{
		$rcmail = rcmail::get_instance();
		$this->global_prefs = $this->_load_prefs($rcmail->config->get('sauserprefs_global_userid'));
		$this->global_prefs = array_merge($rcmail->config->get('sauserprefs_default_prefs'), $this->global_prefs);
	}

	private function _load_user_prefs()
	{
		$this->user_prefs = $this->_load_prefs($_SESSION['username']);
	}

	private function _load_prefs($user)
	{
		$rcmail = rcmail::get_instance();
		$prefs = array();

		$sql_result = $this->db->query(
		  "SELECT ". $rcmail->config->get('sauserprefs_sql_preference_field') .", ". $rcmail->config->get('sauserprefs_sql_value_field') ."
		   FROM   ". $rcmail->config->get('sauserprefs_sql_table_name') ."
		   WHERE  ". $rcmail->config->get('sauserprefs_sql_username_field') ." = '". $user ."'
		   AND    ". $rcmail->config->get('sauserprefs_sql_preference_field') ." <> 'whitelist_from'
		   AND    ". $rcmail->config->get('sauserprefs_sql_preference_field') ." <> 'blacklist_from'
		   AND    ". $rcmail->config->get('sauserprefs_sql_preference_field') ." <> 'whitelist_to';"
		  );

	    while ($sql_result && ($sql_arr = $this->db->fetch_assoc($sql_result))) {
		    $pref_name = $sql_arr[$rcmail->config->get('sauserprefs_sql_preference_field')];
		    $pref_name = $this->_map_pref_name($pref_name, true);
		    $pref_value = $sql_arr[$rcmail->config->get('sauserprefs_sql_value_field')];

		    $prefs[$pref_name] = $pref_value;

		    // update deprecated prefs in db
		    if ($sql_arr[$rcmail->config->get('sauserprefs_sql_preference_field')] != $this->_map_pref_name($pref_name)) {
 				$this->db->query(
 					  "UPDATE ". $rcmail->config->get('sauserprefs_sql_table_name') ."
 					   SET    ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = '". $this->_map_pref_name($pref_name) ."'
 					   WHERE  ". $rcmail->config->get('sauserprefs_sql_username_field') ." = '". $user ."'
 					   AND    ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = '". $sql_arr[$rcmail->config->get('sauserprefs_sql_preference_field')] ."';"
 					  );
		    }
	    }

		return $prefs;
	}

	private function _prefs_block($part, $attrib)
	{
		$rcmail = rcmail::get_instance();
		$no_override = array_flip($rcmail->config->get('sauserprefs_dont_override'));
		$locale_info = localeconv();

		switch ($part)
		{
		// General tests
		case 'general':
			$out = '';
			$data = '';

			if (!isset($no_override['required_hits'])) {
				$field_id = 'rcmfd_spamthres';
				$input_spamthres = new html_select(array('name' => '_spamthres', 'id' => $field_id));
				$input_spamthres->add($this->gettext('defaultscore'), '');

				$decPlaces = 0;
				if ($rcmail->config->get('sauserprefs_score_inc') - (int)$rcmail->config->get('sauserprefs_score_inc') > 0)
					$decPlaces = strlen($rcmail->config->get('sauserprefs_score_inc') - (int)$rcmail->config->get('sauserprefs_score_inc')) - 2;

				$score_found = false;
				for ($i = 1; $i <= 10; $i = $i + $rcmail->config->get('sauserprefs_score_inc')) {
					$input_spamthres->add(number_format($i, $decPlaces, $locale_info['decimal_point'], ''), number_format($i, $decPlaces, '.', ''));

					if (!$score_found && $this->user_prefs['required_hits'] && (float)$this->user_prefs['required_hits'] == (float)$i)
						$score_found = true;
				}

				if (!$score_found && $this->user_prefs['required_hits'])
					$input_spamthres->add(str_replace('%s', $this->user_prefs['required_hits'], $this->gettext('otherscore')), (float)$this->user_prefs['required_hits']);

				$table = new html_table(array('class' => 'generalprefstable', 'cols' => 2));
				$table->add('title', html::label($field_id, Q($this->gettext('spamthres'))));
				$table->add(null, $input_spamthres->show(number_format($this->user_prefs['required_hits'], $decPlaces, '.', '')));

				$data = $table->show() . Q($this->gettext('spamthresexp')) . '<br /><br />';
			}

			if (!isset($no_override['rewrite_header Subject'])) {
				$table = new html_table(array('class' => 'generalprefstable', 'cols' => 2));

				$field_id = 'rcmfd_spamsubject';
				$input_spamsubject = new html_inputfield(array('name' => '_spamsubject', 'id' => $field_id, 'value' => $this->user_prefs['rewrite_header Subject'], 'style' => 'width:200px;'));

				$table->add('title', html::label($field_id, Q($this->gettext('spamsubject'))));
				$table->add(null, $input_spamsubject->show());

				$table->add(null, "&nbsp;");
				$table->add(null, Q($this->gettext('spamsubjectblank')));

				$data .= $table->show();
			}

			if (!empty($data))
				$out .= html::tag('fieldset', null, html::tag('legend', null, Q($this->gettext('mainoptions'))) . $data);

			if (!isset($no_override['ok_languages']) && !isset($no_override['ok_locales'])) {
				$data = html::p(null, Q($this->gettext('spamlangexp')));

				$table = new html_table(array('class' => 'langprefstable', 'cols' => 2));

				$select_all = $this->api->output->button(array('command' => 'plugin.sauserprefs.select_all_langs', 'type' => 'link', 'label' => 'all'));
				$select_none = $this->api->output->button(array('command' => 'plugin.sauserprefs.select_no_langs', 'type' => 'link', 'label' => 'none'));
				$select_invert = $this->api->output->button(array('command' => 'plugin.sauserprefs.select_invert_langs', 'type' => 'link', 'label' => 'invert'));

				$table->add(array('colspan' => 2, 'id' => 'listcontrols'), $this->gettext('select') .":&nbsp;&nbsp;". $select_all ."&nbsp;&nbsp;". $select_invert ."&nbsp;&nbsp;". $select_none);
				$table->add_row();

				$enable_button = html::img(array('src' => $attrib['enableicon'], 'alt' => $this->gettext('enabled'), 'border' => 0));
				$disable_button = html::img(array('src' => $attrib['disableicon'], 'alt' => $this->gettext('disabled'), 'border' => 0));

				$lang_table = new html_table(array('id' => 'spam-langs-table', 'class' => 'records-table', 'cellspacing' => '0', 'cols' => 2));
				$lang_table->add_header(array('colspan' => 2), $this->gettext('language'));
				$lang_table->set_row_attribs(array('style' => 'display: none;'));
				$lang_table->add(array('id' => 'enable_button'), $enable_button);
				$lang_table->add(array('id' => 'disable_button'), $disable_button);

				if ($this->user_prefs['ok_locales'] == "all")
					$ok_locales = array_keys($rcmail->config->get('sauserprefs_languages'));
				else
					$ok_locales = explode(" ", $this->user_prefs['ok_locales']);

				$i = 0;
				foreach ($rcmail->config->get('sauserprefs_languages') as $lang_code => $name) {
					if (in_array($lang_code, $ok_locales)) {
						$button = $this->api->output->button(array('command' => 'plugin.sauserprefs.message_lang', 'prop' => $lang_code, 'type' => 'link', 'id' => 'spam_lang_' . $i, 'title' => 'sauserprefs.enabled', 'label' => '{[button]}'));
						$button = str_replace('[{[button]}]', $enable_button, $button);
					}
					else {
						$button = $this->api->output->button(array('command' => 'plugin.sauserprefs.message_lang', 'prop' => $lang_code, 'type' => 'link', 'id' => 'spam_lang_' . $i, 'title' => 'sauserprefs.disabled', 'label' => '{[button]}'));
						$button = str_replace('[{[button]}]', $disable_button, $button);
					}

					$input_spamlang = new html_checkbox(array('style' => 'display: none;', 'name' => '_spamlang[]', 'value' => $lang_code));

					$lang_table->add('lang', $name);
					$lang_table->add('tick', $button . $input_spamlang->show(in_array($lang_code, $ok_locales) ? $lang_code : ''));

					$i++;
				}

				$table->add(array('colspan' => 2), html::div(array('id' => 'spam-langs-cont'), $lang_table->show()));
				$table->add_row();

				$out .= html::tag('fieldset', null, html::tag('legend', null, Q($this->gettext('langoptions'))) . $data . $table->show());
			}

			break;

		// Header settings
		case 'headers':
			$data = html::p(null, Q($this->gettext('headersexp')));

			if (!isset($no_override['fold_headers'])) {
				$help_button = html::img(array('class' => $imgclass, 'src' => $attrib['helpicon'], 'alt' => $this->gettext('sieveruleheaders'), 'border' => 0, 'style' => 'margin-left: 4px;'));
				$help_button = html::a(array('name' => '_headerhlp', 'href' => "#", 'onclick' => 'return '. JS_OBJECT_NAME .'.sauserprefs_help("fold_help");', 'title' => $this->gettext('help')), $help_button);

				$field_id = 'rcmfd_spamfoldheaders';
				$input_spamreport = new html_checkbox(array('name' => '_spamfoldheaders', 'id' => $field_id, 'value' => '1'));
				$data .= $input_spamreport->show($this->user_prefs['fold_headers']) ."&nbsp;". html::label($field_id, Q($this->gettext('foldheaders'))) . $help_button . "<br />";
				$data .= html::p(array('id' => 'fold_help', 'style' => 'display: none;'), Q($this->gettext('foldhelp')));
			}

			if (!isset($no_override['add_header all Level'])) {
				$help_button = html::img(array('class' => $imgclass, 'src' => $attrib['helpicon'], 'alt' => $this->gettext('sieveruleheaders'), 'border' => 0, 'style' => 'margin-left: 4px;'));
				$help_button = html::a(array('name' => '_headerhlp', 'href' => "#", 'onclick' => 'return '. JS_OBJECT_NAME .'.sauserprefs_help("level_help");', 'title' => $this->gettext('help')), $help_button);

				if ($this->user_prefs['remove_header all'] != 'Level') {
					$enabled = "1";
					$char = $this->user_prefs['add_header all Level'];
					$char = substr($char, 7, 1);
				}
				else {
					$enabled = "0";
					$char = "*";
				}

				$field_id = 'rcmfd_spamlevelstars';
				$input_spamreport = new html_checkbox(array('name' => '_spamlevelstars', 'id' => $field_id, 'value' => '1',
					'onchange' => JS_OBJECT_NAME . '.sauserprefs_toggle_level_char(this)'));
				$data .= $input_spamreport->show($enabled) ."&nbsp;". html::label($field_id, Q($this->gettext('spamlevelstars'))) . $help_button . "<br />";

				$field_id = 'rcmfd_spamlevelchar';
				$input_spamsubject = new html_inputfield(array('name' => '_spamlevelchar', 'id' => $field_id, 'value' => $char,
					'style' => 'width:20px;', 'disabled' => $enabled?0:1));
				$data .= html::span(array('style' => 'padding-left: 30px;'), $input_spamsubject->show() ."&nbsp;". html::label($field_id, Q($this->gettext('spamlevelchar'))));
				$data .= html::p(array('id' => 'level_help', 'style' => 'display: none;'), Q($this->gettext('levelhelp')));
			}

			$out = html::tag('fieldset', null, html::tag('legend', null, Q($this->gettext('mainoptions'))) . $data);
			break;

		// Test settings
		case 'tests':
			$data = html::p(null, Q($this->gettext('spamtestssexp')));

			if (!isset($no_override['use_razor1'])) {
				$help_button = html::img(array('class' => $imgclass, 'src' => $attrib['helpicon'], 'alt' => $this->gettext('sieveruleheaders'), 'border' => 0, 'style' => 'margin-left: 4px;'));
				$help_button = html::a(array('name' => '_headerhlp', 'href' => "#", 'onclick' => 'return '. JS_OBJECT_NAME .'.sauserprefs_help("raz1_help");', 'title' => $this->gettext('help')), $help_button);

				$field_id = 'rcmfd_spamuserazor1';
				$input_spamtest = new html_checkbox(array('name' => '_spamuserazor1', 'id' => $field_id, 'value' => '1'));
				$data .= $input_spamtest->show($this->user_prefs['use_razor1']) ."&nbsp;". html::label($field_id, Q($this->gettext('userazor1'))) . $help_button . "<br />";
				$data .= html::p(array('id' => 'raz1_help', 'style' => 'display: none;'), Q($this->gettext('raz1help')));
			}

			if (!isset($no_override['use_razor2'])) {
				$help_button = html::img(array('class' => $imgclass, 'src' => $attrib['helpicon'], 'alt' => $this->gettext('sieveruleheaders'), 'border' => 0, 'style' => 'margin-left: 4px;'));
				$help_button = html::a(array('name' => '_headerhlp', 'href' => "#", 'onclick' => 'return '. JS_OBJECT_NAME .'.sauserprefs_help("raz2_help");', 'title' => $this->gettext('help')), $help_button);

				$field_id = 'rcmfd_spamuserazor2';
				$input_spamtest = new html_checkbox(array('name' => '_spamuserazor2', 'id' => $field_id, 'value' => '1'));
				$data .= $input_spamtest->show($this->user_prefs['use_razor2']) ."&nbsp;". html::label($field_id, Q($this->gettext('userazor2'))) . $help_button . "<br />";
				$data .= html::p(array('id' => 'raz2_help', 'style' => 'display: none;'), Q($this->gettext('raz2help')));
			}

			if (!isset($no_override['use_pyzor'])) {
				$help_button = html::img(array('class' => $imgclass, 'src' => $attrib['helpicon'], 'alt' => $this->gettext('sieveruleheaders'), 'border' => 0, 'style' => 'margin-left: 4px;'));
				$help_button = html::a(array('name' => '_headerhlp', 'href' => "#", 'onclick' => 'return '. JS_OBJECT_NAME .'.sauserprefs_help("pyz_help");', 'title' => $this->gettext('help')), $help_button);

				$field_id = 'rcmfd_spamusepyzor';
				$input_spamtest = new html_checkbox(array('name' => '_spamusepyzor', 'id' => $field_id, 'value' => '1'));
				$data .= $input_spamtest->show($this->user_prefs['use_pyzor']) ."&nbsp;". html::label($field_id, Q($this->gettext('usepyzor'))) . $help_button . "<br />";
				$data .= html::p(array('id' => 'pyz_help', 'style' => 'display: none;'), Q($this->gettext('pyzhelp')));
			}

			if (!isset($no_override['use_dcc'])) {
				$help_button = html::img(array('class' => $imgclass, 'src' => $attrib['helpicon'], 'alt' => $this->gettext('sieveruleheaders'), 'border' => 0, 'style' => 'margin-left: 4px;'));
				$help_button = html::a(array('name' => '_headerhlp', 'href' => "#", 'onclick' => 'return '. JS_OBJECT_NAME .'.sauserprefs_help("dcc_help");', 'title' => $this->gettext('help')), $help_button);

				$field_id = 'rcmfd_spamusedcc';
				$input_spamtest = new html_checkbox(array('name' => '_spamusedcc', 'id' => $field_id, 'value' => '1'));
				$data .= $input_spamtest->show($this->user_prefs['use_dcc']) ."&nbsp;". html::label($field_id, Q($this->gettext('usedcc'))) . $help_button . "<br />";
				$data .= html::p(array('id' => 'dcc_help', 'style' => 'display: none;'), Q($this->gettext('dcchelp')));
			}

			if (!isset($no_override['skip_rbl_checks'])) {
				$help_button = html::img(array('class' => $imgclass, 'src' => $attrib['helpicon'], 'alt' => $this->gettext('sieveruleheaders'), 'border' => 0, 'style' => 'margin-left: 4px;'));
				$help_button = html::a(array('name' => '_headerhlp', 'href' => "#", 'onclick' => 'return '. JS_OBJECT_NAME .'.sauserprefs_help("rbl_help");', 'title' => $this->gettext('help')), $help_button);

				if ($this->user_prefs['skip_rbl_checks'] == "1")
					$enabled = "0";
				else
					$enabled = "1";

				$field_id = 'rcmfd_spamskiprblchecks';
				$input_spamtest = new html_checkbox(array('name' => '_spamskiprblchecks', 'id' => $field_id, 'value' => '1'));
				$data .= $input_spamtest->show($enabled) ."&nbsp;". html::label($field_id, Q($this->gettext('skiprblchecks'))) . $help_button . "<br />";
				$data .= html::p(array('id' => 'rbl_help', 'style' => 'display: none;'), Q($this->gettext('rblhelp')));
			}

			$out = html::tag('fieldset', null, html::tag('legend', null, Q($this->gettext('mainoptions'))) . $data);
			break;

		// Bayes settings
		case 'bayes':
			$data = html::p(null, Q($this->gettext('bayeshelp')));

			if (!isset($no_override['use_bayes'])) {
				//$help_button = html::img(array('class' => $imgclass, 'src' => $attrib['helpicon'], 'alt' => $this->gettext('sieveruleheaders'), 'border' => 0, 'style' => 'margin-left: 4px;'));
				//$help_button = html::a(array('name' => '_headerhlp', 'href' => "#", 'onclick' => 'return '. JS_OBJECT_NAME .'.sauserprefs_help("bayes_help");', 'title' => $this->gettext('help')), $help_button);

				$field_id = 'rcmfd_spamusebayes';
				$input_spamtest = new html_checkbox(array('name' => '_spamusebayes', 'id' => $field_id, 'value' => '1',
					'onchange' => JS_OBJECT_NAME . '.sauserprefs_toggle_bayes(this)'));
				$data .= $input_spamtest->show($this->user_prefs['use_bayes']) ."&nbsp;". html::label($field_id, Q($this->gettext('usebayes')));

				if ($rcmail->config->get('sauserprefs_bayes_delete_query', false))
					$data .=  "&nbsp;&nbsp;&nbsp;" . html::span(array('id' => 'listcontrols'), $this->api->output->button(array('command' => 'plugin.sauserprefs.purge_bayes', 'type' => 'link', 'label' => 'sauserprefs.purgebayes', 'title' => 'sauserprefs.purgebayesexp')));

				$data .= "<br />";
				//$data .= html::p(array('id' => 'bayes_help', 'style' => 'display: none;'), Q($this->gettext('bayeshelp')));
			}

			if (!isset($no_override['use_bayes_rules'])) {
				$help_button = html::img(array('class' => $imgclass, 'src' => $attrib['helpicon'], 'alt' => $this->gettext('sieveruleheaders'), 'border' => 0, 'style' => 'margin-left: 4px;'));
				$help_button = html::a(array('name' => '_headerhlp', 'href' => "#", 'onclick' => 'return '. JS_OBJECT_NAME .'.sauserprefs_help("bayesrules_help");', 'title' => $this->gettext('help')), $help_button);

				$field_id = 'rcmfd_spambayesrules';
				$input_spamtest = new html_checkbox(array('name' => '_spambayesrules', 'id' => $field_id, 'value' => '1', 'disabled' => $this->user_prefs['use_bayes']?0:1));
				$data .= $input_spamtest->show($this->user_prefs['use_bayes_rules']) ."&nbsp;". html::label($field_id, Q($this->gettext('bayesrules'))) . $help_button . "<br />";
				$data .= html::p(array('id' => 'bayesrules_help', 'style' => 'display: none;'), Q($this->gettext('bayesruleshlp')));
			}

			if (!isset($no_override['bayes_auto_learn'])) {
				$help_button = html::img(array('class' => $imgclass, 'src' => $attrib['helpicon'], 'alt' => $this->gettext('sieveruleheaders'), 'border' => 0, 'style' => 'margin-left: 4px;'));
				$help_button = html::a(array('name' => '_headerhlp', 'href' => "#", 'onclick' => 'return '. JS_OBJECT_NAME .'.sauserprefs_help("bayesauto_help");', 'title' => $this->gettext('help')), $help_button);

				$field_id = 'rcmfd_spambayesautolearn';
				$input_spamtest = new html_checkbox(array('name' => '_spambayesautolearn', 'id' => $field_id, 'value' => '1',
					'onchange' => JS_OBJECT_NAME . '.sauserprefs_toggle_bayes_auto(this)', 'disabled' => $this->user_prefs['use_bayes']?0:1));
				$data .= $input_spamtest->show($this->user_prefs['bayes_auto_learn']) ."&nbsp;". html::label($field_id, Q($this->gettext('bayesautolearn'))) . $help_button . "<br />";
				$data .= html::p(array('id' => 'bayesauto_help', 'style' => 'display: none;'), Q($this->gettext('bayesautohelp')));
			}

			$out = html::tag('fieldset', null, html::tag('legend', null, Q($this->gettext('mainoptions'))) . $data);

			$data = "";
			if (!isset($no_override['bayes_auto_learn_threshold_nonspam'])) {
				$field_id = 'rcmfd_bayesnonspam';
				$input_bayesnthres = new html_select(array('name' => '_bayesnonspam', 'id' => $field_id, 'disabled' => (!$this->user_prefs['bayes_auto_learn'] || !$this->user_prefs['use_bayes'])?1:0));
				$input_bayesnthres->add($this->gettext('defaultscore'), '');

				$decPlaces = 1;
				//if ($rcmail->config->get('sauserprefs_score_inc') - (int)$rcmail->config->get('sauserprefs_score_inc') > 0)
				//	$decPlaces = strlen($rcmail->config->get('sauserprefs_score_inc') - (int)$rcmail->config->get('sauserprefs_score_inc')) - 2;

				$score_found = false;
				for ($i = -1; $i <= 1; $i = $i + 0.1) {
					$input_bayesnthres->add(number_format($i, $decPlaces, $locale_info['decimal_point'], ''), number_format($i, $decPlaces, '.', ''));

					if (!$score_found && $this->user_prefs['bayes_auto_learn_threshold_nonspam'] && (float)$this->user_prefs['bayes_auto_learn_threshold_nonspam'] == (float)$i)
						$score_found = true;
				}

				if (!$score_found && $this->user_prefs['bayes_auto_learn_threshold_nonspam'])
					$input_bayesnthres->add(str_replace('%s', $this->user_prefs['bayes_auto_learn_threshold_nonspam'], $this->gettext('otherscore')), (float)$this->user_prefs['bayes_auto_learn_threshold_nonspam']);

				$table = new html_table(array('class' => 'generalprefstable', 'cols' => 2));
				$table->add('title', html::label($field_id, Q($this->gettext('bayesnonspam'))));
				$table->add(null, $input_bayesnthres->show(number_format($this->user_prefs['bayes_auto_learn_threshold_nonspam'], $decPlaces, '.', '')));

				$data .= $table->show() . Q($this->gettext('bayesnonspamexp')) . '<br /><br />';
			}

			if (!isset($no_override['bayes_auto_learn_threshold_spam'])) {
				$field_id = 'rcmfd_bayesspam';
				$input_bayesthres = new html_select(array('name' => '_bayesspam', 'id' => $field_id, 'disabled' => (!$this->user_prefs['bayes_auto_learn'] || !$this->user_prefs['use_bayes'])?1:0));
				$input_bayesthres->add($this->gettext('defaultscore'), '');

				$decPlaces = 0;
				if ($rcmail->config->get('sauserprefs_score_inc') - (int)$rcmail->config->get('sauserprefs_score_inc') > 0)
					$decPlaces = strlen($rcmail->config->get('sauserprefs_score_inc') - (int)$rcmail->config->get('sauserprefs_score_inc')) - 2;

				$score_found = false;
				for ($i = 1; $i <= 20; $i = $i + $rcmail->config->get('sauserprefs_score_inc')) {
					$input_bayesthres->add(number_format($i, $decPlaces, $locale_info['decimal_point'], ''), number_format($i, $decPlaces, '.', ''));

					if (!$score_found && $this->user_prefs['bayes_auto_learn_threshold_spam'] && (float)$this->user_prefs['bayes_auto_learn_threshold_spam'] == (float)$i)
						$score_found = true;
				}

				if (!$score_found && $this->user_prefs['required_hits'])
					$input_bayesthres->add(str_replace('%s', $this->user_prefs['bayes_auto_learn_threshold_spam'], $this->gettext('otherscore')), (float)$this->user_prefs['bayes_auto_learn_threshold_spam']);

				$table = new html_table(array('class' => 'generalprefstable', 'cols' => 2));
				$table->add('title', html::label($field_id, Q($this->gettext('bayesspam'))));
				$table->add(null, $input_bayesthres->show(number_format($this->user_prefs['bayes_auto_learn_threshold_spam'], $decPlaces, '.', '')));

				$data .= $table->show() . Q($this->gettext('bayesspamexp')) . '<br />';
			}

			$out .= html::tag('fieldset', null, html::tag('legend', null, Q($this->gettext('bayesautooptions'))) . $data);

			break;

		// Report settings
		case 'report':
			$data = html::p(null, Q($this->gettext('spamreport')));

			if (!isset($no_override['report_safe'])) {
				$field_id = 'rcmfd_spamreport';
				$input_spamreport0 = new html_radiobutton(array('name' => '_spamreport', 'id' => $field_id.'_0', 'value' => '0'));
				$data .= $input_spamreport0->show($this->user_prefs['report_safe']) ."&nbsp;". html::label($field_id .'_0', Q($this->gettext('spamreport0'))) . "<br />";

				$input_spamreport1 = new html_radiobutton(array('name' => '_spamreport', 'id' => $field_id.'_1', 'value' => '1'));
				$data .= $input_spamreport1->show($this->user_prefs['report_safe']) ."&nbsp;". html::label($field_id .'_1', Q($this->gettext('spamreport1'))) . "<br />";

				$input_spamreport2 = new html_radiobutton(array('name' => '_spamreport', 'id' => $field_id.'_2', 'value' => '2'));
				$data .= $input_spamreport2->show($this->user_prefs['report_safe']) ."&nbsp;". html::label($field_id .'_2', Q($this->gettext('spamreport2'))) . "<br />";
			}

			$out = html::tag('fieldset', null, html::tag('legend', null, Q($this->gettext('mainoptions'))) . $data);
			break;

		// Address settings
		case 'addresses':
			$data = html::p(null, Q($this->gettext('whitelistexp')));

			if ($rcmail->config->get('sauserprefs_whitelist_sync'))
				$data .= Q($this->gettext('autowhitelist')) . "<br /><br />";

			$table = new html_table(array('class' => 'addressprefstable', 'cols' => 3));
			$field_id = 'rcmfd_spamaddressrule';
			$input_spamaddressrule = new html_select(array('name' => '_spamaddressrule', 'id' => $field_id));
			$input_spamaddressrule->add($this->gettext('whitelist_from'),'whitelist_from');
			$input_spamaddressrule->add($this->gettext('blacklist_from'), 'blacklist_from');
			$input_spamaddressrule->add($this->gettext('whitelist_to'), 'whitelist_to');

			$field_id = 'rcmfd_spamaddress';
			$input_spamaddress = new html_inputfield(array('name' => '_spamaddress', 'id' => $field_id, 'style' => 'width:200px;'));

			$field_id = 'rcmbtn_add_address';
			$button_addaddress = $this->api->output->button(array('command' => 'plugin.sauserprefs.addressrule_add', 'type' => 'input', 'class' => 'button', 'label' => 'sauserprefs.addrule', 'style' => 'width: 75px;'));

			$table->add(null, $input_spamaddressrule->show());
			$table->add(null, $input_spamaddress->show());
			$table->add(array('align' => 'right'), $button_addaddress);
			$table->add(array('colspan' => 3), "&nbsp;");
			$table->add_row();

			$import = $this->api->output->button(array('command' => 'plugin.sauserprefs.import_whitelist', 'type' => 'link', 'label' => 'import', 'title' => 'sauserprefs.importfromaddressbook'));
			$delete_all = $this->api->output->button(array('command' => 'plugin.sauserprefs.whitelist_delete_all', 'type' => 'link', 'label' => 'sauserprefs.deleteall'));

			$table->add(array('colspan' => 3, 'id' => 'listcontrols'), $import ."&nbsp;&nbsp;". $delete_all);
			$table->add_row();

			$address_table = new html_table(array('id' => 'address-rules-table', 'class' => 'records-table', 'cellspacing' => '0', 'cols' => 3));
			$address_table->add_header(array('width' => '180px'), $this->gettext('rule'));
			$address_table->add_header(null, $this->gettext('email'));
			$address_table->add_header(array('width' => '40px'), '&nbsp;');

			$this->_address_row($address_table, null, null, $attrib);

			$sql_result = $this->db->query(
			  "SELECT ". $rcmail->config->get('sauserprefs_sql_preference_field') .", ". $rcmail->config->get('sauserprefs_sql_value_field') ."
			   FROM   ". $rcmail->config->get('sauserprefs_sql_table_name') ."
			   WHERE  ". $rcmail->config->get('sauserprefs_sql_username_field') ." = '". $_SESSION['username'] ."'
			   AND   (". $rcmail->config->get('sauserprefs_sql_preference_field') ." = 'whitelist_from'
			   OR     ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = 'blacklist_from'
			   OR     ". $rcmail->config->get('sauserprefs_sql_preference_field') ." = 'whitelist_to')
			   ORDER BY ". $rcmail->config->get('sauserprefs_sql_value_field') .";"
			  );

			if ($sql_result && $this->db->num_rows($sql_result) > 0)
				$norules = 'display: none;';

			$address_table->set_row_attribs(array('style' => $norules));
			$address_table->add(array('colspan' => '3'), rep_specialchars_output($this->gettext('noaddressrules')));
			$address_table->add_row();

			$this->api->output->set_env('address_rule_count', $this->db->num_rows());

			while ($sql_result && $sql_arr = $this->db->fetch_assoc($sql_result)) {
				$field = $sql_arr[$rcmail->config->get('sauserprefs_sql_preference_field')];
				$value = $sql_arr[$rcmail->config->get('sauserprefs_sql_value_field')];

				$this->_address_row($address_table, $field, $value, $attrib);
			}

			$table->add(array('colspan' => 3), html::div(array('id' => 'address-rules-cont'), $address_table->show()));
			$table->add_row();

			if ($table->size())
				$out = html::tag('fieldset', null, html::tag('legend', null, Q($this->gettext('mainoptions'))) . $data . $table->show());

			break;

		default:
			$out = '';
		}

		return $out;
	}

	private function _address_row($address_table, $field, $value, $attrib)
	{
		if (!isset($field))
			$address_table->set_row_attribs(array('style' => 'display: none;'));

		$hidden_action = new html_hiddenfield(array('name' => '_address_rule_act[]', 'value' => ''));
		$hidden_field = new html_hiddenfield(array('name' => '_address_rule_field[]', 'value' => $field));
		$hidden_text = new html_hiddenfield(array('name' => '_address_rule_value[]', 'value' => $value));

		switch ($field) {
			case "whitelist_from":
				$fieldtxt = rep_specialchars_output($this->gettext('whitelist_from'));
				break;
			case "blacklist_from":
				$fieldtxt = rep_specialchars_output($this->gettext('blacklist_from'));
				break;
			case "whitelist_to":
				$fieldtxt = rep_specialchars_output($this->gettext('whitelist_to'));
				break;
		}

		$address_table->add(array('class' => $field), $fieldtxt);
		$address_table->add(array('class' => 'email'), $value);
		$del_button = $this->api->output->button(array('command' => 'plugin.sauserprefs.addressrule_del', 'type' => 'image', 'image' => $attrib['deleteicon'], 'alt' => 'delete', 'title' => 'delete'));
		$address_table->add('control', '&nbsp;' . $del_button . $hidden_action->show() . $hidden_field->show() . $hidden_text->show());

		return $address_table;
	}

	private function _map_pref_name($pref, $reverse = false)
	{
		$prefs_map = rcmail::get_instance()->config->get('sauserprefs_deprecated_prefs', array());
		if (!$reverse) {
			if (array_key_exists($pref, $prefs_map))
				$pref = $prefs_map[$pref];
		}
		else {
			if (($orig_pref = array_search($pref, $prefs_map)) != FALSE)
				$pref = $orig_pref;
		}

		return $pref;
	}
}

?>
