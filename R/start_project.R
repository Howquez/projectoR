#' Initialize Research Project Structure
#' @description Creates a standardized research project structure with optional literate programming and git initialization
#' @param path Directory where the project should be created. If it doesn't exist, it will be created. Use "." to work in current directory.
#' @param project_name Name of the overall research project. If NULL, uses the basename of the path.
#' @param study_name Name of the study folder within studies/ (default: "study-1")
#' @param overwrite Whether to overwrite existing files
#' @param literate If TRUE, creates .qmd files for literate programming. If FALSE, creates .R scripts with a master source file
#' @param git_init If TRUE, initializes a git repository with initial commit
#' @param open_session If TRUE, opens .Rproj of newly created project
#' @export
#' @examples
#' \dontrun{
#' # Create new project in new directory
#' start_project("~/research/my-awesome-study")
#'
#' # Create project in current directory with custom name
#' start_project(".", project_name = "dissertation-study", study_name = "experiment-1")
#'
#' # Create with R scripts instead of .qmd files
#' start_project("my-project", study_name = "pilot", literate = FALSE, git_init = TRUE)
#' }
start_project <- function(path = ".",
                          project_name = NULL,
                          study_name = "study-1",
                          overwrite = FALSE,
                          literate = TRUE,
                          git_init = FALSE,
                          open_session = FALSE) {

  # minimal dependencies: base R only
  join <- function(...) file.path(..., fsep = .Platform$file.sep)
  mkd  <- function(p) if (!dir.exists(p)) dir.create(p, recursive = TRUE, showWarnings = FALSE)
  write_if_absent <- function(path, text) {
    if (file.exists(path) && !overwrite) return(invisible(FALSE))
    cat(text, file = path)
    invisible(TRUE)
  }
  touch <- function(path) {
    if (file.exists(path) && !overwrite) return(invisible(FALSE))
    file.create(path)
    invisible(TRUE)
  }

  # helper for string concatenation
  `%+%` <- function(a, b) paste0(a, b)

  # Determine the actual project directory and project name
  if (is.null(project_name)) {
    # No project name provided - use path as-is
    project_dir <- path
    if (path == ".") {
      project_name <- basename(getwd())
    } else {
      project_name <- basename(normalizePath(path, mustWork = FALSE))
    }
  } else {
    # Project name provided - determine if we need a subdirectory
    if (path == ".") {
      # Working in current directory with explicit project name
      project_dir <- "."
    } else {
      # Create subdirectory with project name
      project_dir <- file.path(path, project_name)
    }
  }

  # Create project directory if needed
  if (project_dir != "." && !dir.exists(project_dir)) {
    dir.create(project_dir, recursive = TRUE)
    message("Created new project directory: ", normalizePath(project_dir))
  } else if (project_dir == ".") {
    message("Working in current directory: ", getwd())
  } else {
    message("Working in existing directory: ", normalizePath(project_dir))
  }

  # Define directory structure with studies folder
  dirs <- c(
    "writeup",
    "literature",
    "studies",
    "studies/" %+% study_name,
    "studies/" %+% study_name %+% "/materials",
    "studies/" %+% study_name %+% "/code",
    "studies/" %+% study_name %+% "/data",
    "studies/" %+% study_name %+% "/data/raw",
    "studies/" %+% study_name %+% "/data/processed",
    "studies/" %+% study_name %+% "/outputs",
    "studies/" %+% study_name %+% "/outputs/plots",
    "studies/" %+% study_name %+% "/outputs/fitted_models",
    "studies/" %+% study_name %+% "/outputs/results",
    "studies/" %+% study_name %+% "/preregistration"
  )

  # create all directories
  paths_dir <- file.path(project_dir, dirs)
  invisible(lapply(paths_dir, mkd))

  # --- .Rproj file ---
  rproj_path <- join(project_dir, paste0(project_name, ".Rproj"))
  rproj_content <- paste(
    "Version: 1.0",
    "",
    "RestoreWorkspace: No",
    "SaveWorkspace: No",
    "AlwaysSaveHistory: Default",
    "",
    "EnableCodeIndexing: Yes",
    "UseSpacesForTab: Yes",
    "NumSpacesForTab: 2",
    "Encoding: UTF-8",
    "",
    "RnwWeave: Sweave",
    "LaTeX: pdfLaTeX",
    "",
    "BuildType: Package",
    "PackageUseDevtools: Yes",
    "PackageInstallArgs: --no-multiarch --with-keep.source",
    sep = "\n"
  )
  write_if_absent(rproj_path, rproj_content)

  # --- files: LICENSE (CC BY 4.0), bibtex & README ---
  license_path <- join(project_dir, "LICENSE")
  license_text <- paste(
    "Creative Commons Attribution 4.0 International (CC BY 4.0)\n",
    "This work is licensed under the Creative Commons Attribution 4.0",
    "International License. You are free to share and adapt the material for",
    "any purpose, even commercially, under the terms below:",
    "",
    "  Attribution: You must give appropriate credit, provide a link to the",
    "    license, and indicate if changes were made.",
    "",
    "No additional restrictions: You may not apply legal terms or technological",
    "measures that legally restrict others from doing anything the license permits.",
    "",
    "Full license text: https://creativecommons.org/licenses/by/4.0/legalcode",
    sep = "\n"
  )
  write_if_absent(license_path, license_text)

  # bibtex
  references_path <- join(project_dir, "literature", "_references.bib")
  references_text <- paste(
    "@article{RoggenkampEtAl_2025,",
    "  title={DICE: Advancing Social Media Research through Digital In-Context Experiments},",
    "  author={Roggenkamp, Hauke and Boegershausen, Johannes and Hildebrand, Christian},",
    "  journal={Journal of Marketing},",
    "  year={2025},",
    "  publisher={SAGE Publications},",
    "  doi={10.1177/00222429251371702},",
    "  url={https://doi.org/10.1177/00222429251371702},",
    "  note={Forthcoming. First published online August 13, 2025}",
    "}",
    sep = "\n"
  )
  write_if_absent(references_path, references_text)

  # READMEs
  readme_path <- join(project_dir, "README.md")
  file_ext <- if (literate) ".qmd/.Rmd" else ".R"
  readme_text <- paste(
    "# " %+% project_name,
    "",
    "## Overview",
    "Add aims, data sources, and reproduction steps.",
    "",
    "## Structure",
    "```\n" %+%
      "literature/_references.bib  # project-wide bibliography\n" %+%
      "writeup/                    # thesis, manuscript, preprints, slides, etc.\n" %+%
      "studies/                    # individual studies within the project\n" %+%
      "  " %+% study_name %+% "/\n" %+%
      "    code/                   # analysis and processing scripts (" %+% file_ext %+% ")\n" %+%
      "    data/\n" %+%
      "      README.md             # explain when, how, and by whom the data was collected\n" %+%
      "      raw/                  # raw data and codebooks/data dictionaries (read-only)\n" %+%
      "      processed/            # cleaned datasets and codebooks/data dictionaries\n" %+%
      "    outputs/                # outputs of the processing and analyses scripts\n" %+%
      "      plots/                # plots and figures, .png/.pdf/etc.\n" %+%
      "      fitted_models/        # fitted model objects, eg from brms, lme4, lavaan, etc.\n" %+%
      "      results/              # tables and matrices, eg descriptive stats, correlation tables\n" %+%
      "    materials/              # measures, implementations (qualtrics, lab.js, etc.)\n" %+%
      "    preregistration/        # preregistration documents\n" %+%
      "LICENSE                     # suggested: CC BY 4.0\n" %+%
      "README.md                   # this file\n" %+%
      "```",
    "",
    if (literate) {
      paste(
        "## Reproducibility",
        "- Place raw data in `studies/" %+% study_name %+% "/data/raw/`.",
        "- Write processing in `studies/" %+% study_name %+% "/code/01-processing.qmd` and analyses in `studies/" %+% study_name %+% "/code/02-analysis.qmd`.",
        "- Re-run data processing with `studies/" %+% study_name %+% "/code/01-processing.qmd`. This will create `01-processing.html` and files in `data/processed/` and `outputs/results/`.",
        "- Re-run analyses with `studies/" %+% study_name %+% "/code/02-analysis.qmd`. This will create `02-analysis.html`, plots in `outputs/plots/` and fitted model objects in `outputs/fitted_models/`.",
        sep = "\n"
      )
    } else {
      paste(
        "## Reproducibility",
        "- Place raw data in `studies/" %+% study_name %+% "/data/raw/`.",
        "- Write processing in `studies/" %+% study_name %+% "/code/01-processing.R` and analyses in `studies/" %+% study_name %+% "/code/02-analysis.R`.",
        "- Run entire workflow with `source('studies/" %+% study_name %+% "/code/00-run-all.R')` or run scripts individually.",
        "- Processing creates files in `data/processed/` and `outputs/results/`.",
        "- Analysis creates plots in `outputs/plots/` and fitted model objects in `outputs/fitted_models/`.",
        sep = "\n"
      )
    },
    "",
    "## License",
    "CC BY 4.0 (see `LICENSE`).",
    "## Suggested citation",
    "Authors (Year). " %+% project_name %+% ". URL.",
    sep = "\n"
  )
  write_if_absent(readme_path, readme_text)

  # data README.md
  data_readme_path <- join(project_dir, "studies", study_name, "data", "README.md")
  data_readme_text <- paste(
    "# Data Provenance",
    "",
    "Explain when, how, and by whom the data was collected.",
    sep = "\n"
  )
  write_if_absent(data_readme_path, data_readme_text)

  # --- .gitignore ---
  gitignore_path <- join(project_dir, ".gitignore")
  gitignore_text <- paste(
    "# History files",
    ".Rhistory",
    ".Rapp.history",
    "",
    "# Session Data files",
    ".RData",
    "",
    "# User-specific files",
    ".Rproj.user/",
    "",
    "# Quarto / R Markdown caches",
    "_cache/",
    "*/_cache/",
    "*.knit.md",
    "*.utf8.md",
    "",
    "# Temporary files",
    "*.tmp",
    "*.log",
    "",
    "# Large data (use Git LFS or external storage)",
    "studies/*/outputs/fitted_models/",
    "studies/*/outputs/plots/",
    "",
    "# OS-specific files",
    ".DS_Store",
    "Thumbs.db",
    sep = "\n"
  )
  write_if_absent(gitignore_path, gitignore_text)

  # --- .gitattributes ---
  gitattributes_path <- join(project_dir, ".gitattributes")
  gitattributes_text <- paste(
    "# Auto detect text files and perform LF normalization",
    "* text=auto",
    "",
    "# Prevent GitHub Linguist from detecting generated HTML",
    "*.html linguist-detectable=false",
    sep = "\n"
  )
  write_if_absent(gitattributes_path, gitattributes_text)

  # --- empty .qmd stubs or .R scripts ---
  if (literate) {
    # Create .qmd files
    qmd_files <- c(
      "studies/" %+% study_name %+% "/code/01-processing.qmd",
      "studies/" %+% study_name %+% "/code/02-analysis.qmd"
    )

    qmd_header <- function(title) {
      # Clean up title for display
      title_clean <- sub("^studies/" %+% study_name %+% "/code/", "", title)
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
        "bibliography: ../../../literature/_references.bib\n",
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
      write_if_absent(join(project_dir, rel), qmd_header(rel))
    }))

    code_files <- file.path(project_dir, qmd_files)
  } else {
    # Create .R files and master source script
    r_files <- c(
      "studies/" %+% study_name %+% "/code/01-processing.R",
      "studies/" %+% study_name %+% "/code/02-analysis.R"
    )

    # R script content
    r_content <- function(script_name) {
      paste0(
        "# ", script_name, "\n",
        "# Author: author\n\n",
        "# Consider loading and installing required packages in main file (00-run-all.R)\n\n",
        "# Your code here...\n\n",
        "# Session info\n",
        "sessionInfo()\n\n"
      )
    }

    # Create individual R scripts
    script_names <- c("01-processing", "02-analysis")
    invisible(lapply(seq_along(r_files), function(i) {
      write_if_absent(join(project_dir, r_files[i]), r_content(script_names[i]))
    }))

    # Create master source script
    master_script_path <- join(project_dir, "studies", study_name, "code", "00-run-all.R")
    master_script_content <- paste0(
      "# Main script to run entire analysis workflow\n",
      "# Setup -----\n",
      "options(scipen = 999) # turn off scientific notation globally\n",
      "set.seed(42)\n\n",
      "# Load packages ----- \n",
      "# Consider loading and installing required packages here:\n",
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

    code_files <- c(file.path(project_dir, r_files), master_script_path)
  }

  # --- Initialize git repository (optional) ---
  if (git_init) {
    if (Sys.which("git") != "") {
      old_wd <- getwd()
      setwd(project_dir)
      # Initialize git repo
      git_init_result <- system2("git", args = c("init"), stdout = FALSE, stderr = FALSE)
      if (git_init_result == 0) {
        # Stage all files
        system2("git", args = c("add", "."), stdout = FALSE, stderr = FALSE)
        # Initial commit
        initial_commit_msg <- paste0("Initial project setup: ", project_name, " with ", study_name)
        system2("git", args = c("commit", "-m", shQuote(initial_commit_msg)),
                stdout = FALSE, stderr = FALSE)
        message("Git repository initialized with initial commit")
      } else {
        warning("Failed to initialize git repository")
      }
      setwd(old_wd)
    } else {
      warning("Git not found on system. Skipping git initialization.")
    }
  }

  # --- Final messages and suggestions ---
  message("\n", "* Project '", project_name, "' created successfully!")
  message("* Study '", study_name, "' initialized in studies/ folder")
  if (literate) {
    message("* Created .qmd files for literate programming")
  } else {
    message("* Created .R scripts with master source file")
  }
  if (git_init && Sys.which("git") != "") {
    message("* Git repository initialized")
  }

  # Suggest opening the project
  if (!open_session){
    rproj_file <- normalizePath(rproj_path, mustWork = FALSE)
    message("\n", "To get started:")
    message("   Open the project: ", rproj_file)
    if (requireNamespace("rstudioapi", quietly = TRUE)) {
      message("\n", "Or run: rstudioapi::openProject(\"", normalizePath(project_dir), "\")")
    }
  }

  if (open_session && requireNamespace("rstudioapi", quietly = TRUE)) {
    rstudioapi::openProject(normalizePath(project_dir), newSession = TRUE)
    message("* Opened project in RStudio")
  } else if (open_session) {
    warning("rstudioapi not available - cannot open project automatically")
  }
}
