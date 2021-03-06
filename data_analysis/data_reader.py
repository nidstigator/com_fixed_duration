import pandas as pd
import os

class DataReader:
    index = ['subj_id', 'session_no', 'block_no', 'trial_no']
    
    def fix_data(self, data, subjects_to_fix):
        # in some subjects, the practice block in the beginning of the first session was mistakenly included in the data
        # at the same time, the is_practice flag was not always switched off during actual data collection
        # here we remove the practice data without relying on the is_pracice column
        data.loc[(data.subj_id.isin(subjects_to_fix)) & (data.session_no==1), 'block_no'] -= 1
        data = data[data.block_no>0]        
        
        # these two subjects have exceedingly high number of CoMs (9% and 13%)
        # this suggests these CoMs are of different nature (e.g. just a particular way of responding)
        # print(choices.groupby('subj_id').is_com.mean())
        data = data[~data.subj_id.isin([216, 747])]
        data = data.set_index(self.index, drop=True).sort_index()
        
        return data
    
    def get_data(self, path, sep='\t', rename_vars=False, stim_viewing=False):
        filePath = os.path.join(path, '%s.txt')
        
        choicesFilePath = filePath % ('choices')
        choices = pd.read_csv(choicesFilePath, sep=sep)

        n_blocks_per_subject = choices[choices.session_no==1].groupby('subj_id').apply(lambda c: c.block_no.max())
        subjects_to_fix = n_blocks_per_subject[n_blocks_per_subject>10].index.values
        
        choices = self.fix_data(choices, subjects_to_fix)
        
        dynamicsFilePath = filePath % ('dynamics')       
        dynamics = pd.read_csv(dynamicsFilePath, sep=sep)
        dynamics = self.fix_data(dynamics, subjects_to_fix)
               
        # for displaying the binary variables is_com and is_correct on plots, it's better to rename them
        if rename_vars:
            choices.loc[choices['is_correct'], 'choice'] = 'Correct'
            choices.loc[~choices['is_correct'], 'choice'] = 'Error'
            choices.loc[choices['is_com'], 'type'] = 'CoM'
            choices.loc[~choices['is_com'], 'type'] = 'non-CoM'
                
        if stim_viewing:
            stimFilePath = filePath % ('stim_viewing')       
            stim_viewing = pd.read_csv(stimFilePath, sep=sep)
            stim_viewing = self.fix_data(stim_viewing, subjects_to_fix)    
            return choices, dynamics, stim_viewing        
        else:
            return choices, dynamics 