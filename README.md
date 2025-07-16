
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{barqueShinyApp}`

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Installation

You can install the development version of `{barqueShinyApp}` like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Run

You can launch the application by running:

``` r
barqueShinyApp::run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-07-16 13:52:58 EDT"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ══ Documenting ═════════════════════════════════════════════════════════════════
#> ℹ Installed roxygen2 version (7.3.2) doesn't match required (7.1.1)
#> ✖ `check()` will not re-document this package
#> ── R CMD check results ────────────────────────── barqueShinyApp 0.0.0.9000 ────
#> Duration: 39.8s
#> 
#> ❯ checking dependencies in R code ... WARNING
#>   '::' or ':::' imports not declared from:
#>     ‘bslib’ ‘cli’ ‘fontawesome’ ‘reactable’
#> 
#> ❯ checking for hidden files and directories ... NOTE
#>   Found the following hidden files and directories:
#>     inst/barque/.git
#>     inst/barque/11_non_annotated/.gitignored
#>   These were most likely included in error. See section ‘Package
#>   structure’ in the ‘Writing R Extensions’ manual.
#> 
#> ❯ checking installed package size ... NOTE
#>     installed size is 1289.0Mb
#>     sub-directories of 1Mb or more:
#>       barque  1288.9Mb
#> 
#> ❯ checking top-level files ... NOTE
#>   Non-standard files/directories found at top level:
#>     ‘Dockerfile’ ‘dev’
#> 
#> ❯ checking package subdirectories ... NOTE
#>   Problems with news in ‘NEWS.md’:
#>   No news entries found.
#> 
#> 0 errors ✔ | 1 warning ✖ | 4 notes ✖
#> Error: R CMD check found WARNINGs
```

``` r
covr::package_coverage()
#> Error in loadNamespace(x): there is no package called 'covr'
```
