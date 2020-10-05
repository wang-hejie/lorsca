#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""
将整个工作流包装成软件self-correction
使用-h查看使用说明
"""

import argparse
import subprocess
import os


parser = argparse.ArgumentParser(description='Automate self-correcting workflow scripts. '
                                             'workflow: correct->assemble->count')
parser.add_argument('-s', '--species', type=str, help='ecoli, scere')
parser.add_argument('-f', '--folds', type=str, help='10, 30, 50, 75, 100')
parser.add_argument('-t', '--tools', type=str, default='raw', help='mecat2, falcon, lorma, canu, pbcr, flas, consent, daccord, sprai')
parser.add_argument('-c', '--company', type=str, default='pacbio', help='pacbio, ont')
parser.add_argument('-a', '--assembler', type=str, default='miniasm', help='miniasm')
args = parser.parse_args()

species = args.species      # 纠错物种
folds = args.folds          # 纠错raw data深度
tools = args.tools          # 纠错工具。若为raw，则不纠错直接组装
company = args.company      # raw data数据类型
assembler = args.assembler  # 装配工具

print(f'species = {species}\n'
      f'folds = {folds}\n'
      f'tools = {tools}\n'
      f'company = {company}\n'
      f'assembler = {assembler}')
script_path = os.path.abspath(__file__)  # 软件根目录/self-correction.py
software_path = os.path.abspath(os.path.dirname(script_path) + os.path.sep + ".")  # 软件根目录

subprocess.call(f'bash {software_path}/scripts/correct.sh {species} {folds} {tools} {company}', shell=True)
subprocess.call(f'bash {software_path}/scripts/assemble.sh {species} {folds} {tools} {company} {assembler}', shell=True)
subprocess.call(f'bash {software_path}/scripts/count.sh {species} {folds} {tools}', shell=True)
subprocess.call(f'bash {software_path}/scripts/tabulate.sh {species} {folds} {tools}', shell=True)
