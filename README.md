# barqueShinyApp

> A containerized Shiny app interface for BARQUE, the reproducible eDNA analysis pipeline.

[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

---

## 🐳 Why Run in a Container?

This application is designed to run inside a Docker container that includes **all dependencies required by BARQUE**, including:

- FLASH (v2.2.00)
- VSEARCH (v2.30.0)
- GNU Parallel
- etc. 

See the BARQUE's documentation for the full list of dependencies.

Here is the full list of R, Python, and system dependencies included in the Docker image:
- R packages: shiny, shinydashboard, DT, dplyr, readr, remotes, pkgload, config, golem, shinyWidgets, bslib, reactable, cli, fontawesome, rsconnect, usethis, desc, httpuv
- Python 3 + packages: biopython, pandas, numpy
- System libraries: libcurl4-openssl-dev, libssl-dev, libxml2-dev, libgit2-dev, libglpk-dev, libharfbuzz-dev, libfribidi-dev, openjdk-11-jre-headless, build-essential, etc.

This approach ensures:
- 💡 Reproducibility: every user runs the exact same environment.
- 💻 Simplicity: no R, Python, or system-level installations are needed locally.
- 🔒 Isolation: the host system stays clean and untouched.

---

## 🚀 Running the App in Docker

To build and run the app inside Docker:

```bash
git clone --recurse-submodules https://github.com/taq-community/barqueShinyApp.git
cd barqueShinyApp
docker build -t barque-app:dev .
docker run -p 3838:3838 -v $(pwd):/srv/shiny-server -t barque-app:dev
```
Run the app inside the container:

```bash

```

Then access the app in your browser at:

```
http://localhost:3838
```

This launches the full BARQUE environment with all the eDNA toolchain pre-installed.

---

## 💻 Development (Optional - Local R Session)

If you want to develop or debug locally instead:

```r
# inside R
golem::document_and_reload()
barqueShinyApp::run_app()
```

---

## 🧪 Test Results

This project uses:
- `devtools::check()` for validation
- `covr` + `covrpage` for test coverage
- `testthat` for unit testing

See [dev/](dev/) for development scripts.

---

## 📬 Maintainer

Steve Vissault — <steve.vissault@inrs.ca>  
Developed for the TAQ initiative on environmental DNA in Québec.
