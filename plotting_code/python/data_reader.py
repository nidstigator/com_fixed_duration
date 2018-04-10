import pandas as pd

class DataReader:
    index = ['subj_id', 'session_no', 'block_no', 'trial_no']
    
    def get_data(self, path, stim_viewing=False, sep='\t', nrows=None):
        filePath = path + '%s.txt'
        choicesFilePath = filePath % ('choices')
        choices = pd.read_csv(choicesFilePath, sep=sep).set_index(self.index, drop=True)
        
        dynamicsFilePath = filePath % ('dynamics')       
        dynamics = pd.read_csv(dynamicsFilePath, sep=sep, nrows=nrows, low_memory=True).set_index(self.index, drop=True)        
        
        if stim_viewing:
            stimFilePath = filePath % ('stim_viewing')       
            stim_viewing = pd.read_csv(stimFilePath, sep=sep).set_index(self.index, drop=True)
            
            return choices, dynamics, stim_viewing        
        else:
            return choices, dynamics 