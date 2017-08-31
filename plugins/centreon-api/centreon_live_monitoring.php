<?php

ini_set('display_errors', 1);
error_reporting(E_ALL ^ E_NOTICE);

 
require_once ("/appcentreon/users/appcentreon/deployer/DBConnect.php");
require_once ("/appcentreon/users/appcentreon/deployer/lib/getopt.php");
require_once ("/appcentreon/users/appcentreon/deployer/lib/centreon_API.php");

$shortopts = 'vha::d::';
$longopts = array('help','host:','service:','servicegroup:','hostgroup:','add','delete','duration:', 'verbose', 'comment:');
$options = _getopt($shortopts, $longopts);
$duration = '14400';
$quiet = 'true';

global $cmd_file, $logfile;
$cmd_file='/appcentreon/data/centreon/centcore.cmd';
$logfile='/appcentreon/data/centreon/log/downtime.log';

require_once realpath(dirname(__FILE__) . "/../../config/centreon.config.php");
require_once _CENTREON_PATH_ . 'www/class/centreon.class.php';
require_once _CENTREON_PATH_ . "/www/class/centreonDB.class.php";
require_once dirname(__FILE__) . '/class/webService.class.php';
require_once dirname(__FILE__) . '/exceptions.php';

$pearDB = new CentreonDB();

/* Purge old token */
$pearDB->query("DELETE FROM ws_token WHERE generate_date < DATE_SUB(NOW(), INTERVAL 1 HOUR)");

/* Test if the call is for authenticate */
if ($_SERVER['REQUEST_METHOD'] === 'POST' &&
    isset($_GET['action']) && $_GET['action'] == 'authenticate') {
    if (false === isset($_POST['username']) || false === isset($_POST['password'])) {
        CentreonWebService::sendJson("Bad parameters", 400);
    }

    /* @todo Check if user already have valid token */
    require_once _CENTREON_PATH_ . "/www/class/centreonLog.class.php";
    require_once _CENTREON_PATH_ . "/www/class/centreonAuth.class.php";

    /* Authenticate the user */
    $log = new CentreonUserLog(0, $pearDB);
    $auth = new CentreonAuth($_POST['username'], $_POST['password'], 0, $pearDB, $log);
    if ($auth->passwdOk == 0) {
        CentreonWebService::sendJson("Bad credentials", 403);
        exit();
    }

    /* Check if user exists in contact table */
    $reachAPI = 0;
    $res = $pearDB->prepare("SELECT contact_id, reach_api, contact_admin FROM contact WHERE contact_activate = '1' AND contact_register = '1' AND contact_alias = ?");
    $res = $pearDB->execute($res, array($_POST['username']));
    while ($data = $res->fetchRow()) {
      if (isset($data['contact_admin']) && $data['contact_admin'] == 1) {
            $reachAPI = 1;
        } else {
            if (isset($data['reach_api']) && $data['reach_api'] == 1) {
               $reachAPI = 1;
            }
        }
    }

    /* Sorry no access for this user */
    if ($reachAPI == 0) {
        CentreonWebService::sendJson("Unauthorized - Account not enabled", 401);
        exit();
    }

    /* Insert Token in API webservice session table */
    $token = base64_encode(uniqid('', true));
        $res = $pearDB->prepare("INSERT INTO ws_token (contact_id, token, generate_date) VALUES (?, ?, NOW())");
        $pearDB->execute($res, array($auth->userInfos['contact_id'], $token));
    
        /* Send Data in Json */
        CentreonWebService::sendJson(array('authToken' => $token));
    }
    
    /* Test authentication */
    if (false === isset($_SERVER['HTTP_CENTREON_AUTH_TOKEN'])) {
        CentreonWebService::sendJson("Unauthorized", 401);
    }
    
    /* Create the default object */
    $res = $pearDB->prepare("SELECT c.* FROM ws_token w, contact c WHERE c.contact_id = w.contact_id AND token = ?");
    $res = $pearDB->execute($res, array($_SERVER['HTTP_CENTREON_AUTH_TOKEN']));
    if (PEAR::isError($res)) {
        CentreonWebService::sendJson("Database error", 500);
    }
    $userInfos = $res->fetchRow();
    if (is_null($userInfos)) {
        CentreonWebService::sendJson("Unauthorized", 401);
    }
    
