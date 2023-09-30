CREATE TABLE IF NOT EXISTS `Licence` (
  `UNID`	bigint(30) NOT NULL auto_increment,
  `LICENCE`	varchar(255) NOT NULL default '',
  `CMIN`	varchar(255) NOT NULL default '',
  `CMAX`	varchar(255) NOT NULL default '',
  `VALIDUNTIL`	date NOT NULL default '1981-03-03',
  `FORMATBILD`	int(1),
  `FORMATMP3`	int(1),
  `FORMATRING`	int(1),
  `FORMATVIDEO`	int(1),
  `FORMATJAVA`	int(1),
  `FORMATDOC`	int(1),
  `ADDED`	datetime NOT NULL default '1981-03-03 00-00-00',	
  `HITS`	bigint(30) default '1',
  PRIMARY KEY  (`UNID`),
  UNIQUE KEY `LICENCE` (`UNID`,`LICENCE`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=0;


INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` )
VALUES ( '', 'TESTLICENCE', '1.0', '1.1', '2006-06-30', '1', '1', '1', '1', '1', '1', '', '0')

INSERT DELAYED INTO `Licence` ( `UNID` , `LICENCE` , `CMIN` , `CMAX` , `VALIDUNTIL` , `FORMATBILD` , `FORMATMP3` , `FORMATRING` , `FORMATVIDEO` , `FORMATJAVA` , `FORMATDOC` , `ADDED` , `HITS` )
VALUES ( '', 'WELTMEISTER', '1.0', '1.1', '2007-06-30', '1', '1', '1', '1', '1', '1', '', '0')

