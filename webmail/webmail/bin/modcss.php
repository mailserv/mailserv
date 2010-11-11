<?php

/*
 +-----------------------------------------------------------------------+
 | bin/modcss.php                                                        |
 |                                                                       |
 | This file is part of the RoundCube Webmail client                     |
 | Copyright (C) 2007-2009, RoundCube Dev. - Switzerland                 |
 | Licensed under the GNU GPL                                            |
 |                                                                       |
 | PURPOSE:                                                              |
 |   Modify CSS source from a URL                                        |
 |                                                                       |
 +-----------------------------------------------------------------------+
 | Author: Thomas Bruederli <roundcube@gmail.com>                        |
 +-----------------------------------------------------------------------+

 $Id: modcss.php 2853 2009-08-12 10:44:46Z thomasb $

*/

define('INSTALL_PATH', realpath(dirname(__FILE__) . '/..') . '/');
require INSTALL_PATH . 'program/include/iniset.php';

$RCMAIL = rcmail::get_instance();

$source = '';
$error  = 'Requires a valid user session and source url';

if (empty($RCMAIL->user->ID)) {
    header('HTTP/1.1 403 Forbidden');
    echo $error;
    exit;
}

$url = preg_replace('![^a-z0-9:./\-_?$&=%]!i', '', $_GET['u']);
if ($url === null) {
    header('HTTP/1.1 403 Forbidden');
    echo $error;
    exit;
}

$a_uri = parse_url($url);
$port  = $a_uri['port'] ? $a_uri['port'] : 80;
$host  = $a_uri['host'];
$path  = $a_uri['path'] . ($a_uri['query'] ? '?'.$a_uri['query'] : '');

// don't allow any other connections than http(s)
if (strtolower(substr($a_uri['scheme'], 0, 4)) != 'http') {
    header('HTTP/1.1 403 Forbidden');
    echo "Invalid URL";
    exit;
}

// try to open socket connection
if (!($fp = fsockopen($host, $port, $errno, $error, 15))) {
    header('HTTP/1.1 500 Internal Server Error');
    echo $error;
    exit;
}

// set timeout for socket
stream_set_timeout($fp, 30);

// send request
$out  = "GET $path HTTP/1.0\r\n";
$out .= "Host: $host\r\n";
$out .= "Connection: Close\r\n\r\n";
fwrite($fp, $out);

// read response
$header = true;
$headers = array();
while (!feof($fp)) {
    $line = trim(fgets($fp, 4048));

    if ($header) {
        if (preg_match('/^HTTP\/1\..\s+(\d+)/', $line, $regs)
            && intval($regs[1]) != 200) {
            break;
        }
        else if (empty($line)) {
            $header = false;
        }
        else {
            list($key, $value) = explode(': ', $line);
            $headers[strtolower($key)] = $value;
        }
    }
    else {
        $source .= "$line\n";
    }
}
fclose($fp);

// check content-type header and mod styles
$mimetype = strtolower($headers['content-type']);
if (!empty($source) && in_array($mimetype, array('text/css','text/plain'))) {
    header('Content-Type: text/css');
    echo rcmail_mod_css_styles($source, preg_replace('/[^a-z0-9]/i', '', $_GET['c']));
    exit;
}
else
    $error = "Invalid response returned by server";

header('HTTP/1.0 404 Not Found');
echo $error;
exit;
