--
-- Table structure for table `address`
--

DROP TABLE IF EXISTS `address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `address` (
  `addressID` bigint(20) NOT NULL AUTO_INCREMENT,
  `adIndex` varchar(255) NOT NULL,
  `adRegion` varchar(255) NOT NULL,
  `adZone` varchar(255) NOT NULL,
  `adCity` varchar(255) NOT NULL,
  `adTown` varchar(255) NOT NULL,
  `adStreet` varchar(255) NOT NULL,
  `adHouse` varchar(255) NOT NULL,
  `adBuilding` varchar(255) NOT NULL,
  `adApartment` varchar(255) NOT NULL,
  `adRegionCode` varchar(255) NOT NULL,
  `adZoneCode` varchar(255) NOT NULL,
  `adCityCode` varchar(255) NOT NULL,
  `adTownCode` varchar(255) NOT NULL,
  `adStreetCode` varchar(255) NOT NULL,
  UNIQUE KEY `addressID` (`addressID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `drivers`
--

DROP TABLE IF EXISTS `drivers`;

CREATE TABLE `drivers` (
  `driverID` bigint(20) NOT NULL AUTO_INCREMENT,
  `addedOn` date NOT NULL,
  `driverUID` varchar(35) DEFAULT NULL,
  `name` tinytext NOT NULL,
  `birthDate` date DEFAULT NULL,
  `address` tinytext NOT NULL,
  `phone` varchar(11) DEFAULT NULL,
  `phone1` varchar(11) DEFAULT NULL,
  `phone2` varchar(11) DEFAULT NULL,
  `phone3` varchar(11) DEFAULT NULL,
  `mobilePhone` varchar(11) DEFAULT NULL,
  `licenseNumber` varchar(75) NOT NULL,
  `licenseGivenBy` tinytext,
  `licenseGivenDate` date DEFAULT NULL,
  `passportType` enum('ПАСПОРТ РФ','ПАСПОРТ РБ','ЗАГРАНПАСПОРТ') NOT NULL DEFAULT 'ПАСПОРТ РФ',
  `passportSeries` varchar(4) NOT NULL,
  `passportNumber` varchar(7) NOT NULL,
  `passportGivenBy` tinytext,
  `passportGivenDate` date DEFAULT NULL,
  `userID` varchar(75) NOT NULL,
  `approved` datetime DEFAULT NULL,
  `newData` int(1) DEFAULT '1',
  `deleted` tinyint(1) DEFAULT NULL,
  `checkState` smallint(1) DEFAULT NULL,
  `allowState` smallint(1) DEFAULT NULL,
  `addressID` bigint(20) DEFAULT NULL,
  `missing` tinyint(1) unsigned DEFAULT '0',
  `missing_date` date DEFAULT NULL,
  `missing_times` tinyint(1) DEFAULT '0',
  `numDaysResoursesBlock` int(11) NOT NULL DEFAULT '0',
  `kkRaceNumDaysResourcesBlock` int(11) DEFAULT NULL,
  PRIMARY KEY (`driverID`),
  KEY `missing` (`missing`),
  KEY `passport` (`passportType`,`passportSeries`,`passportNumber`),
  KEY `userID` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `trucks`
--

DROP TABLE IF EXISTS `trucks`;

CREATE TABLE `trucks` (
  `truckID` bigint(20) NOT NULL AUTO_INCREMENT,
  `userID` varchar(75) NOT NULL,
  `addedOn` date NOT NULL,
  `truckName` varchar(50) NOT NULL,
  `truckFullNumber` varchar(12) NOT NULL,
  `VIN` varchar(17) DEFAULT NULL,
  `engineNumber` varchar(255) DEFAULT NULL,
  `bodyNumber` varchar(255) DEFAULT NULL,
  `chassisNumber` varchar(255) DEFAULT NULL,
  `VRCowner` tinytext,
  `VRCnumber` varchar(14) DEFAULT NULL,
  `approved` datetime DEFAULT NULL,
  `newData` int(1) DEFAULT '1',
  `deleted` tinyint(1) DEFAULT NULL,
  `phone` varchar(11) DEFAULT NULL,
  `checkState` tinyint(1) DEFAULT NULL,
  `allowState` tinyint(1) DEFAULT NULL,
  `numDaysResoursesBlock` int(11) NOT NULL DEFAULT '0',
  `mustHaveTrailer` tinyint(1) DEFAULT '1',
  `vehicleGroupUID` varchar(255) DEFAULT NULL,
  `topLoading` tinyint(1) DEFAULT '0',
  `sideLoading` tinyint(1) DEFAULT '0',
  `backLoading` tinyint(1) DEFAULT '0',
  `kkRaceNumDaysResourcesBlock` int(11) DEFAULT NULL,
  PRIMARY KEY (`truckID`),
  KEY `deleted` (`deleted`),
  KEY `truckNumber` (`truckFullNumber`),
  KEY `userID` (`userID`),
  KEY `VIN` (`VIN`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `trailers`;

CREATE TABLE `trailers` (
  `trailerID` bigint(20) NOT NULL AUTO_INCREMENT,
  `addedOn` date NOT NULL,
  `userID` varchar(75) NOT NULL,
  `trailerName` varchar(100) NOT NULL,
  `trailerFullNumber` varchar(11) NOT NULL,
  `VIN` varchar(17) DEFAULT NULL,
  `chassisNumber` varchar(255) DEFAULT NULL,
  `trailerType` varchar(15) NOT NULL DEFAULT 'tent',
  `deleted` int(1) DEFAULT NULL,
  `numDaysResoursesBlock` int(11) NOT NULL DEFAULT '0',
  `vehicleGroupUID` varchar(255) DEFAULT NULL,
  `topLoading` tinyint(1) DEFAULT '0',
  `sideLoading` tinyint(1) DEFAULT '0',
  `backLoading` tinyint(1) DEFAULT '1',
  `kkRaceNumDaysResourcesBlock` int(11) DEFAULT NULL,
  PRIMARY KEY (`trailerID`),
  KEY `trailerType` (`trailerType`),
  KEY `userID` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `kkTypeTrailers`
--

DROP TABLE IF EXISTS `kkTypeTrailers`;

CREATE TABLE `kkTypeTrailers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` varchar(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `markedDelete` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid_UNIQUE` (`uid`),
  KEY `index_kkTypeTrailers_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for table `registry`
--

DROP TABLE IF EXISTS `registry`;

CREATE TABLE `registry` (
  `email` varchar(75) NOT NULL,
  `created` datetime NOT NULL DEFAULT '2009-07-23 00:01:00',
  `approved` datetime DEFAULT NULL,
  `companyType` varchar(10) NOT NULL,
  `companyName` tinytext NOT NULL,
  `companyAddress` tinytext NOT NULL,
  `companyPostalAddress` tinytext NOT NULL,
  `ownerType` varchar(15) NOT NULL,
  `phone1` tinytext NOT NULL,
  `phone2` tinytext,
  `fax` tinytext,
  `homepage` tinytext,
  `person` tinytext NOT NULL,
  `authorizedPerson` tinytext NOT NULL,
  `authorizedPersonStatus` tinytext NOT NULL,
  `authorizationReason` tinytext NOT NULL,
  `payment` varchar(35) DEFAULT NULL,
  `nds` tinyint(2) DEFAULT NULL,
  `selfPark` int(11) DEFAULT NULL,
  `attractPark` int(11) DEFAULT NULL,
  `autopark` text,
  `moreInfo` text,
  `blocked` tinyint(1) DEFAULT NULL,
  `rating` float DEFAULT NULL,
  `dispatcherAuthStatusID` bigint(20) DEFAULT NULL,
  `totalInsurance` tinyint(1) DEFAULT NULL,
  `discount` double NOT NULL DEFAULT '0',
  `ban` datetime DEFAULT NULL,
  `dispatcherUID` varchar(35) DEFAULT NULL,
  `contractID` varchar(150) DEFAULT NULL,
  `INN` varchar(12) DEFAULT NULL,
  `KPP` varchar(9) DEFAULT NULL,
  `op_account` varchar(20) DEFAULT NULL,
  `cor_account` varchar(20) DEFAULT NULL,
  `bankName` tinytext,
  `BIK` varchar(9) DEFAULT NULL,
  `OGRN` varchar(13) NOT NULL,
  `OGRNdat` date DEFAULT NULL,
  `OKVED` varchar(50) NOT NULL,
  `warrantyNum` varchar(20) DEFAULT NULL,
  `warrantyDat` date DEFAULT NULL,
  `SMScellphone` tinytext,
  `subscribeEmail` varchar(50) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `citiesInsurance` text,
  `reqWork` tinyint(1) DEFAULT NULL,
  `sleep` date DEFAULT NULL,
  `managerID` int(11) DEFAULT NULL,
  `addressID` bigint(20) DEFAULT NULL,
  `postalAddressID` bigint(20) DEFAULT NULL,
  `contract_num` varchar(255) DEFAULT NULL,
  `contract_date` date DEFAULT NULL,
  `contract_expiry_date` date DEFAULT NULL,
  `uid` varchar(36) DEFAULT NULL,
  `kk_contract_number` varchar(255) DEFAULT NULL,
  `kk_contract_date` date DEFAULT NULL,
  `kk_contract_expiry_date` date DEFAULT NULL,
  `category_rating_access` int(11) DEFAULT NULL,
  `rating_date` date DEFAULT NULL,
  `receiveNotificationsAboutPolls` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`email`),
  KEY `addressID` (`addressID`),
  KEY `index_registry_on_uid` (`uid`),
  KEY `managerID` (`managerID`),
  KEY `postalAddressID` (`postalAddressID`),
  KEY `reqWork` (`reqWork`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `assets_resources`
--

DROP TABLE IF EXISTS `assets_resources`;

CREATE TABLE `assets_resources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created` datetime DEFAULT NULL,
  `user_id` varchar(50) DEFAULT NULL,
  `type_resource` enum('driver','truck','trailer') DEFAULT NULL,
  `asset_url` varchar(255) DEFAULT NULL,
  `file_size` decimal(10,1) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `num_rows_download` int(11) DEFAULT NULL,
  `num_rows_errors` int(11) DEFAULT NULL,
  `info` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for table `conditionallyAdmittedDrivers`
--

DROP TABLE IF EXISTS `conditionallyAdmittedDrivers`;

CREATE TABLE `conditionallyAdmittedDrivers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `addedOn` datetime DEFAULT NULL,
  `driverID` bigint(20) DEFAULT NULL,
  `info` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for table `kkTonnage`
--

DROP TABLE IF EXISTS `kkTonnage`;

CREATE TABLE `kkTonnage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` varchar(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `tonnageNumber` float DEFAULT NULL,
  `trailerRequiredTonnage` tinyint(1) DEFAULT NULL,
  `tenderDLT` tinyint(1) DEFAULT NULL,
  `markedDelete` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_kkTonnage_on_uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for table `kkVolume`
--

DROP TABLE IF EXISTS `kkVolume`;

CREATE TABLE `kkVolume` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` varchar(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `volumeNumber` float DEFAULT NULL,
  `trailerRequiredVolume` tinyint(1) DEFAULT NULL,
  `tenderDLT` tinyint(1) DEFAULT NULL,
  `markedDelete` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `sql_names`
--

DROP TABLE IF EXISTS `sql_names`;

CREATE TABLE `sql_names` (
  `name` varchar(100) NOT NULL,
  `kind` varchar(20) NOT NULL,
  KEY `kind` (`kind`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `oldNewUIDsDispatchers`
--

DROP TABLE IF EXISTS `oldNewUIDsDispatchers`;

CREATE TABLE `oldNewUIDsDispatchers` (
  `email` varchar(75) DEFAULT NULL,
  `companyName` tinytext,
  `INN` varchar(12) DEFAULT NULL,
  `oldUID` varchar(36) DEFAULT NULL,
  `newUID` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for table `kkExtParamsAddress`
--

DROP TABLE IF EXISTS `kkExtParamsAddress`;

CREATE TABLE `kkExtParamsAddress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `addressID` int(11) DEFAULT NULL,
  `time_zone` int(11) DEFAULT NULL,
  `KLADR` decimal(25,0) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_kkExtParamsAddress_on_addressID` (`addressID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп структуры для таблица intercity.objectsLog
--
DROP TABLE IF EXISTS `objectsLog`;

CREATE TABLE IF NOT EXISTS `objectsLog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `objectDate` datetime NOT NULL,
  `action` varchar(20) NOT NULL,
  `author` varchar(75) NOT NULL,
  `objectID` int(11) NOT NULL,
  `newObjectID` bigint(20) DEFAULT NULL,
  `objectType` smallint(6) NOT NULL,
  `comment` text,
  PRIMARY KEY (`id`),
  KEY `objectID` (`objectID`),
  KEY `newObjectID` (`newObjectID`),
  KEY `objectType` (`objectType`),
  KEY `action` (`action`)
) ENGINE=InnoDB AUTO_INCREMENT=47705 DEFAULT CHARSET=utf8;

--
-- Table structure for table `driverProxy`
--

DROP TABLE IF EXISTS `driverProxy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `driverProxy` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `driverID` bigint(20) unsigned DEFAULT NULL,
  `file` varchar(41) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `dateFrom` date DEFAULT NULL,
  `dateTo` date DEFAULT NULL,
  `copy` tinyint(1) unsigned DEFAULT '0',
  `origin` tinyint(1) unsigned DEFAULT '0',
  `copy_date` date DEFAULT NULL,
  `deleted` tinyint(1) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `copy` (`copy`),
  KEY `deleted` (`deleted`),
  KEY `driverID` (`driverID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
