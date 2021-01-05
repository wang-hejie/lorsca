'''
Description: 统计corrected_longreads.fasta中每个reads的长度
Author: Wang Hejie
Date: 2021-01-05 09:33:15
LastEditTime: 2021-01-05 09:54:36
LastEditors: Wang Hejie
'''

import sys


input_file = sys.argv[1]
if input_file.split('.')[1] != 'fasta':
    print('请输入fasta格式文件!')
    sys.exit()
output_file = input_file.split('.')[0] + '_lengthStat.txt'


with open(input_file, 'r') as f_in:
    with open(output_file, 'w') as f_out:
        for line in f_in:
            if '>' in line:
                continue
            read_len = len(line.replace('\r', '').replace('\n', ''))
            f_out.write(f'{read_len}\n')