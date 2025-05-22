-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: k12c105.p.ssafy.io    Database: Buds
-- ------------------------------------------------------
-- Server version	8.4.5

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activities` (
  `activity_id` int NOT NULL AUTO_INCREMENT,
  `bonus_letter` int DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `name` enum('TEXT','VISIT_PAGE','VISIT_PLACE','VOICE_TEXT','WAKE','WALK') NOT NULL,
  PRIMARY KEY (`activity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `admin_id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `admin_email` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('ADMIN','ANONYMOUS','USER') NOT NULL,
  PRIMARY KEY (`admin_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2100000524 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `answers`
--

DROP TABLE IF EXISTS `answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `answers` (
  `answer_id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `content` varchar(255) NOT NULL,
  PRIMARY KEY (`answer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `badges`
--

DROP TABLE IF EXISTS `badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `badges` (
  `badge_id` int NOT NULL AUTO_INCREMENT,
  `badge_type` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`badge_id`),
  CONSTRAINT `badges_chk_1` CHECK ((`badge_type` in (_utf8mb4'ACTIVE',_utf8mb4'EMOTION')))
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calendar_badges`
--

DROP TABLE IF EXISTS `calendar_badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `calendar_badges` (
  `badge_id` int NOT NULL,
  `calendar_id` int NOT NULL,
  PRIMARY KEY (`badge_id`,`calendar_id`),
  KEY `FKeix9hfb5s5hkgxf64e76744fk` (`calendar_id`),
  CONSTRAINT `FK40gdk6f3t5i7bk8cqfli8wgk3` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`badge_id`),
  CONSTRAINT `FKeix9hfb5s5hkgxf64e76744fk` FOREIGN KEY (`calendar_id`) REFERENCES `calendars` (`calendar_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calendars`
--

DROP TABLE IF EXISTS `calendars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `calendars` (
  `calendar_id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `badge` varchar(255) DEFAULT NULL,
  `date` date NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`calendar_id`),
  KEY `FK2ef443fpfyuaay9nc09tvhjre` (`user_id`),
  CONSTRAINT `FK2ef443fpfyuaay9nc09tvhjre` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `diaries`
--

DROP TABLE IF EXISTS `diaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diaries` (
  `diary_id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `active_diary` varchar(255) NOT NULL,
  `date` datetime(6) NOT NULL,
  `emotion_diary` varchar(255) NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`diary_id`),
  KEY `FKki7hoimuu910cy56y2695to5e` (`user_id`),
  CONSTRAINT `FKki7hoimuu910cy56y2695to5e` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `letter_favorites`
--

DROP TABLE IF EXISTS `letter_favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `letter_favorites` (
  `created_at` datetime(6) NOT NULL,
  `letter_id` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`letter_id`,`user_id`),
  KEY `FKohvc998qmiq9vlht3kvw0qrxs` (`user_id`),
  CONSTRAINT `FKo66p61ysm6g6g2ed13po8g0vy` FOREIGN KEY (`letter_id`) REFERENCES `letters` (`letter_id`),
  CONSTRAINT `FKohvc998qmiq9vlht3kvw0qrxs` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `letters`
--

DROP TABLE IF EXISTS `letters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `letters` (
  `letter_id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `content` varchar(255) DEFAULT NULL,
  `is_tag_based` bit(1) NOT NULL,
  `status` enum('READ','UNREAD') NOT NULL,
  `receiver` int NOT NULL,
  `sender` int NOT NULL,
  `is_scrapped` bit(1) DEFAULT NULL,
  `is_answered` bit(1) DEFAULT NULL,
  PRIMARY KEY (`letter_id`),
  KEY `FK6njsg4ikv2u3cfybpfkpnuno4` (`receiver`),
  KEY `FKivc0wka4vnugpk5l0uqn17opq` (`sender`),
  CONSTRAINT `FK6njsg4ikv2u3cfybpfkpnuno4` FOREIGN KEY (`receiver`) REFERENCES `users` (`user_id`),
  CONSTRAINT `FKivc0wka4vnugpk5l0uqn17opq` FOREIGN KEY (`sender`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=196 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `matches`
--

DROP TABLE IF EXISTS `matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `matches` (
  `user1_id` int NOT NULL,
  `user2_id` int NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`user1_id`,`user2_id`),
  KEY `FKgxaf471cy6rk84ux6avpw5vb0` (`user2_id`),
  CONSTRAINT `FKgxaf471cy6rk84ux6avpw5vb0` FOREIGN KEY (`user2_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `FKow9p2p6lb04rmjphffgyc48y` FOREIGN KEY (`user1_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questions`
--

DROP TABLE IF EXISTS `questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `questions` (
  `question_id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `content` varchar(255) NOT NULL,
  `status` enum('ANSWERED','UNANSWERED') NOT NULL DEFAULT 'UNANSWERED',
  `subject` varchar(255) NOT NULL,
  `answer_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`question_id`),
  UNIQUE KEY `UK9ypaq46le8hdelyolqfaoxfdy` (`answer_id`),
  KEY `FKjoo8hp6d3gfwctr68dl2iaemj` (`user_id`),
  CONSTRAINT `FKi9m5qugsha5u5335en1f998h1` FOREIGN KEY (`answer_id`) REFERENCES `answers` (`answer_id`),
  CONSTRAINT `FKjoo8hp6d3gfwctr68dl2iaemj` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quotes`
--

DROP TABLE IF EXISTS `quotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quotes` (
  `quote_id` int NOT NULL AUTO_INCREMENT,
  `sentence` varchar(255) DEFAULT NULL,
  `speaker` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`quote_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `random_names`
--

DROP TABLE IF EXISTS `random_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `random_names` (
  `random_name_id` int NOT NULL AUTO_INCREMENT,
  `assigned_at` datetime(6) DEFAULT NULL,
  `random_name` varchar(20) NOT NULL,
  `status` enum('AVAILABLE','USED') NOT NULL DEFAULT 'AVAILABLE',
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`random_name_id`),
  KEY `FKj2vstxm7eii5hawfr583r2jic` (`user_id`),
  CONSTRAINT `FKj2vstxm7eii5hawfr583r2jic` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2545 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag_types`
--

DROP TABLE IF EXISTS `tag_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tag_types` (
  `tag_type_id` int NOT NULL AUTO_INCREMENT,
  `display_name` varchar(255) NOT NULL,
  PRIMARY KEY (`tag_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tags` (
  `tag_id` int NOT NULL AUTO_INCREMENT,
  `tag_name` enum('CERTIFICATION','COMIC','COOKING','FASHION','GAME','JOB','MOVIE','MUSIC','READING','SPORTS') NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`tag_id`),
  KEY `FKpsynysaxl7cyw8mr5c8xevneg` (`user_id`),
  CONSTRAINT `FKpsynysaxl7cyw8mr5c8xevneg` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_activities`
--

DROP TABLE IF EXISTS `user_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_activities` (
  `user_activity_id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `proof` varchar(255) DEFAULT NULL,
  `status` enum('DONE','PENDING') NOT NULL,
  `activity_id` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`user_activity_id`),
  KEY `FK234dtcelry3pf97oi0hmo1cv6` (`activity_id`),
  KEY `FKbe7yq8t74yxeoarmxlxevoped` (`user_id`),
  CONSTRAINT `FK234dtcelry3pf97oi0hmo1cv6` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`activity_id`),
  CONSTRAINT `FKbe7yq8t74yxeoarmxlxevoped` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_page_visits`
--

DROP TABLE IF EXISTS `user_page_visits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_page_visits` (
  `page_name` enum('LETTER','MAIN','MYPAGE') NOT NULL,
  `user_id` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`page_name`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_tags`
--

DROP TABLE IF EXISTS `user_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_tags` (
  `user_tag_id` int NOT NULL AUTO_INCREMENT,
  `tag_type_id` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`user_tag_id`),
  KEY `FKis5a1swjkalvyj07s996rwm6b` (`tag_type_id`),
  KEY `FKdylhtw3qjb2nj40xp50b0p495` (`user_id`),
  CONSTRAINT `FKdylhtw3qjb2nj40xp50b0p495` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `FKis5a1swjkalvyj07s996rwm6b` FOREIGN KEY (`tag_type_id`) REFERENCES `tag_types` (`tag_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `expression_score` int NOT NULL,
  `is_active` bit(1) NOT NULL,
  `is_completed` enum('DONE','PENDING') NOT NULL,
  `letter_cnt` int NOT NULL,
  `openness_score` int NOT NULL,
  `password` varchar(255) NOT NULL,
  `quietness_score` int NOT NULL,
  `role` enum('ADMIN','ANONYMOUS','USER') NOT NULL,
  `routine_score` int NOT NULL,
  `seclusion_score` int NOT NULL,
  `sociability_score` int NOT NULL,
  `user_character` enum('CAT','DUCK','FROG','GECKO','MARMOT','RABBIT') NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2100000549 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wakes`
--

DROP TABLE IF EXISTS `wakes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wakes` (
  `wake_id` int NOT NULL AUTO_INCREMENT,
  `wake_time` varchar(255) DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`wake_id`),
  KEY `FKi1ohuejlkcklohml60d6uor26` (`user_id`),
  CONSTRAINT `FKi1ohuejlkcklohml60d6uor26` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-05-22  9:40:12
