#!/bin/bash

#########################################
#  $1: species - ecoli, scere
#  $2: folds - 10x, 30x, 50x, 75x, 100x
#  $3: tools - mecat2, falcon, lorma, canu, pbcr
#  $4: company - pacbio, ont
#  $5: assembler - miniasm
#  (all varaibles are converted to the lower cases)
#########################################
species="$(echo $1 | tr '[:upper:]' '[:lower:]')"
folds="$(echo $2 | tr '[:upper:]' '[:lower:]')"
tools="$(echo $3 | tr '[:upper:]' '[:lower:]')"
company="$(echo $4 | tr '[:upper:]' '[:lower:]')"
assembler="$(echo $5 | tr '[:upper:]' '[:lower:]')"


#########################################
# set paths
#########################################
home="/home/wanghejie"
experience_dir="$home/experience/"$species"_"$folds"/$tools/assemble"
standard_assemble_file_name="contig.fasta"
corrected_reads_file="$home/experience/"$species"_"$folds"/$tools/correct/corrected_longreads.fasta"  # 纠错后reads文件

#scripts path
scripts_path="$(cd `dirname $0`; pwd)"


#########################################
# create experience directory
#########################################
if [ -d $experience_dir ]
    then
        echo -e "\e[1;35m #### Warning: $experience_dir Exist! #### \e[0m"  # Warning
        rm -rf $experience_dir
        echo -e "\e[1;35m #### Warning end: Already remove it. #### \e[0m"
fi
mkdir -p $experience_dir
cd $experience_dir


#########################################
# Set assembler path
#########################################
if [ $assembler == "miniasm" ]
    then
        source activate
        source deactivate
        conda activate miniasm
fi


#########################################
# Running the tools 
#########################################
#### 1. miniasm ####
if [ $assembler == "miniasm" ]
    then
        # minimap2
        echo -e "\e[1;32m #### "$tools" assemble step 1/3: minimap2 #### \e[0m"
        if [ $company == "pacbio" ]
            then
                echo "#### Start: minimap2 -x ava-pb -t8 $corrected_reads_file $corrected_reads_file | gzip -1 > reads.paf.gz ####"
                perl $scripts_path/memory3.pl memoryrecord_1 "minimap2 -x ava-pb -t8 $corrected_reads_file $corrected_reads_file | gzip -1 > reads.paf.gz"
                echo -e "#### End: minimap2 -x ava-pb -t8 $corrected_reads_file $corrected_reads_file | gzip -1 > reads.paf.gz ####\n"
        else
            echo "#### Start: minimap2 -x ava-ont -t8 $corrected_reads_file $corrected_reads_file | gzip -1 > reads.paf.gz ####"
            perl $scripts_path/memory3.pl memoryrecord_1 "minimap2 -x ava-ont -t8 $corrected_reads_file $corrected_reads_file | gzip -1 > reads.paf.gz"
            echo -e "#### End: minimap2 -x ava-ont -t8 $corrected_reads_file $corrected_reads_file | gzip -1 > reads.paf.gz ####\n"
        fi

        # miniasm
        echo -e "\e[1;32m #### "$tools" assemble step 2/3: miniasm #### \e[0m"
        echo "#### Start: miniasm -f $corrected_reads_file reads.paf.gz > reads.gfa ####"
        perl $scripts_path/memory3.pl memoryrecord_2 "miniasm -f $corrected_reads_file reads.paf.gz > reads.gfa"
        echo -e "#### End: miniasm -f $corrected_reads_file reads.paf.gz > reads.gfa ####\n"

        # 从重叠图文件中提取contig
        echo -e "\e[1;32m #### "$tools" assemble step 3/3: extract contig #### \e[0m"
        echo '#### Start: awk ####'
        awk '/^S/{print ">"$2"\n"$3}' reads.gfa | fold > $standard_assemble_file_name
        echo -e '#### End: awk ####\n'


else
    echo -e "\e[1;31m #### Error: $assembler NOT EXIST! #### \e[0m"  # Error
fi
