app_ui <- function(request) {
  tagList(
    shinyjs::useShinyjs(),
    golem_add_external_resources(),
    bslib::page_navbar(
      theme = bslib::bs_theme(version = 5),
      title = tagList(
        img(
          src = "https://raw.githubusercontent.com/enormandeau/barque/master/00_archive/barque_small.png",
          height = "60px"
        ),
        strong("BARQUE"),
        span(class = "badge bg-dark", "v1.8.5", style = "margin-right: 30px;")
      ),

      # Tab 1: Sequences Upload
      bslib::nav_panel(
        "1. Sequences Upload",
        # Carte 1 – Upload
       bslib::card(
        bslib::card_header(h5("Sequences manager", style = "font-weight: bold;")),
        class = "mb-4",
        # Section Upload
        fluidRow(
          column(
            width = 8,
            fileInput("upload_files",
              div(fontawesome::fa("upload"), " Upload sequences"),
              multiple = TRUE,
              accept = ".fastq.gz",
              width = "100%"
            )
          ),
          column(
            width = 2,
            br(),
            actionButton("refresh_folder",
              div(fontawesome::fa("refresh"), " Refresh"),
              class = "btn-primary",
              style = "width: 100%;"
            )
          ),
          column(
            width = 2,
            br(),
            actionButton("clear_data_folder",
              div(fontawesome::fa("trash"), " Clear all"),
              class = "btn-danger",
              style = "width: 100%;"
            )
          )
        ),

        # Section File List
        tags$p("Sequences waiting for processing", style = "font-weight: bold;"),
        div(
          reactable::reactableOutput("file_list")
        )
      )

      ),

      # Tab 2: Configuration and Run Pipeline
      bslib::nav_panel(
        "2. Configuration & Run",
        fluidRow(
          column(
            6,
            bslib::card(
              bslib::card_header(h5("Configuration", style = "font-weight: bold;")),
              bslib::accordion(
                open = "global", # Only the first panel (Global) will be open by default
                # ───── Global Settings ─────
                bslib::accordion_panel(
                  "Global",
                  value = "global",
                  fluidRow(
                    column(
                      6,
                      bslib::tooltip(
                        selectInput("PRIMER_SELECTED", "Primer selected:",
                          choices = get_primer_names(),
                          selected = "12s200pb"
                        ),
                        "PCR primer to use for the analysis"
                      )
                    ),
                    column(
                      6,
                      tableOutput("primer_info")
                    )
                  )
                ),
                # ───── Data Preparation ─────
                bslib::accordion_panel(
                  "Data Preparation",
                  value = "data_prep",
                  fluidRow(
                    column(
                      6,
                      bslib::tooltip(
                        selectInput("SKIP_DATA_PREP", "Skip Data Preparation:", c("Run full pipeline" = 0, "Skip data prep" = 1)),
                        "1 to skip data preparation steps, 0 to run full pipeline (recommended)"
                      )
                    ),
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("CROP_LENGTH", "Crop Length:", value = 200, min = 1),
                        "Cut reads to this length after filtering. Just under amplicon length"
                      )
                    )
                  )
                ),
                # ───── Read Merging ─────
                bslib::accordion_panel(
                  "Read Merging",
                  value = "read_merging",
                  fluidRow(
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("MIN_OVERLAP", "Min Overlap:", value = 30, min = 1),
                        "Minimum number of overlapping nucleotides to merge reads (int, 1+)"
                      )
                    ),
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("MAX_OVERLAP", "Max Overlap:", value = 280, min = 1),
                        "Maximum number of overlapping nucleotides to merge reads (int, 1+)"
                      )
                    )
                  )
                ),
                # ───── Barcoding & Chimera ─────
                bslib::accordion_panel(
                  "Barcodes & Chimera Detection",
                  value = "barcodes_chimera",
                  fluidRow(
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("MAX_PRIMER_DIFF", "Max Primer Differences:", value = 8, min = 0),
                        "Maximum number of differences allowed between primer and sequence (int, 0+)"
                      )
                    ),
                    column(
                      6,
                      bslib::tooltip(
                        selectInput("SKIP_CHIMERA_DETECTION", "Chimera Detection:", c("Search for chimeras" = 0, "Skip chimera detection" = 1)),
                        "0 to search for chimeras (RECOMMENDED), 1 to skip chimera detection or use already created chimera cleaned files"
                      )
                    )
                  )
                ),
                # ───── VSEARCH Parameters ─────
                bslib::accordion_panel(
                  "VSEARCH",
                  value = "vsearch",
                  fluidRow(
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("MAX_ACCEPTS", "Max Accepts:", value = 20),
                        "Accept at most this number of sequences before stopping search (int, 1+)"
                      )
                    ),
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("MAX_REJECTS", "Max Rejects:", value = 20),
                        "Reject at most this number of sequences before stopping search (int, 1+)"
                      )
                    )
                  ),
                  fluidRow(
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("QUERY_COV", "Query Coverage:", value = 0.6, min = 0, max = 1, step = 0.1),
                        "At least that proportion of the sequence must match the database (float, 0-1)"
                      )
                    ),
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("MIN_HIT_LENGTH", "Min Hit Length:", value = 100),
                        "Minimum vsearch hit length to keep in results (int, 1+)"
                      )
                    )
                  )
                ),
                # ───── Filtering Thresholds ─────
                bslib::accordion_panel(
                  "Filtering",
                  value = "filtering",
                  fluidRow(
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("MIN_HITS_SAMPLE", "Min Hits / Sample:", value = 10),
                        "Minimum number of hits in at least one sample to keep in results (int, 1+)"
                      )
                    ),
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("MIN_HITS_EXPERIMENT", "Min Hits / Experiment:", value = 20),
                        "Minimum number of hits in whole experiment to keep in results (int, 1+)"
                      )
                    )
                  ),
                  fluidRow(
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("NUM_NON_ANNOTATED_SEQ", "# Non-Annotated Seqs:", value = 200),
                        "Number of unique most-frequent non-annotated reads to keep (int, 1+)"
                      )
                    ),
                    column(6, div()) # Empty column for spacing
                  )
                ),
                # ───── OTUs & Multi-Hits ─────
                bslib::accordion_panel(
                  "OTUs & Multiple Hits",
                  value = "otus_multi",
                  fluidRow(
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("MIN_DEPTH_MULTI", "Min Depth (Multi-Hits):", value = 10),
                        "Min depth to report unique reads per sample in multiple hit reports"
                      )
                    ),
                    column(
                      6,
                      bslib::tooltip(
                        selectInput("SKIP_OTUS", "OTU Creation:", c("Create OTUs" = 0, "Skip OTUs" = 1)),
                        "1 to skip OTU creation, 0 to use it"
                      )
                    )
                  ),
                  fluidRow(
                    column(
                      6,
                      bslib::tooltip(
                        numericInput("MIN_SIZE_FOR_OTU", "Min Size for OTU:", value = 20),
                        "Only unique reads with at least this coverage will be used for OTUs"
                      )
                    ),
                    column(6, div()) # Empty column for spacing
                  )
                )
              ),
              # ───── Save & Run Buttons ─────
              fluidRow(
                column(
                  6,
                  br(),
                  actionButton("save_config",
                    div(fontawesome::fa("save"), " Save Configuration"),
                    class = "btn-warning", style = "width: 100%;"
                  )
                ),
                column(
                  6,
                  br(),
                  uiOutput("script_control_button")
                )
              ),
              div(id = "config_message", style = "margin-top: 10px;")
            )
          ),
          column(
            6,
            bslib::card(
              bslib::card_header(h5("Script Output", style = "font-weight: bold;")),
              style = "height: 85vh; max-height: 85vh; overflow-y: auto;",
              fluidRow(
                column(
                  6,
                  br(),
                  actionButton("clear_log", div(fontawesome::fa("broom"), "Clear Log"), class = "btn-primary", style = "width: 100%;")
                ),
                column(
                  6,
                  br(),
                  uiOutput("download_result_zip_ui")
                )
              ),
              verbatimTextOutput("log_output", placeholder = TRUE)
            )
          )
        )
      )
    )
  )
}

golem_add_external_resources <- function(){
  golem::add_resource_path(
    'www', app_sys('app/www')
  )

  tags$head(
    # Autres ressources ici (favicon, css)
    tags$script(src = "www/scroll.js")
  )
}
