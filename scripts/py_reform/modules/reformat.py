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


def ctg_lay_to_fasta(input_file, output_file):
    """
    将wtdbg2软件中第一个步骤assemble生成的.ctg.lay文件，转换成标准fasta格式

    :param input_file: 输入.ctg.lay文件
    :param output_file: 输出fasta文件
    :return: 无
    """
    with open(input_file, 'r') as f_in:
        with open(output_file, 'a') as f_out:
            f_in.readline()
            for line in f_in:
                temp_list = line.rstrip().split('\t')  # 将.ctg.lay文件的一行按成分切分
                if (temp_list[0] != 'S') or (len(temp_list) < 6):
                    continue
                f_out.write('>' + temp_list[1] + '/' + '_'.join(temp_list[3:5]) + '\n')
                f_out.write(temp_list[5] + '\n')


def daccord_output_to_fasta(input_file, output_file):
    """
    将daccord生成的输出文件，转换成标准fasta格式

    :param input_file: daccord生成的输出文件
    :param output_file: 标准fasta格式
    :return: 无
    """
    begin = False
    with open(input_file, 'r') as f_in:
        with open(output_file, 'a') as f_out:
            for line in f_in:
                if line[0] != '>':
                    if begin is False:
                        continue
                    elif (line[0] == '[') and (line[2] == ']'):
                        continue
                    else:
                        f_out.write(line)
                else:
                    begin = True
                    f_out.write(line)
