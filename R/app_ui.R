#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    bslib::page_sidebar(
      title = div(
        img(
          src = "https://raw.githubusercontent.com/enormandeau/barque/master/00_archive/barque_small.png",
          height = "40px", style = "margin-right: 10px;"
        ),
        "BARQUE v1.8.5"
      ),
      sidebar = bslib::sidebar(
        width = 300,
        # File management buttons
        fluidRow(
          column(
            6,
            actionButton("refresh_folder",
              div(fontawesome::fa("refresh"), "Refresh"),
              class = "btn-primary mb-3", style = "width: 100%;"
            )
          ),
          column(
            6,
            downloadButton("download_files",
              div(" Download sequences"),
              class = "btn-info mb-3", style = "width: 100%;"
            )
          )
        ),
        # Upload file input
        fileInput("upload_files",
          div(fontawesome::fa("upload"), " Upload Files"),
          multiple = TRUE,
          accept = NULL,
          width = "100%"
        ),
        # File list
        div(
          style = "height: 350px; overflow-y: auto; border: 1px solid #ddd; padding: 10px;",
          verbatimTextOutput("file_list")
        )
      ),
      bslib::card(
  bslib::card_header("Configuration"),
  bslib::accordion(
    bslib::accordion_panel(
      "Pipeline Configuration",
      # ───── Global Settings ─────
      bslib::card(
        bslib::card_header("Global"),
        fluidRow(
          column(6, numericInput("NCPUS", "Number of CPUs:", value = 20, min = 1)),
          column(6, textInput("PRIMER_FILE", "Primer File:", value = "02_info/primers.csv"))
        )
      ),
      # ───── Data Preparation ─────
      bslib::card(
        bslib::card_header("Data Preparation"),
        fluidRow(
          column(6, selectInput("SKIP_DATA_PREP", "Skip Data Preparation:", c("Run full pipeline" = 0, "Skip data prep" = 1))),
          column(6, numericInput("CROP_LENGTH", "Crop Length:", value = 200, min = 1))
        )
      ),
      # ───── Read Merging ─────
      bslib::card(
        bslib::card_header("Read Merging"),
        fluidRow(
          column(6, numericInput("MIN_OVERLAP", "Min Overlap:", value = 30, min = 1)),
          column(6, numericInput("MAX_OVERLAP", "Max Overlap:", value = 280, min = 1))
        )
      ),
      # ───── Barcoding & Chimera ─────
      bslib::card(
        bslib::card_header("Barcodes & Chimera Detection"),
        fluidRow(
          column(6, numericInput("MAX_PRIMER_DIFF", "Max Primer Differences:", value = 8, min = 0)),
          column(6, selectInput("SKIP_CHIMERA_DETECTION", "Chimera Detection:", c("Search for chimeras" = 0, "Skip chimera detection" = 1)))
        )
      ),
      # ───── VSEARCH Parameters ─────
      bslib::card(
        bslib::card_header("VSEARCH"),
        fluidRow(
          column(3, numericInput("MAX_ACCEPTS", "Max Accepts:", value = 20)),
          column(3, numericInput("MAX_REJECTS", "Max Rejects:", value = 20)),
          column(3, numericInput("QUERY_COV", "Query Coverage:", value = 0.6, min = 0, max = 1, step = 0.1)),
          column(3, numericInput("MIN_HIT_LENGTH", "Min Hit Length:", value = 100))
        )
      ),
      # ───── Filtering Thresholds ─────
      bslib::card(
        bslib::card_header("Filtering"),
        fluidRow(
          column(4, numericInput("MIN_HITS_SAMPLE", "Min Hits / Sample:", value = 10)),
          column(4, numericInput("MIN_HITS_EXPERIMENT", "Min Hits / Experiment:", value = 20)),
          column(4, numericInput("NUM_NON_ANNOTATED_SEQ", "# Non-Annotated Seqs:", value = 200))
        )
      ),
      # ───── OTUs & Multi-Hits ─────
      bslib::card(
        bslib::card_header("OTUs & Multiple Hits"),
        fluidRow(
          column(4, numericInput("MIN_DEPTH_MULTI", "Min Depth (Multi-Hits):", value = 10)),
          column(4, selectInput("SKIP_OTUS", "OTU Creation:", c("Create OTUs" = 0, "Skip OTUs" = 1))),
          column(4, numericInput("MIN_SIZE_FOR_OTU", "Min Size for OTU:", value = 20))
        )
      ),
      # ───── Save & Run Buttons ─────
      fluidRow(
        column(
          12,
          br(),
          actionButton("save_config",
            div(fontawesome::fa("save"), " Save Configuration"),
            class = "btn-warning", style = "width: 100%;"
          ),
          div(id = "config_message", style = "margin-top: 10px;")
        )
      )
    )
  ),
  br(),
  actionButton("execute_script",
    div(fontawesome::fa("play"), " Execute Script"),
    class = "btn-success", style = "width: 100%;"
  )
),
      bslib::card(
        bslib::card_header("Script Output"),
        verbatimTextOutput("script_output", placeholder = TRUE)
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "barque"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
