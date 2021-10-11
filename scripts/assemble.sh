#!/bin/bash

#########################################
#  $1: corrected_reads_file - the corrected reads file path
#  $2: experience_dir - the experience root path
#########################################
corrected_reads_file=$1
experience_dir=$2


#########################################
# set paths
#########################################
assemble_dir=$experience_dir"/assemble"
standard_assemble_file_name="contig.fasta"
echo $assemble_dir


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
if [ -d $assemble_dir ]
    then
        echo -e "\e[1;35m #### Warning: $assemble_dir Exist! #### \e[0m"  # Warning
        rm -rf $assemble_dir
        echo -e "\e[1;35m #### Warning end: Already remove it. #### \e[0m"
fi
mkdir -p $assemble_dir
cd $assemble_dir


#########################################
# Set assembler path
#########################################
source activate
source deactivate
conda activate miniasm


#########################################
# Running the tools 
#########################################
#### 1. miniasm ####
# set file to be assembled
echo -e "\e[1;32m #### assemble step 1/3: minimap2 #### \e[0m"
assemble_file=$corrected_reads_file

# minimap2
echo "#### Start: minimap2 -x ava-pb -t$threads_num $assemble_file $assemble_file | gzip -1 > reads.paf.gz ####"
minimap2 -x ava-pb -t$threads_num $assemble_file $assemble_file | gzip -1 > reads.paf.gz
echo -e "#### End: minimap2 -x ava-pb -t$threads_num $assemble_file $assemble_file | gzip -1 > reads.paf.gz ####\n"

# miniasm
echo -e "\e[1;32m #### assemble step 2/3: miniasm #### \e[0m"
echo "#### Start: miniasm -f $assemble_file reads.paf.gz > reads.gfa ####"
miniasm -f $assemble_file reads.paf.gz > reads.gfa
echo -e "#### End: miniasm -f $assemble_file reads.paf.gz > reads.gfa ####\n"

# 从重叠图文件中提取contig
echo -e "\e[1;32m #### assemble step 3/3: extract contig #### \e[0m"
echo '#### Start: awk ####'
awk '/^S/{print ">"$2"\n"$3}' reads.gfa | fold > $standard_assemble_file_name
echo -e '#### End: awk ####\n'

