/*
 Navicat Premium Data Transfer

 Source Server         : Localhost
 Source Server Type    : MySQL
 Source Server Version : 50726
 Source Host           : localhost:3306
 Source Schema         : atm

 Target Server Type    : MySQL
 Target Server Version : 50726
 File Encoding         : 65001

 Date: 12/04/2021 01:57:22
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for bancos
-- ----------------------------
DROP TABLE IF EXISTS `bancos`;
CREATE TABLE `bancos`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigoBanco` int(11) NOT NULL,
  `codigoPlazaBancaria` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for clientes
-- ----------------------------
DROP TABLE IF EXISTS `clientes`;
CREATE TABLE `clientes`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `correo` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `telefono` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cuentas
-- ----------------------------
DROP TABLE IF EXISTS `cuentas`;
CREATE TABLE `cuentas`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `banco_id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `numeroCuenta` int(11) NOT NULL,
  `digitoControl` int(1) NOT NULL,
  `tipo` enum('ahorros','cheques') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `tasaInteres` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_banco_id`(`banco_id`) USING BTREE,
  INDEX `fk_cliente_id`(`cliente_id`) USING BTREE,
  CONSTRAINT `fk_banco_id` FOREIGN KEY (`banco_id`) REFERENCES `bancos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for tarjetas
-- ----------------------------
DROP TABLE IF EXISTS `tarjetas`;
CREATE TABLE `tarjetas`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `numeroTarjeta` int(16) NOT NULL,
  `mesExpiracion` int(11) NOT NULL,
  `anioExpiracion` int(11) NOT NULL,
  `ccv` int(3) NOT NULL,
  `cuenta_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_cuenta_id`(`cuenta_id`) USING BTREE,
  CONSTRAINT `fk_cuenta_id` FOREIGN KEY (`cuenta_id`) REFERENCES `cuentas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for transacciones
-- ----------------------------
DROP TABLE IF EXISTS `transacciones`;
CREATE TABLE `transacciones`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` datetime(0) NOT NULL,
  `importe` double NOT NULL,
  `concepto` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `tipo` enum('substraccion','adicion') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `cuentaEmisora_id` int(11) NOT NULL,
  `numeroReferencia` int(11) NOT NULL,
  `cuentaBeneficiaria_id` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_cuentaBeneficiaria_id`(`cuentaBeneficiaria_id`) USING BTREE,
  INDEX `fk_cuentaEmisor_id`(`cuentaEmisora_id`) USING BTREE,
  CONSTRAINT `fk_cuentaBeneficiaria_id` FOREIGN KEY (`cuentaBeneficiaria_id`) REFERENCES `cuentas` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_cuentaEmisor_id` FOREIGN KEY (`cuentaEmisora_id`) REFERENCES `cuentas` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
