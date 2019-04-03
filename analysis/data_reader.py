import pandas as pd
import os

class DataReader:
    index = ['subj_id', 'session_no', 'block_no', 'trial_no']
    
    def get_data(self, path, sep='\t', nrows=None, rename_vars=False, RT_threshold=None, stim_viewing=False):
        # rename_vars triggers renaming the variables to more readable versions
        filePath = os.path.join(path, '%s.txt')
        choicesFilePath = filePath % ('choices')
        choices = pd.read_csv(choicesFilePath, sep=sep).set_index(self.index, drop=True)
        
        dynamicsFilePath = filePath % ('dynamics')       
        dynamics = pd.read_csv(dynamicsFilePath, sep=sep, nrows=nrows, low_memory=True).set_index(self.index, drop=True)
        
        if rename_vars:
            choices.loc[choices['is_correct'], 'choice'] = 'Correct'
            choices.loc[~choices['is_correct'], 'choice'] = 'Error'
            choices.loc[choices['is_com'], 'type'] = 'CoM'
            choices.loc[~choices['is_com'], 'type'] = 'non-CoM'
        
        if RT_threshold:
            choices = choices[(choices['RT']<RT_threshold)]
        
        if stim_viewing:
            stimFilePath = filePath % ('stim_viewing')       
            stim_viewing = pd.read_csv(stimFilePath, sep=sep).set_index(self.index, drop=True)
            
            return choices, dynamics, stim_viewing        
        else:
            return choices, dynamics 