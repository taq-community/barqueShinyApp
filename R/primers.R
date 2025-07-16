#' Activate a Specific Primer Entry in a Hashtag-Commented CSV File
#'
#' This function processes a primer definition file where each entry line is commented out with a leading `#`.
#' It ensures all data lines begin with a `#` (normalization step), then activates a specific primer by removing
#' the `#` character from the line that matches the given primer name in the first column.
#'
#' @param input_file Character. Path to the input CSV file with primer definitions.
#' @param output_file Character. Path to the output CSV file to write the modified data.
#' @param primer_to_activate Character. The exact name of the primer (first column value) to activate
#' (i.e., remove the `#` prefix from its line).
#'
#' @return Invisibly returns `TRUE` on successful write. The modified file is written to `output_file`.
#'
#' @details This function is useful for selecting a single active primer in workflows where only one
#' primer block should be used at a time. It preserves all other lines as commented, and the file
#' remains readable as a CSV after processing.
#'
#' @examples
#' \dontrun{
#' write_selected_primer_csv("primers.csv", "primers_active.csv", "COI_F230")
#' }
#'
#' @export
write_selected_primer_csv <- function(input_file, output_file, primer_to_activate) {
  # Read lines as characters
  lines <- readLines(input_file)
  
  # Normalize: ensure every non-empty, non-commented line starts with "#"
  normalized_lines <- vapply(lines, function(line) {
    if (grepl("^[^#\\s]", line)) {
      paste0("#", line)
    } else {
      line
    }
  }, character(1))

  # Now safely un-comment the selected primer line
  pattern <- paste0("^#", primer_to_activate, ",")
  updated_lines <- gsub(pattern, paste0(primer_to_activate, ","), normalized_lines)

  # Write to output
  writeLines(updated_lines, output_file)
}

#' Extract Primer Names from a Hashtag-Commented CSV File
#'
#' Parses a CSV-style primer definition file in which each row may be commented out with a leading `#`,
#' and extracts the names from the first column of all valid lines. The leading `#` is removed from each entry.
#'
#' @param input_file Character. Path to the CSV file containing primer definitions, with rows optionally
#' prefixed by `#`.
#'
#' @return A character vector of primer names (first column), with any leading `#` removed.
#'
#' @details This function is useful when reading primer configuration files where all entries may be commented
#' out by default. It extracts all lines that look like primer entries (i.e., match a pattern like `#PrimerName,...`)
#' and strips the comment symbol from the primer name.
#'
#' @examples
#' \dontrun{
#' primers <- get_primer_names("primers.csv")
#' print(primers)
#' }
#'
#' @export
get_primer_names <- function(input_file = get_golem_config("bq_primer_file")) {
  lines <- readLines(input_file)
  
  # Filter out the header row if present
  data_lines <- lines[grepl("^[#]?[A-Za-z0-9_]+,", lines)]

  # Extract the first column and remove leading "#"
  primer_names <- sub("^#?", "", sub(",.*$", "", data_lines))

  return(primer_names[-1])
}



