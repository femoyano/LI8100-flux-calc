##### Read and merge multiplexed Licor-8100 data from .dat stream files

LI8100_stream_mergedat <- function(path) {
  require(readr)
  files <- list.files(path, pattern = ".dat$", full.names = TRUE, recursive = TRUE)
  
  # Read and merge files
  for(i in 1:length(files)) {
    filedata <- read_csv(
      files[i], na = c("", "NA", "NAN"), col_names = FALSE, 
      col_types = cols(
        X1 = col_datetime(format = "%Y%m%d%H%M%S"), 
        X2 = col_datetime(format = "%Y%m%d%H%M%S"),
        X3 = col_double(), X4 = col_double(),
        X5 = col_double(), X6 = col_double(),
        X7 = col_double(), X8 = col_double(),
        X9 = col_double(), X10 = col_double(),
        X11 = col_double(), X12 = col_double(),
        X13 = col_double(), X14 = col_double(),
        X15 = col_double(), X16 = col_double()),
      skip = 4)
    if(i == 1) {
      rawdata <- filedata
    } else {
      rawdata <- rbind(rawdata, filedata)
    }
  }
  
  dataheader <- names(read.csv(files[1], skip = 1))
  names(rawdata) <- dataheader
  return(rawdata)
}
