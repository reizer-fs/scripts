#!/tools/list/nagios/php/bin/php
<?php
require('/tools/list/nagios/amundi-plugins/getopt.php');
$args = array();
//$shortopts = 'hosgpae';
$shortopts = 'vha::d::';
//$longopts = array('help','host','service','hostgroup','servicegroup','action','env');
$longopts = array('help','object:','action:','verbose','env:');
$options = _getopt($shortopts, $longopts);

if(isset($options['h']) || isset($options['help']))
	usage(0,$argv[0],"");

if(isset($options['object'])) {
        $array_object = array("host", "hostgroup", "service", "servicegroup");
        if(in_array($options['object'], $array_object)){
                $args['object'] = $options['object'];
        }else{
                usage(1,$argv[0],"[error] : --object must be in " . implode("|", $array_object)) . ".";
        }

}
else{
        usage(1,$argv[0],"[error] : You must use --object\n");
}


if(isset($options['action'])) {
	$array_action = array("add", "show", "delete");
	if(in_array($options['action'], $array_action)){
		$args['action'] = $options['action'];
	}else{
		usage(1,$argv[0],"[error] : --action must be in " . implode("|", $array_action)) . ".";
	}
			
}
else{	
	usage(1,$argv[0],"[error] : You must use --action\n");
}



//$tty_cmd = "who am i";
//$tty_cmd = "uname -n";
//$tty = exec($tty_cmd);
//$args[comment]="$tty";
//$args[comment]=tty;

if(!isset($options['env']) OR $options['env'] == 'prod')
	$url = 'https://centreon.com';
elseif($options['env'] == 'hprod')
	$url = 'https://rct-centreon.com';
elseif($options['env'] == 'dev')
	$url = 'https://dev-centreon.com';

$uri = '/centreon/api/index.php?action=action&object=centreon_clapi';
$auth_uri = '/centreon/api/index.php?action=authenticate';
$auth_args = array('username' => 'test_form','password' => 'dfghjk');



// Get Token authentication
$auth_request = $url.$auth_uri;

$ch = curl_init($auth_request); 
curl_setopt_array($ch, array(
	CURLOPT_POST           => TRUE,
	CURLOPT_RETURNTRANSFER => TRUE,
	CURLOPT_SSL_VERIFYPEER => FALSE,
	CURLOPT_HTTPHEADER     => array(
		'Content-type: application/x-www-form-urlencoded',
	),
	CURLOPT_POSTFIELDS => http_build_query($auth_args)
));
$response = curl_exec($ch);

$response_array = json_decode($response, TRUE);
$access_token = $response_array["authToken"];

curl_close($ch);

// Send action (ex. remove) request
$request = $url.$uri; 
$c = curl_init($request);
$json_args = json_encode($args);
curl_setopt_array($c, array(
        CURLOPT_POST           => TRUE,
	//CURLOPT_VERBOSE	       => TRUE,
        CURLOPT_CUSTOMREQUEST  => "POST",
        CURLOPT_RETURNTRANSFER => TRUE,
        CURLOPT_SSL_VERIFYPEER => FALSE,
        CURLOPT_HTTPHEADER     => array(
		'Content-Type: application/json',
		'Content-Length: ' . strlen($json_args),
		"centreon_auth_token: {$access_token}",
        ),
        CURLOPT_POSTFIELDS => $json_args
));


$result = curl_exec($c);
curl_close($c);
//echo $result . "\n";
//echo $result;
$response = json_decode($result, TRUE);
var_dump($response);

function usage($exit,$script,$message) {
print $message."\n";
        exitstatus($exit,"Set downtime for host|hostgroup|service|servicegroup.

Usage: ".trim(`basename $script`)." [-h|--help]

        Options:
                -h|--help               	: show help
                --object	           	: object
                --action	 	 	: action
                --servicegroup <servicegroup>	: set downtime on servicegroup
                --hostgroup <hostgroup>       	: set downtime on hostgroup
                --add                   	: add downtime
                --delete                	: delete downtime
                --duration <duration>        	: set downtime duration in seconds, default is 14400 (4 hours)
                --verbose|-v            	: verbose mode
                --env|-e                	: environnement [prod|hprod|dev], default prod

Examples:
	# downtime --host ORA-ADF2P --service cluster --add    		// Set downtime for service 'cluster' on host 'ORA-ADF2P' during 14400s on Centreon prod. 
	# downtime --servicegroup livraison_noee --delete --env hprod   // Unset downtime for servicegroup 'livraison_noee' on Centreon hprod. 
	# downtime --host t72s-01 --add --duration 600s   		// Set downtime for all services from host 't72s-01' on Centreon prod during 600s. 

");
}

?>
