'''
Description: 将整个工作流包装成软件self-correction
             使用-h查看使用说明
Author: Wang Hejie
Date: 2021-10-09 21:13:23
LastEditTime: 2021-10-09 22:13:28
LastEditors: Wang Hejie
'''
#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import argparse
import subprocess
import os
import datetime


# 执行-h 或 -help 的说明
parser = argparse.ArgumentParser(description='Automate self-correcting workflow scripts. '
                                             'workflow: assemble->count->tabulate')
parser.add_argument('-c', '--correct', type=str, help='set the corrected reads file path, must .fasta file')
parser.add_argument('-o', '--original', type=str, help='set the original reads file path, must .fasta file')
parser.add_argument('-f', '--fna', type=str, help='set the reference genome .fna file path')
parser.add_argument('-g', '--gff', type=str, help='set the reference genome .gff file path')
args = parser.parse_args()

corrected_reads_file = args.correct    # 纠错后reads
original_reads_file = args.original    # 原始reads
fna_file = args.fna  # 参考基因组fna文件
gff_file = args.gff  # 参考基因组gff文件

print(f'corrected_reads_file = {corrected_reads_file}\n'
      f'original_reads_file = {original_reads_file}\n'
      f'fna_file = {fna_file}\n'
      f'gff_file = {gff_file}\n')
if not os.path.isfile(corrected_reads_file) or corrected_reads_file.split('.')[-1] != 'fasta':
    print(f'{corrected_reads_file} is not .fasta file!')
    exit(0)
if not os.path.isfile(original_reads_file) or original_reads_file.split('.')[-1] != 'fasta':
    print(original_reads_file.split('.')[-1])
    print(f'{original_reads_file} is not .fasta file!')
    exit(0)
if not os.path.isfile(fna_file):
    print(f'{fna_file} is not file!')
    exit(0)
if not os.path.isfile(gff_file):
    print(f'{gff_file} is not file!')
    exit(0)

# 新建实验用文件夹
home = os.getenv('HOME')
datetime = '_'.join(str(datetime.datetime.now()).split())
print(datetime)
experience_dir = f'{home}/lorsca_experience/{datetime}'
os.makedirs(experience_dir)

script_path = os.path.abspath(__file__)  # 软件根目录/lorsca.py
software_path = os.path.abspath(os.path.dirname(script_path) + os.path.sep + ".")  # 软件根目录

subprocess.call(f'bash {software_path}/scripts/assemble.sh {corrected_reads_file} {experience_dir}', shell=True)

subprocess.call(f'bash {software_path}/scripts/count.sh {original_reads_file} {fna_file} {gff_file} {experience_dir}/raw', shell=True)
subprocess.call(f'bash {software_path}/scripts/count.sh {corrected_reads_file} {fna_file} {gff_file} {experience_dir}', shell=True)

subprocess.call(f'bash {software_path}/scripts/tabulate.sh {corrected_reads_file} {experience_dir}', shell=True)
