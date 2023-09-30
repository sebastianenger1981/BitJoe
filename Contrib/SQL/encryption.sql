CREATE TABLE IF NOT EXISTS `Crypto` (
  `UNID`	bigint(30) NOT NULL auto_increment,
  `PUBLICKEY`	varchar(255) NOT NULL default '',
  `PRIVATEKEY`	varchar(255) NOT NULL default '',
  `VALIDUNTIL`	date NOT NULL default '1981-03-03',
  `ADDED`	datetime NOT NULL default '1981-03-03 00-00-00',	
  `HITS`	bigint(30) default '0',
  PRIMARY KEY  (`UNID`),
  UNIQUE KEY `LICENCE` (`UNID`,`PRIVATEKEY`, `PUBLICKEY`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=0;



INSERT DELAYED INTO `Crypto` ( `UNID` , `PUBLICKEY` , `PRIVATEKEY` ,`VALIDUNTIL`, `ADDED` , `HITS` )
VALUES ( "", "", "", "", "", "")