$centreon = new Centreon($userInfos);
$oreon = $centreon;


    
/*
Checking GET options
*/
//if (isset($_GET['host']))
//      $options['host'] = $_GET['host'];
//if (isset($_GET['service']))
//      $options['service'] = $_GET['service'];
//if (isset($_GET['fields']))
//      $options['fields'] = $_GET['fields'];

$json = file_get_contents('php://input'); 
$options = json_decode($json,true);

/*
Checking CLI options
*/

if(isset($options['h']) || isset($options['help']))
        usage(0,$argv[0],"");

if(isset($options['v']) || isset($options['verbose']))
	$quiet="false";

/*
Help Msg
*/
function usage($exit,$script,$message) {
print $message."\n";
	exitstatus($exit,"Get monitoring status for host|service.
	
Usage: ".trim(`basename $script`)." [-h|--help] 

	Options:
		-h|--help		: show help
		--host			: hostname
		--service		: service description (used with --host)
		--fields		: fields to show
		--list_fields		: list available fields (host OR service)
		--verbose|-v		: verbose mode

");
}

function getuserip() {
    $client  = @$_SERVER['HTTP_CLIENT_IP'];
    $forward = @$_SERVER['HTTP_X_FORWARDED_FOR'];
    $remote  = $_SERVER['REMOTE_ADDR'];

    if(filter_var($client, FILTER_VALIDATE_IP)) {
        $ip = $client;
    }
    elseif(filter_var($forward, FILTER_VALIDATE_IP)) {
        $ip = $forward;
    }
    else {
        $ip = $remote;
    }

    return $ip;
}

function get_service_fields() {

	global $centstorageDB ;

	$DBRESULT =& $centstorageDB->query("DESC services" );
	if (PEAR::isError($DBRESULT))
		die("DB Error : ".$DBRESULT->getDebugInfo()."\n");

	if($DBRESULT->numRows() == '0') {
                print "[error] ".__FUNCTION__.": Unable to get services fields.\n";
		exit(1);
	}
	while($object = $DBRESULT->fetchRow())
		$result[] = $object["Field"];
	
	return $result;
}

function get_service_status($fields,$service,$host) {

	global $centstorageDB ;

	$array_fields = explode(",",$fields);
	$allowed_fields = get_service_fields();
	foreach($array_fields AS $value)
	{
		if(!in_array($value,$allowed_fields))
		{
			print "[error] $value argument not exist!";
			exit;
		}
	}

	foreach ($array_fields AS $line) $new_fields[] = 's.'. "$line"; 
	$sql_fields = implode(',',$new_fields);

	if(isset($service))
		$sql_service_filter = " AND s.description LIKE "."'". $service ."' ";

	if(isset($host))
		$sql_host_filter = " AND h.name LIKE "."'". $host ."' ";

	$sql = "SELECT h.name,$sql_fields from services AS s, hosts AS h" . 
		" WHERE s.host_id = h.host_id ".
		" $sql_service_filter ".
		" $sql_host_filter ".
		" ORDER BY h.name";
	$DBRESULT =& $centstorageDB->query("$sql"); 
	if (PEAR::isError($DBRESULT))
		die("DB Error : ".$DBRESULT->getDebugInfo()."\n");

	if($DBRESULT->numRows() == '0') {
                print "[error] ".__FUNCTION__.": Unable to get services.\n";
		exit(1);
	}
	while($object = $DBRESULT->fetchRow())
		$result[] = $object;

	return $result;
}

function get_host_fields() {

	global $centstorageDB ;

	$DBRESULT =& $centstorageDB->query("DESC hosts" );
	if (PEAR::isError($DBRESULT))
		die("DB Error : ".$DBRESULT->getDebugInfo()."\n");

	if($DBRESULT->numRows() == '0') {
                print "[error] ".__FUNCTION__.": Unable to get hosts fields.\n";
		exit(1);
	}
	while($object = $DBRESULT->fetchRow())
		$result[] = $object["Field"];

	return $result;
}

/*
Main 
*/

$start_time=time();
$end_time=$start_time + $duration;
$cmd = array();

if($options['list_fields'] == 'host')
{
	$list = get_host_fields();
	print implode(',',$list);
	exit;
} elseif ($options['list_fields'] == 'service') {
	$list = get_service_fields();
	print implode(',',$list);
	exit;
} 

$result = get_service_status($options['fields'],$options['service'],$options['host']);
foreach($result AS $service)
{
	foreach($service AS $key => $value)	
		print "$value;";

	print "\n";
}

?>
