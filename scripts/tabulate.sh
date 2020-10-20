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
raw_dir="$home/experience/"$species"_"$folds"/raw"  # raw data统计目录

if [ $tools == "raw" ]
    then
        reads_dir="$experience_dir/raw_data"  # raw reads目录
else
    reads_dir="$experience_dir/correct"       # 执行纠错的目录
fi

assemble_dir="$experience_dir/assemble"       # 执行组装的目录
dnadiff_dir="$experience_dir/dnadiff_result"  # 执行dnadiff的目录
blasr_dir="$experience_dir/blasr_result"      # 执行blasr的目录
quast_dir="$experience_dir/quast_result"      # 执行quast的目录
raw_blasr_dir="$raw_dir/blasr_result"         # raw data的blasr目录

if [ $tools == "raw" ]
    then
        reads_stat_file="$reads_dir/raw_longreads_"$folds"x.log"
else
    reads_stat_file="$reads_dir/corrected_longreads.log"
fi

dnadiff_stat_file="$dnadiff_dir/dnadiff_output.txt"
blasr_stat_file="$blasr_dir/blasr_count.txt"
quast_stat_file="$quast_dir/quast_output.txt"
raw_blasr_stat_file="$raw_blasr_dir/blasr_count.txt"
raw_reads_stat_file="$raw_dir/raw_data/*.log"

table_seq="$experience_dir/table_seq.csv"
table_contig="$experience_dir/table_contig.csv"

#scripts path
scripts_path="$(cd `dirname $0`; pwd)"

#########################################
# Tabulate the statistical results of seq
#########################################
# about corrected_longreads.log
sequence="$(grep output_reads_num $reads_stat_file | awk '{printf $2}')"
mean_bp="$(grep output_mean_bp $reads_stat_file | awk '{printf ("%.0f", $2)}')"
depa="$(grep output_depth $reads_stat_file | awk '{printf ("%.2f", $2)}')"

if [ $tools != "raw" ]
    then
        # about correct time and mem
        correct_real_time=0     # 纠错真实时间初始化为0
        correct_cpu_time=0      # 纠错cpu时间初始化为0
        correct_mem=0           # 纠错内存初始化为0

        cd $reads_dir
        for i in $(find memoryrecord* -type d)
            do
                if [ $(echo "$correct_mem < $(grep maxMem "$reads_dir"/"$i"/t.log | awk '{printf $2}')" | bc) == "1" ]
                    then
                        correct_mem=$(grep maxMem "$reads_dir"/"$i"/t.log | awk '{printf ("%.2f", $2)}')
                fi
            done
        
        for i in $(find timelog* -type f)
            do
                correct_real_time=$(echo "scale=2; $correct_real_time + $(tail -3 $i | grep real | awk '{printf $2}' | awk 'BEGIN{FS="m"}{print $1}') + $(tail -3 $i | grep real | awk '{printf $2}' | awk 'BEGIN{FS="."}{print $1}' | awk 'BEGIN{FS="m"}{print $2}') / 60" | bc | awk '{printf ("%.2f", $1)}')
                correct_cpu_time=$(echo "scale=2; $correct_cpu_time + $(tail -3 $i | grep user | awk '{printf $2}' | awk 'BEGIN{FS="m"}{print $1}') + $(tail -3 $i | grep user | awk '{printf $2}' | awk 'BEGIN{FS="."}{print $1}' | awk 'BEGIN{FS="m"}{print $2}') / 60" | bc | awk '{printf ("%.2f", $1)}')
            done
fi

# about blasr_count.txt
ins_rate=$(echo "$(grep ins_rate $blasr_stat_file | awk '{printf $2}') * 100" | bc | awk '{printf ("%.2f", $1)}')
del_rate=$(echo "$(grep del_rate $blasr_stat_file | awk '{printf $2}') * 100" | bc | awk '{printf ("%.2f", $1)}')
sub_rate=$(echo "$(grep mismatch_rate $blasr_stat_file | awk '{printf $2}') * 100" | bc | awk '{printf ("%.2f", $1)}')


# about dnadiff_output.txt
# aarl=$(grep AvgLength $dnadiff_stat_file | head -1 | awk '{printf ("%.0f", $3)}')
# # iden=$(grep AvgIdentity $dnadiff_stat_file | head -1 | awk '{printf $3}')
# seq_cov=$(grep AlignedBases $dnadiff_stat_file | head -1 | awk '{printf $2}' | cut -d '(' -f2 | cut -d '%' -f1)
# aligned_rate=$(grep AlignedBases $dnadiff_stat_file | head -1 | awk '{printf $3}' | cut -d '(' -f2 | cut -d '%' -f1)


# sensitivity, seq_accuracy
mismatch_num=$(grep mismatch_num $blasr_stat_file | awk '{printf $2}')
ins_num=$(grep ins_num $blasr_stat_file | awk '{printf $2}')
del_num=$(grep del_num $blasr_stat_file | awk '{printf $2}')
corrected_error=$(($mismatch_num+$ins_num+$del_num))  # corrected data错误数
aligned_reads_length=$(grep aligned_base_num $blasr_stat_file | awk '{printf $2}')  # corrected data比对长度
if [ $tools == "raw" ]
    then
        echo -e "\e[1;35m raw data has no sensitivity. \e[0m"
