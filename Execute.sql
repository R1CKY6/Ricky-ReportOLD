CREATE TABLE IF NOT EXISTS `ricky_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(46) DEFAULT NULL,
  `reportInfo` longtext DEFAULT '[]',
  `message` longtext DEFAULT '[]',
  `staff` longtext DEFAULT '[]',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
