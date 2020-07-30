#!/bin/bash

#########################################
#  $1: species - ecoli, scere
#  $2: folds - 10, 30, 50, 75, 100
#  $3: tools - raw, mecat2, falcon, lorma, canu, pbcr, flas, consent, daccord
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
raw_file_fa="$experience_dir/raw_data/raw_longreads_"$folds"x.fasta"  # 原始long reads的fasta
corrected_reads_file="$experience_dir/correct/corrected_longreads.fasta"  # 纠错后reads文件
contig_file="$experience_dir/assemble/contig.fasta"  # 组装产生的contig文件

if [ $species == "ecoli" ]
    then
        ref_file_fna="/HDD1/wanghejie/datasets/Reference/$species/GCF_000005845.2_ASM584v2_genomic.fna"
        ref_file_gff="/HDD1/wanghejie/datasets/Reference/$species/GCF_000005845.2_ASM584v2_genomic.gff"
else
    ref_file_fna="/HDD1/wanghejie/datasets/Reference/$species/GCF_000146045.2_R64_genomic.fna"
    ref_file_gff="/HDD1/wanghejie/datasets/Reference/$species/GCF_000146045.2_R64_genomic.gff"
fi

cd $experience_dir

#scripts path
scripts_path="$(cd `dirname $0`; pwd)"


#########################################
# create experience directory
#########################################
dir=($dnadiff_dir $blasr_dir $quast_dir)
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
# collecing performance of the tools 
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
cd $dnadiff_dir

echo -e "\e[1;32m #### "$tools" count step 1/3: dnadiff #### \e[0m"
echo "#### Start: dnadiff $ref_file_fna $count_file ####"
dnadiff $ref_file_fna $count_file
echo -e "#### End: dnadiff $ref_file_fna $count_file ####\n"
echo "#### Start: mv out.report dnadiff_output.txt ####"
mv out.report dnadiff_output.txt
echo -e "#### End: mv out.report dnadiff_output.txt ####\n"

#### blasr ####
# ins, del, sub
source activate
source deactivate
conda activate blasr
cd $blasr_dir

echo -e "\e[1;32m #### "$tools" count step 2/3: blasr #### \e[0m"
echo "#### Start: blasr $count_file $ref_file_fna --nproc 16 -m 5 ####"
blasr $count_file $ref_file_fna --nproc 16 -m 5 > blasr_output.txt 2>&1
echo -e "#### End: blasr $count_file $ref_file_fna --nproc 16 -m 5 ####\n"
echo "#### Start: python3 $scripts_path/py_count/py_count.py $species $folds $tools ####"
python3 $scripts_path/py_count/py_count.py $species $folds $tools
echo -e "#### End: python3 $scripts_path/py_count/py_count.py $species $folds $tools ####\n"


#### quast ####
# contig N50, contig number
cd $quast_dir

echo -e "\e[1;32m #### "$tools" count step 3/3: quast #### \e[0m"
echo "#### Start: quast.py -o . -r $ref_file_fna -g $ref_file_gff -m 500 -t 16 $contig_file ####"
quast.py -o . -r $ref_file_fna -g $ref_file_gff -m 500 -t 16 $contig_file
echo -e "#### End: quast.py -o . -r $ref_file_fna -g $ref_file_gff -m 500 -t 16 $contig_file ####\n"
echo "#### Start: mv report.txt quast_output.txt ####"
mv report.txt quast_output.txt
echo -e "#### End: mv report.txt quast_output.txt ####\n"