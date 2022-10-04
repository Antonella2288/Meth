# Pipeline methilation analysis

## Create a file .m5
```
meth5 create_m5 --input_paths /lustre/home/enza/embryo_meth/Progetto_Embrioni/analysis/run1/AV067_analysis/fastq_pass_meth/nanopolish/chr19/methylation_calls_AV067_chr19.tsv --output_file /lustre/home/enza/mlan/m5/methylation_calls_AV067_chr19.m5
```
```
meth5 create_m5 --input_paths /lustre/home/enza/embryo_meth/Progetto_Embrioni/analysis/run1/AS090_analysis/fastq_pass_meth/nanopolish/chr19/methylation_calls_AS090_chr19.tsv --output_file /lustre/home/enza/mlan/m5/methylation_calls_AS090.chr19.m5
```

## Take column 5 from the .tsv file, sort, delete duplicates, add a new column containing the group name, exchange space with tab and then write all into a .tsv file
```
cat methylation_calls_AV067_chr19.tsv | cut -f5 | tail -n +2 | sort | uniq | awk '$(NF+1) = 2'| sed 's/ /\t/g' > AV067.chr19_readGroup.tsv
```
```
cat methylation_calls_AS090_chr19.tsv | cut -f5 | tail -n +2 | sort | uniq | awk '$(NF+1) = 1'| sed 's/ /\t/g' > AS090.chr19_readGroup.tsv
```
## Annotate
```
~/.conda/envs/meth/bin/meth5 annotate_reads --m5file /lustre/home/enza/mlan/m5/methylation_calls_AV067_chr19.m5 --read_groups_key AV067 --read_group_file /lustre/home/enza/mlan/m5/AV067.chr19_readGroup.tsv 
```
```
~/.conda/envs/meth/bin/meth5 annotate_reads --m5file /lustre/home/enza/mlan/m5/methylation_calls_AS090.chr19.m5 --read_groups_key AS090 --read_group_file /lustre/home/enza/mlan/m5/AS090.chr19_readGroup.tsv 

```
## Merge .m5 files 
```
meth5 merge_m5 \
--input_m5_files /lustre/home/enza/mlan/m5/methylation_calls_AV067_chr19.m5 /lustre/home/enza/mlan/m5/methylation_calls_AS090.chr19.m5 \
--read_group_names 2 1  \
--read_groups_key AV067,AS090 \
--output_file /lustre/home/enza/mlan/m5/merge_chr19.m5
```
## Meth-Seg
```
pycoMeth Meth_Seg -i /lustre/home/enza/mlan/m5/merge_chr19.m5 -c chr19 -t /lustre/home/enza/mlan/m5/seg_chr19.tsv
```
## CGI Finder 
```
pycoMeth CGI_Finder -f GCA_000001405.15_GRCh38_no_alt_analysis_set.fna -t /lustre/home/enza/mlan/m5/CpG_island.tsv 
```
## Meth-Comp
```
pycoMeth Meth_Comp -i /lustre/home/enza/mlan/m5/methylation_calls_AV067_chr19.m5 /lustre/home/enza/mlan/m5/methylation_calls_AS090.chr19.m5 -f /lustre/home/enza/pangenome/new/ref/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna -a /lustre/home/enza/mlan/hg38.CpG.bed -t /lustre/home/enza/mlan/chr19_comp.tsv -b /lustre/home/enza/mlan/chr19_comp.bed --sample_id_list AV067 AS090
```
## Comp_Report
```
pycoMeth Comp_Report -i /lustre/home/enza/mlan/m5/methylation_calls_AV067_chr19.m5 /lustre/home/enza/mlan/m5/methylation_calls_AS090.chr19.m5 -f /lustre/home/enza/pangenome/new/ref/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna -c /lustre/home/enza/mlan/chr19_comp.tsv -g /lustre/home/enza/mlan/Homo_sapiens.GRCh38.103_modded_V2.gff3 --pvalue_threshold 0.05 --sample_id_list AV067 AS090 -o /lustre/home/enza/mlan/chr19_report
```





