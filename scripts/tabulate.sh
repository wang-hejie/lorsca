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
correct_dir="$experience_dir/correct"         # 执行纠错的目录
assemble_dir="$experience_dir/assemble"       # 执行组装的目录
dnadiff_dir="$experience_dir/dnadiff_result"  # 执行dnadiff的目录
blasr_dir="$experience_dir/blasr_result"      # 执行blasr的目录
quast_dir="$experience_dir/quast_result"      # 执行quast的目录

correct_stat_file="$correct_dir/corrected_longreads.log"
dnadiff_stat_file="$dnadiff_dir/dnadiff_output.txt"
blasr_stat_file="$blasr_dir/blasr_count.txt"
quast_stat_file="$quast_dir/quast_output.txt"

table_seq="$experience_dir/table_seq.txt"
table_contig="$experience_dir/table_contig.txt"


#########################################
# Tabulate the statistical results of seq
#########################################
# about corrected_longreads.log
sequence="$(grep output_reads_num $correct_stat_file | awk '{printf $2}')"
mean_bp="$(grep output_mean_bp $correct_stat_file | awk '{printf ("%.2f", $2)}')"
depa="$(grep output_depth $correct_stat_file | awk '{printf ("%.2f", $2)}')"

# about correct time and mem
correct_time=0  # 纠错时间初始化为0
correct_mem=0   # 纠错内存初始化为0

cd $correct_dir
for i in $(find memoryrecord* -type d)
    do
        correct_time=$(echo "$correct_time + $(grep time "$correct_dir"/"$i"/t.log | awk '{printf $2}')" | bc | awk '{printf ("%.2f", $1)}')
        if [ $(echo "$correct_mem < $(grep maxMem "$correct_dir"/"$i"/t.log | awk '{printf $2}')" | bc) == "1" ]
            then
                correct_mem=$(grep maxMem "$correct_dir"/"$i"/t.log | awk '{printf ("%.2f", $2)}')
        fi
    done

# about blasr_count.txt
ins=$(echo "$(grep ins_rate $blasr_stat_file | awk '{printf $2}') * 100" | bc | awk '{printf ("%.2f", $1)}')
del=$(echo "$(grep del_rate $blasr_stat_file | awk '{printf $2}') * 100" | bc | awk '{printf ("%.2f", $1)}')
sub=$(echo "$(grep mismatch_rate $blasr_stat_file | awk '{printf $2}') * 100" | bc | awk '{printf ("%.2f", $1)}')


# about dnadiff_output.txt
aarl=$(grep AvgLength $dnadiff_stat_file | head -1 | awk '{printf $3}')
iden=$(grep AvgIdentity $dnadiff_stat_file | head -1 | awk '{printf $3}')
cov=$(grep AlignedBases $dnadiff_stat_file | head -1 | awk '{printf $2}' | cut -d '(' -f2|cut -d '%' -f1)

# 对seq相关统计结果制表
echo -e "Sequence \t Mean(x) \t DepA(x) \t Time(min) \t Mem(Gb) \t Ins(%) \t Del(%) \t Sub(%) \t AARL(bp) \t Iden(%) \t Cov(%)" > $table_seq
echo -e "$sequence    $mean_bp    $depa    $correct_time    $correct_mem    $ins    $del    $sub    $aarl    $iden    $cov" >> $table_seq



############################################
# Tabulate the statistical results of contig
############################################
# about assemble time and mem
assemble_time=0  # 组装时间初始化为0
assemble_mem=0   # 组装内存初始化为0

cd $assemble_dir
for i in $(find memoryrecord* -type d)
    do
        assemble_time=$(echo "$assemble_time + $(grep time "$assemble_dir"/"$i"/t.log | awk '{printf $2}')" | bc | awk '{printf ("%.2f", $1)}')
        if [ $(echo "$assemble_mem < $(grep maxMem "$assemble_dir"/"$i"/t.log | awk '{printf $2}')" | bc) == "1" ]
            then
                assemble_mem=$(grep maxMem "$assemble_dir"/"$i"/t.log | awk '{printf ("%.2f", $2)}')
        fi
    done

# about quast_output.txt
n50=$(grep N50 $quast_stat_file | awk '{printf $2}')
ctg_num=$(grep "# contigs" $quast_stat_file | tail -1 | awk '{printf $3}')

# 对contig相关统计结果制表
echo -e "Time(min) \t Mem(Gb) \t N50(bp) \t Ctg_num" > $table_contig
echo -e "$assemble_time    $assemble_mem    $n50    $ctg_num" >> $table_contig

