library(dplyr)
library(Strategus)

# Define cohorts for each analysis version
# Version 1A: Newly Diagnosed with standard In Office screening
cohorts_v1a <- c(
  2,   # Newly Diagnosed T2DM (3 Years Continuous Observation): target
  110, # DR Screening, In Office
  120, # DR Screening, Telemedicine
  130  # DR Screening, AIoka
)

# Version 1B: Newly Diagnosed with No Specialty In Office screening
cohorts_v1b <- c(
  2,   # Newly Diagnosed T2DM (3 Years Continuous Observation): target
  111, # DR Screening, In Office (No Specialty)
  120, # DR Screening, Telemedicine
  130  # DR Screening, AI
)

# Version 2A: Prevalent with standard In Office screening
cohorts_v2a <- c(
  11,  # Prevalent T2DM (3 Years Continuous Observation): target
  110, # DR Screening, In Office
  120, # DR Screening, Telemedicine
  130  # DR Screening, AI
)

# Version 2B: Prevalent with No Specialty In Office screening
cohorts_v2b <- c(
  11,  # Prevalent T2DM (3 Years Continuous Observation): target
  111, # DR Screening, In Office (No Specialty)
  120, # DR Screening, Telemedicine
  130  # DR Screening, AI
)

# Time-at-risks (TARs) for the outcomes of interest in your study
timeAtRisks <- tibble(
  label = c("Year 1", "Year 2", "Year 3", "Year 4"),
  riskWindowStart  = c(0, 365, 730, 1095),
  startAnchor = c("cohort start"),
  riskWindowEnd  = c(365, 730, 1095, 1460),
  endAnchor = c("cohort end")
)

studyStartDate <- '20210101' #YYYYMMDD
studyEndDate <- '20241231'   #YYYYMMDD

# Some of the settings require study dates with hyphens
studyStartDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyStartDate)
studyEndDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyEndDate)

# Function to create analysis specification for a given set of cohorts
createTPAnalysisSpec <- function(cohortsToKeep, analysisName) {

  # Get cohort definitions for this analysis
  cohortDefinitionSetLimited <- CohortGenerator::getCohortDefinitionSet(
    settingsFileName = "inst/cohorts.csv",
    jsonFolder = "inst/cohorts",
    sqlFolder = "inst/sql/sql_server"
  ) |>
    filter(cohortId %in% cohortsToKeep)

  if (any(duplicated(cohortDefinitionSetLimited$cohortId))) {
    stop("*** Error: duplicate cohort IDs found ***")
  }

  # CohortGeneratorModule
  cgModuleSettingsCreator <- CohortGeneratorModule$new()
  cohortDefinitionShared <- cgModuleSettingsCreator$createCohortSharedResourceSpecifications(cohortDefinitionSetLimited)

  cohortGeneratorModuleSpecifications <- cgModuleSettingsCreator$createModuleSpecifications(
    generateStats = TRUE
  )

  # TreatmentPatternsModule Settings
  tpSettingsCreator <- Strategus::TreatmentPatternsModule$new()

  # Define cohorts with their types
  tpTargetCohorts <- cohortDefinitionSetLimited |>
    mutate(
      type = case_when(
        cohortId < 100 ~ "target",
        cohortId >= 100 & cohortId < 200 ~ "event"
      )
    ) |>
    select(cohortId, cohortName, type)

  treatmentPatternsModuleSpecifications <- tpSettingsCreator$createModuleSpecifications(
    cohorts = tpTargetCohorts,
    includeTreatments = "startDate",
    indexDateOffset = 0,
    minEraDuration = 0,
    splitEventCohorts = NULL,
    splitTime = NULL,
    eraCollapseSize = 0,
    combinationWindow = 0,
    minPostCombinationDuration = 0,
    filterTreatments = "Changes",
    maxPathLength = 5
  )

  # Create the analysis specifications
  analysisSpecifications <- Strategus::createEmptyAnalysisSpecificiations() |>
    Strategus::addSharedResources(cohortDefinitionShared) |>
    Strategus::addModuleSpecifications(cohortGeneratorModuleSpecifications) |>
    Strategus::addModuleSpecifications(treatmentPatternsModuleSpecifications)

  # Save the specification
  ParallelLogger::saveSettingsToJson(
    analysisSpecifications,
    file.path("inst", paste0("drScreeningStudyAnalysisSpecificationTP_", analysisName, ".json"))
  )

  cat("Created specification for", analysisName, "\n")

  return(analysisSpecifications)
}

# Create all four analysis specifications
spec_v1a <- createTPAnalysisSpec(cohorts_v1a, "v1a")
spec_v1b <- createTPAnalysisSpec(cohorts_v1b, "v1b")
spec_v2a <- createTPAnalysisSpec(cohorts_v2a, "v2a")
spec_v2b <- createTPAnalysisSpec(cohorts_v2b, "v2b")
