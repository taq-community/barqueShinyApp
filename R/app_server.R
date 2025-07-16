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
  
  # Reactive values for storing data
  values <- reactiveValues(
    script_output = "",
    config_message = ""
  )
  
  # File list in sidebar
  output$file_list <- reactable::renderReactable({
    # Trigger refresh when button is clicked or files are uploaded
    input$refresh_folder
    input$upload_files
    
    cli::cli_alert_info("File list refresh triggered")
    
    tryCatch({
      folder_path <- get_golem_config("bq_seqs_dir")  # Use current working directory
      cli::cli_alert_info("Reading folder: {.path {folder_path}}")
      
      if (dir.exists(folder_path)) {
        files <- list.files(folder_path, full.names = FALSE, all.files = TRUE, no.. = TRUE, include.dirs = FALSE, pattern = "*.fastq.gz")
        cli::cli_alert_success("Found {.strong {length(files)}} files in folder")
        
        if (length(files) > 0) {
          # Create a data frame with file information
          file_info <- data.frame(
            Files = files,
            stringsAsFactors = FALSE
          )
          
          # Add file size in MB and modification date
          file_details <- file.info(file.path(folder_path, files))
          file_info$Size <- paste0(round(file_details$size / (1024^2), 2), " MB")
          file_info$Modified <- format(file_details$mtime, "%Y-%m-%d %H:%M")
          
          cli::cli_alert_success("File information successfully processed for reactable")
          
          reactable::reactable(
            file_info,
            compact = TRUE,
            fullWidth = TRUE,
            showPageInfo = FALSE,
            searchable = TRUE,
            showPageSizeOptions = FALSE,
            defaultPageSize = 100,
            columns = list(
              Files = reactable::colDef(
                name = "Files",
                minWidth = 120,
              ),
              Size = reactable::colDef(
                name = "Size (MB)",
                width = 120,
                align = "right"
              ),
              Modified = reactable::colDef( 
                name = "Last Modified",
                width = 150,
                align = "right"
              )
            ),
            theme = reactable::reactableTheme(
              style = list(fontSize = "14px")
            )
          )
        } else {
          cli::cli_alert_warning("Folder is empty")
          # Return empty reactable with message
          empty_df <- data.frame(Message = "Folder is empty", stringsAsFactors = FALSE)
          reactable::reactable(
            empty_df,
            compact = TRUE,
            fullWidth = TRUE,
            showPageInfo = FALSE,
            searchable = TRUE,
            showPageSizeOptions = FALSE,
            columns = list(
              Message = reactable::colDef(
                name = "",
                style = list(textAlign = "center", fontStyle = "italic", color = "#666")
              )
            )
          )
        }
      } else {
        cli::cli_alert_danger("Folder does not exist: {.path {folder_path}}")
        # Return empty reactable with error message
        error_df <- data.frame(Message = "Folder does not exist", stringsAsFactors = FALSE)
        reactable::reactable(
          error_df,
          compact = TRUE,
          fullWidth = TRUE,
          showPageInfo = FALSE,
          searchable = TRUE,
          showPageSizeOptions = FALSE,
          columns = list(
            Message = reactable::colDef(
              name = "",
              style = list(textAlign = "center", fontStyle = "italic", color = "#d32f2f")
            )
          )
        )
      }
    }, error = function(e) {
      cli::cli_alert_danger("Error reading folder: {.strong {e$message}}")
      # Return empty reactable with error message
      error_df <- data.frame(Message = paste("Error reading folder:", e$message), stringsAsFactors = FALSE)
      reactable::reactable(
        error_df,
        compact = TRUE,
        fullWidth = TRUE,
        showPageInfo = FALSE,
        searchable = TRUE,
        showPageSizeOptions = FALSE,
        columns = list(
          Message = reactable::colDef(
            name = "",
            style = list(textAlign = "center", fontStyle = "italic", color = "#d32f2f")
          )
        )
      )
    })
  })
  
  # Display script output
  output$script_output <- renderText({
    values$script_output
  })
  
  # Placeholder for execute script button
  observeEvent(input$execute_script, {
    cli::cli_alert_info("Execute script button clicked")
    cli::cli_process_start("Starting script execution...")
    values$script_output <- "Execute script functionality - placeholder for future implementation"
    cli::cli_process_done()
  })

  observeEvent(input$execute_script, {
    system("cd inst/barque && ./barque 02_info/barque_config.sh", wait = TRUE)
  })
  

  observeEvent(input$save_config, {
    cli::cli_h2("Configuration Save")
    cli::cli_alert_info("Save configuration button clicked")
    
    tryCatch({
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
        PRIMER_FILE = get_golem_config("bq_primer_file"),
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

      write_selected_primer_csv(primer_to_activate = input$PRIMER_SELECTED)

      cli::cli_alert_success("Configuration successfully saved")

      shinyWidgets::show_toast(
        title = "Success!",
        text = "Configuration saved! Ready for BARQUE.",
        type = "success",
        position = "center",
        timer = 3000
      )

    }, error = function(e) {
      cli::cli_alert_danger("Error saving configuration: {.strong {e$message}}")

      shinyWidgets::show_toast(
        title = "Error",
        text = paste("Error saving configuration:", e$message),
        type = "error",
        position = "center",
        timer = 7000
      )
    })
  })

  # Log file uploads
  observeEvent(input$upload_files, {
    if (!is.null(input$upload_files)) {
      cli::cli_h3("File Upload")
      cli::cli_alert_info("Files uploaded: {.strong {nrow(input$upload_files)}} files")
      
      for (i in 1:nrow(input$upload_files)) {
        size_mb <- round(input$upload_files$size[i] / (1024^2), 2)
        cli::cli_li("File: {.file {input$upload_files$name[i]}} ({.val {size_mb}} MB)")
      }
    }
  })
  
  # Log refresh button clicks
  observeEvent(input$refresh_folder, {
    cli::cli_alert_info("Refresh folder button clicked")
  })
  
  # Log app shutdown
  session$onSessionEnded(function() {
    cli::cli_alert_info("BARQUE Shiny app session ended at {Sys.time()}")
  })
}
