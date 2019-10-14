import pandas as pd
import numpy as np
import derivative_calculator

class DataPreprocessor:
    x_lim = 1920
    y_lim = 1080
    
    com_threshold_x = 100
    com_threshold_y = 100

    late_com_y_threshold = 700
    
    # to determine exact response intiation,
    # threshold for distance travelled by mouse cursor (in pixels) during single movement
    # it is needed when calculating initation time
    RT_distance_threshold = 100
        
    index = ['subj_id', 'session_no', 'block_no', 'trial_no']
    
    def preprocess_data(self, choices, dynamics):
        dynamics = self.set_origin_to_start(dynamics)   
        dynamics = self.shift_timeframe(dynamics)
        
        # flip trajectories for trials where direction == left
        # so that all correct trajectories go to the right
        dynamics.loc[choices.direction==180, ['mouse_x']] *= -1
        
        dc = derivative_calculator.DerivativeCalculator()        
        dynamics = dc.append_derivatives(dynamics)
        
        dynamics['mouse_v'] = np.sqrt(dynamics.mouse_vx**2 + dynamics.mouse_vy**2 )

        return dynamics  
    
    def get_measures(self, choices, dynamics, stim_viewing=None):
        choices['is_correct'] = choices['direction'] == choices['response']
        choices = choices.rename(columns={'response_time': 'trial_time'})        
        choices.trial_time /= 1000.0
        
        choices['xflips'] = dynamics.groupby(level=self.index).\
                                    apply(lambda traj: self.zero_cross_count(traj.mouse_vx.values))    
        choices = choices.join(dynamics.groupby(level=self.index).apply(self.get_maxd))
        choices = choices.join(dynamics.groupby(level=self.index).apply(self.get_midline_d))

        choices['is_com'] = ((choices.midline_d > self.com_threshold_x) & \
                                    (choices.midline_d_y > self.com_threshold_y))
        # threshold of 450ms is based on Gallivan et al 2018
        choices['com_type'] = pd.cut(choices.midline_d_t, bins=[0, 0.45, choices.midline_d_t.max()], 
                                       include_lowest=True, labels=['early', 'late'])

        choices['is_correct_init'] = choices['is_correct']
        choices.loc[choices.is_com, 'is_correct_init'] = (dynamics[choices.is_com]. \
                   groupby(level=self.index).apply(self.get_initial_decision))
        choices['is_double_com'] = choices.is_com & (choices.is_correct_init == choices.is_correct)

        choices = choices.join(dynamics.groupby(level=self.index).apply(self.get_RT))
        
