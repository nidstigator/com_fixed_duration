'''
This script was used to fix two data recording errors due to software bugs
1. session_no missing from the choices file of one subject
2. session_no data missing in some dynamics files 
The script reads files from the '_corrupt' subfolder.
The output of this scripts is stored in the 'raw' subfolder.
'''

import os
import pandas as pd
import re

def fix_headers(directory):
# delete 'session_no' from the header in each file
    for i, file_name in enumerate(os.listdir(directory)):
        file_path = os.path.join(directory, file_name)
        with open(file_path) as f:
            data = f.readlines()
        data[0] = re.sub('session_no\t', '', data[0])
        
        with open(file_path, 'w') as f:
            f.writelines(data)

def fix_session_no(directory, session_no = 1):
# insert session_no column to dynamics log files
    for i, file_name in enumerate(os.listdir(directory)):
        file_path = os.path.join(directory, file_name)
        dynamics = pd.read_csv(file_path, sep='\t')
        dynamics['session_no'] = session_no
        dynamics.set_index(['subj_id', 'session_no', 'block_no', 'trial_no'], inplace=True, drop=True)
        dynamics.to_csv(os.path.join(directory, os.path.splitext(file_name)[0] + '_fixed.txt'), sep='\t')

def fix_choices_session_no(choices_directory, file_name, session_no = 1):
# only applies to 269's first session, when no session_no was recorded to choices log 
    file_path = os.path.join(choices_directory, file_name)
    choices = pd.read_csv(file_path, sep='\t')
    choices['session_no'] = session_no
    choices.set_index(['subj_id', 'session_no', 'block_no', 'trial_no'], inplace=True, drop=True)
    choices.to_csv(os.path.join(file_path), sep='\t')

with open('data_path.txt') as f:
    data_path = f.read()

# Add session_no to dynamics files. As a result of error in experiment software, session_no
# was not actually recorded to dynamics log files, although the headers contain 'session_no'. 
# To fix this, we first remove 'session_no' from the header of each dynamics file, and then
# insert new column to these files, one session at a time (change session_no from 1 to 4)
for session in range(1,5):    
    dynamics_directory = os.path.join(data_path, 'raw/dynamics_corrupt/session_%i' % (session))
    fix_headers(dynamics_directory)
    fix_session_no(dynamics_directory, session_no = session)
