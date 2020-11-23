#!/bin/bash
###
 # @Description: extract statistics alignment rate, aarl and coverage from minimap2 alignment results
 # @Author: Wang Hejie
 # @Date: 2020-11-16 09:07:38
 # @LastEditTime: 2020-11-18 10:56:47
 # @LastEditors: Wang Hejie
### 
species="$(echo $1 | tr '[:upper:]' '[:lower:]')"
folds="$(echo $2 | tr '[:upper:]' '[:lower:]')"
tools="$(echo $3 | tr '[:upper:]' '[:lower:]')"


#########################################
# set paths
#########################################
home="/home/wanghejie"
experience_dir="$home/experience/"$species"_"$folds"/$tools"  # 执行统计的目录
minimap2_dir="$experience_dir/minimap2_result"  # 执行minimap2的目录

cd $minimap2_dir

alnrate_aarl_filename="stats.txt"
alnrate_aarl_file="$minimap2_dir/$alnrate_aarl_filename"
cov_filename="coverage.txt"
cov_file="$minimap2_dir/$cov_filename"



#########################################
# set threads num
#########################################
threads_num=$(nproc)
echo "threads_num = $threads_num"


#########################################
# enter conda env
#########################################
source activate
source deactivate
conda activate samtools

# count alignment rate, aarl and coverage by samtools
samtools view -bS "$minimap2_dir"/aln.sam > "$minimap2_dir"/aln.bam
samtools sort -@ $threads_num -o "$minimap2_dir"/aln.sorted.bam "$minimap2_dir"/aln.bam
samtools coverage "$minimap2_dir"/aln.sorted.bam > $cov_file
samtools stats "$minimap2_dir"/aln.sorted.bam > $alnrate_aarl_file

# extract alignment rate
total_length=$(grep 'total length' $alnrate_aarl_file | awk '{printf $4}')  # 纠错后输出总长
mapped_length=$(grep 'bases mapped (cigar)' $alnrate_aarl_file | head -1 | awk '{printf $5}')  # 比对上的base长度
aln_rate=$(echo "scale=6;($mapped_length / $total_length) * 100" | bc | awk '{printf ("%.2f", $1)}')  # aln_rate = 比对上的长度 / 纠错后总长

# extract aarl
mapped_reads_num=$(grep 'reads mapped' $alnrate_aarl_file | head -1 | awk '{printf $4}')  # 比对上的reads数
aarl=$(echo "scale=1;$mapped_length / $mapped_reads_num" | bc | awk '{printf ("%.0f", $1)}')  # aarl = 比对上的长度 / 比对上的reads数

# extract coverage
ref_total_len=$(grep -v "#" $cov_file | awk '{sum += $3}END{print sum}')
ref_cov_len=$(grep -v "#" $cov_file | awk '{sum += $5}END{print sum}')
seq_cov=$(echo "scale=6;($ref_cov_len / $ref_total_len) * 100" | bc | awk '{printf ("%.2f", $1)}')


#########################################
# write into csv file
#########################################
echo -e "Alignment rate(%),AARL(bp),Cov(%)" > $experience_dir/minimap2.csv
echo -e "$aln_rate,$aarl,$seq_cov" >> $experience_dir/minimap2.csv
