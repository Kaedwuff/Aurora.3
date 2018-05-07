--
-- Adds a new table to load the regulations ("laws") from
--
CREATE TABLE `ss13_law` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`law_id` VARCHAR(4) NOT NULL,
	`name` VARCHAR(50) NOT NULL,
	`description` VARCHAR(500) NOT NULL,
	`min_fine` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`max_fine` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`min_brig_time` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`max_brig_time` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`severity` INT(10) UNSIGNED NULL DEFAULT '0',
	`felony` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`deleted_at` DATETIME NULL DEFAULT NULL,
	PRIMARY KEY (`id`),
	UNIQUE INDEX `UNIQUE LAW` (`law_id`)
)
ENGINE=InnoDB;