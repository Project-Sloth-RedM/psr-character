SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `outfits`;
CREATE TABLE `outfits`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `cid` int NOT NULL,
  `label` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `clothing` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

ALTER TABLE `players` 
ADD COLUMN `skin` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL AFTER `last_updated`,
ADD COLUMN `outfit` int NULL DEFAULT NULL AFTER `skin`;

SET FOREIGN_KEY_CHECKS = 1;
