prompt = 'Please enter the coherence level, or please enter 100 for all: \n';
coherences = input(prompt);

coherence_string = [num2str(coherences) '_coh'];

if(coherences==100)
    coherences = [0,3.2,6.4,12.8,25.6,51.2];
    coherence_string = 'all_coh';
end

prompt = 'Please enter the number of trials: \n';
n_of_trials = input(prompt);

prompt = 'Please enter the subject ID from Resulaj et al. 2009 (S, A, E): \n';
subject = input(prompt, 's');

clearvars -except n_of_trials coherences subject
close all;

tStart=tic;


dynamics_and_results = repmat(struct('block_no',0,'block_size',0,...
    'trial_no',0,'coherence_level',0,'timestep_size',0,'trial_length',0,...
    'stim_onset',0,'stim_offset',0,...
    'x',[],...
    'B',0,...
    'initial_decision_threshold_crossed',false,...
    'is_motor_correct',false,...
    'initiation_time',0,...
    'is_motor_com',false,'second_threhsold_crossed',false,...
    'motor_decision_made',false)...
    , n_of_trials*size(coherences,2), 1);

% coherences for loop
index = 0;
no_of_blocks = size(coherences,2);
for k = 1: no_of_blocks
    coh = coherences(k);
    for i = 1:n_of_trials
        
        index = index+1;
        
        [x,initial_decision_threshold_crossed, initiation_time, correct, com,...
            second_threhsold_crossed, stim_onset, stim_offset, ...
            trial_length, dt, B]...
            = ddm_simulate...
            (coh, subject);
        
        dynamics_and_results(index).block_no=k;
        dynamics_and_results(index).block_size=n_of_trials;
        dynamics_and_results(index).trial_no=i;
        dynamics_and_results(index).coherence_level=coh;
        dynamics_and_results(index).timestep_size=dt;
        dynamics_and_results(index).trial_length=trial_length;
        dynamics_and_results(index).stim_onset=stim_onset;
        dynamics_and_results(index).x=x;
        dynamics_and_results(index).B = B;
        dynamics_and_results(index).initial_decision_threshold_crossed = ...
            initial_decision_threshold_crossed;
        dynamics_and_results(index).is_motor_correct = correct;
        dynamics_and_results(index).initiation_time =  initiation_time;
        dynamics_and_results(index).is_motor_com = com;
        dynamics_and_results(index).second_threhsold_crossed = ...
            second_threhsold_crossed;
        dynamics_and_results(index).motor_decision_made = ...
            second_threhsold_crossed;
        %%%%%%%%%%%
        
        %%%% Clear vars before next trial
        clearvars -except dynamics_and_results k i ...
            coh tStart filename coherences  ...
            index no_of_blocks n_of_trials subject ...
            %%%%
    end
    
end

clearvars -except dynamics_and_results tStart filename

tElapsed=toc(tStart);

fprintf('Time taken to run this: %f \n',tElapsed)

clearvars tStart tElapsed;

function [x,initial_decision_threshold_crossed,...
    initiation_time, correct, com, second_threhsold_crossed,...
    stim_onset, stim_offset, trial_length, dt, B]= ...
    ddm_simulate(coh, subject)

%% Experiment parameters:
pd=makedist('Exponential','mu',0.82);
dist = truncate(pd, 0.7, 1);
stim_onset =  random(dist) * 1000;
stim_offset = 0;
dt = 1;
trial_length = 2000/dt;
% % % % 

%% SUBJECT S:
if(subject == 'S')
    k = 0.30;
    B = 13.2;
    t_nd_right = 322;
    t_nd_left = 326;
    mu0 = 0.006;
    starting_point = 0.0004;
    B_delta = 23.3;
    PIP_fraction = 1;
    t_com_deadline_right =  PIP_fraction * t_nd_right;
    t_com_deadline_left =  PIP_fraction * t_nd_left;
end

