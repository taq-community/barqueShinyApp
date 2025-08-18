#' Clear intermediate and result folders of the BARQUE pipeline
#'
#' This utility function deletes all files (except `.gitignore`) in key output
#' folders used by the BARQUE eDNA processing pipeline. It is useful for
#' resetting the application state after a pipeline cancellation or after downloading results.
#'
#' @param base_dir Character. Path to the base BARQUE directory. Defaults to `"inst/barque"`.
#' @param verbose Logical. If `TRUE`, prints informative messages using `cli`. Default is `TRUE`.
#'
#' @return Invisibly returns `NULL`. Used for its side effects.
#'
#' @examples
#' clear_barque_folders() # Clears all BARQUE intermediate folders
#' clear_barque_folders("custom/barque/path", verbose = FALSE)
#'
#' @export
clear_barque_folders <- function(base_dir = "inst/barque", verbose = TRUE) {
  folders_to_clear <- c(
    "05_trimmed",
    "06_merged",
    "07_split_amplicons",
    "08_chimeras",
    "09_vsearch",
    "10_read_dropout",
    "11_non_annotated",
    "12_results"
  )

  for (folder in folders_to_clear) {
    full_path <- file.path(base_dir, folder)
    if (dir.exists(full_path)) {
      files <- list.files(full_path, full.names = TRUE, recursive = TRUE)
      files_to_delete <- files[!basename(files) %in% ".gitignore"]
      unlink(files_to_delete, recursive = TRUE, force = TRUE)
      if (verbose) cli::cli_alert_info("Cleared folder: {.path {full_path}}")
    } else if (verbose) {
      cli::cli_alert_warning("Folder does not exist: {.path {full_path}}")
    }
  }

  invisible(NULL)
}
