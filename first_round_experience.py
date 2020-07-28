import subprocess
import os

script_path = os.path.abspath(__file__)  # 软件根目录/self-correction.py
software_path = os.path.abspath(os.path.dirname(script_path) + os.path.sep + ".")  # 软件根目录
lorsca_path = software_path + '/lorsca.py'

# species_list = ['ecoli', 'scere']
species_list = ['ecoli']
# folds_list = ['10', '30', '50', '75', '100']
folds_list = ['30']
tools_list = ['mecat2', 'falcon', 'lorma', 'canu', 'pbcr','flas', 'consent']
company_list = ['pacbio', 'ont']
assembler_list = ['miniasm']

for species in species_list:
    for folds in folds_list:
        for tools in tools_list:
            company = 'pacbio'
            for assembler in assembler_list:
                subprocess.call(f'python {lorsca_path} -s {species} -f {folds} -t {tools} '
                                f'-c {company} -a {assembler}', shell=True)
