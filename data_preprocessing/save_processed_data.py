import data_reader, data_preprocessor, os

def save_processed_data(path):
    dr = data_reader.DataReader()
    dp = data_preprocessor.DataPreprocessor()
    
    choices, dynamics, stim_viewing = dr.get_data(path=os.path.join(path, 'merged_raw'), stim_viewing=True)
    dynamics = dp.preprocess_data(choices, dynamics)
    stim_viewing = dp.preprocess_data(choices, stim_viewing)
    
    choices = dp.get_measures(choices, dynamics, stim_viewing)
    choices, dynamics, stim_viewing = dp.exclude_trials(choices, dynamics, stim_viewing)    
    
    processed_path = path + 'processed/'
    if not os.path.exists(processed_path):
        os.makedirs(processed_path)
    choices.to_csv(processed_path + 'choices.txt', sep='\t', na_rep='nan', float_format='%.4f')
    dynamics.to_csv(processed_path + 'dynamics.txt', sep='\t', na_rep='nan', float_format='%.4f')
    stim_viewing.to_csv(processed_path + 'stim_viewing.txt', sep='\t', na_rep='nan', float_format='%.4f')

save_processed_data(path='C:/Users/Arkady/Google Drive/data/CoM_fixed_duration')