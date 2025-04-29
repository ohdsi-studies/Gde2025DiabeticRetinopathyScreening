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

################################################################################
# ❗️CONFIGURATION FOR RUNNING STUDY PACKAGE 
# 
# Please follow the directions below to configure the package.
# 
# No edits need to be made to this file, only to "env.R"
################################################################################

# 1. Copy "env.example.R" to "env.R"
# 
# Run the below code to copy the contents of "env.example.R" to "env.R". 
if(!file.exists("env.R")) {
  ParallelLogger::logInfo("Copying env.example.R to env.R")
  file.copy("env.example.R", "env.R")
}

# 2. Edit "env.R" file with settings for your site.
# 
# An "env.R" file will be created in the directory of the package. This file
# contains settings, such as database connection details, that are needed to run
# the study.


# You may now run the entire contents of this file.  If there are errors, you 
# will be notified.


################################################################################
# ⚡️ STUDY EXECUTION
# 
# Run the code below to execute the study
################################################################################

# Read in settings
if(!file.exists("env.R")) {
  stop("Please copy env.example.R to env.R and edit the file to set your environment variables.")
}

# Once your env.R file is created, you can source it to set the environment variables.
# If there are issues with your configuration, you will be prompted to fix them.
source("env.R")


# ENVIRONMENT SETTINGS NEEDED FOR RUNNING Strategus ------------

invisible({
  # Sets the Java maximum heap space. 
  # Default: 4g
  if (!exists("javaMaxHeapSize")) {
    javaMaxHeapSize <- "4G"
  } else {
    if (!is.character(javaMaxHeapSize) || length(javaMaxHeapSize) != 1 || !grepl("^[0-9]+[GgMm]$", javaMaxHeapSize)) {
      stop("Invalid javaMaxHeapSize. It must be a string like '4G' or '512M'.")
    }
  }
  
  Sys.setenv("_JAVA_OPTIONS" = paste0("-Xmx", javaMaxHeapSize))
  
  # Set vroom thread count
  # Default: 1
  if (!exists("vroomThreadCount")) {
    vroomThreadCount <- 1
  } else {
    if (!is.numeric(vroomThreadCount) || length(vroomThreadCount) != 1 || vroomThreadCount < 1) {
      stop("Invalid vroomThreadCount. It must be a positive number (>=1).")
    }
  }
  
  Sys.setenv("VROOM_THREADS" = vroomThreadCount)
  
  # Status output
  ParallelLogger::logInfo("\n------------------------------------------------------------------------------")
  ParallelLogger::logInfo("⚙️ Settings:")
  ParallelLogger::logInfo("------------------------------------------------------------------------------")
  ParallelLogger::logInfo(sprintf("Study output folder:      %s", outputLocation))
  ParallelLogger::logInfo(sprintf("Database:                 %s", dbms))
  ParallelLogger::logInfo(sprintf("Database server:          %s", dbServer))
  ParallelLogger::logInfo(sprintf("Database username:        %s", dbUsername))
  ParallelLogger::logInfo(sprintf("Database password:        %s", ifelse(nchar(dbPassword) > 0, "********", "No password provided")))
  ParallelLogger::logInfo(sprintf("Database name:            %s", dbName))
  ParallelLogger::logInfo(sprintf("Database port:            %s", dbPort))
  ParallelLogger::logInfo(sprintf("CDM database schema:      %s", cdmDatabaseSchema))
  ParallelLogger::logInfo(sprintf("Work database schema:     %s", workDatabaseSchema))
  ParallelLogger::logInfo(sprintf("Cohort table name:        %s", cohortTableName))
  ParallelLogger::logInfo(sprintf("Min cell count:           %s", minCellCount))
  
  ParallelLogger::logInfo("\n------------------------------------------------------------------------------")
  ParallelLogger::logInfo("🔗 Testing database connection:")
  ParallelLogger::logInfo("------------------------------------------------------------------------------")
  
  
  tryCatch({
    testConnection <- DatabaseConnector::connect(connectionDetails)
    DatabaseConnector::disconnect(testConnection)
    ParallelLogger::logInfo("Database connection successful.")
  }, error = function(e) {
    ParallelLogger::logError("Database connection failed. Please check your settings.")
    stop(e)
  })
  
  ParallelLogger::logInfo("\n------------------------------------------------------------------------------")
  ParallelLogger::logInfo("✅ Study is ready to run.")
  ParallelLogger::logInfo("------------------------------------------------------------------------------")
})


# Execute the study

analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/drScreeningStudyAnalysisSpecification.json"
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
