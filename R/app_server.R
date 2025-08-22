#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  
  # Initialize cli logging
  cli::cli_h1("BARQUE Shiny Application")
  cli::cli_alert_info("Server initialized at {Sys.time()}")

  # Set 100 Mo per file upload limit
  options(shiny.maxRequestSize = 100 * 1024^2)
  options(shiny.reactlog = TRUE)

  folder_path <- get_golem_config("bq_seqs_dir")

  update_file_list <- function() {
    if (dir.exists(folder_path)) {
      values$file_list <- list.files(folder_path, full.names = TRUE)
    } else {
      values$file_list <- character(0)
    }
  }

  render_download_button <- function() {
    output$download_result_zip_ui <- renderUI({
      results_dir <- get_golem_config("bq_results_dir")
      has_results <- dir.exists(results_dir) && length(list.files(results_dir)) > 0
      is_running <- !is.null(values$proc) && values$proc$is_alive()

      disabled <- !has_results || is_running

      downloadButton("download_result_zip", "Download Results (.zip)",
        class = if (disabled) "btn-secondary disabled" else "btn-primary",
        style = "width: 100%;",
        disabled = disabled
      )
    })
  }

  clear_barque_folders()
  render_download_button()

  # Reactive values for storing data
  values <- reactiveValues(proc = NULL, log_timer = NULL, script_output = "", file_list = list.files(folder_path, full.names = TRUE), file_buttons = list())

  # File list
  output$file_list <- reactable::renderReactable({

    if (length(values$file_list) == 0) {
      return(reactable::reactable(data.frame(Message = "Folder is empty")))
    }

    file_df <- data.frame(
      Filename = basename(values$file_list),
      Size = paste0(round(file.info(values$file_list)$size / 1024^2, 2), " MB"),
      Modified = format(file.info(values$file_list)$mtime, "%Y-%m-%d %H:%M"),
      FullPath = values$file_list,
      stringsAsFactors = FALSE
    )

    # Stocke les noms des fichiers (utilisé par observe)
    values$file_buttons <- setNames(file_df$FullPath, paste0("delete_", seq_along(values$file_list)))

    reactable::reactable(
      file_df,
      compact = TRUE,
      fullWidth = TRUE,
      defaultPageSize = 50,
      columns = list(
        Filename = reactable::colDef(name = "Filename", searchable = TRUE),
        Size     = reactable::colDef(name = "Size", align = "right", width = 100),
        Modified = reactable::colDef(name = "Modified", align = "right", width = 160),
        FullPath   = reactable::colDef(name = "", align = "center", width = 70, html = TRUE,
        cell = function(value, index) {
            id <- paste0("delete_", index)
            as.character(tags$button(
              onclick = sprintf("Shiny.setInputValue('delete_trigger', '%s', {priority: 'event'})", id),
              class = "btn btn-sm btn-danger",
              fontawesome::fa("trash")
            ))
        })
      )
    )
  })

  # Bouton dynamique selon l'état
  output$script_control_button <- renderUI({
    if (!is.null(values$proc) && values$proc$is_alive()) {
      actionButton("cancel_script", div(fontawesome::fa("ban"), "Cancel run"), class = "btn-danger", style = "width: 100%;")
    } else {
      actionButton("execute_script", div(fontawesome::fa("play"), "Run pipeline"),, class = "btn-success", style = "width: 100%;")
    }
  })

  output$download_result_zip <- downloadHandler(
    filename = function() {
      paste0("barque_results_", Sys.Date(), ".zip")
    },
    content = function(file) {
      results_dir <- get_golem_config("bq_results_dir")
      
      # Temp zip file
      tmp_zip <- tempfile(fileext = ".zip")
      
      # Compress all contents in 12_results/
      old_wd <- setwd(results_dir)
      on.exit(setwd(old_wd), add = TRUE)

      zip::zip(zipfile = tmp_zip, files = list.files(".", recursive = TRUE))
      
      # Move zip to requested file location
      file.copy(tmp_zip, file)

      clear_barque_folders()

      cli::cli_alert_info("Clean barque folder after download.")
    },
    contentType = "application/zip"
  )
  
  # Execute script
  observeEvent(input$execute_script, {
    cli::cli_process_start("Launching script asynchronously...")
    shinyjs::disable("execute_script")

    clear_barque_folders()
    render_download_button()

    values$proc <- processx::process$new(
      command = "./barque",
      args = c("02_info/barque_config.sh"),
      wd = "inst/barque",
      stdout = "|", # pipe la sortie
      stderr = "2>&1"
    )
    
    cli::cli_alert_info("Running process with { values$proc$get_wd() }")

    # Timer pour lire la sortie toutes les secondes
    values$log_timer <- reactiveTimer(1000)
  })

  # Interruption du processus
  observeEvent(input$cancel_script, {
    if (!is.null(values$proc) && values$proc$is_alive()) {
      values$proc$kill()
      values$log_output <- c(values$log_output, "\n\n⛔ Pipeline annulé par l'utilisateur.")
      cli::cli_alert_danger("Pipeline interrompu.")
      values$proc <- NULL
      clear_barque_folders()
      render_download_button()
    }
  })

  # Lire et accumuler la sortie
  observe({
    req(values$proc)
    req(values$log_timer)
    values$log_timer()

    if (values$proc$is_alive()) {
      new_lines <- values$proc$read_output_lines()
      if (length(new_lines) > 0) {
        values$log_output <- c(values$log_output, new_lines)
      }
    } else {
      new_lines <- values$proc$read_all_output_lines()
      values$log_output <- c(values$log_output, new_lines)

      cli::cli_process_done()
      shinyjs::enable("execute_script")
      values$proc <- NULL
      render_download_button()
    }
  })

  # Affichage de tout le log
  output$log_output <- renderText({
    isolate({
      session$sendCustomMessage("scrollLogToBottom", "log_output")
    })
    paste(values$log_output, collapse = "\n")
  })
  
  observeEvent(input$save_config, {
    cli::cli_h2("Configuration Save")
    cli::cli_alert_info("Save configuration button clicked")

    tryCatch(
      {
        # Log configuration values being saved
        cli::cli_alert_info("Saving configuration parameters:")
        cli::cli_ul(c(
          "NCPUS: {.val {input$NCPUS}}",
          "PRIMER_FILE: {.file {input$PRIMER_SELECTED}}",
          "SKIP_DATA_PREP: {.val {input$SKIP_DATA_PREP}}",
          "CROP_LENGTH: {.val {input$CROP_LENGTH}}",
          "MIN_OVERLAP: {.val {input$MIN_OVERLAP}}",
          "MAX_OVERLAP: {.val {input$MAX_OVERLAP}}",
          "MAX_PRIMER_DIFF: {.val {input$MAX_PRIMER_DIFF}}",
          "SKIP_CHIMERA_DETECTION: {.val {input$SKIP_CHIMERA_DETECTION}}",
          "MAX_ACCEPTS: {.val {input$MAX_ACCEPTS}}",
          "MAX_REJECTS: {.val {input$MAX_REJECTS}}",
          "QUERY_COV: {.val {input$QUERY_COV}}",
          "MIN_HIT_LENGTH: {.val {input$MIN_HIT_LENGTH}}",
          "MIN_HITS_SAMPLE: {.val {input$MIN_HITS_SAMPLE}}",
          "MIN_HITS_EXPERIMENT: {.val {input$MIN_HITS_EXPERIMENT}}",
          "NUM_NON_ANNOTATED_SEQ: {.val {input$NUM_NON_ANNOTATED_SEQ}}",
          "MIN_DEPTH_MULTI: {.val {input$MIN_DEPTH_MULTI}}",
          "SKIP_OTUS: {.val {input$SKIP_OTUS}}",
          "MIN_SIZE_FOR_OTU: {.val {input$MIN_SIZE_FOR_OTU}}"
        ))

        write_barque_config(
          file = get_golem_config("bq_config_file"),
          NCPUS = input$NCPUS,
          PRIMER_FILE = stringr::str_replace(get_golem_config("bq_primer_file"), "inst/barque/", ""),
          SKIP_DATA_PREP = input$SKIP_DATA_PREP,
          CROP_LENGTH = input$CROP_LENGTH,
          MIN_OVERLAP = input$MIN_OVERLAP,
          MAX_OVERLAP = input$MAX_OVERLAP,
          MAX_PRIMER_DIFF = input$MAX_PRIMER_DIFF,
          SKIP_CHIMERA_DETECTION = input$SKIP_CHIMERA_DETECTION,
          MAX_ACCEPTS = input$MAX_ACCEPTS,
          MAX_REJECTS = input$MAX_REJECTS,
          QUERY_COV = input$QUERY_COV,
          MIN_HIT_LENGTH = input$MIN_HIT_LENGTH,
          MIN_HITS_SAMPLE = input$MIN_HITS_SAMPLE,
          MIN_HITS_EXPERIMENT = input$MIN_HITS_EXPERIMENT,
          NUM_NON_ANNOTATED_SEQ = input$NUM_NON_ANNOTATED_SEQ,
          MIN_DEPTH_MULTI = input$MIN_DEPTH_MULTI,
          SKIP_OTUS = input$SKIP_OTUS,
          MIN_SIZE_FOR_OTU = input$MIN_SIZE_FOR_OTU
        )

        write_selected_primer_csv(
          input_file = get_golem_config("bq_primer_file"), 
          output_file = get_golem_config("bq_primer_file"), 
          primer_to_activate = input$PRIMER_SELECTED
        )

        cli::cli_alert_success("Configuration successfully saved")

        shinyWidgets::show_toast(
          title = "Success!",
          text = "Configuration saved! Ready for BARQUE.",
          type = "success",
          position = "center",
          timer = 3000
        )
      },
      error = function(e) {
        cli::cli_alert_danger("Error saving configuration: {.strong {e$message}}")

        shinyWidgets::show_toast(
          title = "Error",
          text = paste("Error saving configuration:", e$message),
          type = "error",
          position = "center",
          timer = 7000
        )
      }
    )
  })
  
  # Clear data folder
  observeEvent(input$clear_data_folder, {
    shinyWidgets::confirmSweetAlert(
      session = session,
      inputId = "confirm_clear",
      title = "Are you sure?",
      text = "This will delete all files in the folder.",
      type = "warning"
    )
  })

  # Handle confirmation for clearing data folder
  observeEvent(input$confirm_clear, {
    if (isTRUE(input$confirm_clear)) {
      files <- list.files(folder_path, full.names = TRUE)
      file.remove(files)
      update_file_list()
      shinyWidgets::show_toast(title = "Success!", text = "All files removed from data folder", type = "success", position = "center", timer = 3000)
    }
  })

  # Log file uploads
  observeEvent(input$upload_files, {
    for (i in seq_len(nrow(input$upload_files))) {
      file.copy(
        from = input$upload_files$datapath[i],
        to = file.path(folder_path, input$upload_files$name[i]),
        overwrite = TRUE
      )
    }

    cli::cli_alert_success("Uploaded {nrow(input$upload_files)} files to {.path {folder_path}}")
    print(values$file_buttons)
    update_file_list()
  })

  observeEvent(input$delete_trigger, {
    id <- input$delete_trigger
    path <- values$file_buttons[[id]]
    if (file.exists(path)) {
      file.remove(path)
      cli::cli_alert_success("Deleted file {.file {basename(path)}}")
      update_file_list()
    }
  })

  output$primer_info <- renderTable({
      req(input$PRIMER_SELECTED)

      primer_path <- get_golem_config("bq_primer_file")
      primers <- read_primers(primer_path)

      selected <- primers[primers$PrimerName == input$PRIMER_SELECTED, ]

      if (nrow(selected) == 0) {
        return(data.frame(Property = "Error", Value = "Selected primer not found."))
      }

      data.frame(
        Property = c("Forward", "Reverse", "Amplicon Size", "Database"),
        Value = c(
          selected$ForwardSeq,
          selected$ReverseSeq,
          paste0(selected$MinAmpliconSize, "–", selected$MaxAmpliconSize),
          selected$DatabaseName
        ),
        stringsAsFactors = FALSE
      )
    },
    striped = FALSE,
    bordered = FALSE,
    spacing = "xs"
  )
  
  observeEvent(input$clear_log, {
    values$log_output <- character(0)
    cli::cli_alert_info("Console log cleared by user.")
  })

  # Log app shutdown
  session$onSessionEnded(function() {
    cli::cli_alert_info("BARQUE Shiny app session ended at {Sys.time()}")
  })
}

