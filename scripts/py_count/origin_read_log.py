'''
Description: 生成原始数据的统计log文件
Author: Wang Hejie
Date: 2021-03-13 20:01:32
LastEditTime: 2021-03-13 20:07:29
LastEditors: Wang Hejie
'''

from modules import origin_reads_analyse as or_analyse
import sys


reads_file = sys.argv[1]
if reads_file.split('.')[1] != 'fasta':
    print('请输入fasta格式文件!')
    sys.exit()
ref_file = sys.argv[2]

or_analyse.reads_stat(reads_file, ref_file)