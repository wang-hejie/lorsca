#!/bin/bash

#########################################
#  $1: species - ecoli, scere, dmela, athal, human
#  $2: folds - 10, 30, 50, 75, 100
#  $3: tools - raw, mecat2, falcon, lorma, canu, pbcr, flas, consent, daccord, sprai, pbdagcon
#  (all varaibles are converted to the lower cases)
#########################################
species="$(echo $1 | tr '[:upper:]' '[:lower:]')"
folds="$(echo $2 | tr '[:upper:]' '[:lower:]')"
tools="$(echo $3 | tr '[:upper:]' '[:lower:]')"


#########################################
# set paths
#########################################
home="/home/wanghejie"
experience_dir="$home/experience/"$species"_"$folds"/$tools"  # 执行统计的目录
dnadiff_dir="$experience_dir/dnadiff_result"  # 执行dnadiff的目录
blasr_dir="$experience_dir/blasr_result"  # 执行blasr的目录
quast_dir="$experience_dir/quast_result"  # 执行quast的目录
minimap2_dir="$experience_dir/minimap2_result"  # 执行minimap2的目录
raw_dir="$home/experience/"$species"_"$folds"/raw"  # raw data统计目录
raw_file_fa="$raw_dir/raw_data/raw_longreads_"$folds"x.fasta"  # 原始long reads的fasta
corrected_reads_file="$experience_dir/correct/corrected_longreads.fasta"  # 纠错后reads文件
contig_file="$experience_dir/assemble/contig.fasta"  # 组装产生的contig文件

# 参考基因组
ref_file_fna=$(ls $home/datasets/Reference/$species/*.fna)
ref_file_gff=$(ls $home/datasets/Reference/$species/*.gff)

# 统计minimap2结果的文件
alnrate_aarl_filename="stats.txt"
alnrate_aarl_file="$minimap2_dir/$alnrate_aarl_filename"
cov_filename="coverage.txt"
cov_file="$minimap2_dir/$cov_filename"

cd $experience_dir

#scripts path
scripts_path="$(cd `dirname $0`; pwd)"


#########################################
# set threads num
#########################################
# cpu=$(cat /proc/cpuinfo |grep "physical id"|sort|uniq|wc -l)
# cpu_cores=$(cat /proc/cpuinfo |grep "cpu cores"|uniq|wc -l)
# core_processor=$(cat /proc/cpuinfo |grep "processor"|wc -l)
# threads_num=$(($cpu*$cpu_cores*$core_processor))
threads_num=$(nproc)
echo "threads_num = $threads_num"


#########################################
# create experience directory
#########################################
# dir=($dnadiff_dir $blasr_dir $quast_dir)
dir=($minimap2_dir $blasr_dir $quast_dir)
for i in ${dir[@]}
    do
        if [ -d $i ]
            then
                echo -e "\e[1;35m #### Warning: $i Exist! #### \e[0m"  # Warning
                rm -rf $i
                echo -e "\e[1;35m #### Warning end: Already remove it. #### \e[0m"
        fi
        mkdir -p $i
    done



#########################################
# calculate performance of the tools 
#########################################
# set file to be counted
if [ $tools == "raw" ]
    then
        count_file=$raw_file_fa
else
    count_file=$corrected_reads_file
fi

#### dnadiff ####
# aarl, iden, cov
# cd $dnadiff_dir

# echo -e "\e[1;32m #### "$tools" count step 1/3: dnadiff #### \e[0m"
# echo "#### Start: dnadiff $ref_file_fna $count_file ####"
# dnadiff $ref_file_fna $count_file
# echo -e "#### End: dnadiff $ref_file_fna $count_file ####\n"
# echo "#### Start: mv out.report dnadiff_output.txt ####"
# mv out.report dnadiff_output.txt
# echo -e "#### End: mv out.report dnadiff_output.txt ####\n"


#### minimap2 + samtools ####
# aln rate, aarl, cov
source activate
source deactivate
conda activate miniasm
cd $minimap2_dir

echo -e "\e[1;32m #### "$tools" count step 1/3: minimap2 + samtools #### \e[0m"
echo "#### Start: minimap2 -ax map-pb -t$threads_num $ref_file_fna $count_file > aln.sam ####"
minimap2 -ax map-pb -t$threads_num $ref_file_fna $count_file > aln.sam
echo -e "#### End: minimap2 -ax map-pb -t$threads_num $ref_file_fna $count_file > aln.sam ####\n"

# count alignment rate, aarl and coverage by samtools
source activate
source deactivate
conda activate samtools

samtools view -bS "$minimap2_dir"/aln.sam > "$minimap2_dir"/aln.bam
samtools sort -@ $threads_num -o "$minimap2_dir"/aln.sorted.bam "$minimap2_dir"/aln.bam
samtools coverage "$minimap2_dir"/aln.sorted.bam > $cov_file
samtools stats "$minimap2_dir"/aln.sorted.bam > $alnrate_aarl_file


#### blasr ####
# ins, del, sub, sensitivity, seq accuracy
source activate
source deactivate
conda activate blasr
cd $blasr_dir

echo -e "\e[1;32m #### "$tools" count step 2/3: blasr #### \e[0m"
echo "#### Start: blasr $count_file $ref_file_fna --nproc $threads_num -m 5 ####"
blasr $count_file $ref_file_fna --nproc $threads_num -m 5 > blasr_output.txt 2>&1
echo -e "#### End: blasr $count_file $ref_file_fna --nproc $threads_num -m 5 ####\n"
echo "#### Start: python3 $scripts_path/py_count/py_count.py $species $folds $tools $ref_file_fna ####"
python3 $scripts_path/py_count/py_count.py $species $folds $tools $ref_file_fna
echo -e "#### End: python3 $scripts_path/py_count/py_count.py $species $folds $tools $ref_file_fna ####\n"



#### quast ####
# Ctg_num, Cov(%), Accuracy(%), Total length(bp), N50(bp), NGA50(bp), Misassemblies, Duplication ratio
cd $quast_dir

echo -e "\e[1;32m #### "$tools" count step 3/3: quast #### \e[0m"
echo "#### Start: quast.py -o . -r $ref_file_fna -g $ref_file_gff -m 500 -t $threads_num $contig_file ####"
quast.py -o . -r $ref_file_fna -g $ref_file_gff -m 500 -t $threads_num $contig_file
echo -e "#### End: quast.py -o . -r $ref_file_fna -g $ref_file_gff -m 500 -t $threads_num $contig_file ####\n"
echo "#### Start: mv report.txt quast_output.txt ####"
mv report.txt quast_output.txt
echo -e "#### End: mv report.txt quast_output.txt ####\n"
