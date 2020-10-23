#!/usr/bin/python3
# -*- encoding: utf-8 -*-

"""
@File   :   daccord_reform.py
@Time   :   2020/7/29 16:08
@Author :   Wang Hejie
@Version:   1.0
@Contact:   984468110@qq.com
@Desc   :   将daccord的输出转换为标准fasta格式
"""
# import lib
from modules import reformat
import sys


input_file = sys.argv[1]
output_file = sys.argv[2]

reformat.daccord_output_to_fasta(input_file, output_file)
