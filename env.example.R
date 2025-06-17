# ############################################################################ #
#
# Carefully edit the below settings to match the environment in which you are 
# running the study package.
#
# ############################################################################ #

# Environment-related Tweaks----------------------------------------------------

runInclusionStats <- TRUE

# Database Drivers ----------------------------------------------------
# Follow the directions here: https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html
# to download your drivers. Then note the location of this directory.

dbDriverLocation <- "~/OHDSI/DatabaseDrivers"

# Database Connection Settings ----------------------------------------------------

# Configure the connection for your CDM.
# 
# More details on how to do this are found here:
# https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html

dbms <- 'postgresql'
dbConnectionString <- 'hostname.net/db'
dbUsername <- 'username'
dbPassword <- 'password'
dbPort <- 5432

# The below code creates and tests the connection details object. You can edit
# this to work with your database, so long as you use a method supported by
# the DatabaseConnector package.
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = dbms,
  server = dbServer,
  user = dbUsername,
  password = dbPassword,
  port = dbPort,
  pathToDriver = dbDriverLocation)



# Database Storage Settings -------------------------------------------------------

# CDM Database Schema: This is the OMOP CDM schema that contains the CDM tables
cdmDatabaseSchema <- "dbo"

# Work Database Schema: This is the schema where the study will create its tables
# and store its results.
workDatabaseSchema <- "res"

# Results Schema: This is the schema where the shiny results will be stored to run
# the app locally. This will only be used if you want to inspect results on your
# local machine.
resultsDatabaseSchema <- "res_view"

# Cohort Table Name: This is the name of the table where the study will create its cohorts.
cohortTableName <- "dr_screening"


# Misc. Settings ----------------------------------------------------------

# Database Name: This is used only as a folder name for results from the study
databaseName <- "DR_Screening"

# Min Cell Count: This is the minimum cell count when exporting data.
minCellCount <- 5

# Output Location: This is the location where the study will store its results.
# By default it will store results in the current working directory in a 
# directory called "results".
outputLocation <- file.path(getwd(), "results")


################################################################################
## ️⚠ The below settings only need to be changed if you have execution issues.  #
################################################################################

# Environmental Variables -------------------------------------------------

# Maximum Heap Size: This is the maximum heap size for Java.
javaMaxHeapSize <- "4g"

# he number of threads to 1 to avoid deadlocks on file system
vroomThreadCount <- 1