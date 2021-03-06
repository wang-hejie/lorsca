import sys, os
from pbcore.io import FastaIO

def run(reader, writer):
    for record in reader:
        ori_header = record.header
        seq_length = len(record.sequence)
        start, end = 0, 0
        new_end = start + seq_length

        new_header = f"{ori_header}/{start}_{new_end}"
        writer.writeRecord(new_header, record.sequence)


def main(iname, ofile):
    reader = FastaIO.FastaReader(iname)
    writer = FastaIO.FastaWriter(ofile)
    run(reader, writer)


if __name__ == '__main__':
    iname, oname = sys.argv[1:3]
    ofile = open(oname, 'w')
    try:
        main(iname, ofile)
    except:
        ofile.close()
        os.unlink(oname)
        raise
