<?php

/*
 +-----------------------------------------------------------------------+
 | program/include/rcube_html_page.php                                   |
 |                                                                       |
 | This file is part of the RoundCube PHP suite                          |
 | Copyright (C) 2005-2009, RoundCube Dev. - Switzerland                 |
 | Licensed under the GNU GPL                                            |
 |                                                                       |
 | CONTENTS:                                                             |
 |   Class to build XHTML page output                                    |
 |                                                                       |
 +-----------------------------------------------------------------------+
 | Author: Thomas Bruederli <roundcube@gmail.com>                        |
 +-----------------------------------------------------------------------+

 $Id: rcube_html_page.php 3235 2010-01-28 14:46:26Z alec $

*/

/**
 * Class for HTML page creation
 *
 * @package HTML
 */
class rcube_html_page
{
    protected $scripts_path = '';
    protected $script_files = array();
    protected $scripts = array();
    protected $charset = RCMAIL_CHARSET;

    protected $script_tag_file = "<script type=\"text/javascript\" src=\"%s\"></script>\n";
    protected $script_tag  =  "<script type=\"text/javascript\">\n/* <![CDATA[ */\n%s\n/* ]]> */\n</script>";
    protected $default_template = "<html>\n<head><title></title></head>\n<body></body>\n</html>";

    protected $title = '';
    protected $header = '';
    protected $footer = '';
    protected $body = '';
    protected $base_path = '';


    /** Constructor */
    public function __construct() {}

    /**
     * Link an external script file
     *
     * @param string File URL
     * @param string Target position [head|foot]
     */
    public function include_script($file, $position='head')
    {
        static $sa_files = array();
        
        if (!preg_match('|^https?://|i', $file) && $file[0] != '/')
          $file = $this->scripts_path . $file . (($fs = @filemtime($this->scripts_path . $file)) ? '?s='.$fs : '');

        if (in_array($file, $sa_files)) {
            return;
        }
        if (!is_array($this->script_files[$position])) {
            $this->script_files[$position] = array();
        }
        $this->script_files[$position][] = $file;
    }

    /**
     * Add inline javascript code
     *
     * @param string JS code snippet
     * @param string Target position [head|head_top|foot]
     */
    public function add_script($script, $position='head')
    {
        if (!isset($this->scripts[$position])) {
            $this->scripts[$position] = "\n".rtrim($script);
        } else {
            $this->scripts[$position] .= "\n".rtrim($script);
        }
    }

    /**
     * Add HTML code to the page header
     */
    public function add_header($str)
    {
        $this->header .= "\n".$str;
    }

    /**
     * Add HTML code to the page footer
     * To be added right befor </body>
     */
    public function add_footer($str)
    {
        $this->footer .= "\n".$str;
    }

    /**
     * Setter for page title
     */
    public function set_title($t)
    {
        $this->title = $t;
    }

    /**
     * Setter for output charset.
     * To be specified in a meta tag and sent as http-header
     */
    public function set_charset($charset)
    {
        $this->charset = $charset;
    }

    /**
     * Getter for output charset
     */
    public function get_charset()
    {
        return $this->charset;
    }

    /**
     * Reset all saved properties
     */
    public function reset()
    {
        $this->script_files = array();
        $this->scripts = array();
        $this->title = '';
        $this->header = '';
        $this->footer = '';
        $this->body = '';
    }

    /**
     * Process template and write to stdOut
     *
     * @param string HTML template
     * @param string Base for absolute paths
     */
    public function write($templ='', $base_path='')
    {
        $output = empty($templ) ? $this->default_template : trim($templ);

        // set default page title
        if (empty($this->title)) {
            $this->title = 'RoundCube Mail';
        }

        // replace specialchars in content
        $__page_title = Q($this->title, 'show', FALSE);
        $__page_header = $__page_body = $__page_footer = '';

        // include meta tag with charset
        if (!empty($this->charset)) {
            if (!headers_sent()) {
                header('Content-Type: text/html; charset=' . $this->charset);
            }
            $__page_header = '<meta http-equiv="content-type"';
            $__page_header.= ' content="text/html; charset=';
            $__page_header.= $this->charset . '" />'."\n";
        }

        // definition of the code to be placed in the document header and footer
        if (is_array($this->script_files['head'])) {
            foreach ($this->script_files['head'] as $file) {
                $__page_header .= sprintf($this->script_tag_file, $file);
            }
        }

        $head_script = $this->scripts['head_top'] . $this->scripts['head'];
        if (!empty($head_script)) {
            $__page_header .= sprintf($this->script_tag, $head_script);
        }

        if (!empty($this->header)) {
            $__page_header .= $this->header;
        }

        if (is_array($this->script_files['foot'])) {
            foreach ($this->script_files['foot'] as $file) {
                $__page_footer .= sprintf($this->script_tag_file, $file);
            }
        }

        if (!empty($this->scripts['foot'])) {
            $__page_footer .= sprintf($this->script_tag, $this->scripts['foot']);
        }

        if (!empty($this->footer)) {
            $__page_footer .= $this->footer;
        }

        // find page header
        if ($hpos = stripos($output, '</head>')) {
            $__page_header .= "\n";
        }
        else {
            if (!is_numeric($hpos)) {
                $hpos = stripos($output, '<body');
            }
            if (!is_numeric($hpos) && ($hpos = stripos($output, '<html'))) {
                while ($output[$hpos] != '>') {
                    $hpos++;
                }
                $hpos++;
            }
            $__page_header = "<head>\n<title>$__page_title</title>\n$__page_header\n</head>\n";
        }

        // add page hader
        if ($hpos) {
            $output = substr($output,0,$hpos) . $__page_header . substr($output,$hpos,strlen($output));
        }
        else {
            $output = $__page_header . $output;
        }

        // find page body
        if ($bpos = stripos($output, '<body')) {
            while ($output[$bpos] != '>') {
                $bpos++;
            }
            $bpos++;
        }
        else {
            $bpos = stripos($output, '</head>')+7;
        }

        // add page body
        if ($bpos && $__page_body) {
            $output = substr($output,0,$bpos) . "\n$__page_body\n" . substr($output,$bpos,strlen($output));
        }

        // find and add page footer
        if (($fpos = strripos($output, '</body>')) || ($fpos = strripos($output, '</html>'))) {
            $output = substr($output, 0, $fpos) . "$__page_footer\n" . substr($output, $fpos);
        }
        else {
            $output .= "\n".$__page_footer;
        }

        // reset those global vars
        $__page_header = $__page_footer = '';

	$this->base_path = $base_path;
        // correct absolute paths in images and other tags
	// add timestamp to .js and .css filename
        $output = preg_replace_callback('!(src|href|background)=(["\']?)([a-z0-9/_.-]+)(["\'\s>])!i',
	    array($this, 'file_callback'), $output);
        $output = str_replace('$__skin_path', $base_path, $output);

        if ($this->charset != RCMAIL_CHARSET)
	    echo rcube_charset_convert($output, RCMAIL_CHARSET, $this->charset);
	else
	    echo $output;
    }
    
    /**
     * Callback function for preg_replace_callback in write()
     */
    private function file_callback($matches)
    {
	$file = $matches[3];

        // correct absolute paths
	if ($file[0] == '/')
	    $file = $this->base_path . $file;

        // add file modification timestamp
	if (preg_match('/\.(js|css)$/', $file))
    	    $file .= '?s=' . @filemtime($file);

	return sprintf("%s=%s%s%s", $matches[1], $matches[2], $file, $matches[4]);
    }
}

