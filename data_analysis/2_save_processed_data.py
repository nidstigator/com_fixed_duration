'''
This script processes the raw data from the 'merged_raw' folder and saves it to the 'processed' folder
'''

import data_reader, data_preprocessor, os

with open('data_path.txt') as f:
    data_path = f.read()

dr = data_reader.DataReader()
dp = data_preprocessor.DataPreprocessor()

choices, dynamics, stim_viewing = dr.get_data(path=os.path.join(data_path, 'merged_raw'), stim_viewing=True)

dynamics = dp.preprocess_data(choices, dynamics)
stim_viewing = dp.preprocess_data(choices, stim_viewing)

choices = dp.get_measures(choices, dynamics, stim_viewing)
choices, dynamics, stim_viewing = dp.exclude_trials(choices, dynamics, stim_viewing)    

processed_path = os.path.join(data_path, 'processed')
if not os.path.exists(processed_path):
    os.makedirs(processed_path)
choices.to_csv(os.path.join(processed_path, 'choices.txt'), sep='\t', na_rep='nan', float_format='%.4f')
dynamics.to_csv(os.path.join(processed_path, 'dynamics.txt'), sep='\t', na_rep='nan', float_format='%.4f')
stim_viewing.to_csv(os.path.join(processed_path, 'stim_viewing.txt'), sep='\t', na_rep='nan', float_format='%.4f')
