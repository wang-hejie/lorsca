"""
workflow: correct->assemble->count
在count步骤中使用
1. 对correct后的reads文件进行统计，计算DepA
2. 对blasr的输出进行统计，计算Ins, Del, Sub
"""

from modules import origin_reads_analyse as or_analyse
from modules import blasr_statistics
import sys
import os


species = sys.argv[1]
folds = sys.argv[2]
tools = sys.argv[3]
ref_file_fna = sys.argv[4]

home = os.getenv('HOME')
dataset_dir = f'{home}/datasets'
experience_dir = f'{home}/experience/{species}_{folds}/{tools}'
corrected_reads_file = f'{experience_dir}/correct/corrected_longreads.fasta'  # 纠错后reads的fa文件
raw_file_fa = f'{experience_dir}/raw_data/raw_longreads_{folds}x.fasta'

if tools == 'raw':
    count_file = raw_file_fa
else:
    count_file = corrected_reads_file
# contig_file = f'{experience_dir}/assemble/contig.fasta'  # 使用纠错后fa文件组装好的contig

# raw_reads_file_fa = f'{dataset_dir}/Reads/{species}/raw_longreads_{folds}.fasta'  # 原始long reads的fa文件

blasr_output_file = f'{experience_dir}/blasr_result/blasr_output.txt'  # blasr的输出文件
blasr_count_file = f'{experience_dir}/blasr_result/blasr_count.txt'  # 对blasr输出文件计算之后得到的统计文件


# self-correct workflow
# origin_reads_count = or_analyse.reads_stat(raw_reads_file_fa, ref_file_fna)  # 输出统计信息
# print(origin_reads_count)

corrected_reads_count = or_analyse.reads_stat(count_file, ref_file_fna)  # 计算DepA
print(corrected_reads_count)

blasr_statistics.count_indel_mismatch_aarl(blasr_output_file, blasr_count_file)  # 计算Ins, Del, Sub
