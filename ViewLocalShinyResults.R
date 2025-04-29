library(ShinyAppBuilder)
library(OhdsiShinyModules)

source("env.R")

# ADD OR REMOVE MODULES TAILORED TO YOUR STUDY
shinyConfig <- initializeModuleConfig() |>
  addModuleConfig(
    createDefaultAboutConfig()
  ) |>
  addModuleConfig(
    createDefaultDatasourcesConfig()
  ) |>
  addModuleConfig(
    createDefaultCohortGeneratorConfig()
  ) |>
  addModuleConfig(
    createDefaultCohortDiagnosticsConfig()
  ) |>
  addModuleConfig(
    createDefaultCharacterizationConfig()
  ) |>
  addModuleConfig(
    createDefaultPredictionConfig()
  ) |>
  addModuleConfig(
    createDefaultEstimationConfig()
  )

resultsDatabaseConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = dbServer,
  user = dbUsername,
  password = dbPassword
)

# now create the shiny app based on the config file and view the results
# based on the connection
ShinyAppBuilder::createShinyApp(
  config = shinyConfig,
  connectionDetails = resultsDatabaseConnectionDetails,
  resultDatabaseSettings = createDefaultResultDatabaseSettings(schema = resultsDatabaseSchema),
  title = "GDE2025 DR Screening",
  studyDescription = "Results of the GDE2025 DR Screening Network Study"
)