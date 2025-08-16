#' Initialize Research Project Structure
#' @description Creates a standardized research project structure with optional literate programming and git initialization
#' @param project_root Root directory for the project. If it doesn't exist, it will be created. Use "." to work in current directory.
#' @param study_name Name of the study folder (default: "study-1")
#' @param overwrite Whether to overwrite existing files
#' @param literate If TRUE, creates .qmd files for literate programming. If FALSE, creates .R scripts with a master source file
#' @param git_init If TRUE, initializes a git repository with initial commit
#' @return Invisible data frame of created paths
#' @export
#' @examples
#' \dontrun{
#' # Create new project in new directory
#' init_project("my-awesome-study")
#'
#' # Create project in current directory
#' init_project(".", study_name = "experiment-1")
#'
#' # Create with R scripts instead of .qmd files
#' init_project("my-project", literate = FALSE, git_init = TRUE)
#' }
init_project <- function(project_root = ".",
                         study_name = "study-1",
                         overwrite = FALSE,
                         literate = TRUE,
                         git_init = FALSE) {

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

  # Handle directory creation
  if (project_root != ".") {
    if (dir.exists(project_root) && !overwrite) {
      message("Working in existing directory: ", normalizePath(project_root))
    } else {
      if (!dir.exists(project_root)) {
        dir.create(project_root, recursive = TRUE)
        message("Created new directory: ", normalizePath(project_root))
      }
    }
  } else {
    message("Working in current directory: ", getwd())
  }

  dirs <- c(
    "writeup",
    "literature",
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

  # create all directories
  paths_dir <- file.path(project_root, dirs)
  invisible(lapply(paths_dir, mkd))

  # --- .Rproj file ---
  project_name <- if (project_root == ".") basename(getwd()) else basename(normalizePath(project_root))
  rproj_path <- join(project_root, paste0(project_name, ".Rproj"))
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
  license_path <- join(project_root, "LICENSE")
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
  references_path <- join(project_root, "literature", "_references.bib")
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
  readme_path <- join(project_root, "README.md")
  file_ext <- if (literate) ".qmd/.Rmd" else ".R"
  readme_text <- paste(
    "# Project Title",
    "",
    "## Overview",
    "Add aims, data sources, and reproduction steps.",
    "",
    "## Structure",
    "```\n" %+%
      "literature/_references.bib  # \n" %+%
      "writeup/                    # thesis, manuscript, preprints, slides, etc.\n" %+%
      study_name %+% "\n" %+%
      "  code/                     # analysis and processing scripts (" %+% file_ext %+% ")\n" %+%
      "  models/                   # fitted model objects (.rds)\n" %+%
      "  plots/                    # generated figures (.png)\n" %+%
      "  data/\n" %+%
      "    README.md               # explain when, how, and by whom the data was collected.\n" %+%
      "    raw/                    # raw data and codebooks/data dictionaries (should be read-only, except for removal of private data)\n" %+%
      "    processed/              # cleaned datasets and codebooks/data dictionaries\n" %+%
      "  outputs/                  # outputs of the processing and analyses scripts\n" %+%
      "    plots/                  # plots and figures, .png/.pdf/etc.\n" %+%
      "    fitted_models/          # fitted model objects, eg from brms, lme4, lavaan, etc.\n" %+%
      "    results/                # tables and matrices, eg for descriptive statistics, formatted statistical results, correlation tables\n" %+%
      "  materials/                # measures, implementations (qualtrics, lab.js, psychopy files, etc.), .docx files with items, etc.\n" %+%
      "preregistration/            # preregistration documents\n" %+%
      "LICENSE               # suggested: CC BY 4.0\n" %+%
      "README.md             # this file\n" %+%
      "```",
    "",
    if (literate) {
      paste(
        "## Reproducibility",
        "- Place raw data in `data/raw/`.",
        "- Write processing in `code/01-processing.qmd` and analyses in `code/02-analysis.qmd`.",
        "- Re-run data processing with `code/01-processing.qmd`. This will create `code/01-processing.html` and files in `data/processed/` and `data/results/`.",
        "- Re-run analyses with `code/02-analysis.qmd`. This will create `code/02-analysis.html`, plots in `code/plots/` and fitted model objects in `code/models/`.",
        sep = "\n"
      )
    } else {
      paste(
        "## Reproducibility",
        "- Place raw data in `data/raw/`.",
        "- Write processing in `code/01-processing.R` and analyses in `code/02-analysis.R`.",
        "- Run entire workflow with `source('code/00_run_all.R')` or run scripts individually.",
        "- Processing creates files in `data/processed/` and `data/results/`.",
        "- Analysis creates plots in `code/plots/` and fitted model objects in `code/models/`.",
        sep = "\n"
      )
    },
    "",
    "## License",
    "CC BY 4.0 (see `LICENSE`).",
    "## Suggested citation",
    "Authors (Year). Title. URL.",
    sep = "\n"
  )
  write_if_absent(readme_path, readme_text)

  # data README.md
  data_readme_path <- join(project_root, study_name, "/data/README.md")
  data_readme_text <- paste(
    "# Data Provenance",
    "",
    "Explain when, how, and by whom the data was collected.",
    sep = "\n"
  )
  write_if_absent(data_readme_path, data_readme_text)

  # --- .gitignore ---
  gitignore_path <- join(project_root, ".gitignore")
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
    "data/outputs/fitted_models/",
    "data/outputs/plots/",
    "",
    "# OS-specific files",
    ".DS_Store",
    "Thumbs.db",
    sep = "\n"
  )
  write_if_absent(gitignore_path, gitignore_text)

  # --- .gitattributes ---
  gitattributes_path <- join(project_root, ".gitattributes")
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
    # Create .qmd files (existing behavior)
    qmd_files <- c(
      study_name %+% "/code/01-processing.qmd",
      study_name %+% "/code/02-analysis.qmd"
    )

    qmd_header <- function(title) {
      # Normalize both paths
      project_root_norm <- normalizePath(project_root, winslash = "/", mustWork = FALSE)
      title_norm <- normalizePath(title, winslash = "/", mustWork = FALSE)
      # Remove project_root prefix if present
      if (startsWith(title_norm, project_root_norm)) {
        title_clean <- substr(title_norm, nchar(project_root_norm) + 2, nchar(title_norm))
        # +2 accounts for trailing slash in project_root_norm
      } else {
        title_clean <- title
      }
      # Remove leading "code/" if present
      title_clean <- sub("^" %+% study_name %+% "/code/", "", title_clean)
      # Remove trailing ".qmd"
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
      write_if_absent(join(project_root, rel), qmd_header(gsub("^" %+% study_name %+% "/code/|\\.qmd$", "", rel)))
    }))

    code_files <- file.path(project_root, qmd_files)

  } else {
    # Create .R files and master source script
    r_files <- c(
      study_name %+% "/code/01-processing.R",
      study_name %+% "/code/02-analysis.R"
    )

    # R script content (extracted R code from qmd template)
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

  # --- Initialize git repository (optional) ---
  if (git_init) {
    if (Sys.which("git") != "") {
      old_wd <- getwd()
      setwd(project_root)

      # Initialize git repo
      git_init_result <- system2("git", args = c("init"), stdout = FALSE, stderr = FALSE)

      if (git_init_result == 0) {
        # Stage all files
        system2("git", args = c("add", "."), stdout = FALSE, stderr = FALSE)

        # Initial commit
        initial_commit_msg <- paste0("Initial project setup for ", study_name)
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
  message("\n", "* Project structure created successfully!")

  if (literate) {
    message("* Created .qmd files for literate programming")
  } else {
    message("* Created .R scripts with master source file")
  }

  if (git_init && Sys.which("git") != "") {
    message("* Git repository initialized")
  }

  # Suggest opening the project
  rproj_file <- normalizePath(rproj_path, mustWork = FALSE)
  message("\n", "To get started:")
  message("   Open the project: ", rproj_file)

  if (requireNamespace("rstudioapi", quietly = TRUE)) {
    message("\n", "Or run: rstudioapi::openProject(\"", normalizePath(project_root), "\")")
  }

  # return a summary
  created <- data.frame(
    path = c(paths_dir,
             license_path, readme_path, rproj_path,
             code_files),
    type = c(rep("dir", length(paths_dir)),
             "file","file", "file", rep("file", length(code_files)))
  )
  invisible(created)
}
