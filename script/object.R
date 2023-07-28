# This is objects for handling data in 4C experiments

# built-in list

## set class 
setClass("summaryObj", slots=c(input_dir = "character",
                               fname = "character",
                               input_fname = "character",
                               output_dir = "character",
                               chr_list = "character",
                               RawReads = "data.frame",
                               subset = "data.frame",
                               summary = "data.frame"))

setGeneric("loadRawReads", function(obj) {
  standardGeneric("loadRawReads")
})

setMethod("loadRawReads", signature = "summaryObj",
          function(obj) {
            print(sprintf("Read data from: %s",obj@input_fname))
            obj@RawReads <- read.delim(file.path(obj@input_dir,obj@input_fname)
                                          ,sep=",")
            obj@RawReads <- obj@RawReads[,2:ncol(obj@RawReads)]
            obj
          })

setGeneric("getSubset", function(obj) {
  standardGeneric("getSubset")
})

setMethod("getSubset", signature = "summaryObj",
          function(obj) {
            print(sprintf("get reads mapped to convincing chr from: %s",obj@input_fname))
            matching_expression <- paste(chr_list,collapse="|")
            subset <- obj@RawReads %>%
              dplyr::filter(grepl(matching_expression, chromosomeName)) %>%
              dplyr::filter(!grepl("random", chromosomeName))
            obj@subset <- subset
            obj
          })

setGeneric("getSummary", function(obj) {
  standardGeneric("getSummary")
})

setMethod("getSummary", signature = "summaryObj",
          function(obj) {
            total_counts <- obj@subset %>%
              summarize(sum = sum(fragEndReadsAverage))
            print(sprintf("get summary for: %s",obj@input_fname))
            summary <- obj@subset %>%
              group_by(chromosomeName) %>%
              summarize(sum = sum(fragEndReadsAverage)) %>%
              mutate(freq = round(100 * (sum / total_counts$sum),digits=2))
            summary$chr.factor <- factor(summary$chromosomeName,levels=obj@chr_list)
            obj@summary <- summary
            obj
          })

setGeneric("getGraph", function(obj) {
  standardGeneric("getGraph")
})

setMethod("getGraph", signature = "summaryObj", 
          function(obj) {
            library(ggplot2)
            obj@subset$chr.factor <- factor(obj@subset$chromosomeName,levels=obj@chr_list)
            plot.df <- obj@subset %>%
              filter(log10(fragEndReadsAverage) > 0) %>%
              left_join(obj@summary,by="chr.factor")
            chr2_perc = obj@summary %>%
              filter(chromosomeName == "chr2")
            
            print(sprintf("generate QC plots and save files in: %s",paste0(obj@fname,".pdf")))
            p <- ggplot(plot.df, aes(x=fragmentCentre/10000000, y=log10(fragEndReadsAverage))) + 
              geom_point(size=0.01) + 
              theme(panel.background = element_rect(fill = "white", colour = "grey50")) +
              ggtitle(paste0(obj@fname," Reads in chr2 = ",chr2_perc$freq,"%"))
            p <- p + facet_wrap(~ chr.factor, ncol=5)
            pfname=file.path(obj@output_dir,paste0(obj@fname,".pdf"))
            ggsave(pfname,plot=p)
            while (!is.null(dev.list()))  dev.off()
            print("Done")
          })
