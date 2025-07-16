# Building a Prod-Ready, Robust Shiny Application.
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
#
########################################
#### CURRENT FILE: ON START SCRIPT #####
########################################

## Fill the DESCRIPTION ----
## Add meta data about your application and set some default {golem} options

golem::fill_desc(
  pkg_name = "barqueShinyApp", # The name of the golem package containing the app
  pkg_title = "BARQUE Viewer", # Title of the app
  pkg_description = "A Shiny application for executing and exploring outputs from the BARQUE eDNA analysis pipeline.", 
  authors = person(
    given = "Steve", 
    family = "Vissault", 
    email = "steve.vissault@inrs.ca", 
    role = c("aut", "cre")
  ),
  repo_url = "https://github.com/taq-community/barque-app", # Correct GitHub URL
  pkg_version = "0.0.0.9000",
  set_options = TRUE
)

## Install the required dev dependencies ----
golem::install_dev_deps()

## Create Common Files ----
usethis::use_mit_license("Steve Vissault") 
golem::use_readme_rmd(open = FALSE)
devtools::build_readme()
usethis::use_code_of_conduct(contact = "steve.vissault@inrs.ca")
usethis::use_lifecycle_badge("Experimental")
usethis::use_news_md(open = FALSE)

## Init Testing Infrastructure ----
golem::use_recommended_tests()

## Favicon ----
golem::use_favicon() # Default icon

## Add helper functions ----
golem::use_utils_ui(with_test = TRUE)
golem::use_utils_server(with_test = TRUE)

## Use git ----
usethis::use_git()
usethis::use_git_remote(
  name = "origin",
  url = "https://github.com/taq-community/barqueShinyApp",
  overwrite = TRUE
)

# You're now set! ----

# go to dev/02_dev.R
rstudioapi::navigateToFile("dev/02_dev.R")
