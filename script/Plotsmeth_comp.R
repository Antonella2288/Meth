# Plots with output of meth_comp
# use the output of meth_comp 
x<-read.table("/home/antonella/mergecomp.seg.tsv", header=T, sep="\t")
comp<-read.table(file = "/home/antonella/mergecomp.sigpvalue.splitsample.tsv", header = T)

# Plot pvalue distribution 
  x<-comp %>% ggplot(aes(x=pvalue)) + 
  geom_density(color="darkblue") + 
  theme_bw() 

#Plot distribution of cpg with significant and non significant pvalue 

  x$unique_cpg_pos <- as.numeric(as.character(x$unique_cpg_pos))
  df<-x %>% select(comment, unique_cpg_pos) %>%  group_by(comment) 

  plot<-df %>% ggplot(aes(x=unique_cpg_pos, color = comment)) + 
  geom_density() + scale_color_brewer(palette="Dark2") + theme_bw() + labs(x="number of CpG")

#Plot distribution of avg_coverage 
# split the column avg_coverage in 2 columns colled AS090 and AV067, and create two columns, one with all avg_coverage values and one with samples.
x$avg_coverage<-gsub("\\[|\\]", "", x$avg_coverage)
df <- x %>% separate(avg_coverage, c("AV067", "AS090"), ",")
y<-df %>% gather(sample,avg_coverage, AV067:AS090)
coverage <- y %>% select(sample, avg_coverage, comment) 
coverage$avg_coverage <- as.numeric(as.character(x$avg_coverage))

coverage %>% filter(avg_coverage < 1000) %>% ggplot(aes(x=avg_coverage, color = comment )) + 
  geom_density() + theme_bw() +facet_grid(sample ~ .)

#Plot number of intervals

chr<-x %>% group_by(chromosome, comment) %>% tally() %>% print(n=22)
chr$chromosome<-factor(chr$chromosome, levels=c("chr1", "chr2", "chr3", "chr4", "chr5", "chr6", "chr7", "chr8", "chr9", "chr10", "chr11", "chr12", "chr13", "chr14", "chr15", "chr16", "chr17", "chr18", "chr19", "chr20", "chr21", "chr22"))
colnames(chr) <- c("chromosome", "comment", "number")

chr %>% ggplot(aes(x=chromosome, y=number, fill=comment)) + geom_bar(stat="identity") + scale_fill_manual(values=c("#0033FF", "#00CCFF", "#000033"))+ theme_bw() + labs(y="number of intervals") + theme(legend.title = element_blank())

#Use KaryoploteR to plot regions with significant pvalue as ideograms

library(karyoploteR)
library(rtracklayer)
#  intersect gff file and regions with significant pvalue found by meth_comp
bedtools intersect -a /lustre/home/enza/mlan/Homo_sapiens.GRCh38.108.chr.gff3 -b /lustre/home/enza/mlan/meth_comp.merg.sig1.bed > /lustre/home/enza/mlan/intersect_comp_gff.tsv

# read 23 header lines specifying chromosomes length.
header.lines <- readLines("/lustre/home/enza/mlan/intersect_comp_gff_header.tsv", n = 23)
ll <- header.lines[grepl(header.lines, pattern = "##sequence-region")]
# split them by space, and create a data.frame
gg <- data.frame(do.call(rbind, strsplit(ll, split = " ")))
gg[,4] <- as.numeric(as.character(gg[,4]))
gg[,5] <- as.numeric(as.character(gg[,5]))
gg[,6] <- as.numeric(as.character(gg[,6]))
#create a GRanges with the information
genome <- toGRanges(gg[,c(4,5,6)])
# plot the genome
kp <- plotKaryotype(genome=genome)
# use the function import.gff to read the ggf file as a GRanges object
features<- import.gff("/lustre/home/enza/mlan/intersect_comp_gff_header.tsv")
# rename all features type as DMR  
table(features$type)
features$type <- "DMR"
DMR <- features[features$type=="DMR"]
# plot DMR in the genome
kp<-plotKaryotype(genome=genome, chromosomes=(paste0(c(1:22))), ideogram.plotter = NULL)
kpAddCytobandsAsLine(kp)
kpPlotRegions(kp, data=DMR)