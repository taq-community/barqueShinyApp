#' Write a Barque Configuration File
#'
#' Generates a `.sh` file to configure a Barque pipeline run, with all parameters inserted as shell variables.
#' The function ensures reproducibility and simplifies launching Barque with consistent settings.
#'
#' @param file Character. Output file path for the `.sh` config script.
#' @param NCPUS Integer. Number of CPUs to use. A lot of the steps are parallelized (int, 1+).
#' @param PRIMER_FILE Character. File with PCR primers information.
#' @param SKIP_DATA_PREP Integer. Set to 1 to skip data preparation steps, 0 to run the full pipeline (recommended).
#' @param CROP_LENGTH Integer. Cut reads to this length after filtering. Should be just under amplicon length.
#' @param MIN_OVERLAP Integer. Minimum number of overlapping nucleotides to merge reads (int, 1+).
#' @param MAX_OVERLAP Integer. Maximum number of overlapping nucleotides to merge reads (int, 1+).
#' @param MAX_PRIMER_DIFF Integer. Maximum number of differences allowed between primer and sequence (int, 0+).
#' @param SKIP_CHIMERA_DETECTION Integer. 0 to search for chimeras (recommended), 1 to skip detection or reuse existing files.
#' @param MAX_ACCEPTS Integer. Accept at most this number of sequences before stopping search (int, 1+).
#' @param MAX_REJECTS Integer. Reject at most this number of sequences before stopping search (int, 1+).
#' @param QUERY_COV Numeric. At least that proportion of the sequence must match the database (float, 0-1).
#' @param MIN_HIT_LENGTH Integer. Minimum vsearch hit length to keep in results (int, 1+).
#' @param MIN_HITS_SAMPLE Integer. Minimum number of hits in at least one sample to keep in results (int, 1+).
#' @param MIN_HITS_EXPERIMENT Integer. Minimum number of hits in the whole experiment to keep in results (int, 1+).
#' @param NUM_NON_ANNOTATED_SEQ Integer. Number of most frequent non-annotated unique reads to keep (int, 1+).
#' @param MIN_DEPTH_MULTI Integer. Minimum depth to report unique reads per sample in multiple-hit reports.
#' @param SKIP_OTUS Integer. Set to 1 to skip OTU creation, 0 to use it.
#' @param MIN_SIZE_FOR_OTU Integer. Minimum coverage of unique reads used for OTUs.
#'
#' @return Invisibly returns `TRUE` on success. Writes a Bash script to the specified output path.
#'
#' @examples
#' \dontrun{
#' write_barque_config("barque_config.sh", NCPUS = 16, CROP_LENGTH = 180)
#' }
#' @export
write_barque_config <- function(
  file = get_golem_config("bq_config_file"),
  NCPUS = get_golem_config("bq_ncpus"),
  PRIMER_FILE = get_golem_config("bq_primer_file"),
  SKIP_DATA_PREP = 0,
  CROP_LENGTH = 200,
  MIN_OVERLAP = 30,
  MAX_OVERLAP = 280,
  MAX_PRIMER_DIFF = 8,
  SKIP_CHIMERA_DETECTION = 0,
  MAX_ACCEPTS = 20,
  MAX_REJECTS = 20,
  QUERY_COV = 0.6,
  MIN_HIT_LENGTH = 100,
  MIN_HITS_SAMPLE = 10,
  MIN_HITS_EXPERIMENT = 20,
  NUM_NON_ANNOTATED_SEQ = 200,
  MIN_DEPTH_MULTI = 10,
  SKIP_OTUS = 1,
  MIN_SIZE_FOR_OTU = 20
) {
  template <- glue::glue(
    "#!/bin/bash

# Modify the following parameter values according to your experiment
# Do not modify the parameter names or remove parameters
# Do not add spaces around the equal (=) sign
# It is a good idea to try to run Barque with different parameters 

# Global parameters
NCPUS={NCPUS}
PRIMER_FILE=\"{PRIMER_FILE}\"

# Skip data preparation and rerun only from vsearchp
SKIP_DATA_PREP={SKIP_DATA_PREP}

# Filtering with Trimmomatic
CROP_LENGTH={CROP_LENGTH}

# Merging reads with flash
MIN_OVERLAP={MIN_OVERLAP}
MAX_OVERLAP={MAX_OVERLAP}

# Extracting barcodes
MAX_PRIMER_DIFF={MAX_PRIMER_DIFF}

# Running or skipping chimera detection
SKIP_CHIMERA_DETECTION={SKIP_CHIMERA_DETECTION}

# vsearch
MAX_ACCEPTS={MAX_ACCEPTS}
MAX_REJECTS={MAX_REJECTS}
QUERY_COV={QUERY_COV}
MIN_HIT_LENGTH={MIN_HIT_LENGTH}

# Filters
MIN_HITS_SAMPLE={MIN_HITS_SAMPLE}
MIN_HITS_EXPERIMENT={MIN_HITS_EXPERIMENT}

# Non-annotated reads
NUM_NON_ANNOTATED_SEQ={NUM_NON_ANNOTATED_SEQ}

# Multiple hits
MIN_DEPTH_MULTI={MIN_DEPTH_MULTI}

# OTUs
SKIP_OTUS={SKIP_OTUS}
MIN_SIZE_FOR_OTU={MIN_SIZE_FOR_OTU}
", .open = "{", .close = "}"
  )

  writeLines(template, con = file)
  invisible(TRUE)
}
