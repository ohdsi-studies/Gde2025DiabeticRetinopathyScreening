# ############################################################################ #
#
# This file defines connections to a results viewer database. 
#
# Carefully edit the below settings to match the environment in which you are 
# running the study package.
#
# ############################################################################ #

# Database Drivers ----------------------------------------------------
# Follow the directions here: https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html
# to download your drivers. Then note the location of this directory.

dbDriverLocation <- "~/OHDSI/DatabaseDrivers"

# Database Connection Settings ----------------------------------------------------

# Configure the connection for your CDM.
# 
# More details on how to do this are found here:
# https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html

resultsDbms <- 'postgresql'
resultsDbServer <- '127.0.0.1/dr_screening_results'
resultsDbUsername <- 'root'
resultsDbPassword <- ''
resultsDbPort <- 5432

# The below code creates and tests the connection details object. You can edit
# this to work with your database, so long as you use a method supported by
# the DatabaseConnector package.
resultsConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = resultsDbms,
  server = resultsDbServer,
  user = resultsDbUsername,
  password = resultsDbPassword,
  port = resultsDbPort,
  pathToDriver = dbDriverLocation)


# Database Storage Settings -------------------------------------------------------

# Results Schema: This is the schema where the shiny results will be stored to run
# the app locally.
resultsDatabaseSchema <- "public"