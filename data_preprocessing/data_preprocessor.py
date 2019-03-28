import pandas as pd
import numpy as np
import derivative_calculator

class DataPreprocessor:
    x_lim = 1920
    y_lim = 1080
    
    com_threshold_x = 50
    com_threshold_y = 100

    late_com_y_threshold = 700
    
    # to determine exact response intiation,
    # threshold for distance travelled by mouse cursor (in pixels) during single movement
    # it is needed when calculating initation time
    RT_distance_threshold = 100
    
    resp_AOI_radius = 200
    mouse_AOI_radius = 100
    incorrect_AOI_centre = [-(x_lim/2-resp_AOI_radius), (y_lim-resp_AOI_radius)]
    correct_AOI_centre = [(x_lim/2-resp_AOI_radius), (y_lim-resp_AOI_radius)] 
        
    index = ['subj_id', 'session_no', 'block_no', 'trial_no']
    
    def preprocess_data(self, choices, dynamics, resample=0, model_data=False):       
        if not model_data:            
            dynamics = self.set_origin_to_start(dynamics)                   
        
        dynamics = self.shift_timeframe(dynamics)
        
        # flip trajectories for trials where direction == left
        # so that all correct trajectories go to the right
        dynamics.loc[choices.direction==180, ['mouse_x']] *= -1
        
        if resample:
            dynamics = self.resample_trajectories(dynamics, n=resample)
        
        dc = derivative_calculator.DerivativeCalculator()
        dynamics = dc.append_diff(dynamics)
        dynamics = dc.append_derivatives(dynamics)
        
        dynamics['mouse_v'] = np.sqrt(dynamics.mouse_vx**2 + dynamics.mouse_vy**2 )

        return dynamics  
    
    def get_measures(self, choices, dynamics, stim_viewing=None, model_data=False):
        # TODO: get rid of extra index added as extra columns somewhere along the way (subj_id.1, ...)
        choices['is_correct'] = choices['direction'] == choices['response']        
        choices.response_time /= 1000.0        
        choices['xflips'] = dynamics.groupby(level=self.index).\
                                    apply(lambda traj: self.zero_cross_count(traj.mouse_vx.values))    
        choices = choices.join(dynamics.groupby(level=self.index).apply(self.get_maxd))
        choices = choices.join(dynamics.groupby(level=self.index).apply(self.get_midline_d))

        if model_data:
            choices['is_com'] = ((choices.midline_d > self.com_threshold_x))
        else:                
            choices['is_com'] = ((choices.midline_d > self.com_threshold_x) & \
                                    (choices.midline_d_y > self.com_threshold_y))
        choices['com_type'] = pd.cut(choices.midline_d_y, 
               bins=[0, self.late_com_y_threshold, self.y_lim], labels=['early', 'late'])

        choices['is_correct_init'] = choices['is_correct']
        choices.loc[choices.is_com, 'is_correct_init'] = (dynamics[choices.is_com]. \
                   groupby(level=self.index).apply(self.get_initial_decision))
        choices['is_double_com'] = choices.is_com & (choices.is_correct_init == choices.is_correct)

        choices = choices.join(dynamics.groupby(level=self.index).apply(self.get_RT))
        
        # initiation time during stimulus presentation is aligned at stimulus offset, so it is non-positive
        if not stim_viewing is None:
            choices['stim_RT'] = stim_viewing.groupby(level=self.index).apply(self.get_stim_RT)
            # Comment next line for premature responses to have RT = 0 regardless hand movements during stimulus viewing   
            # TODO: even after this, there are too many zero hand IT's
            # investigate the trajectories in Exp 2 where both RT = 0 and stim_RT = 0
            # Most are in subject 624
            choices.loc[choices.RT==0, 'RT'] = choices.loc[choices.RT==0, 'stim_RT']
                               
        # We can also z-score within participant AND coherence level, the results remain the same
        # ['subj_id', 'coherence']
        z = lambda c: (c-np.nanmean(c))/np.nanstd(c)
        choices['RT_z'] = choices.RT.groupby(level='subj_id').apply(z)
        
        if not model_data:
            choices['RT_tertile'] = pd.qcut(choices['RT'], 3, labels=[1, 2, 3])
        
        return choices
    
    def exclude_trials(self, choices, dynamics, stim_viewing):        
        dynamics = dynamics[~choices.is_double_com]
        stim_viewing = stim_viewing[~choices.is_double_com]
        choices = choices[~choices.is_double_com]
        
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

    def resample_trajectories(self, dynamics, n_steps=100):
        resampled_dynamics = dynamics.groupby(level=self.index).\
                                    apply(lambda traj: self.resample_trajectory(traj, n_steps=n_steps))
        resampled_dynamics.index = resampled_dynamics.index.droplevel(4)
        return resampled_dynamics
        
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
        midline_d_y = traj.mouse_y.values[idx_midline_d]
        return pd.Series({'midline_d': abs(midline_d), 
                          'idx_midline_d': idx_midline_d,
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
                if is_previous_v_zero:
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
                 'distance':(traj.mouse_v[onsets[i]:offsets[i]]*
                             traj.timestamp.diff()[onsets[i]:offsets[i]]).sum()}
                for i in range(len(onsets))])
        if len(submovements):
            RT = submovements.loc[submovements.distance.ge(self.RT_distance_threshold ).idxmax()].on_t
        else:
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
    
    def resample_trajectory(self, traj, n_steps):
        # Make the sampling time intervals regular
        n = np.arange(0, n_steps+1)
        t_regular = np.linspace(traj.timestamp.min(), traj.timestamp.max(), n_steps+1)
        mouse_x_interp = np.interp(t_regular, traj.timestamp.values, traj.mouse_x.values)
        mouse_y_interp = np.interp(t_regular, traj.timestamp.values, traj.mouse_y.values)
        eye_x_interp = np.interp(t_regular, traj.timestamp.values, traj.eye_x.values)
        eye_y_interp = np.interp(t_regular, traj.timestamp.values, traj.eye_y.values)
        pupil_size_interp = np.interp(t_regular, traj.timestamp.values, 
                                      traj.pupil_size.values)
        traj_interp = pd.DataFrame([n, t_regular, mouse_x_interp, mouse_y_interp, \
                                    eye_x_interp, eye_y_interp, pupil_size_interp]).transpose()
        traj_interp.columns = ['n', 'timestamp', 'mouse_x', 'mouse_y', 'eye_x', 'eye_y', 'pupil_size']
#        traj_interp.index = range(1,n_steps+1)
        return traj_interp