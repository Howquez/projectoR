# projectoR <img src="man/figures/hex.png" align="right" height="160" alt="projectoR hex sticker" />

Create standardized, reproducible research project structures with support for literate programming and multiple studies.

## Overview

This package is a fork of [Ian Hussey's psychdsish project](https://github.com/ianhussey/psychdsish/tree/main). Hence, all credit goes to him. I merely changed and removed some functions. 

`projectoR` provides two main functions:

- **`start_project()`** - Initialize a new research project with standardized folder structure
- **`add_study()`** - Add additional studies to existing projects with automatic mode detection

## Organizational Philosophy

**Traditional approach:** Single data and scripts folders with multiple files
```
traditional-project/
├── data/
│   ├── study1_raw.csv
│   ├── study2_raw.csv
│   └── study1_processed.csv
├── scripts/
│   ├── study1_analysis.R
│   ├── study2_analysis.R
│   └── study1_preprocessing.R
└── outputs/
    ├── study1_plots/
    └── study2_results/
```

**projectoR approach:** Project-as-container with self-contained studies
```
research-project/
├── studies/
│   ├── study-1/          # Completely self-contained
│   │   ├── data/
│   │   ├── code/
│   │   ├── outputs/
│   │   └── materials/
│   └── study-2/          # Independent of study-1
│       ├── data/
│       ├── code/
│       ├── outputs/
│       └── materials/
├── literature/           # Shared project resources
├── writeup/              # Project-level manuscripts
└── README.md
```

**Why this matters:**
- **Independence**: Each study is completely self-contained and can be shared/archived separately
- **Clarity**: No confusion about which data/scripts belong to which study
- **Scalability**: Easy to add new studies without cluttering existing folders
- **Collaboration**: Team members can work on different studies without conflicts
- **Reproducibility**: Each study has its own complete workflow and dependencies

## Key Features

- Standardized directory structure for reproducible research
- Support for both literate programming (.qmd) and traditional R scripts
- Multi-study project support with automatic organization
- Git integration with smart commit messages
- Auto-detection of existing project modes
- Project-level shared resources (literature, writeup)

## Installation

Install the development version from GitHub:

```r
# Install from GitHub
devtools::install_github("howquez/projectoR")
```

## Quick Start

### Create a New Research Project

```r
library(projectoR)

# Create a new project with literate programming (default)
start_project(path = "my-research-project",
              project_name = "social-media-study",
              study_name = "pilot-study")

# Or create a project with traditional R scripts
start_project(path = "my-research-project", 
              project_name = "social-media-study",
              study_name = "pilot-study",
              literate = FALSE)

# Work in current directory
start_project(path = ".", 
              project_name = "dissertation-project",
              study_name = "experiment-1")
```

This creates the project structure:

```
social-media-study/
├── studies/
│   └── pilot-study/
│       ├── code/                     # Analysis scripts (.qmd or .R)
│       ├── data/
│       │   ├── raw/                  # Raw data (read-only)
│       │   ├── processed/            # Cleaned datasets
│       │   └── README.md             # Data documentation
│       ├── outputs/
│       │   ├── plots/                # Generated figures
│       │   ├── fitted_models/        # Model objects
│       │   └── results/              # Tables and results
│       ├── materials/                # Experimental materials
│       └── preregistration/          # Preregistration documents
├── writeup/                          # Manuscripts, theses, slides
├── literature/
│   └── _references.bib               # Project-wide bibliography
├── LICENSE                           # CC BY 4.0 license
├── README.md                         # Project documentation
└── social-media-study.Rproj          # RStudio project file
```

### Add Studies to Existing Projects

```r
# Add a new study (automatically detects literate vs. script mode)
add_study("main-experiment", path = "my-research-project")

# Add study with specific settings
add_study("follow-up-study", 
          path = "my-research-project", 
          literate = FALSE)

# The function is smart about paths - both of these work:
add_study("replication", path = "my-research-project")
add_study("replication", path = "my-research-project/studies")  # Auto-detects parent
```

## Usage Examples

### Multi-Study Longitudinal Project

```r
# Initialize project
start_project(path = "longitudinal-study",
              project_name = "adolescent-development",
              study_name = "baseline")

# Add follow-up studies
add_study("6-month-followup", path = "longitudinal-study") 
add_study("12-month-followup", path = "longitudinal-study")
add_study("24-month-followup", path = "longitudinal-study")
```

Results in:
```
adolescent-development/
├── studies/
│   ├── baseline/           # Independent study
│   ├── 6-month-followup/   # Independent study  
│   ├── 12-month-followup/  # Independent study
│   └── 24-month-followup/  # Independent study
├── literature/             # Shared across all studies
├── writeup/               # Project-level papers
└── README.md              # Updated automatically
```

### Mixed-Methods Project

```r
# Quantitative arm
start_project("mixed-methods", study_name = "survey-study", literate = TRUE)

# Qualitative arm  
add_study("interview-study", path = "mixed-methods", literate = FALSE)

# Meta-analysis combining both
add_study("meta-analysis", path = "mixed-methods", literate = TRUE)
```

## Workflow Modes

### Literate Programming Mode (`literate = TRUE`)

Creates .qmd files with YAML headers, setup chunks, and bibliography integration:
- **01-processing.qmd** - Data cleaning and preprocessing
- **02-analysis.qmd** - Statistical analyses and modeling

Each file includes:
- Proper YAML frontmatter with output formatting
- Setup chunks with reproducible package management (groundhog)
- Bibliography integration pointing to project-level `_references.bib`

### Traditional R Script Mode (`literate = FALSE`)

Creates traditional R workflow:
- **00-run-all.R** - Master script to run entire workflow
- **01-processing.R** - Data processing script  
- **02-analysis.R** - Analysis script

Includes package management setup and clear workflow structure.

## Auto-Detection Features

- **Mode detection**: When adding studies, automatically detects whether existing studies use literate or traditional mode
- **README updates**: Automatically updates project README when multiple studies are added
- **Git integration**: Smart commit messages and staging of new study files
- **Path flexibility**: Handles various path inputs intelligently

## Function Reference

### `start_project()`

Initialize a new research project structure.

**Arguments:**
- `path` - Directory where project should be created (default: ".")
- `project_name` - Name of the overall research project (if NULL, uses path basename)
- `study_name` - Name of the first study folder (default: "study-1")
- `overwrite` - Whether to overwrite existing files (default: FALSE)
- `literate` - Use .qmd files (TRUE) or .R scripts (FALSE, default: TRUE)
- `git_init` - Initialize git repository (default: FALSE)
- `open_session` - Open project in new RStudio session (default: FALSE)

### `add_study()`

Add a new study to an existing project.

**Arguments:**
- `study_name` - Name of the new study folder (required)
- `literate` - Use .qmd files (TRUE) or .R scripts (FALSE) (auto-detects if NULL)
- `git_add` - Stage and commit new study (default: TRUE)
- `path` - Root directory of the project (default: ".")
- `overwrite` - Whether to overwrite existing study (default: FALSE)

## Benefits of This Approach

1. **Clean separation**: Each study is completely independent
2. **Easy collaboration**: Multiple researchers can work on different studies simultaneously
3. **Simple archiving**: Individual studies can be shared or archived independently
4. **Reproducible**: Each study contains everything needed to reproduce its results

## Acknowledgments

This package is forked/inspired/mainly copied from [Ian Hussey's psychdsish project](https://github.com/ianhussey/psychdsish/tree/main). The original work provided an excellent foundation for reproducible research project structures. This fork extended the functionality to support multi-study projects with improved organization.

## License

CC BY 4.0 License - see [LICENSE](LICENSE) file for details.
