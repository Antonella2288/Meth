# Pipeline methylation analysis 

## Create a file .m5 from nanopore methylation calls
```
meth5 create_m5 \
--input_paths methylation_calls_sample1_chr.tsv \
--output_file methylation_calls_sample1_chr.m5
```
```
meth5 create_m5 \
--input_paths methylation_calls_sample2_chr.tsv \
--output_file methylation_calls_sample2_chr.m5
```
## Add read group to methylation calls

### Take column 5 (sample ID) from the .tsv file, sort, delete duplicates, add a new column containing the group name, exchange space with tab and then write all into a .tsv file
```
cat methylation_calls_sample1_chr.tsv | \
cut -f5 | \
tail -n +2 | \
sort | \
uniq | \
awk '$(NF+1) = 2'| \
sed 's/ /\t/g' >sample1.chr_readGroup.tsv
```
```
cat methylation_calls_sample2_chr.tsv | \
cut -f5 | \
tail -n +2 | \
sort | \
uniq | \
awk '$(NF+1) = 1'| \
sed 's/ /\t/g' >sample2.chr_readGroup.tsv
```
the output is:
read_name       group
0000174a-d806-4e5f-933c-1e69fb483ce6    2
00001bb2-6fd1-4c90-a7a3-446696674eb1    2



## Annotate .m5 file with read group
```
meth5 annotate_reads \
--m5file methylation_calls_sample1_chr.m5 \
--read_groups_key sample1 \
--read_group_file /sample1.chr_readGroup.tsv \
```
```
meth5 annotate_reads \
--m5file methylation_calls_sample2_chr.m5 \
--read_groups_key sample2 \
--read_group_file sample2.chr_readGroup.tsv
```
## Merge .m5 files from different samples
```
meth5 merge_m5 \
--input_m5_files methylation_calls_sample1_chr.m5 methylation_calls_sample2_chr.m5 \
--read_group_names 2 1  \
--read_groups_key sample1,sample2 \
--output_file merge_chr.m5
```

## Check number of chunks per chormosome using meth5 list_chunks
```
meth5 list_chunks \
--input_m5_files merge_chr.m5
```
 the output is 
-------- merge_chr.m5 ---------
| Chromosome | Number of chunks |
| chr        | 9                |
---------------------------------


## Run Meth-Seg

### Parallelize per chromosome and per chunks within chromosomes 
```
pycoMeth Meth_Seg \
--h5_file_list merge_chr.m5 \ 
--chromosome chr \
--output_tsv_fn seg_chr.tsv \
--read_groups_key sample1,sample2 \
--chunks 0 1 2 3 4 5 6 7 8 9
```
## Run CGI Finder 
```
pycoMeth CGI_Finder \
--ref_fasta_fn GRCh38.fna \
--output_tsv_fn hg38.CpG.tsv \ 
--output_bed_fn hg38.CpG.bed
```
```
head -n 1 hg38.CpG.bed > chr.CpG.bed

grep -w chr19 hg38.CpG.bed >> chr.CpG.bed
```
### For the analysis you can use either Meth_Seg or CGI_Finder. In the next functions you can use either the output of Meth_Seg or the output of CGI_Finder

## Run Meth_Comp

### with Meth_Seg's output
```
pycoMeth Meth_Comp \
--h5_file_list methylation_calls_sample1_chr.m5 methylation_calls_sample2_chr.m5 \
--ref_fasta_fn GRCh38.fna \
--interval_bed_fn seg_chr.tsv \
--output_tsv_fn chr_comp_seg.tsv \
--output_bed_fn chr_comp_seg.bed \
--sample_id_list sample1 sample2
```
### with CGI_Finder's output
```
pycoMeth Meth_Comp \
--h5_file_list methylation_calls_sample1_chr.m5 methylation_calls_sample2_chr.m5 \
--ref_fasta_fn GRCh38.fna \
--interval_bed_fn chr.CpG.bed \
--output_tsv_fn chr_comp.tsv \
-output_bed_fn chr_comp.bed 
--sample_id_list sample1 sample2
```
## Run Comp_Report

### with Meth_Seg's output
```
pycoMeth Comp_Report \
--h5_file_list methylation_calls_sample1_chr.m5 methylation_calls_sample2_chr.m5 \
--ref_fasta_fn GRCh38.fna \
--methcomp_fn chr_comp_seg.tsv \
--gff3_fn Homo_sapiens.GRCh38.103_modded_V2.gff3 \
--pvalue_threshold 0.05 \
--sample_id_list sample1 sample2 \
--outdir chr_seg_report
```
### with CGI_Finder's output
```
pycoMeth Comp_Report \
--h5_file_list methylation_calls_sample1_chr.m5 methylation_calls_sample2_chr.m5 \
--ref_fasta_fn GRCh38.fna \
--methcomp_fn chr_comp.tsv \
--gff3_fn Homo_sapiens.GRCh38.103_modded_V2.gff3 \
--pvalue_threshold 0.05 \
--sample_id_list sample1 sample2 \
--outdir chr_report
```