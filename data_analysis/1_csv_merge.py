'''
This script is used to merge individual data files from the 'raw' folder 
into aggregate choices, dynamics, and stim_viewing data files ('merged_raw' folder)
'''

import os

with open('data_path.txt') as f:
    data_path = f.read()

data_types = ['choices', 'dynamics', 'stim_viewing']

in_folder = os.path.join(data_path, 'raw')
out_folder = os.path.join(data_path, 'merged_raw')

if not os.path.exists(out_folder):
    os.makedirs(out_folder)

for data_type in data_types:
    in_path = os.path.join(in_folder, data_type)
    out_path = os.path.join(out_folder, data_type)

    fout=open(out_path + '.txt','w+')
    for i, f in enumerate(os.listdir(in_path)):
        file_path=os.path.join(in_path,f)            
        if file_path.endswith('.txt'):
            f = open(file_path)
            if i!=0:
                # skip the header for the first row
                next(f) 
            for line in f:
                fout.write(line)
            f.close()
            print(file_path)
    fout.close()