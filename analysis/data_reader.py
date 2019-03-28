import pandas as pd

class DataReader:
    index = ['subj_id', 'session_no', 'block_no', 'trial_no']
    
    def get_data(self, path, sep='\t', nrows=None, rename_vars=False, IT_threshold=None, stim_viewing=False):
        filePath = path + '%s.txt'
        choicesFilePath = filePath % ('choices')
        choices = pd.read_csv(choicesFilePath, sep=sep).set_index(self.index, drop=True)
        
        dynamicsFilePath = filePath % ('dynamics')       
        dynamics = pd.read_csv(dynamicsFilePath, sep=sep, nrows=nrows, low_memory=True).set_index(self.index, drop=True)      
          
        if IT_threshold is not None:
            choices = choices[(choices['mouse_IT']<IT_threshold) & (choices['eye_IT']<IT_threshold)]
        
        if rename_vars == True:
            choices = choices.rename(columns={
                    'mouse_IT': 'hand IT', 
                    'eye_IT': 'eye IT', 
                    'mouse_IT_z': 'hand IT (z)', 
                    'eye_IT_z': 'eye IT (z)', 
                    'mouse_IT_tertile': 'hand IT tertile',
                    'eye_IT_tertile': 'eye IT tertile',
                    'ID_lag': 'hand-eye lag at initiation',
                    'ID_lag_z': 'hand-eye lag at initiation (z)'})
    
            choices.loc[choices['is_correct'], 'choice'] = 'Correct'
            choices.loc[~choices['is_correct'], 'choice'] = 'Error'
            choices.loc[choices['is_com'], 'type'] = 'CoM'
            choices.loc[~choices['is_com'], 'type'] = 'non-CoM'

 
        if stim_viewing:
            stimFilePath = filePath % ('stim_viewing')       
            stim_viewing = pd.read_csv(stimFilePath, sep=sep).set_index(self.index, drop=True)
            
            return choices, dynamics, stim_viewing        
        else:
            return choices, dynamics 