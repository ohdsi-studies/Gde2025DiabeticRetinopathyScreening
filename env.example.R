# Change the values below to match your environment


# javaLocation <- "C:/Program Files/Microsoft/jdk-17.0.8.101-hotspot"
javaLocation <- ""

## Database Drivers
# Follow the directions here: https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html
# to download your drivers. Then note the location of this directory.
# 
# dbDriverLocation <- "C:/Users/{username}/Documents/OHDSI/DatabaseDrivers"
dbDriverLocation <- "~/OHDSI/DatabaseDrivers"

## Database
dbms <- 'postgresql'
dbHost <- 'cdm.address.net/db_name'
dbUsername <- 'username'
dbPassword <- 'password'
dbName <- 'db_name'
dbPort <- 5432

cdmDatabaseSchema <- "dbo"
workDatabaseSchema <- "res"
tablePrefix <- "cm_example"

databaseName <- "DR_Screening"  # Only used as a folder name for results from the study
minCellCount <- 5  # Minimum cell count when exporting data

# Do not change
outputLocation <- file.path(getwd(), "results")
minCellCount <- 5  # Do not change this value
cohortTableName <- "dr_screening"



