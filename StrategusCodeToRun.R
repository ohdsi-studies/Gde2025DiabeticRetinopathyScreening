# -------------------------------------------------------
#                     PLEASE READ
# -------------------------------------------------------
#
# You must call "renv::restore()" and follow the prompts
# to install all of the necessary R libraries to run this
# project. This is a one-time operation that you must do
# before running any code.
#
# !!! PLEASE RESTART R AFTER RUNNING renv::restore() !!!
#
# -------------------------------------------------------
# renv::restore()

## CONFIGURATION FOR RUNNING STUDY PACKAGE
# Uncomment the below lines and run it. This will copy the contents of "env.example.R"
# to "env.R". You must then edit "env.R" to set the values for your environment.
# 
# file.copy("env.example.R", "env.R")

# ENVIRONMENT SETTINGS NEEDED FOR RUNNING Strategus ------------
Sys.setenv("_JAVA_OPTIONS"="-Xmx4g") # Sets the Java maximum heap space to 4GB
Sys.setenv("VROOM_THREADS"=1) # Sets the number of threads to 1 to avoid deadlocks on file system

##=========== START OF INPUTS ==========

if(!file.exists("env.R")) {
  stop("Please copy env.example.R to env.R and edit the file to set your environment variables.")
}

# !!! WIP !!!
source("env.R")

# Run below and inspect before proceeding. If anything is missing or off, please fix it in the env.R file.
invisible({
  cat("Settings:\n")
  cat("-------------------------------\n")
  cat(sprintf("Study output folder:      %s\n", studyOutputDirectory))
  cat(sprintf("Database:                 %s\n", dbms))
  cat(sprintf("Database server:          %s\n", dbServer))
  cat(sprintf("Database username:        %s\n", dbUsername))
  cat(sprintf("Database password:        %s\n", ifelse(nchar(dbPassword) > 0, "********", "No password provided")))
  cat(sprintf("Database name:            %s\n", dbName))
  cat(sprintf("Database port:            %s\n", dbPort))
  cat(sprintf("CDM database schema:      %s\n", cdmDatabaseSchema))
  cat(sprintf("Work database schema:     %s\n", cohortDatabaseSchema))
  cat(sprintf("Database ID:              %s\n", databaseId))
  cat("-------------------------------\n")
})


# Create the connection for your CDM. Please note that 
# 
# More details on how to do this are found here:
# https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = dbms,
  server = dbServer,
  user = dbUsername,
  password = dbPassword,
  port = dbPort,
  pathToDriver = Sys.getenv('DATABASECONNECTOR_JAR_FOLDER'))


# You can use this snippet to test your connection
#conn <- DatabaseConnector::connect(connectionDetails)
#DatabaseConnector::disconnect(conn)

##=========== END OF INPUTS ==========
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/sampleStudyAnalysisSpecification.json"
)

executionSettings <- Strategus::createCdmExecutionSettings(
  workDatabaseSchema = workDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputLocation, databaseName, "strategusWork"),
  resultsFolder = file.path(outputLocation, databaseName, "strategusOutput"),
  minCellCount = minCellCount
)

if (!dir.exists(file.path(outputLocation, databaseName))) {
  dir.create(file.path(outputLocation, databaseName), recursive = T)
}
ParallelLogger::saveSettingsToJson(
  object = executionSettings,
  fileName = file.path(outputLocation, databaseName, "executionSettings.json")
)

Strategus::execute(
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings,
  connectionDetails = connectionDetails
)