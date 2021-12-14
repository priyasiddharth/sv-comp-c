#!/usr/bin/env python3

import argparse
from enum import Enum
import sys
import yaml
import glob, os


import pdb

YAML_EXT = 'yml'


class TESTKIND(Enum):
    TRUE = 0
    FALSE = 1
    EXCLUDED = 2

# 1. find all yaml files in dir
#  return a set/list of said files
def FindYamlFilesInDir(dir):
    fnames = []
    os.chdir(os.path.abspath(dir))
    for file in glob.glob('*.' + 'yml'):
        fnames.append(file)
    return fnames

# 2. read all yaml files and if the required string is found
# return TESTKIND
def GetTestKind(filename):
    fpath = os.path.abspath(filename)
    stream = open(fpath, 'r')
    y = yaml.safe_load(stream)
    #pdb.set_trace()
    for p in y['properties']:
        prop = p['property_file']
        if 'unreach-call' in prop:
            verdict = p['expected_verdict']
            if verdict is True:
                return TESTKIND.TRUE
            else:
                return TESTKIND.FALSE
    return TESTKIND.EXCLUDED

# 3. Either output a sat or an unsat test
#

import argparse, os

def dir_path(string):
    if os.path.isdir(string):
        return string
    else:
        raise NotADirectoryError(string)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--path', type=dir_path)
    args = parser.parse_args()
    files = FindYamlFilesInDir(args.path)
    for f in files:
        r = GetTestKind(f)
        if r is TESTKIND.TRUE:
            print('sea_add_sat_test({f_wo_ext})'.format(
                  f_wo_ext=os.path.splitext(f)[0]))
        elif r is TESTKIND.FALSE:
            print('sea_add_unsat_test({f_wo_ext})'.format(
                  f_wo_ext=os.path.splitext(f)[0]))

if __name__ == '__main__':
    main()
