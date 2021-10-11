import random
import os
import csv


def reads_stat(reads_file, ref_file, log_path):
    """
    统计fasta文件中序列个数，以及相对于参考基因组的深度

    :param reads_file: fasta文件路径
    :param ref_file: 参考基因组路径
    :return: 深度，序列个数，最短序列长度，最长序列长度，平均序列长度
    """
    log_file = log_path + '/corrected_longreads.log'
    reads_num = 0          # 统计reads的条数
    min_bp = float('inf')  # 最短reads所含碱基数
    max_bp = 0             # 最长reads所含碱基数

    # 1.统计reads中的碱基个数
    reads_base_num = 0
    with open(reads_file, 'r') as f:
        for line in f:
            if '>' in line:
                continue
            reads_base_num += len(line) - 1  # 减去windows中的换行符
            if len(line) >= max_bp:
                max_bp = len(line)
            if len(line) <= min_bp:
                min_bp = len(line)
            reads_num += 1

    # 2.统计ref中的碱基个数
    ref_base_num = 0
    with open(ref_file, 'r') as f:
        for line in f:
            if '>' in line:
                continue
            ref_base_num += len(line) - 1  # 减去windows中的换行符

    # 3.计算depth = reads碱基个数 / ref碱基个数
    depth = reads_base_num / ref_base_num
    mean_bp = reads_base_num / reads_num

    print('depth: {0}'.format(depth))
    print('reads number: {0}'.format(reads_num))

    with open(log_file, 'w') as f_log:
        f_log.write(f'output_depth {depth}\n'
                    f'output_reads_num {reads_num}\n'
                    f'output_min_bp {min_bp}\n'
                    f'output_max_bp {max_bp}\n'
                    f'output_mean_bp {mean_bp}\n')

    return depth, reads_num, min_bp, max_bp, mean_bp


def cut_to_depth(want_depth, reads_file, ref_file):
    """
    将输入的reads文件，切成指定深度

    :param want_depth: 希望得到的深度
    :param reads_file: 输入reads文件路径
    :param ref_file: 对应参考基因组路径
    :return: 无
    """
    output_file = reads_file.split('.')[0] + '_{0}x'.format(want_depth) + '.fasta'
    log_file = reads_file.split('.')[0] + '_{0}x'.format(want_depth) + '.log'

    ori_depth, ori_reads_num, ori_min_bp, ori_max_bp, ori_mean_bp \
        = reads_stat(reads_file, ref_file)  # 计算输入reads文件的初始深度

    keep_rate = int(want_depth / ori_depth * 1000)  # 希望保留的比例
    print('ori_depth = {0}'.format(ori_depth))
    print('want_depth = {0}'.format(want_depth))
    print('keep_rate = {0}'.format(keep_rate))
    print('')

    # 根据希望保留的比例，对每条reads都随机确定是否保留
    while True:
        with open(reads_file, 'r') as f_in:
            for line in f_in:
                if '>' not in line:
                    continue
                if random.randint(1, 1000) <= keep_rate:
                    with open(output_file, 'a') as f_out:
                        f_out.write(line)
                        f_out.write(f_in.readline())

        # 计算output文件的深度
        output_depth, output_reads_num, output_min_bp, output_max_bp, output_mean_bp \
            = reads_stat(output_file, ref_file)

        # 波动在+-0.5x即合格，若不合格，动态调整keep_rate使快速收敛
        if output_depth >= want_depth+0.5:
            keep_rate -= 5
        elif output_depth <= want_depth-0.5:
            keep_rate += 5
        else:
            print('output_depth = {0}'.format(output_depth))
            with open(log_file, 'w') as f_log:
                f_log.write('ori_depth {0}\n'.format(ori_depth))
                f_log.write('ori_reads_num {0}\n'.format(ori_reads_num))
                f_log.write('ori_min_bp {0}\n'.format(ori_min_bp))
                f_log.write('ori_max_bp {0}\n'.format(ori_max_bp))
                f_log.write('ori_mean_bp {0}\n'.format(ori_mean_bp))
                f_log.write('\n')
                f_log.write('output_depth {0}\n'.format(output_depth))
                f_log.write('output_reads_num {0}\n'.format(output_reads_num))
                f_log.write('output_min_bp {0}\n'.format(output_min_bp))
                f_log.write('output_max_bp {0}\n'.format(output_max_bp))
                f_log.write('output_mean_bp {0}\n'.format(output_mean_bp))
            break
        os.remove(output_file)


def get_each_reads_length(reads_file, length_file):
    """
    统计输入reads文件中，每个read的长度，将每个长度作为一行输出成csv文件

    :param reads_file: reads的fa文件
    :param length_file: 每条read长度作为一行的csv文件
    :return: 无
    """
    header = ['length']
    rows = list()
    with open(reads_file, 'r') as f_in:
        for line in f_in:
            if '>' in line:
                continue
            else:
                rows.append([len(line)])

    with open(length_file, 'w', newline='') as f_out:
        writer = csv.writer(f_out)
        writer.writerow(header)
        writer.writerows(rows)