else
    # 若没对raw进行过统计，先统计raw
    if [ ! -d $raw_dir ]
        then
            python3 "$scripts_path/../lorsca.py" -s $species -f $folds
    fi
    raw_mismatch_num=$(grep mismatch_num $raw_blasr_stat_file | awk '{printf $2}')
    raw_ins_num=$(grep ins_num $raw_blasr_stat_file | awk '{printf $2}')
    raw_del_num=$(grep del_num $raw_blasr_stat_file | awk '{printf $2}')
    raw_error=$(($raw_mismatch_num+$raw_ins_num+$raw_del_num))  # raw data错误数
    raw_aligned_reads_length=$(grep aligned_base_num $raw_blasr_stat_file | awk '{printf $2}')  # raw data比对长度
    sensitivity=$(echo "scale=2;($raw_error-$corrected_error)/$raw_error*$aligned_reads_length/$raw_aligned_reads_length" | bc | awk '{printf ("%.2f", $1)}')  # 敏感度
fi
seq_accuracy=$(echo "scale=5;(1-$corrected_error/$aligned_reads_length)*100" | bc | awk '{printf ("%.2f", $1)}')  # 纠错后seq本身的准确率，而不是纠错的准确率

# output_total_bp=$(echo "$sequence * $mean_bp" | bc | awk '{printf ("%.0f", $1)}')  # 纠错后输出的总碱基数


# 对seq相关统计结果制表
echo -e "RunTime(min),CpuTime(min),Mem(Gb),Sequence,Mean(x),DepA(x),Sensitivity,Accuracy(%),Ins(%),Del(%),Sub(%),Alignment rate(%),AARL(bp),Cov(%)" > $table_seq
echo -e "$correct_real_time,$correct_cpu_time,$correct_mem,$sequence,$mean_bp,$depa,$sensitivity,$seq_accuracy,$ins_rate,$del_rate,$sub_rate,$aligned_rate,$aarl,$seq_cov" >> $table_seq



############################################
# Tabulate the statistical results of contig
############################################
# about assemble time and mem
assemble_real_time=0  # 组装真实时间初始化为0
assemble_cpu_time=0   # 组装cpu时间初始化为0
assemble_mem=0        # 组装内存初始化为0

cd $assemble_dir
for i in $(find memoryrecord* -type d)
    do
        if [ $(echo "$assemble_mem < $(grep maxMem "$assemble_dir"/"$i"/t.log | awk '{printf $2}')" | bc) == "1" ]
            then
                assemble_mem=$(grep maxMem "$assemble_dir"/"$i"/t.log | awk '{printf ("%.2f", $2)}')
        fi
    done

for i in $(find timelog* -type f)
    do
        assemble_real_time=$(echo "scale=2; $assemble_real_time + $(tail -3 $i | grep real | awk '{printf $2}' | awk 'BEGIN{FS="m"}{print $1}') + $(tail -3 $i | grep real | awk '{printf $2}' | awk 'BEGIN{FS="."}{print $1}' | awk 'BEGIN{FS="m"}{print $2}') / 60" | bc | awk '{printf ("%.2f", $1)}')
        assemble_cpu_time=$(echo "scale=2; $assemble_cpu_time + $(tail -3 $i | grep user | awk '{printf $2}' | awk 'BEGIN{FS="m"}{print $1}') + $(tail -3 $i | grep user | awk '{printf $2}' | awk 'BEGIN{FS="."}{print $1}' | awk 'BEGIN{FS="m"}{print $2}') / 60" | bc | awk '{printf ("%.2f", $1)}')
    done


# about quast_output.txt
n50=$(grep N50 $quast_stat_file | awk '{printf $2}')  # N50
ctg_num=$(grep "# contigs" $quast_stat_file | tail -1 | awk '{printf $3}')  # ctg条数
ctg_cov=$(grep "Genome fraction" $quast_stat_file | awk '{printf ("%.2f", $4)}')  # 参考基因组被ctg覆盖的比例

mismatch_per100=$(grep "mismatches" $quast_stat_file | awk '{printf $6}')  # ctg上每100kb出现的mismatches数量
indel_per100=$(grep "indels" $quast_stat_file | awk '{printf $6}')  # ctg上每100kb出现的indels数量
ctg_accuracy=$(echo "scale=6;(1 - ($mismatch_per100 + $indel_per100) / 100000) * 100" | bc | awk '{printf ("%.2f", $1)}')  # ctg自身的正确率

total_length=$(grep "Total length" $quast_stat_file | tail -1 | awk '{printf $3}')  # 所有组装好ctg的总长度
nga50=$(grep "NGA50" $quast_stat_file | awk '{printf $2}')  # NGA50
dup_ratio=$(grep "Duplication ratio" $quast_stat_file | awk '{printf $3}')  # ctg中比对上的碱基总数，除以参考基因组碱基总数。取值大于1才有意义，超过1越多越差，代表组装时对于重复区域进行了多次组装
misassemblies=$(grep "# misassemblies" $quast_stat_file | head -1 | awk '{printf $3}')  # ctg在比对回参考基因组的过程中产生断点，且该断点是组装时的组装错误导致的


# 对contig相关统计结果制表
echo -e "Ctg_num,Cov(%),Accuracy(%),Total length(bp),N50(bp),NGA50(bp),Misassemblies,Duplication ratio,RunTime(min),CpuTime(min),Mem(Gb)" > $table_contig
echo -e "$ctg_num,$ctg_cov,$ctg_accuracy,$total_length,$n50,$nga50,$misassemblies,$dup_ratio,$assemble_real_time,$assemble_cpu_time,$assemble_mem" >> $table_contig

