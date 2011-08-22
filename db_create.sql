CREATE DATABASE openurlrec;
USE openurlrec;

# Dump of table articles
# ------------------------------------------------------------

CREATE TABLE `articles` (
  `id` varchar(350) NOT NULL DEFAULT '',
  `userEncryptedIP` varchar(30) DEFAULT NULL,
  `institutionResolverID` int(11) DEFAULT NULL,
  `aulast` varchar(300) DEFAULT NULL,
  `au` varchar(450) DEFAULT NULL,
  `atitle` varchar(500) DEFAULT NULL,
  `jtitle` varchar(500) DEFAULT NULL,
  `adate` varchar(100) DEFAULT NULL,
  `vol` varchar(100) DEFAULT NULL,
  `issue` varchar(100) DEFAULT NULL,
  `spage` varchar(100) DEFAULT NULL,
  `issn` varchar(70) DEFAULT NULL,
  `eissn` varchar(70) DEFAULT NULL,
  `isbn` varchar(200) DEFAULT NULL,
  `doi` varchar(100) DEFAULT NULL,
  `genre` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;



# Dump of table aweights
# ------------------------------------------------------------

CREATE TABLE `aweights` (
  `artid` varchar(350) NOT NULL,
  `atitle` varchar(500) DEFAULT NULL,
  `weight` int(11) DEFAULT NULL,
  PRIMARY KEY (`artid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;



# Dump of table sessions
# ------------------------------------------------------------

CREATE TABLE `sessions` (
  `artid` varchar(350) DEFAULT NULL,
  `sessionid` int(11) DEFAULT NULL,
  `atitle` varchar(500) DEFAULT NULL,
  KEY `artiid_index` (`artid`),
  KEY `sessionid_index` (`sessionid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

