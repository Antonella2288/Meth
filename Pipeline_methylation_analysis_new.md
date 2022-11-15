# Pipeline methylation analysis 

## Create a file .m5
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
## Take column 5 from the .tsv file, sort, delete duplicates, add a new column containing the group name, exchange space with tab and then write all into a .tsv file
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
## Annotate
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
## Merge .m5 files 
```
meth5 merge_m5 \
--input_m5_files methylation_calls_sample1_chr.m5 methylation_calls_sample2_chr.m5 \
--read_group_names 2 1  \
--read_groups_key sample1,sample2 \
--output_file merge_chr.m5
```
## Meth-Seg
```
pycoMeth Meth_Seg \
--h5_file_list merge_chr.m5 \ 
--chromosome chr \
--output_tsv_fn seg_chr.tsv \
--read_groups_key sample1,sample2 \
--chunk_size 500 
```
## CGI Finder 
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

## Meth_Comp

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
## Comp_Report

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