#        # response time during stimulus presentation is aligned at stimulus offset, so it is non-positive
        if not stim_viewing is None:
            choices['stim_RT'] = stim_viewing.groupby(level=self.index).apply(self.get_stim_RT)
            # Comment next line for premature responses to have RT = 0 regardless hand movements during stimulus viewing   
            # TODO: even after this, there are too many zero hand IT's
            # investigate the trajectories in where both RT = 0 and stim_RT = 0
            choices.loc[choices.RT==0, 'RT'] = choices.loc[choices.RT==0, 'stim_RT']
                               
        # We can also z-score within participant AND coherence level, the results remain the same
        # ['subj_id', 'coherence']
        z = lambda c: (c-np.nanmean(c))/np.nanstd(c)
        choices['RT (z)'] = choices.RT.groupby(level='subj_id').apply(z)
        
        choices['RT tertile'] = pd.qcut(choices['RT'], 3, labels=[1, 2, 3])
        choices['RT (z) tertile'] = pd.qcut(choices['RT (z)'], 3, labels=[1, 2, 3])
        
        return choices
    
    def exclude_trials(self, choices, dynamics, stim_viewing):  
        exclusion_criteria = (choices.is_double_com) | (choices.RT==np.inf)
        print('%i trials excluded based on exclusion criterion (choices.is_double_com)' 
              % (len(choices[(choices.is_double_com)])))
        print('%i trials excluded based on exclusion criterion (choices.RT==np.inf)' 
              % (len(choices[(choices.RT==np.inf)])))
        
        dynamics = dynamics[~exclusion_criteria]
        stim_viewing = stim_viewing[~exclusion_criteria]
        choices = choices[~exclusion_criteria]
        
        return choices, dynamics, stim_viewing
    
    def set_origin_to_start(self, dynamics):
        # set origin to start button location
        dynamics.mouse_x -= self.x_lim/2
        dynamics.mouse_y = self.y_lim - dynamics.mouse_y
        return dynamics
    
    def shift_timeframe(self, dynamics):
        # shift time to the timeframe beginning at 0 for each trajectory
        # also, express time in seconds rather than milliseconds
        dynamics.loc[:,'timestamp'] = dynamics.timestamp.groupby(by=self.index). \
                                        transform(lambda t: (t-t.min()))/1000.0
        return dynamics
        
    def get_maxd(self, traj):
        alpha = np.arctan((traj.mouse_y.iloc[-1]-traj.mouse_y.iloc[0])/ \
                            (traj.mouse_x.iloc[-1]-traj.mouse_x.iloc[0]))
        d = (traj.mouse_x.values-traj.mouse_x.values[0])*np.sin(-alpha) + \
            (traj.mouse_y.values-traj.mouse_y.values[0])*np.cos(-alpha)
        if abs(d.min())>abs(d.max()):
            return pd.Series({'max_d': d.min(), 'idx_max_d': d.argmin()})
        else:
            return pd.Series({'max_d': d.max(), 'idx_max_d': d.argmax()})
        
    def get_midline_d(self, traj):
        mouse_x = traj.mouse_x.values
        is_final_point_positive = (mouse_x[-1]>0)
        
        midline_d = mouse_x.min() if is_final_point_positive else mouse_x.max()

        idx_midline_d = (mouse_x == midline_d).nonzero()[0][-1]
        
        midline_d_t = traj.timestamp.values[idx_midline_d]
        midline_d_y = traj.mouse_y.values[idx_midline_d]
        
        return pd.Series({'midline_d': abs(midline_d), 
                          'idx_midline_d': idx_midline_d,
                          'midline_d_t': midline_d_t,
                          'midline_d_y': midline_d_y})

    def get_initial_decision(self, traj):    
        # after flipping, x>0 is correct
        return traj.mouse_x.values[np.argmax(abs(traj.mouse_x.values)>self.com_threshold_x)] > 0
    
    def zero_cross_count(self, x):
        return (abs(np.diff(np.sign(x)[np.nonzero(np.sign(x))]))>1).sum()

    def get_RT(self, traj):
        v = traj.mouse_v.values
    
        onsets = []
        offsets = []
        is_previous_v_zero = True
    
        for i in np.arange(0,len(v)):
            if v[i]!=0:                
                if ((is_previous_v_zero) & (i < len(v)-1)) :
                    is_previous_v_zero = False
                    onsets += [i]
                elif (i==len(v)-1):
                    offsets += [i]            
            elif (not is_previous_v_zero):
                offsets += [i]
                is_previous_v_zero = True
                
        submovements = pd.DataFrame([{'on': onsets[i], 
                                     'off': offsets[i], 
                                     'on_t': traj.timestamp.values[onsets[i]],
                                     # distance travelled by the mouse cursor for each submovement
                                     # is an integral of mouse velocity over time
                                     'distance':(traj.mouse_v[onsets[i]:offsets[i]]*
                                                 traj.timestamp.diff()[onsets[i]:offsets[i]]).sum()}
                                    for i in range(len(onsets))])
        if len(submovements):
            RT = submovements.loc[submovements.distance.ge(self.RT_distance_threshold ).idxmax()].on_t
        else:
            # if no submovements could be found, we set RT to infinity and discard these trials
            RT = np.inf
        return pd.Series({'RT': RT, 'motion_time': traj.timestamp.max()-RT})

    def get_stim_RT(self, stim_traj):
        t = stim_traj.timestamp.values
        v = stim_traj.mouse_v.values
        if v[-1]:
            idx = np.where(v==0)[0][-1]+1 if len(v[v==0]) else 0
            RT = (t[idx] - t.max())
        else:
            RT = 0
        return RT