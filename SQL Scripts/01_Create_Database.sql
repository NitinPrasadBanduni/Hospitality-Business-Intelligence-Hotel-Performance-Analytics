/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
Author  : Nitin Prasad
Database: Hospitality_BI
File    : 01_Create_Database.sql

Description:
Creates the project database and selects it for use.
The database is recreated during development to provide a
clean environment for building and testing the project.

===========================================================================*/


-- ========================================
-- Drop Database if it already exists
-- ========================================

DROP DATABASE IF EXISTS Hospitality_BI;


-- ========================================
-- Create Database and Access Database
-- ========================================

CREATE DATABASE Hospitality_BI;

USE Hospitality_BI;
