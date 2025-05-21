library(dplyr)

baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"

# Naming scheme:
# < 100 = Indication cohorts
# >= 100 & < 200 = Outcomes
# >= 200 "Utility" cohorts for aggregated covariates, etc.

cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = c(
    1792943,
    1792942,
    1792945,
    1792944,
    1793022,
    1793027,
    1792940,  # Awaiting fix
    1792939,  # Awaiting fix
    1792934,
    1792935,
    1792941,
    1792936,
    1792937,
    1792938,
    1792930,
    1792931,
    1793230
  ),
  generateStats = TRUE
)

cohortDefinitionSet <- cohortDefinitionSet |>
  mutate(
    cohortName = case_when(
      cohortId == 1792943 ~ "Newly Diagnosed T2DM",
      cohortId == 1792942 ~ "Newly Diagnosed T2DM (3 Years Continuous Observation)",
      cohortId == 1792945 ~ "Prevalent T2DM",
      cohortId == 1792944 ~ "Prevalent T2DM (3 Years Continuous Observation)",
      cohortId == 1793022 ~ "DR Screening, Any",
      cohortId == 1793027 ~ "DR Screening, Any (No Specialty)",
      cohortId == 1792940 ~ "DR Screening, In Office",
      cohortId == 1792939 ~ "DR Screening, In Office (No Specialty)",
      cohortId == 1792934 ~ "DR Screening, In Office (First Type)",
      cohortId == 1792935 ~ "DR Screening, In Office (No Specialty, First Type)",
      cohortId == 1792941 ~ "DR Screening, Telemedicine",
      cohortId == 1792936 ~ "DR Screening, Telemedicine (First Type, Excludes In Office, With Specialty)",
      cohortId == 1792937 ~ "DR Screening, Telemedicine (First Type, Excludes In Office, Without Specialty)",
      cohortId == 1792938 ~ "DR Screening, AI",
      cohortId == 1792930 ~ "DR Screening, AI (First Type, Excludes In Office, With Specialty)",
      cohortId == 1792931 ~ "DR Screening, AI (First Type, Excludes In Office, Without Specialty)",
      cohortId == 1793230 ~ "Treatment-requiring Diabetic Retinopathy or Macular Edema including vitrectomy",
      TRUE ~ cohortName
    ),
    cohortId = case_when(
      cohortId == 1792943 ~ 1,
      cohortId == 1792942 ~ 2,
      cohortId == 1792945 ~ 10,
      cohortId == 1792944 ~ 11,
      cohortId == 1793022 ~ 100,
      cohortId == 1793027 ~ 101,
      cohortId == 1792940 ~ 110,
      cohortId == 1792939 ~ 111,
      cohortId == 1792934 ~ 112,
      cohortId == 1792935 ~ 113,
      cohortId == 1792941 ~ 120,
      cohortId == 1792936 ~ 121,
      cohortId == 1792937 ~ 122,
      cohortId == 1792938 ~ 130,
      cohortId == 1792930 ~ 131,
      cohortId == 1792931 ~ 132,
      cohortId == 1793230 ~ 200,
      TRUE ~ cohortId
    )
  )

CohortGenerator::saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSet,
  settingsFileName = "inst/cohorts.csv",
  jsonFolder = "inst/cohorts",
  sqlFolder = "inst/sql/sql_server",
)

# Temp: Limited set for testing
cohortDefinitionSetLimited <- cohortDefinitionSet |> 
filter(
  cohortId %in% c(2, 11) | cohortId >= 100 & cohortId < 200
)

CohortGenerator::saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSetLimited,
  settingsFileName = "inst/cohorts_limited.csv",
  jsonFolder = "inst/cohorts/limited",
  sqlFolder = "inst/sql/sql_server/limited",
)

# No negative control outcomes.