import pandas as pd
import os
import seaborn as sns

subj_id = 315   
data_directory = '../../../data/rdk_data/choices'

files = [filename for filename in os.listdir(data_directory) if filename.startswith(str(subj_id))]

if len(files)>0:
    choices = pd.read_csv(os.path.join(data_directory, files[0]), sep='\t')
else:
    raise Exception('No data for subject %i found' % (subj_id)) 

choices['is_correct'] = choices['direction'] == choices['response']
#sns.pointplot(x='coherence', y='is_correct', data=choices)

accuracy = choices.groupby('coherence').is_correct.mean().rename('p_correct')

if ((accuracy.loc[0.512]>0.8)&(accuracy.loc[0.256]>0.7)&(accuracy.loc[0.128]>0.6)&(accuracy.loc[0.064]>0.5)):
    print('Subject %i' % (subj_id))
    print('Performance criteria satisfied. Participant should be invited for three more sessions')
#    print('CoM rate: %.3f' % (com_rate))
else:
    print('Performance below threshold')
    
print(accuracy)
ax = sns.pointplot(x=accuracy.reset_index().coherence, y=accuracy.reset_index().p_correct)
for level in [0.5, 0.6, 0.7, 0.8]:
    ax.axhline(level, ls='--', color='grey')