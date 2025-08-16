# projectoR <img src="man/figures/hex.png" align="right" height="138" alt="" />

Create standardized, reproducible research project structures with support for literate programming and multiple studies.

## Overview

This package is a fork of [Ian Hussey's psychdsish project](https://github.com/ianhussey/psychdsish/tree/main). Hence, all creadit goes to him. I merely changed and removed some functions. Specifically, `projectoR` provides two main functions:

- **`init_project()`** - Initialize a new research project with standardized folder structure
- **`add_study()`** - Add additional studies to existing projects with automatic mode detection

Key features:
- Standardized directory structure for reproducible research
- Support for both literate programming (.qmd) and traditional R scripts
- Multi-study project support
- Basic git integration

## Installation

Install the development version from GitHub:

```r
# Install from GitHub
devtools::install_github("howquez/projectoR")

# Or install locally if you've cloned the repo
devtools::install()
```

## Quick Start

### Create a New Research Project

```r
library(projectoR)

# Create a new project with literate programming (default)
init_project("my-research-project", study_name = "pilot-study")

# Or create a project with traditional R scripts
init_project("my-project", literate = FALSE)
```

This creates the project structure:
```
my-research-project/
├── pilot-study/
│   ├── code/                     # Analysis scripts (.qmd or .R)
│   ├── data/
│   │   ├── raw/                  # Raw data (read-only)
│   │   └── processed/            # Cleaned datasets
│   ├── outputs/
│   │   ├── plots/                # Generated figures
│   │   ├── fitted_models/        # Model objects
│   │   └── results/              # Tables and results
│   ├── materials/                # Experimental materials
│   └── preregistration/          # Preregistration documents
├── writeup/                      # Manuscripts, theses, slides
├── literature/
│   └── _references.bib           # Bibliography
├── LICENSE                       # MIT license
├── README.md                     # Project documentation
└── my-research-project.Rproj     # RStudio project file
```

### Add Studies to Existing Projects

```r
# Add a new study (automatically detects literate vs. script mode)
add_study("study-2", project_root = "my-research-project")

# Add study with specific settings
add_study("follow-up-study", project_root = "my-research-project", literate = FALSE)
```

## Usage

### Literate Programming Mode

When `literate = TRUE`, creates .qmd files with YAML headers, setup chunks, and bibliography integration:

- **01-processing.qmd** - Data cleaning and preprocessing
- **02-analysis.qmd** - Statistical analyses and modeling

### Traditional R Script Mode

When `literate = FALSE`, creates:

- **00_run_all.R** - Master script to run entire workflow
- **01-processing.R** - Data processing script  
- **02-analysis.R** - Analysis script

### Multi-Study Projects

```r
# Initialize project
init_project("longitudinal-study", study_name = "baseline")

# Add follow-up studies
add_study("6-month-followup", project_root = "longitudinal-study") 
add_study("12-month-followup", project_root = "longitudinal-study")
```

The package automatically detects the existing mode and updates the main README.

## Function Reference

### `init_project()`

Initialize a new research project structure.

Key parameters: `project_root`, `study_name`, `literate`, `overwrite`, `git_init`

### `add_study()`

Add a new study to an existing project.

Key parameters: `study_name`, `literate` (auto-detects if NULL), `project_root`, `overwrite`

## Acknowledgments

This package is forked/inspired/mainly copied from [Ian Hussey's psychdsish project](https://github.com/ianhussey/psychdsish/tree/main). The original work provided an excellent foundation for reproducible research project structures. This fork removed and extended some functionality (e.g., to support multi-study projects).

## License

MIT License - see [LICENSE](LICENSE) file for details.
