#!/bin/bash
SECONDS=0

#working directory
cd /home/vishal/Desktop/Parth/Monsoon_RNAseq/

# Step 1 ; FASTQC
#fastqc -t 8 raw/*.fastq.gz -o raw_qc

# Step 2 : Trimming
# run fastp to trim adapters and reads with poor quality (paired-end)

#mkdir -p trimmed/reports

#for S in HS1 HS2 HS3 IM1 IM2 IM3 MII1 MII2 MII3 reseq_IM1
#do
 # echo "Running fastp on ${S} ..."
  #fastp \
   # -i raw/${S}_R1.fastq.gz -I raw/${S}_R2.fastq.gz \
   # -o trimmed/${S}_R1_trimmed.fastq.gz -O trimmed/${S}_R2_trimmed.fastq.gz \
    #--detect_adapter_for_pe \
    #--trim_front1 5 --trim_front2 15 \
   # --trim_poly_g --poly_g_min_len 10 \
    #--cut_tail --cut_tail_mean_quality 10 \
   # --cut_right --cut_right_window_size 4 --cut_right_mean_quality 15 \
    #--length_required 50 \
   # --thread 8 \
    #-h reports/${S}_fastp.html -j reports/${S}_fastp.json
#done
#echo "fastp finished running!"

#fastqc -t 8 trimmed/*.fastq.gz -o trimmed_qc

# Step 3 : Alignment

for S in HS1 HS2 HS3 IM1 IM2 IM3 MII1 MII2 MII3 reseq_IM1
do
  echo "Aligning ${S} ..."
  STAR --runThreadN 8 \
    --genomeDir referance/Buffalo/star_index \
    --readFilesIn trimmed/${S}_R1_trimmed.fastq.gz trimmed/${S}_R2_trimmed.fastq.gz \
    --readFilesCommand zcat \
    --outFileNamePrefix aligned/${S}_ \
    --outSAMtype BAM SortedByCoordinate \
    --outSAMattributes NH HI AS NM MD \
    --quantMode GeneCounts
  samtools index aligned/${S}_Aligned.sortedByCoord.out.bam
done
echo "STAR finished running!"

# Step 4 : Feature Counts

featureCounts -T 8 \
  -p --countReadPairs \
  -s 2 \
  -t exon -g gene_id \
  -a referance/Buffalo/genomic.gtf \
  -o counts/featurecounts_raw.txt \
  aligned/*_Aligned.sortedByCoord.out.bam

  grep -v "^#" referance/Buffalo/genomic.gtf | head -3

# Complete basic analysis till counts