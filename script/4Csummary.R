# This script is used for generating statics summary for 4C experiments

library(tidyverse)
library(ggplot2)

# path 
wd <- getwd()
sampleSheet_file <- file.path(wd,paste0("sampleSheet",".csv"))
input_dir <- file.path(wd,"output_data")
output_dir <- file.path(wd,"output_data")

# read sample sheet
sampleSheet <- read.csv(sampleSheet_file)
sampleSheet <- sampleSheet[,2:ncol(sampleSheet)]
sampleSheet <- sampleSheet %>%
  mutate(fname = paste(Day, VP, treatment, readLength,sep="_"))

# import objects and functions ====
source(file.path(wd,"scripts","object.R"))

# list
chr_list <- c("chr1","chr2","chr3","chr4","chr5","chr6",
              "chr7","chr8","chr9","chr10","chr11","chr12",
              "chr13","chr14","chr15","chr16","chr17","chr18",
              "chr19","chr20","chr21","chr22","chrX","chrY","chrM")

# Initiate the object
summaryObj <- new("summaryObj",
                  input_dir = input_dir,
                  fname="",
                  input_fname = "",
                  output_dir = output_dir,
                  chr_list = chr_list,
                  RawReads = data.frame(),
                  subset = data.frame(),
                  summary = data.frame())
# loop it!
for (i in 1:nrow(sampleSheet)) {
  summaryObj@fname <- sampleSheet$fname[i]
  summaryObj@input_fname <- paste0(sampleSheet$fname[i],"_rawReads.csv")
  summaryObj <- loadRawReads(summaryObj)
  summaryObj <- getSubset(summaryObj)
  summaryObj <- getSummary(summaryObj)
  getGraph(summaryObj)  
}