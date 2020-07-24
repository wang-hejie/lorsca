def standard_fasta(input_file, output_file):
    """
    将每条序列的每行后都有换行符(每条序列都有n行)的非标准fasta文件，转换成每条序列只有1行的标准fasta文件

    :param input_file: 非标准fasta文件
    :param output_file: 标准fasta文件
    :return: 无
    """
    temp_list = []

    with open(input_file, 'r') as f_in:
        with open(output_file, 'a') as f_out:
            while True:
                line = f_in.readline()
                if line == '':
                    f_out.write(''.join(temp_list))
                    break  # 文件已读完
                if '>' in line:  # 读到序列头
                    if temp_list:  # 已经有序列被记录
                        f_out.write(''.join(temp_list))
                        f_out.write('\n')
                        temp_list = []
                    f_out.write(line)
                    continue

                temp_list.append(line.rstrip().replace(" ", ""))


def fasta_to_fastq(input_file, output_file):
    """
    将fasta文件转换成fastq文件，测序质量全部补成'I'。注意：原fasta文件尾一定要空一行

    :param input_file: 输入fasta文件
    :param output_file: 输出fastq文件
    :return: 无
    """
    line_num = 0
    with open(input_file, 'r') as f_in:
        with open(output_file, 'a') as f_out:
            while True:
                line = f_in.readline()
                if line == '':
                    break
                else:
                    f_out.write(line)
                    line_num += 1
                    if line_num == 2:
                        f_out.write('+\n')
                        f_out.write('I'*len(line) + '\n')
                        line_num = 0
