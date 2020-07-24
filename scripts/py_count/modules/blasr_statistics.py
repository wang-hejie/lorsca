def count_indel_mismatch_aarl(blasr_output_file, blasr_count_file):
    """
    对blasr生成的输出做统计
    
    :param blasr_output_file: blasr生成的输出文件
    :param blasr_count_file: 统计文件
    :return: 无
    """
    mismatch_num = 0      # 错配数
    ins_num = 0           # 插入数
    del_num = 0           # 缺失数
    aligned_base_num = 0  # 比对上的碱基总数
    aligned_num = 0       # 比对上的reads条数

    with open(blasr_output_file, 'r') as f:
        for line in f:
            if '[INFO]' in line:
                continue
            aligned_num += 1
            temp_list = line.split(' ')
            mismatch_num += int(temp_list[13])
            ins_num += int(temp_list[14])
            del_num += int(temp_list[15])
            aligned_base_num += len(temp_list[17])

    print('aligned_num = {0}'.format(aligned_num))
    print('mismatch_num = {0}'.format(mismatch_num))
    print('ins_num = {0}'.format(ins_num))
    print('del_num = {0}'.format(del_num))
    print('aligned_base_num = {0}'.format(aligned_base_num))

    # 计算需要的统计指标
    mismatch_rate = mismatch_num / aligned_base_num
    ins_rate = ins_num / aligned_base_num
    del_rate = del_num / aligned_base_num
    aarl = aligned_base_num / aligned_num

    print('mismatch_rate = {0}'.format(mismatch_rate))
    print('ins_rate = {0}'.format(ins_rate))
    print('del_rate = {0}'.format(del_rate))
    print('aarl = {0}'.format(aarl))

    # 写output文件
    with open(blasr_count_file, 'w') as f_out:
        f_out.write('aligned_num {0}\n'.format(aligned_num))
        f_out.write('mismatch_num {0}\n'.format(mismatch_num))
        f_out.write('ins_num {0}\n'.format(ins_num))
        f_out.write('del_num {0}\n'.format(del_num))
        f_out.write('aligned_base_num {0}\n'.format(aligned_base_num))
        f_out.write('\n')
        f_out.write('mismatch_rate {0}\n'.format(mismatch_rate))
        f_out.write('ins_rate {0}\n'.format(ins_rate))
        f_out.write('del_rate {0}\n'.format(del_rate))
        f_out.write('aarl {0}\n'.format(aarl))

    return
