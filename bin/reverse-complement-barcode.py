#!/usr/bin/env python3

import sys
import re
import csv

table = str.maketrans('ACGT', 'TGCA')
nt = re.compile('^[ACGT]+$')


def readSamples(lineNumber):
    """
    Read the sample lines from a sample sheet.

    @param lineNumber: The C{int} number of lines of input already read.
    """
    reader = csv.reader(sys.stdin)
    for lineNumber, row in enumerate(reader, start=lineNumber + 1):
        if len(row) == 12:
            barcode2 = row[9]
            if nt.match(barcode2) is None:
                print('Barcode 2 on line %d is %r (not all nucleotides).' %
                      (lineNumber, ','.join(row)), file=sys.stderr)
                sys.exit(3)
            else:
                row[9] = barcode2.translate(table)[::-1]
                print(','.join(row))
        else:
            print('Line %d (%r) had %d fields, not 12.' %
                  (lineNumber, ','.join(row), len(row)), file=sys.stderr)
            sys.exit(4)


def readStart():
    """
    Read up to the sample lines in a sample sheet.

    @return: The C{int} number of lines of input read.
    """
    state = 'expecting data'

    for lineNumber, line in enumerate(sys.stdin):
        line = line.strip()
        if state == 'expecting data':
            print(line)
            if line == '[Data]':
                state = 'expecting header'
        elif state == 'expecting header':
            if line.startswith('Lane,'):
                print(line)
                return lineNumber
            else:
                print('Expected to find Lane, on line %d. Instead found %r' %
                      (lineNumber, line), file=sys.stderr)
                sys.exit(1)
        else:
            print('Unexpected state (%r) on line %d!' %
                  (state, lineNumber), file=sys.stderr)
            sys.exit(2)


if __name__ == '__main__':
    readSamples(readStart())
