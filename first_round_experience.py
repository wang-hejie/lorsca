import subprocess

scripts_path = r'/home/wanghejie/biotools/scripts'

species_list = ['ecoli', 'scere']
folds_list = ['10', '30', '50', '75', '100']
tools_list = ['mecat2', 'falcon', 'lorma', 'canu', 'pbcr']
company_list = ['pacbio', 'ont']
assembler_list = ['miniasm']

for species in species_list:
    for folds in folds_list:
        for tools in tools_list:
            company = 'pacbio'
            for assembler in assembler_list:
                subprocess.call(f'python {scripts_path}/self-correction.py -s {species} -f {folds} -t {tools} '
                                f'-c {company} -a {assembler}', shell=True)
