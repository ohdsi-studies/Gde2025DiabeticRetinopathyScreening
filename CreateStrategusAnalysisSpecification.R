library(dplyr)
library(Strategus)

# Time-at-risks (TARs) for the outcomes of interest in your study
timeAtRisks <- tibble(
  label = c("Year 1", "Year 2", "Year 3", "Year 4"),
  riskWindowStart = c(0, 365, 730, 1095),
  startAnchor = c("cohort start"),
  riskWindowEnd = c(365, 730, 1095, 1460),
  endAnchor = c("cohort end")
)

studyStartDate <- "20210101" # YYYYMMDD
studyEndDate <- "20241231" # YYYYMMDD

# Some of the settings require study dates with hyphens
studyStartDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyStartDate)
studyEndDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyEndDate)


# Shared Resources -------------------------------------------------------------
# NOTE: Generated by DownloadCohorts.R
cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = "inst/cohorts.csv",
  jsonFolder = "inst/cohorts",
  sqlFolder = "inst/sql/sql_server"
)

if (any(duplicated(cohortDefinitionSet$cohortId))) {
  stop("*** Error: duplicate cohort IDs found ***")
}

# Create some data frames to hold the cohorts we'll use in each analysis ---------------
# Outcomes: The outcomes for this study take values >= 100 and < 200
oList <- cohortDefinitionSet |>
  filter(cohortId >= 100 & cohortId < 200) |>
  mutate(outcomeCohortId = cohortId, outcomeCohortName = cohortName) |>
  select(outcomeCohortId, outcomeCohortName) |>
  mutate(cleanWindow = 0)


# CohortGeneratorModule --------------------------------------------------------
cgModuleSettingsCreator <- CohortGeneratorModule$new()
cohortDefinitionShared <- cgModuleSettingsCreator$createCohortSharedResourceSpecifications(cohortDefinitionSet)

cohortGeneratorModuleSpecifications <- cgModuleSettingsCreator$createModuleSpecifications(
  generateStats = TRUE
)

# CohortDiagnosticsModule Settings ---------------------------------------------
cdModuleSettingsCreator <- CohortDiagnosticsModule$new()
cohortDiagnosticsModuleSpecifications <- cdModuleSettingsCreator$createModuleSpecifications(
  cohortIds = cohortDefinitionSet$cohortId,
  runInclusionStatistics = TRUE,
  runIncludedSourceConcepts = TRUE,
  runOrphanConcepts = TRUE,
  runTimeSeries = FALSE,
  runVisitContext = TRUE,
  runBreakdownIndexEvents = TRUE,
  runIncidenceRate = TRUE,
  runCohortRelationship = TRUE,
  runTemporalCohortCharacterization = TRUE,
  minCharacterizationMean = 0.01
)

# CharacterizationModule Settings ---------------------------------------------

cModuleSettingsCreator <- CharacterizationModule$new()


# Custom covariates
customCovariateCohorts <- tibble(
  cohortId = 200,
  cohortName = "Treatment-requiring Diabetic Retinopathy or Macular Edema including vitrectomy"
)

customCovariateSettings <- FeatureExtraction::createCohortBasedCovariateSettings(
  analysisId = 999,
  covariateCohorts = customCovariateCohorts,
  valueType = "binary",
  startDay = -365,
  endDay = 0,
)

covariateSettings <- FeatureExtraction::createDefaultCovariateSettings()
characterizationModuleSpecifications <- cModuleSettingsCreator$createModuleSpecifications(
  targetIds = cohortDefinitionSet$cohortId, # NOTE: This is all T/C/I/O
  outcomeIds = oList$outcomeCohortId,
  minPriorObservation = 180,
  dechallengeStopInterval = 0,
  dechallengeEvaluationWindow = 0,
  riskWindowStart = timeAtRisks$riskWindowStart,
  startAnchor = timeAtRisks$startAnchor,
  riskWindowEnd = timeAtRisks$riskWindowEnd,
  endAnchor = timeAtRisks$endAnchor,
  minCharacterizationMean = 0,
  outcomeWashoutDays = rep(0, nrow(oList)),
  covariateSettings = list(covariateSettings, customCovariateSettings)
)


# CohortIncidenceModule --------------------------------------------------------
ciModuleSettingsCreator <- CohortIncidenceModule$new()

tIds <- cohortDefinitionSet |>
  filter(!cohortId %in% oList$outcomeCohortId) |>
  pull(cohortId)

targetList <- lapply(
  tIds,
  function(cohortId) {
    CohortIncidence::createCohortRef(
      id = cohortId,
      name = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == cohortId]
    )
  }
)

outcomeList <- lapply(
  seq_len(nrow(oList)),
  function(i) {
    CohortIncidence::createOutcomeDef(
      id = i,
      name = cohortDefinitionSet$cohortName[cohortDefinitionSet$cohortId == oList$outcomeCohortId[i]],
      cohortId = oList$outcomeCohortId[i],
      cleanWindow = oList$cleanWindow[i]
    )
  }
)

tars <- list()
for (i in seq_len(nrow(timeAtRisks))) {
  tars[[i]] <- CohortIncidence::createTimeAtRiskDef(
    id = i,
    startWith = gsub("cohort ", "", timeAtRisks$startAnchor[i]),
    endWith = gsub("cohort ", "", timeAtRisks$endAnchor[i]),
    startOffset = timeAtRisks$riskWindowStart[i],
    endOffset = timeAtRisks$riskWindowEnd[i]
  )
}

analysis1 <- CohortIncidence::createIncidenceAnalysis(
  targets = tIds,
  outcomes = seq_len(nrow(oList)),
  tars = seq_along(tars)
)

irStudyWindow <- CohortIncidence::createDateRange(
  startDate = studyStartDateWithHyphens,
  endDate = studyEndDateWithHyphens
)

irDesign <- CohortIncidence::createIncidenceDesign(
  targetDefs = targetList,
  outcomeDefs = outcomeList,
  tars = tars,
  analysisList = list(analysis1),
  studyWindow = irStudyWindow,
  strataSettings = CohortIncidence::createStrataSettings(
    byYear = TRUE,
    byGender = TRUE,
    byAge = TRUE,
    ageBreaks = seq(0, 110, by = 5)
  )
)
cohortIncidenceModuleSpecifications <- ciModuleSettingsCreator$createModuleSpecifications(
  irDesign = irDesign$toList()
)

# NOTE: TreatmentPatterns module has been moved to a separate analysis
# See CreateStrategusAnalysisSpecificationTreatmentPatterns.R for the 
# properly configured TreatmentPatterns analyses (4 separate versions)

# Create the analysis specifications ------------------------------------------
analysisSpecifications <- Strategus::createEmptyAnalysisSpecificiations() |>
  Strategus::addSharedResources(cohortDefinitionShared) |>
  Strategus::addModuleSpecifications(cohortGeneratorModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortDiagnosticsModuleSpecifications) |>
  Strategus::addModuleSpecifications(characterizationModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortIncidenceModuleSpecifications)

ParallelLogger::saveSettingsToJson(
  analysisSpecifications,
  file.path("inst", "drScreeningStudyAnalysisSpecification.json")
)