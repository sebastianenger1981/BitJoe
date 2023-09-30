<?php

/**
 * PHP5-API zum Zugriff auf den easyKonto Online Web-service
 *
 * @copyright Copyright &copy; 2006-2007 by Oliver Siegmar
 * @license http://www.easykonto.de/agb.htm Proprietäre Lizenz
 * @package easykonto
 * @version 1.0 - $LastChangedDate: 2007-07-17 18:48:01 +0200 (Tue, 17 Jul 2007) $
 *
 */
class Easykonto_Check
{

    /**
     * @var resource Das cURL resource handle
     */
    private $curl;

    /**
     * @var string Die Basis-URL des Web-Services
     */
    private $base_url;

    /**
     * Initialisiert die von dieser Klasse verwendete cURL-Bibliothek mit
     * den angegebenen Zugriffsdaten.
     *
     * @param string $username Der Benutzername, der für den Zugriff auf die
     *                         easyKonto Online-Schnittstelle verwendet werden
     *                         soll
     * @param string $password Das Passwort, der für den Zugriff auf die
     *                         easyKonto Online-Schnittstelle verwendet werden
     *                         soll
     * @param bool $use_ssl Ob SSL beim Zugriff verwendet werden soll
     */
    function __construct($username, $password, $use_ssl)
    {
        $this->curl = curl_init();
        curl_setopt($this->curl, CURLOPT_HEADER, 0);
        curl_setopt($this->curl, CURLOPT_NOBODY, 0);
        curl_setopt($this->curl, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($this->curl, CURLOPT_USERPWD, $username . ':' . $password);

        $this->base_url = (($use_ssl) ? 'https' : 'http') .
            '://www.easykonto.de/services/';
    }

    /**
     * Gibt alle von dieser Klasse geöffneten Resourcen wieder frei
     * @see function close
     */
    function __destruct()
    {
        $this->close();
    }

    /**
     * Gibt alle von dieser Klasse geöffneten Resourcen wieder frei
     */
    function close()
    {
        if (!is_null($this->curl))
            curl_close($this->curl);

        $this->curl = null;
    }

    /**
     * Setzt die Proxy-Konfiguration.
     *
     * Wenn die easyKonto Online-Schnittstelle über einen Proxy aufgerufen
     * werden soll, so muss durch diese Methode der Proxy und ggf. die
     * Authentifizierungs-Daten gesetzt werden.
     *
     * Beispiel:
     * <code>
     * <?php
     *     // ...
     *     $easykonto->set_proxy('http://myproxy.de:3128');
     *     // oder:
     *     $easykonto->set_proxy('http://myproxy.de', 'benutzer', 'passwort');
     *     // ...
     * ?>
     * </code>
     *
     * @param string $url Die Proxy-URL (komplette http-URL ggf. mit Port)
     * @param string $username Der Benutzername für den Proxy
     * @param string $password Das Passwort für den Proxy
     */
    function set_proxy($url, $username = null, $password = null)
    {
        curl_setopt($this->curl, CURLOPT_PROXY, $url);

        if (!is_null($username) && !is_null($password))
            curl_setopt($this->curl, CURLOPT_PROXYUSERPWD,
                $username . ':' . $password);
    }

    /**
     * Ruft die übergebene URL auf und gibt die Service-Antwort (ggf. als
     * deserialisiertes WDDX-Dokument) zurück.
     *
     * @param string $url Die aufzurufende URL
     * @param bool $deserialize Ob die zurückgegebenen Daten deserialisiert
     *                          werden sollen
     * @return mixed Die Service-Antwort (als Code oder als deserialisiertes
     *               WDDX)
     */
    private function get_data($url, $deserialize = true)
    {
        curl_setopt($this->curl, CURLOPT_URL, $url);
        $r = curl_exec($this->curl);
        if (curl_errno($this->curl))
        {
            // echo curl_error($this->curl);
            return null;
        }
        return ($deserialize) ? wddx_deserialize($r) : $r;
    }

    /**
     * Prüft eine Bankverbindung anhand der BLZ (Bankleitzahl) sowie der
     * Kontonummer
     *
     * @param $blz int Die zu prüfende BLZ
     * @param $kto int Die zu prüfende Kontonummer
     * @param $info bool Ob auch Zusatzinformationen zurückgegeben werden
     *                   sollen
     * @return mixed Returncode oder, sofern $info==true, assoziatives Array
     *               mit zusätzlichen Informationen
     */
    function konto_check_blzkto($blz, $kto, $info = false)
    {
        $url = sprintf($this->base_url . 'kontocheck?blz=%s&kto=%s&viewmode=%s',
            $blz, $kto, ($info) ? 'wddx' : 'code');
        return $this->get_data($url, $info);
    }

    /**
     * Prüft eine Bankverbindung anhand der IBAN (International Bank Account
     * Number)
     *
     * @param $iban string Die zu prüfende IBAN
     * @param $info bool Ob auch Zusatzinformationen zurückgegeben werden sollen
     * @return mixed Returncode oder, sofern $info==true, assoziatives Array
     *               mit zusätzlichen Informationen
     */
    function konto_check_iban($iban, $info = false)
    {
        $url = sprintf($this->base_url . 'kontocheck?iban=%s&viewmode=%s',
            $iban, ($info) ? 'wddx' : 'code');
        return $this->get_data($url, $info);
    }

    /**
     * Liefert Informationen über die zur angegebenen BLZ (Bankleitzahl)
     * gehörende Bank
     *
     * @param $blz int Die zu beauskunftende BLZ
     * @return array Assoziatives array mit den Informationen zur Bank
     */
    function bank_info_blz($blz)
    {
        $url = sprintf($this->base_url . 'bankinfo?viewmode=wddx&blz=%s',
            $iban);
        return $this->get_data($url);
    }

    /**
     * Liefert Informationen über die zur angegebenen IBAN (International Bank
     * Account Number) gehörende Bank
     *
     * @param $iban int Die zu beauskunftende IBAN
     * @return array Assoziatives array mit den Informationen zur Bank
     */
    function bank_info_iban($iban)
    {
        $url = sprintf($this->base_url . 'bankinfo?viewmode=wddx&iban=%s',
            $iban);
        return $this->get_data($url);
    }

}

if (!function_exists('wddx_deserialize'))
{
    /**
     * Clone implementation of wddx_deserialize
     */
    function wddx_deserialize($xmlpacket)
    {
        if ($xmlpacket instanceof SimpleXMLElement)
        {
            if (!empty($xmlpacket->struct))
            {
                $struct = array();
                foreach ($xmlpacket->xpath("struct/var") as $var)
                {
                    if (!empty($var["name"]))
                    {
                        $key = (string) $var["name"];
                        $struct[$key] = wddx_deserialize($var);
                    }
                }
                return $struct;
            }
            else if (!empty($xmlpacket->array))
            {
                $array = array();
                foreach ($xmlpacket->xpath("array/*") as $var)
                {
                    array_push($array, wddx_deserialize($var));
                }
                return $array;
            }
            else if (!empty($xmlpacket->string))
            {
                return (string) $xmlpacket->string;
            }
            else if (!empty($xmlpacket->number))
            {
                return (int) $xmlpacket->number;
            }
            else
            {
                if (is_numeric((string) $xmlpacket))
                {
                    return (int) $xmlpacket;
                }
                else
                {
                    return (string) $xmlpacket;
                }
            }
        }
        else
        {
            $sxe = simplexml_load_string($xmlpacket);
            $datanode = $sxe->xpath("/wddxPacket[@version='1.0']/data");
            return wddx_deserialize($datanode[0]);
        }
    }
}

?>
