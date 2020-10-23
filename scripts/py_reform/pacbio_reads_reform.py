#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""
@File   :   pacbio_reads_reform.py
@Time   :   2020/10/23 21:56
@Author :   Wang Hejie
@Version:   1.0
@Contact:   984468110@qq.com
@Desc   :   将D.melanogaster和A.thaliana的fasta和fastq的head修改为标准pacbio格式
"""
# import lib
import subprocess
import os
import sys

change_file_list = sys.argv[1:]
script_path = os.path.abspath(__file__)  # 软件根目录/scripts/py_reform/pacbio_reads_reform.py
script_dir_path = os.path.abspath(os.path.dirname(script_path) + os.path.sep + ".")  # 软件根目录/scripts/py_reform

for change_file in change_file_list:
    subprocess.call(f'bash {script_dir_path}/modules/chhead.sh {change_file}', shell=True)  # 将">SRR1204085.29 /1"变为">SRR1204085.29/1"

    