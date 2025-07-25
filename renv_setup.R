# renv Setup Script for OHDSI DR Screening Project
# 
# This script ensures that renv is properly configured and all packages
# are installed according to the renv.lock file, including the forked
# TreatmentPatterns package with bug fixes.
#
# Run this script after:
# - Cloning the repository
# - Pulling updates from the repository
# - If you encounter package-related issues
#
# Usage: source("renv_setup.R")

cat("========================================\n")
cat("OHDSI DR Screening - renv Setup\n")
cat("========================================\n\n")

# Check if renv is installed
if (!requireNamespace("renv", quietly = TRUE)) {
  cat("Installing renv...\n")
  install.packages("renv")
}

# Load renv
library(renv)

# Check renv status
cat("Checking renv status...\n")
status <- tryCatch({
  renv::status()
}, error = function(e) {
  cat("Note: renv status check encountered an issue.\n")
  cat("This is normal for first-time setup.\n\n")
  NULL
})

# Restore packages from renv.lock
cat("\n----------------------------------------\n")
cat("Restoring packages from renv.lock...\n")
cat("This may take several minutes on first run.\n\n")

restore_result <- tryCatch({
  renv::restore(prompt = FALSE)
  TRUE
}, error = function(e) {
  cat("\n✗ Error during restore:\n")
  cat(paste0("  ", e$message, "\n"))
  FALSE
})

if (!restore_result) {
  cat("\n----------------------------------------\n")
  cat("Attempting to fix common issues...\n\n")
  
  # Try to install TreatmentPatterns fork directly first
  cat("Installing TreatmentPatterns fork directly...\n")
  tryCatch({
    renv::install("erikwestlund/TreatmentPatterns@gde-fork")
    cat("✓ TreatmentPatterns fork installed\n")
    
    # Try restore again
    cat("\nRetrying restore...\n")
    renv::restore(prompt = FALSE)
    restore_result <- TRUE
  }, error = function(e) {
    cat("✗ Still encountering issues\n")
    cat("Please check your internet connection and GitHub access\n")
  })
}

# Verify critical packages
cat("\n----------------------------------------\n")
cat("Verifying critical packages...\n\n")

# Check TreatmentPatterns
tp_check <- tryCatch({
  pkg_info <- packageDescription("TreatmentPatterns")
  if (!is.null(pkg_info$GithubUsername) && pkg_info$GithubUsername == "erikwestlund") {
    cat("✓ TreatmentPatterns: Using forked version with bug fixes\n")
    cat(paste0("  Version: ", pkg_info$Version, "\n"))
    cat(paste0("  GitHub: ", pkg_info$GithubUsername, "/", pkg_info$GithubRepo, "\n"))
    TRUE
  } else {
    cat("⚠ TreatmentPatterns: Not using the forked version\n")
    FALSE
  }
}, error = function(e) {
  cat("✗ TreatmentPatterns: Not installed\n")
  FALSE
})

# Check Strategus
strategus_check <- tryCatch({
  pkg_info <- packageDescription("Strategus")
  cat("✓ Strategus: Installed\n")
  cat(paste0("  Version: ", pkg_info$Version, "\n"))
  TRUE
}, error = function(e) {
  cat("✗ Strategus: Not installed\n")
  FALSE
})

# Final status
cat("\n========================================\n")
if (restore_result && tp_check && strategus_check) {
  cat("✓ Setup complete! Your environment is ready.\n")
  cat("\nThe TreatmentPatterns fork includes fixes for:\n")
  cat("- Era collapse row removal bug\n")
  cat("- Consecutive same-event transitions after combinations\n")
} else {
  cat("⚠ Setup incomplete. Some issues need attention.\n")
  cat("\nTroubleshooting steps:\n")
  cat("1. Ensure you have internet access\n")
  cat("2. Check GitHub authentication if needed\n")
  cat("3. Try running: renv::restore()\n")
  cat("4. If issues persist, run: source('Renv.R')\n")
}
cat("========================================\n")