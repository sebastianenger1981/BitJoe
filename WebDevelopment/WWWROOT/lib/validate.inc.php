<?php 
/**
 * Validation helper class.
 *
 * $Id$
 *
 * @package    Core
 * @author     Kohana Team
 * @copyright  (c) 2007-2008 Kohana Team
 * @license    http://kohanaphp.com/license.html
 */


/**
	* Validate email, commonly used characters only
	*
	* @param   string   email address
	* @return  boolean
	*/
function email($email)
{
	return (bool) preg_match('/^[-_a-z0-9\'+*$^&%=~!?{}]++(?:\.[-_a-z0-9\'+*$^&%=~!?{}]+)*+@(?:(?![-.])[-a-z0-9.]+(?<![-.])\.[a-z]{2,6}|\d{1,3}(?:\.\d{1,3}){3})(?::\d++)?$/iD', (string) $email);
}

/**
	* Validate the domain of an email address by checking if the domain has a
	* valid MX record.
	*
	* @param   string   email address
	* @return  boolean
	*/
function email_domain($email)
{
	// Check if the email domain has a valid MX record
	return (bool) checkdnsrr(preg_replace('/^[^@]+@/', '', $email), 'MX');
}

/**
	* Validate email, RFC compliant version
	* Note: This function is LESS strict than valid_email. Choose carefully.
	*
	* @see  Originally by Cal Henderson, modified to fit Kohana syntax standards:
	* @see  http://www.iamcal.com/publish/articles/php/parsing_email/
	* @see  http://www.w3.org/Protocols/rfc822/
	*
	* @param   string   email address
	* @return  boolean
	*/
function email_rfc($email)
{
	$qtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]';
	$dtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]';
	$atom  = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+';
	$pair  = '\\x5c[\\x00-\\x7f]';

	$domain_literal = "\\x5b($dtext|$pair)*\\x5d";
	$quoted_string  = "\\x22($qtext|$pair)*\\x22";
	$sub_domain     = "($atom|$domain_literal)";
	$word           = "($atom|$quoted_string)";
	$domain         = "$sub_domain(\\x2e$sub_domain)*";
	$local_part     = "$word(\\x2e$word)*";
	$addr_spec      = "$local_part\\x40$domain";

	return (bool) preg_match('/^'.$addr_spec.'$/D', (string) $email);
}

/**
	* Validate URL
	*
	* @param   string   URL
	* @return  boolean
	*/
function url($url)
{
	return (bool) filter_var($url, FILTER_VALIDATE_URL, FILTER_FLAG_HOST_REQUIRED);
}

/**
	* Validate IP
	*
	* @param   string   IP address
	* @param   boolean  allow IPv6 addresses
	* @return  boolean
	*/
function ip($ip, $ipv6 = FALSE)
{
	// Do not allow private and reserved range IPs
	$flags = FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE;

	if ($ipv6 === TRUE)
		return (bool) filter_var($ip, FILTER_VALIDATE_IP, $flags);

	return (bool) filter_var($ip, FILTER_VALIDATE_IP, $flags | FILTER_FLAG_IPV4);
}

/**
	* Checks if a phone number is valid.
	*
	* @param   string   phone number to check
	* @return  boolean
	*/
function phone($number, $lengths = NULL)
{
	if ( ! is_array($lengths))
	{
		$lengths = array(7,10,11);
	}

	// Remove all non-digit characters from the number
	$number = preg_replace('/\D+/', '', $number);

	// Check if the number is within range
	return in_array(strlen($number), $lengths);
}

/**
	* Checks whether a string consists of alphabetical characters only.
	*
	* @param   string   input string
	* @param   boolean  trigger UTF-8 compatibility
	* @return  boolean
	*/
function alpha($str, $utf8 = FALSE)
{
	return ($utf8 === TRUE)
		? (bool) preg_match('/^\pL++$/uD', (string) $str)
		: ctype_alpha((string) $str);
}

/**
	* Checks whether a string consists of alphabetical characters and numbers only.
	*
	* @param   string   input string
	* @param   boolean  trigger UTF-8 compatibility
	* @return  boolean
	*/
function alpha_numeric($str, $utf8 = FALSE)
{
	return ($utf8 === TRUE)
		? (bool) preg_match('/^[\pL\pN]++$/uD', (string) $str)
		: ctype_alnum((string) $str);
}

/**
	* Checks whether a string consists of alphabetical characters, numbers, underscores and dashes only.
	*
	* @param   string   input string
	* @param   boolean  trigger UTF-8 compatibility
	* @return  boolean
	*/
function alpha_dash($str, $utf8 = FALSE)
{
	return ($utf8 === TRUE)
		? (bool) preg_match('/^[-\pL\pN_]++$/uD', (string) $str)
		: (bool) preg_match('/^[-a-z0-9_]++$/iD', (string) $str);
}

/**
	* Checks whether a string consists of digits only (no dots or dashes).
	*
	* @param   string   input string
	* @param   boolean  trigger UTF-8 compatibility
	* @return  boolean
	*/
function digit($str, $utf8 = FALSE)
{
	return ($utf8 === TRUE)
		? (bool) preg_match('/^\pN++$/uD', (string) $str)
		: ctype_digit((string) $str);
}

/**
	* Checks whether a string is a valid number (negative and decimal numbers allowed).
	*
	* @param   string   input string
	* @return  boolean
	*/
function numeric($str)
{
	return (is_numeric($str) AND preg_match('/^[-0-9.]++$/D', (string) $str));
}

/**
	* Checks whether a string is a valid text.
	*
	* @param   string   $str
	* @return  boolean
	*/
function standard_text($str)
{
	return (bool) preg_match('/^[-\pL\pN\pZ_]++$/uD', (string) $str);
}

?>