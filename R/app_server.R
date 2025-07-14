#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  
  # Reactive values for storing data
  values <- reactiveValues(
    script_output = "",
    config_message = ""
  )
  
  # File list in sidebar
  output$file_list <- renderText({
    # Trigger refresh when button is clicked or files are uploaded
    input$refresh_folder
    input$upload_files
    
    tryCatch({
      folder_path <- getwd()  # Use current working directory
      if (dir.exists(folder_path)) {
        files <- list.files(folder_path, full.names = FALSE, all.files = TRUE)
        if (length(files) > 0) {
          paste(files, collapse = "\n")
        } else {
          "Folder is empty"
        }
      } else {
        "Folder does not exist"
      }
    }, error = function(e) {
      paste("Error reading folder:", e$message)
    })
  })
  
  # Handle file upload
  observeEvent(input$upload_files, {
    if (!is.null(input$upload_files)) {
      tryCatch({
        # Copy uploaded files to current working directory
        for (i in 1:nrow(input$upload_files)) {
          file.copy(input$upload_files$datapath[i], 
                   input$upload_files$name[i], 
                   overwrite = TRUE)
        }
        
        # Show success message
        showNotification(
          paste("Successfully uploaded", nrow(input$upload_files), "file(s)"),
          type = "message",
          duration = 3
        )
        
      }, error = function(e) {
        showNotification(
          paste("Error uploading files:", e$message),
          type = "error",
          duration = 5
        )
      })
    }
  })
  
  # Handle file download
  output$download_files <- downloadHandler(
    filename = function() {
      paste("project_files_", Sys.Date(), ".zip", sep = "")
    },
    content = function(file) {
      # Create a temporary directory
      temp_dir <- tempdir()
      
      # Get list of files in current directory
      files <- list.files(getwd(), full.names = TRUE, all.files = FALSE)
      
      # Copy files to temp directory
      if (length(files) > 0) {
        file.copy(files, temp_dir, overwrite = TRUE)
        
        # Create zip file
        zip_files <- list.files(temp_dir, full.names = TRUE)
        zip(file, zip_files, flags = "-r9X")
      } else {
        # Create empty zip if no files
        zip(file, character(0))
      }
    }
  )
  
  # Display script output
  output$script_output <- renderText({
    values$script_output
  })
  
  # Placeholder for execute script button
  observeEvent(input$execute_script, {
    values$script_output <- "Execute script functionality - placeholder for future implementation"
  })
  
  # Save configuration as environment variables
  observeEvent(input$save_config, {
    tryCatch({
      # Set environment variables for all configuration parameters
      Sys.setenv(NCPUS = input$NCPUS)
      Sys.setenv(PRIMER_FILE = input$PRIMER_FILE)
      Sys.setenv(SKIP_DATA_PREP = input$SKIP_DATA_PREP)
      Sys.setenv(CROP_LENGTH = input$CROP_LENGTH)
      Sys.setenv(MIN_OVERLAP = input$MIN_OVERLAP)
      Sys.setenv(MAX_OVERLAP = input$MAX_OVERLAP)
      Sys.setenv(MAX_PRIMER_DIFF = input$MAX_PRIMER_DIFF)
      Sys.setenv(SKIP_CHIMERA_DETECTION = input$SKIP_CHIMERA_DETECTION)
      Sys.setenv(MAX_ACCEPTS = input$MAX_ACCEPTS)
      Sys.setenv(MAX_REJECTS = input$MAX_REJECTS)
      Sys.setenv(QUERY_COV = input$QUERY_COV)
      Sys.setenv(MIN_HIT_LENGTH = input$MIN_HIT_LENGTH)
      Sys.setenv(MIN_HITS_SAMPLE = input$MIN_HITS_SAMPLE)
      Sys.setenv(MIN_HITS_EXPERIMENT = input$MIN_HITS_EXPERIMENT)
      Sys.setenv(NUM_NON_ANNOTATED_SEQ = input$NUM_NON_ANNOTATED_SEQ)
      Sys.setenv(MIN_DEPTH_MULTI = input$MIN_DEPTH_MULTI)
      Sys.setenv(SKIP_OTUS = input$SKIP_OTUS)
      Sys.setenv(MIN_SIZE_FOR_OTU = input$MIN_SIZE_FOR_OTU)
      
      # Show success message
      insertUI(
        selector = "#config_message",
        ui = div(class = "alert alert-success", 
                paste("Configuration saved as environment variables! ",
                      "All parameters are now available for your bash scripts.")),
        where = "afterBegin"
      )
      
    }, error = function(e) {
      insertUI(
        selector = "#config_message",
        ui = div(class = "alert alert-danger", paste("Error saving configuration:", e$message)),
        where = "afterBegin"
      )
    })
  })
}
