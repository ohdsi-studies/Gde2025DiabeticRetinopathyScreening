# This code creates a local SQLite results database, loads the results of one database into the 
# resuls database, and launches a Shiny app to view the results.

##=========== START OF INPUTS ==========

source("env.R")

# Uncomment the below line to use connection defined in envResults.R 
# Leave commented to use SQLite.
# source("envResults.R")  

# databaseName <- "JH_DR_Screening"

# Enter a location to store the SQLite database
sqliteFileName <- "/Users/erikwestlund/code/ohdsi-dr-screening/results/results.sqlite"

##=========== END OF INPUTS ==========

##################################
# DO NOT MODIFY BELOW THIS POINT
##################################
library(ShinyAppBuilder)
library(OhdsiShinyModules)

strategusOutputFolder <- file.path(outputLocation, databaseName, "strategusOutput")

# Comment out the below to use the connection defined in envResults.R
# Leave it in place to create a SQLite databse
resultsDatabaseSchema <- "main"
unlink(sqliteFileName) # Deletes database file if it already exists!
resultsConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "sqlite",
  server = sqliteFileName
)

# Create results schema and upload results ---------------------------------------------------------
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/drScreeningStudyAnalysisSpecification.json"
)

resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = strategusOutputFolder
)

Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)

Strategus::uploadResults(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)

# Launch Shiny app ---------------------------------------------------------------------------------
shinyConfig <- initializeModuleConfig() |>
  addModuleConfig(
    createDefaultAboutConfig()
  )  |>
  addModuleConfig(
    createDefaultDatasourcesConfig()
  )  |>
  addModuleConfig(
    createDefaultCohortGeneratorConfig()
  ) |>
  addModuleConfig(
    createDefaultCohortDiagnosticsConfig()
  ) |>
  addModuleConfig(
    createDefaultCharacterizationConfig()
  ) 

ShinyAppBuilder::createShinyApp(
  config = shinyConfig, 
  connectionDetails = resultsConnectionDetails,
  resultDatabaseSettings = createDefaultResultDatabaseSettings(schema = resultsDatabaseSchema)
)