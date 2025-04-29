################################################################################
# INSTRUCTIONS: The code below assumes you have access to a PostgreSQL database
# and permissions to create tables in an existing schema specified by the
# resultsDatabaseSchema parameter.
# 
# See the Working with results section
# of the UsingThisTemplate.md for more details.
# 
# More information about working with results produced by running Strategus 
# is found at:
# https://ohdsi.github.io/Strategus/articles/WorkingWithResults.html
# ##############################################################################

source("env.R")

analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/drScreeningStudyAnalysisSpecification.json"
)

resultsDatabaseConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = dbServer,
  user = dbUsername,
  password = dbPassword
)

# Create results data model -------------------------

# Use the 1st results folder to define the results data model
resultsFolder <- list.dirs(path = "results", full.names = T, recursive = F)[1]
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = file.path(resultsFolder, "strategusOutput")
)

Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsDatabaseConnectionDetails
)