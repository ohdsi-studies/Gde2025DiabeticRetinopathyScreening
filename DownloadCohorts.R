library(dplyr)

baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"

# TODO: Need to update no specialty.

cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = c(
    1792943, # 001_newly_diagnosed_t2dm.json
    1792942, # 002_newly_diagnosed_t2dm_3yrs_continuous_obs.json
    1792945, # 010_prevalent_t2dm.json
    1792944, # 011_prevalent_t2dm_3yrs_continuous_obs.json
    1792933, # 100_dr_screening_any.json [with specialty]
    1792932, # 101_dr_screening_any_no_specialty.json
    1792940, # 110_dr_screening_in_office.json
    1792934, # 111_dr_screening_in_office_first_type.json
    # 112_dr_screening_in_office_no_specialty.json
    1792939, # 113_dr_screening_in_office_no_specialty_first_type.json [double check; it was duped]
    1792941, # 120_dr_screening_telemedicine.json
    1792936, # 121_dr_screening_telemedicine_first_type_excludes_in_office_with_specialty.json
    1792937, # 122_dr_screening_telemedicine_first_type_excludes_in_office_without_specialty.json
    1792938, # 130_dr_screening_ai.json
    1792930, # 131_dr_screening_ai_first_type_excludes_in_office_with_specialty.json
    1792931 # 132_dr_screening_ai_first_type_excludes_in_office_without_specialty.json
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
      cohortId == 1792933 ~ "DR Screening, Any",
      cohortId == 1792932 ~ "DR Screening, Any (No Specialty)",
      cohortId == 1792940 ~ "DR Screening, In Office",
      cohortId == 1792934 ~ "DR Screening, In Office (First Type)",
      cohortId == 1792939 ~ "DR Screening, In Office (No Specialty, First Type)",
      cohortId == 1792941 ~ "DR Screening, Telemedicine",
      cohortId == 1792936 ~ "DR Screening, Telemedicine (First Type, Excludes In Office, With Specialty)",
      cohortId == 1792937 ~ "DR Screening, Telemedicine (First Type, Excludes In Office, Without Specialty)",
      cohortId == 1792938 ~ "DR Screening, AI",
      cohortId == 1792930 ~ "DR Screening, AI (First Type, Excludes In Office, With Specialty)",
      cohortId == 1792931 ~ "DR Screening, AI (First Type, Excludes In Office, Without Specialty)",
      TRUE ~ cohortName
    ),
    cohortId = case_when(
      cohortId == 1792943 ~ 1,
      cohortId == 1792942 ~ 2,
      cohortId == 1792945 ~ 10,
      cohortId == 1792944 ~ 11,
      cohortId == 1792933 ~ 100,
      cohortId == 1792932 ~ 101,
      cohortId == 1792940 ~ 110,
      cohortId == 1792934 ~ 111,
      cohortId == 1792939 ~ 113,
      cohortId == 1792941 ~ 120,
      cohortId == 1792936 ~ 121,
      cohortId == 1792937 ~ 122,
      cohortId == 1792938 ~ 130,
      cohortId == 1792930 ~ 131,
      cohortId == 1792931 ~ 132,
      TRUE ~ cohortId
    )
  )

CohortGenerator::saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSet,
  settingsFileName = "inst/cohorts.csv",
  jsonFolder = "inst/cohorts",
  sqlFolder = "inst/sql/sql_server",
)


# No negative control outcomes.