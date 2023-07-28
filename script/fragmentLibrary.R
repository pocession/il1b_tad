library(Basic4Cseq)
library(BSgenome.Hsapiens.UCSC.hg38)

# Functions ====
## Generate virtual library
getFragmentData <- function(genome, first_cutter, second_cutter, read_length, library_name) {
  fname <- file.path(wd,fragmentLibrary,paste0(paste(fragmentLibrary,first_cutter,second_cutter,read_length,sep="_"),".csv"))
  fragmentData <- createVirtualFragmentLibrary(chosenGenome = BSgenome.Hsapiens.UCSC.hg38, 
                                               firstCutter = "gatc", #DpnII 
                                               secondCutter = "catg", #N1aIII
                                               readLength = read_length,
                                               onlyNonBlind=TRUE, #=default
                                               useOnlyIndex = FALSE, #chr2
                                               useAllData=TRUE, 
                                               libraryName = fname)
}

# path ==== 
wd <- getwd()
fragmentLibrary <- "fragmentLibrary"

# variable ====
first_cutter <- "DpnII"
second_cutter <- "N1aIII"

# Generate virtual library
readLengthList <- c(21,23,40,42)
for (read_length in readLengthList) {
  library_name <- paste0(paste("FragmentLibrary",first_cutter,second_cutter,read_length,sep="_"),".csv")
  if (!file.exists(file.path(wd,fragmentLibrary,library_name)))
  {
    getFragmentData(BSgenome.Hsapiens.UCSC.hg38,first_cutter,second_cutter,read_length,library_name)
  }
}