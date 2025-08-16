#' Add Study to Existing Project
#' @description Adds a new study structure to an existing research project
#' @param study_name Name of the new study folder
#' @param literate If NULL (default), auto-detects from existing project. If specified, uses .qmd (TRUE) or .R (FALSE) files
#' @param git_add If TRUE and git repo exists, stages and commits the new study
#' @param project_root Root directory of the project (default: current directory)
#' @param overwrite Whether to overwrite existing study if it exists
#' @return Invisible data frame of created paths
#' @export
#' @examples
#' \dontrun{
#' # First create a project
#' init_project("my-project")
#'
#' # Then add studies to it
#' add_study("study-2", project_root = "my-project")
#' add_study("pilot-study", literate = FALSE, project_root = "my-project")
#' add_study("study-3", git_add = FALSE, project_root = "my-project")
#' }
add_study <- function(study_name,
                      literate = NULL,
                      git_add = TRUE,
                      project_root = ".",
                      overwrite = FALSE) {

  # Helper functions (same as init_project)
  join <- function(...) file.path(..., fsep = .Platform$file.sep)
  mkd  <- function(p) if (!dir.exists(p)) dir.create(p, recursive = TRUE, showWarnings = FALSE)
  write_if_absent <- function(path, text) {
    if (file.exists(path) && !overwrite) return(invisible(FALSE))
    cat(text, file = path)
    invisible(TRUE)
  }
  `%+%` <- function(a, b) paste0(a, b)

  # Validate we're in a project directory
  rproj_files <- list.files(project_root, pattern = "\\.Rproj$", full.names = FALSE)
  if (length(rproj_files) == 0) {
    stop("No .Rproj file found in '", project_root, "'. Are you in a valid project directory?")
  }

  # Check if study already exists
  study_path <- file.path(project_root, study_name)
  if (dir.exists(study_path) && !overwrite) {
    stop("Study '", study_name, "' already exists. Use overwrite = TRUE to replace.")
  }

  # Auto-detect literate mode if not specified
  if (is.null(literate)) {
    # Look for existing studies to detect mode
    existing_dirs <- list.dirs(project_root, recursive = FALSE, full.names = FALSE)
    existing_dirs <- existing_dirs[!existing_dirs %in% c("writeup", "literature", ".git")]

    if (length(existing_dirs) > 0) {
      # Check first existing study for .qmd or .R files
      first_study <- existing_dirs[1]
      code_dir <- file.path(project_root, first_study, "code")

      if (dir.exists(code_dir)) {
        qmd_files <- list.files(code_dir, pattern = "\\.qmd$")
        r_files <- list.files(code_dir, pattern = "\\.R$")

        if (length(qmd_files) > 0) {
          literate <- TRUE
          message("Auto-detected literate mode: TRUE (found .qmd files)")
        } else if (length(r_files) > 0) {
          literate <- FALSE
          message("Auto-detected literate mode: FALSE (found .R files)")
        } else {
          literate <- TRUE  # default fallback
          message("Could not auto-detect mode, defaulting to literate = TRUE")
        }
      } else {
        literate <- TRUE  # default fallback
        message("Could not auto-detect mode, defaulting to literate = TRUE")
      }
    } else {
      literate <- TRUE  # default fallback
      message("No existing studies found, defaulting to literate = TRUE")
    }
  }

  # Create study directory structure
  dirs <- c(
    study_name,
    study_name %+% "/materials",
    study_name %+% "/code",
    study_name %+% "/data",
    study_name %+% "/data/raw",
    study_name %+% "/data/processed",
    study_name %+% "/outputs",
    study_name %+% "/outputs/plots",
    study_name %+% "/outputs/fitted_models",
    study_name %+% "/outputs/results",
    study_name %+% "/preregistration"
  )

  # Create all directories
  paths_dir <- file.path(project_root, dirs)
  invisible(lapply(paths_dir, mkd))

  # Create data README.md
  data_readme_path <- join(project_root, study_name, "data", "README.md")
  data_readme_text <- paste(
    "# Data Provenance",
    "",
    "Explain when, how, and by whom the data was collected.",
    sep = "\n"
  )
  write_if_absent(data_readme_path, data_readme_text)

  # Create analysis files based on literate mode
  if (literate) {
    # Create .qmd files
    qmd_files <- c(
      study_name %+% "/code/01-processing.qmd",
      study_name %+% "/code/02-analysis.qmd"
    )

    qmd_header <- function(title) {
      # Clean up title for display
      title_clean <- sub("^" %+% study_name %+% "/code/", "", title)
      title_clean <- sub("\\.qmd$", "", title_clean)

      paste0(
        "---\n",
        "title: \"", title_clean, "\"\n",
        "author: \"author\"\n",
        "date: today\n",
        "format:\n",
        "  html:\n",
        "    code-fold: true\n",
        "    highlight-style: haddock\n",
        "    theme: flatly\n",
        "    toc: true\n",
        "    toc-location: left\n",
        "    embed-resources: true\n",
        "execute:\n",
        "  warning: false\n",
        "  message: false\n",
        "bibliography: ../../literature/_references.bib\n",
        "---\n\n",
        "```{r setup}\n",
        "#| include: false\n",
        "options(scipen = 999) # turn off scientific notation globally\n",
        "set.seed(42)\n",
        "```\n\n",
        "```{r packages_CRAN}\n",
        "options(repos = c(CRAN = 'https://cloud.r-project.org'))\n",
        "if (!requireNamespace('groundhog', quietly = TRUE)) {\n",
        "  install.packages('groundhog')\n",
        "}\n",
        "pkgs <- c('data.table') # add more packages here\n",
        "groundhog::groundhog.library(pkg = pkgs,\n",
        "                             date = '2025-01-01')\n",
        "rm(pkgs)\n",
        "```\n\n",
        "```{r session_info}\n",
        "sessionInfo()\n",
        "```\n"
      )
    }

    invisible(lapply(qmd_files, function(rel) {
      write_if_absent(join(project_root, rel), qmd_header(rel))
    }))

    code_files <- file.path(project_root, qmd_files)

  } else {
    # Create .R files
    r_files <- c(
      study_name %+% "/code/01-processing.R",
      study_name %+% "/code/02-analysis.R"
    )

    # R script content
    r_content <- function(script_name) {
      paste0(
        "# ", script_name, "\n",
        "# Author: author\n\n",
        "# Consider to load and install the required packages in main file (00_run_all.R)\n\n",
        "# Your code here...\n\n",
        "# Session info\n",
        "sessionInfo()\n\n"
      )
    }

    # Create individual R scripts
    script_names <- c("01-processing", "02-analysis")
    invisible(lapply(seq_along(r_files), function(i) {
      write_if_absent(join(project_root, r_files[i]), r_content(script_names[i]))
    }))

    # Create master source script
    master_script_path <- join(project_root, study_name, "code", "00_run_all.R")
    master_script_content <- paste0(
      "# Main script to run entire analysis workflow\n",
      "# Setup -----\n",
      "options(scipen = 999) # turn off scientific notation globally\n",
      "set.seed(42)\n\n",
      "# Load packages ----- \n",
      "# Consider to load and install the required packages here:\n",
      "options(repos = c(CRAN = 'https://cloud.r-project.org'))\n",
      "if (!requireNamespace('groundhog', quietly = TRUE)) {\n",
      "  install.packages('groundhog')\n",
      "}\n",
      "pkgs <- c('data.table') # add more packages here\n",
      "groundhog::groundhog.library(pkg = pkgs,\n",
      "                             date = '2025-01-01')\n",
      "rm(pkgs)\n\n",
      "# Run analysis scripts in order ----- \n",
      "source(\"01-processing.R\")\n\n",
      "source(\"02-analysis.R\")\n\n"
    )
    write_if_absent(master_script_path, master_script_content)

    code_files <- c(file.path(project_root, r_files), master_script_path)
  }

  # Update main README to mention multiple studies
  readme_path <- join(project_root, "README.md")
  if (file.exists(readme_path)) {
    # Get list of all study directories
    all_dirs <- list.dirs(project_root, recursive = FALSE, full.names = FALSE)
    study_dirs <- all_dirs[!all_dirs %in% c("writeup", "literature", ".git", ".Rproj.user")]
    study_dirs <- sort(study_dirs)

    if (length(study_dirs) > 1) {
      # Read existing README
      readme_content <- readLines(readme_path, warn = FALSE)

      # Find and replace the "## Reproducibility" section
      repro_start <- which(grepl("^## Reproducibility", readme_content))

      if (length(repro_start) > 0) {
        # Find next section or end of file
        next_section <- which(grepl("^## ", readme_content[(repro_start[1] + 1):length(readme_content)]))
        if (length(next_section) > 0) {
          repro_end <- repro_start[1] + next_section[1] - 1
        } else {
          repro_end <- length(readme_content)
        }

        # Create new reproducibility section for multiple studies
        file_ext <- if (literate) ".qmd/.Rmd" else ".R"
        multi_study_repro <- c(
          "## Reproducibility",
          "This project contains multiple studies:",
          "",
          paste0("- **", study_dirs, "/**"),
          "",
          "For each study:",
          "- Place raw data in `{study}/data/raw/`",
          "- Document data provenance in `{study}/data/README.md`",
          if (literate) {
            c(
              "- Process data using `{study}/code/01-processing.qmd`",
              "- Run analyses using `{study}/code/02-analysis.qmd`",
              "- Outputs will be created in `{study}/outputs/`"
            )
          } else {
            c(
              "- Run entire workflow with `source('{study}/code/00_run_all.R')`",
              "- Or run individual scripts: `01-processing.R`, `02-analysis.R`",
              "- Outputs will be created in `{study}/outputs/`"
            )
          }
        )

        # Replace the section
        new_readme <- c(
          readme_content[1:(repro_start[1] - 1)],
          multi_study_repro,
          if (repro_end < length(readme_content)) readme_content[(repro_end + 1):length(readme_content)] else character(0)
        )

        writeLines(new_readme, readme_path)
      }
    }
  }

  # Git operations
  if (git_add && dir.exists(file.path(project_root, ".git"))) {
    if (Sys.which("git") != "") {
      old_wd <- getwd()
      setwd(project_root)

      # Stage the new study
      system2("git", args = c("add", study_name), stdout = FALSE, stderr = FALSE)

      # Also stage README if it was updated
      if (file.exists("README.md")) {
        system2("git", args = c("add", "README.md"), stdout = FALSE, stderr = FALSE)
      }

      # Commit
      commit_msg <- paste0("Add ", study_name)
      commit_result <- system2("git", args = c("commit", "-m", shQuote(commit_msg)),
                               stdout = FALSE, stderr = FALSE)

      if (commit_result == 0) {
        message("* Added to git with commit: ", commit_msg)
      }

      setwd(old_wd)
    }
  }

  # Success messages
  message("* Study '", study_name, "' added successfully!")

  if (literate) {
    message("* Created .qmd files for literate programming")
  } else {
    message("* Created .R scripts with master source file")
  }

  message("\n Start working on your new study:")
  message("   ", normalizePath(file.path(project_root, study_name, "code")))

  # Return summary
  created <- data.frame(
    path = c(paths_dir, data_readme_path, code_files),
    type = c(rep("dir", length(paths_dir)), rep("file", 1 + length(code_files)))
  )
  invisible(created)
}
