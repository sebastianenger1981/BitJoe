<?php

require_once("lib/http.inc.php");

$QueryString	= trim($_REQUEST["q"]);
$QueryString	= str_replace(" ", "+", $QueryString);
$usenextLink	= "http://www.usenext.de/index.cfm?TD=388162";
$QueryUri		= "http://85.214.77.110/searches/throughput.de/search.php?q=" . $QueryString;
$HttpObj		= new HTTPRequest($QueryUri);
$RawResults		= explode(';', $HttpObj->DownloadToString());

$durch			= "1048576";


foreach ( $RawResults as $OneUsenextRawResult ) {
       
        $OneResult	= explode(',', $OneUsenextRawResult);
        $FileLenght = $OneResult[0]; # in bytes
        $FileName	= $OneResult[1];
        $FileType	= $OneResult[2];

      	$lenght		= $FileLenght / $durch;
		$lenght		= round($lenght, 2);

		if ( strlen($lenght) > 1 ) {

			echo <<<END
				<span class="result">
					<span class="desc"><a href="$usenextLink&getfile=$FileName" target="_blank" title="Usenet Download" > $FileName </a> </span> <p></p>
					<span class="descdet">Größe: </span> 
						<span id="spacer"></span>
						<span id="spacer"></span>
						<span id="spacer"></span>
						<span id="spacer"></span>
							$lenght MB<p></p>
					<span class="descdet">Dateityp: </span> 
						<span id="spacer"></span>
						<span id="spacer"></span>
						$FileType <p></p>
				<br>
END;
		};
      
}; # foreach ( $RawResults as $OneUsenextRawResult ) {


?>

