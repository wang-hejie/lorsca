"""
@File   :   chform.py
@Time   :   2020/10/23 21:56
@Author :   Wang Hejie
@Version:   1.0
@Contact:   984468110@qq.com
@Desc   :   将sequence行换行的fasta文件，转换成sequence行只有1行的格式
"""
# import lib
import sys
import reformat


ifile, ofile = sys.argv[1:3]

reformat.standard_fasta(ifile, ofile)

