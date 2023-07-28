# This script is used for generating plots and raw reads data frame for 4C experiments

library(Basic4Cseq)
library(tidyverse)
library(GenomicAlignments)
library(BSgenome.Hsapiens.UCSC.hg38)
library(ggplot2)

# path 
wd <- getwd()
fragmentLibrary <- "fragmentLibrary"
bam <- "bam"
pointsofinterests <- "PointsOfInterest_+Ezio_hg38.bed"
sampleSheet_file <- "sampleSheet"
output_data <- "output_data"

# variable
first_cutter <- "DpnII"
second_cutter <- "N1aIII"

# coordinates
## IL1B super TAD
## IL1B_coordinate <- c(112712617,113181216)
regionOfInterest <- c(112712617,113181216)

## VP information
## VP2, VP3, VP6
VP_list=c("VP2","VP3","VP6")
coordinate_list <- list(
  c(112752682,112752956),
  c(112839171,112839390),
  c(112906594,112906900))
VP_coordinate_df <- data.frame(matrix(ncol=2,nrow=length(VP_list)))
colnames(VP_coordinate_df) <- c("VP","vp_coordinate")
for ( i in 1:length(VP_list)) {
  VP <- VP_list[i]
  coordinate <- coordinate_list[i]
  VP_coordinate_df[i,1:2] <- list(VP, coordinate)
}

# read sampleSheet
sampleSheet <- read.csv(file.path(wd,paste0(sampleSheet_file,".csv")))

## Attach VP coordinate information
## Cannot attach this VP information when creating sampleSheet files
sampleSheet <- sampleSheet %>%
  left_join(VP_coordinate_df,by="VP")

## Create the output file names
sampleSheet <- sampleSheet %>%
  mutate(output = paste(Day,VP,treatment,readLength,sep="_"))

# Attach some information to the point of interest
PointsOfInterest <- readPointsOfInterestFile(file.path(wd, pointsofinterests))
PointsOfInterest <- PointsOfInterest %>%
  mutate(colour = ifelse(name %in% c("VP2","VP3","VP6"), "black", 
                         ifelse(name %in% c("VP1_Ez","VP2_Ez","VP3_Ez","VP4_Ez","VP5_Ez"),"gray",
                                ifelse(name %in% c("IL1A","IL1B","IL37","IL36G","IL36A","IL36B","IL36RN","IL1F10","IL1RN"),"red","green"))))

# Functions
get4CData <- function(i) {
  # Read alignment
  print(sprintf("Read Bam from: %s",sampleSheet$bamfile[i]))
  GAlobj <- readGAlignments(file.path(wd,bam,sampleSheet$bamfile[i]))
  print("Done")
  
  ## Create Data4C obj
  data4CObjs <- Data4Cseq(viewpointChromosome="chr2",
                          viewpointInterval=unlist(sampleSheet$vp_coordinate[i]),
                          readLength=sampleSheet$readLength[i],
                          pointsOfInterest=PointsOfInterest,
                          rawReads=GAlobj)
  
  ## The reads are then mapped to the predefined fragment library
  print(sprintf("Assign Bam reads %s to virtual fragment %s",sampleSheet$bamfile[i], sampleSheet$library[i]))
  fragment_library<-file.path(wd,fragmentLibrary,sampleSheet$library[i])
  rawFragments(data4CObjs) <- readsToFragments(data4CObjs,fragment_library)
  print("Done")
  
  ## get data frame for raw reads
  print(sprintf("Get raw reads and write to csv %s",sampleSheet$output[i]))
  df <- data.frame(rawFragments(data4CObjs))
  fname <- file.path(wd,output_data,paste0(sampleSheet$output[i],"_rawReads",".csv"))
  write.csv(df,fname)
  print("Done")
  
  ## Get near cis fragments
  print(sprintf("Get near cis fragments and normalize %s",sampleSheet$bamfile[i]))
  nearCisFragments(data4CObjs) <- chooseNearCisFragments(data4CObjs, regionCoordinates = regionOfInterest)
  nearCisFragments(data4CObjs) <- normalizeFragmentData(data4CObjs)
  getReadDistribution(data4CObjs, useFragEnds = TRUE, outputName = "")
  print("Done")
  
  ## Make df for plot
  print(sprintf("Save 4C plot: %s",paste0(sampleSheet$output[i],".pdf")))
  pfname <- file.path(wd,output_data,paste0(sampleSheet$output[i],".pdf"))
  visualizeViewpoint(data4CObjs, plotFileName = pfname, mainColour = "blue", 
                     plotTitle = paste(sampleSheet$Day[i],sampleSheet$treatment[i],
                                       sampleSheet$VP[i],sep = " "), loessSpan = 0.1, maxY = 1000, 
                     xAxisIntervalLength = 50000, yAxisIntervalLength = 500)
  while (!is.null(dev.list()))  dev.off()
  print("Done")
}

# The real 4c analysis process ====
## I hate loop but we have to use it !!

for (i in 1:nrow(sampleSheet)) {
  get4CData(i)
}

## test block start ====
# GAlobj <- readGAlignments(file.path(wd,bam,sampleSheet$bamfile[1]))
# data4CObjs <- Data4Cseq(viewpointChromosome="chr2",
#                         viewpointInterval=unlist(sampleSheet$vp_coordinate[1]),
#                         readLength=sampleSheet$readLength[1],
#                         pointsOfInterest=PointsOfInterest,
#                         rawReads=GAlobj)
# fragment_library<-file.path(wd,fragmentLibrary,sampleSheet$library[1])
# rawFragments(data4CObjs) <- readsToFragments(data4CObjs,fragment_library)
# nearCisFragments(data4CObjs) <- chooseNearCisFragments(data4CObjs, regionCoordinates = regionOfInterest)
# nearCisFragments(data4CObjs) <- normalizeFragmentData(data4CObjs)
# getReadDistribution(data4CObjs, useFragEnds = TRUE, outputName = "")
# 
# # get the normalized reads dataframe
# nearCisFragments.df <- data.frame(nearCisFragments(data4CObjs))
# head(nearCisFragments(data4CObjs))
# 
# pfname <- file.path(wd,output_data,paste0(sampleSheet$output[1],".pdf"))
# visualizeViewpoint(data4CObjs, plotFileName = pfname, mainColour = "blue", 
#                    plotTitle = paste(sampleSheet$Day[i],sampleSheet$treatment[i],
#                                      sampleSheet$VP[i],sep = " "), loessSpan = 0.1, maxY = 1000, 
#                    xAxisIntervalLength = 50000, yAxisIntervalLength = 500)
# dev.off()
## test block end ====
