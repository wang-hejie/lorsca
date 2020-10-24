#!/bin/bash

change_file=$1  # 每次只能修改1个文件
newhead_change_file=$(echo $change_file | awk 'BEGIN{FS="."}{print $1 "_newhead." $2}')  # raw_longreads_30x_newhead.fastq
reform_newhead_change_file=$(echo $newhead_change_file | awk 'BEGIN{FS="."}{print $1 "_reform." $2}')
scripts_path="$(cd `dirname $0`; pwd)"


source activate
source deactivate
conda activate pbcore



file_type=$(echo $change_file | awk 'BEGIN{FS="."}{print $2}')  # fasta or fastq
if [ $file_type == "fasta" ]
    then
        bash $scripts_path/modules/chhead.sh $change_file  # 将'>SRR1204085.5 /1'变为'>SRR1204085.5/1'
        python $scripts_path/modules/head_add_range_fa.py $change_file $newhead_change_file  # 将'>SRR1204085.5/1'变为'>SRR1204085.5/1/0_1226'
        python $scripts_path/modules/chform.py $newhead_change_file $reform_newhead_change_file  # 将sequence行换行的fasta文件，转换成sequence行只有1行的格式
        rm $change_file
        rm $newhead_change_file
        mv $reform_newhead_change_file $change_file  # 删除中间文件
elif [ $file_type == "fastq" ]
    then
        bash $scripts_path/modules/chhead.sh $change_file  # 将'>SRR1204085.5 /1'变为'>SRR1204085.5/1'
        python $scripts_path/modules/head_add_range_fq.py $change_file $newhead_change_file
        rm $change_file
        mv $newhead_change_file $change_file
else
    echo "The file type is not fasta or fastq!"
    exit 1
fi

