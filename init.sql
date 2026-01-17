-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS msi_database DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE msi_database;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. 用户表 (User)
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户唯一ID(自增主键)',
  `username` varchar(50) NOT NULL COMMENT '登录名(手机号/邮箱，唯一)',
  `password` varchar(100) NOT NULL COMMENT '加密密码(BCrypt 加密后存储，长度足够)',
  `nickname` varchar(50) NOT NULL COMMENT '用户昵称',
  `major` varchar(50) NOT NULL COMMENT '专业(如：计算机科学、临床医学)',
  `grade` int NOT NULL COMMENT '年级(如：2021、2022)',
  `interest_tags` varchar(200) DEFAULT '' COMMENT '兴趣标签(逗号分隔，如：Java,考研,健身)',
  `role` varchar(20) NOT NULL DEFAULT 'STUDENT' COMMENT '角色(STUDENT：普通学习者；TEACHER：辅导老师)',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '账号状态(0：禁用；1：正常)',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间(注册时间)',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间(自动更新)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`) COMMENT '用户名唯一索引(避免重复注册)',
  KEY `idx_role` (`role`) COMMENT '角色索引(方便按角色查询用户)',
  KEY `idx_status` (`status`) COMMENT '状态索引(过滤禁用账号)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表(存储用户基础信息)';

-- 2. 帖子表 (Post)
DROP TABLE IF EXISTS `post`;
CREATE TABLE `post` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '帖子唯一ID',
  `user_id` bigint NOT NULL COMMENT '发帖人ID(关联user表的id)',
  `title` varchar(200) NOT NULL COMMENT '帖子标题(最多200字)',
  `content` text NOT NULL COMMENT '帖子内容(长文本)',
  `view_count` int NOT NULL DEFAULT 0 COMMENT '浏览量(默认0)',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间(发帖时间)',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`) COMMENT '用户ID索引(查询用户的所有帖子)',
  KEY `idx_create_time` (`create_time`) COMMENT '创建时间索引(按时间排序查列表)',
  CONSTRAINT `fk_post_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子表(存储用户发布的帖子)';

-- 3. 评论表 (Comment)
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论唯一ID',
  `post_id` bigint NOT NULL COMMENT '关联帖子ID（对应post表的id）',
  `user_id` bigint NOT NULL COMMENT '评论人ID（对应user表的id）',
  `content` varchar(500) NOT NULL COMMENT '评论内容（最多500字）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`) COMMENT '帖子ID索引（查询某帖子的所有评论）',
  KEY `idx_user_id` (`user_id`) COMMENT '用户ID索引（查询某用户的所有评论）',
  CONSTRAINT `fk_comment_post_id` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论表（存储用户对帖子的评论）';

-- 4. 资源表 (Resource)
DROP TABLE IF EXISTS `resource`;
CREATE TABLE `resource` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '资源ID',
  `user_id` bigint NOT NULL COMMENT '上传者ID（关联user表）',
  `filename` varchar(255) NOT NULL COMMENT '原始文件名',
  `file_suffix` varchar(50) DEFAULT NULL COMMENT '文件后缀（如pdf、jpg）',
  `file_path` varchar(512) NOT NULL COMMENT '服务器存储路径',
  `file_url` varchar(512) NOT NULL COMMENT '访问URL',
  `file_size` bigint NOT NULL COMMENT '文件大小（字节）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`) COMMENT '用户ID索引（查询用户上传的资源）',
  CONSTRAINT `fk_resource_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资源表（存储用户上传的文件信息）';

-- 5. 打卡表 (Clock)
DROP TABLE IF EXISTS `clock`;
CREATE TABLE `clock` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '打卡ID',
  `user_id` bigint NOT NULL COMMENT '打卡用户ID(关联user表)',
  `content` varchar(500) NOT NULL COMMENT '打卡内容(最多500字)',
  `clock_date` date NOT NULL COMMENT '打卡日期(年月日，用于去重)',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '打卡时间(精确到时分秒)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`,`clock_date`) COMMENT '唯一约束：同一用户同一天只能打一次卡',
  KEY `idx_create_time` (`create_time`) COMMENT '按时间排序索引',
  CONSTRAINT `fk_clock_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='打卡表(存储用户每日打卡记录)';

SET FOREIGN_KEY_CHECKS = 1;
