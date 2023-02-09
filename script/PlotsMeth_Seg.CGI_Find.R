# Plots to compare the output of Meth_Seg CGI_Finder

# use the output of meth_seg and CGI_Finder of the Chr19
seg<-read.table(file = "/home/antonella/meth_comp/chr19.comp.segchunks.tsv", sep = "\t", header = T)
cgi<-read.table(file = "/home/antonella/meth_comp/chr19_comp.tsv", sep = "\t", header = T)

seg2<- seg %>% mutate(chr = "chr19_methSeg") %>% select(chromosome, chr, start, end, comment) %>% mutate(class = "meth_seg")
cgi2<- cgi %>% mutate(chr = "chr19_CGI") %>% select(chromosome, chr, start, end, comment) %>% mutate(class = "CGI_finder")

all2 <- rbind(seg2,cgi2)

# Plot chomosome 19 intervals 

all2 %>% mutate(start_kb = start/1000, end_kb = end/1000) %>% arrange(start_kb)  %>% ggplot(aes(y = chromosome)) + geom_linerange(aes(xmin = start_kb, xmax = end_kb, y = chromosome, color = comment, size = 3)) + facet_wrap(~ chr, nrow = 2) + theme_bw() + guides(size = F) + theme(legend.position = "top", legend.title = element_blank()) + ylab("") + xlab("kb")
ggsave("compare_cgi_seg_wholeChr19new.png", width = 10, heigh = 5)

# Plot chomosome 19 intervals in specific region(60-200 kb)

all2 %>% mutate(start_kb = start/1000, end_kb = end/1000) %>% arrange(start_kb) %>% filter(start_kb < 24200 & end_kb < 24200) %>% ggplot(aes(y = chromosome)) + geom_linerange(aes(xmin = start_kb, xmax = end_kb, y = chromosome, color = comment, size = 3)) + facet_wrap(~ chr, nrow = 2) + theme_bw() + guides(size = F) + theme(legend.position = "top", legend.title = element_blank()) + xlim(60,200) + ylab("") + xlab("kb")
ggsave("compare_cgi_seg_60-200.19new.png", width = 10, heigh = 5)

# Plot distribution of intervals lenght 

seglenght<-seg2 %>% mutate(lenght = end - start)
cgilenght<-cgi2 %>% mutate(lenght = end - start)
all3 <- rbind(seglenght,cgilenght)

all3 %>% filter(lenght < 20000) %>% ggplot(aes(x=lenght, color=class)) + 
  geom_density()

all3 %>% filter(lenght < 6000) %>% ggplot(aes(x=lenght, color=class)) + 
  geom_density()

# Plot distribution of intervals lenght with significant pvalue

seglenght.sig<-seg2 %>% filter(comment == "Significant-pvalue") %>% mutate(lenght = end - start)
cgilenght.sig<-cgi2 %>% filter(comment == "Significant-pvalue") %>% mutate(lenght = end - start)
all.lenght.sig <- rbind(seglenght.sig,cgilenght.sig)
all.lenght.sig %>% ggplot(aes(x=lenght, color=class)) + 
  geom_density() + theme_bw() + theme(legend.position = "top", legend.title = element_blank())
ggsave("densitylenght.significant-pvalue.chr19new.png")

