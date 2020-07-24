"""
将整个工作流包装成软件self-correction
使用-h查看使用说明
"""

import argparse
import subprocess


parser = argparse.ArgumentParser(description='Automate self-correcting workflow scripts. '
                                             'workflow: correct->assemble->count')
parser.add_argument('-s', '--species', type=str, help='ecoli, scere')
parser.add_argument('-f', '--folds', type=str, help='10x, 30x, 50x, 75x, 100x')
parser.add_argument('-t', '--tools', type=str, help='mecat2, falcon, lorma, canu, pbcr')
parser.add_argument('-c', '--company', type=str, default='pacbio', help='pacbio, ont')
parser.add_argument('-a', '--assembler', type=str, default='miniasm', help='miniasm')
args = parser.parse_args()

species = args.species      # 纠错物种
folds = args.folds          # 纠错raw data深度
tools = args.tools          # 纠错工具
company = args.company      # raw data数据类型
assembler = args.assembler  # 装配工具

print(f'species = {species}\n'
      f'folds = {folds}\n'
      f'tools = {tools}\n'
      f'company = {company}\n'
      f'assembler = {assembler}')
scripts_path = r'./scripts'

subprocess.call(f'bash {scripts_path}/correct.sh {species} {folds} {tools} {company}', shell=True)
subprocess.call(f'bash {scripts_path}/assemble.sh {species} {folds} {tools} {company} {assembler}', shell=True)
subprocess.call(f'bash {scripts_path}/count.sh {species} {folds} {tools}', shell=True)