%% SUBJECT E:
if(subject == 'E')
    k = 0.27;
    B = 12.4;
    t_nd_right = 368;
    t_nd_left = 378;
    mu0 = 0.018;
    starting_point = 0.0003;
    B_delta = 18.4;
    PIP_fraction = 0.68;
    t_com_deadline_right =  PIP_fraction * t_nd_right;
    t_com_deadline_left =  PIP_fraction * t_nd_left;
end
%% SUBJECT A:
if(subject == 'A')
    k = 0.25;
    B = 13.0;
    t_nd_right = 390;
    t_nd_left = 395;
    mu0 = 0.013;
    starting_point = -0.0005;
    B_delta = 25.5;
    PIP_fraction = 1;
    t_com_deadline_right =  PIP_fraction * t_nd_right;
    t_com_deadline_left =  PIP_fraction * t_nd_left;
end
% % % % % % % % % % % % % % % % % % % %

%% Initialising the decision variable array and setting initial condition.
x = NaN(1,trial_length);
x(1) = starting_point;


%% Trial result flags- set all to false initially
initial_decision_threshold_crossed = false;
second_threhsold_crossed = false;
correct = false;
com = false;
initiation_time = 0;

for t=1:trial_length-1
%% In Resulaj et al. (2009): Basically, there is no drift
% Instead, it's a diffusion process biased by mu0. 
    mu = (k * (coh/100) + mu0);
    
%% Uncomment shut down the signal on 1st threshold crossing.
%     mu = (t>(stim_onset/dt) & ~decision_module_crossed)*...
%     (k * (coh/100) + mu0);

%% Only start accumulating signal+noise after stimulus onset.
    if(t<(stim_onset/dt))
        x(t+1) = x(t);
    else
        x(t+1)= x(t) + sqrt(dt)* (mu + randn());
    end
    
%% Check if initial threshold is reached: Correct
    if (x(t+1) >= B ...
            && ~initial_decision_threshold_crossed)
        initial_decision_threshold_crossed = true;
        initiation_time = t + (t_nd_right/dt) -  stim_onset;
        t_d = t;
        trial_deadline = t_d + (t_nd_right/dt);
        stim_offset = t*dt;
        correct = true;
    end
    
%% Check if initial threshold is reached: Error
    if (x(t+1) <= -B ...
            && ~initial_decision_threshold_crossed)
        initial_decision_threshold_crossed = true;
        initiation_time = t + (t_nd_left/dt) - stim_onset;
        t_d = t;
        trial_deadline = t_d + (t_nd_left/dt);
        stim_offset = t*dt;
        correct = false;
    end

%% Check if 2nd threshold is reached--> in case of initial correct.
    if(initial_decision_threshold_crossed && correct && t<((stim_offset/dt) +...
            (t_com_deadline_right/dt)) && ~second_threhsold_crossed)
        
        B_reaffirm = B_delta;
        B_flip = -(B_delta-B);
        
        if(x(t+1) >= B_reaffirm && ~second_threhsold_crossed)
            second_threhsold_crossed = true;
            correct = true;
            com = false;
        end
        if(x(t+1) <= B_flip && ~second_threhsold_crossed)
            second_threhsold_crossed = true;
            correct = false;
            com = true;
        end
        
    end
    
    
%% Check if 2nd threshold is reached--> in case of initial error.
    if(initial_decision_threshold_crossed && ~correct && t<((stim_offset/dt) +...
            (t_com_deadline_left/dt))&& ~second_threhsold_crossed)
        
        B_reaffirm = -B_delta;
        B_flip = (B_delta-B);
        
        if(x(t+1) <= B_reaffirm && ~second_threhsold_crossed)
            second_threhsold_crossed = true;
            correct = false;
            com = false;
        end
        if(x(t+1) >= B_flip && ~second_threhsold_crossed)
            second_threhsold_crossed = true;
            correct = true;
            com = true;
        end
    end
    
    
%% Check if trial deadline is exceeded (or 2nd thrsh. reached).
    if(initial_decision_threshold_crossed || second_threhsold_crossed)
        if(t > trial_deadline)
%             If so, terminate trial to cut execution time. 
            break;
        end
    end
    
end
return;
end