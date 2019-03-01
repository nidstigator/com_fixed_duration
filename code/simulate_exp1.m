clearvars;
close all;

global dt; global trial_length; global stim_onset; global stim_duration;
global stim_offset;

global x_gather;

dt = 0.5;
trial_length = 4000/dt;
stim_onset = 900;
stim_duration = 850;
stim_offset = stim_duration+stim_onset;

x_gather = [];

%%%%Threshold values:
decision_module_threshold = 37.5;
motor_target_threshold = 17.4;
%%%%%%%%%%%%%%%%%%%%%%


prompt = 'Please enter the coherence level, or please enter 100 for all: \n';
coherences = input(prompt);


coherence_string = [num2str(coherences) '_coh'];

if(coherences==100)
    coherences = [0,3.2,6.4,12.8,25.6,51.2];
    coherence_string = 'all_coh';
end

prompt = 'Please enter the number of trials: \n';
n_of_trials = input(prompt);

tStart=tic;


trial_type_string = 'fixed_duration';

filename = [ 'data' '_' coherence_string '_' trial_type_string  '_'  num2str(n_of_trials) '_' strrep(strrep(datestr(now, 'dd-mm-yyyy HH-MM-SS'),' ', '_'), '-','_') '.mat' ];


dynamics_and_results = repmat(struct('block_no',0,'block_size',0,...
    'trial_no',0,'coherence_level',0,'timestep_size',0,'trial_length',0,...
    'stim_onset',0,'stim_duration',0,'stim_offset',0,...
    'y_1',[],'y_2',[],'y_3',[],'y_4',[],'s_1',[],'s_2',[],'y_5',[],'y_6',[],...
    'y_mc_hu',[], 'y_mc_lu',[], 'y_7',[],'y_8',[],...
    'decision_module_threshold',0,...
    'motor_target_threshold',0,'motor_maximum_value_left',0,...
    'motor_maximum_value_right',0,...
    'decision_module_crossed',false,...
    'is_motor_correct',false,...
    'initation_time',0,'eye_initiation_time',0,...
    'movement_duration',0,...
    'is_motor_com',false,'is_late_com',false,'motor_decision_made',false,...
    'com_initiation_point_hand',0,'com_initiation_point_eye',0,'is_not_com_eye',0)...
    , n_of_trials*size(coherences,2), 1);


% coherences for loop
index = 0;
no_of_blocks = size(coherences,2);

for k = 1: no_of_blocks
    coh = coherences(k);
    % Trials for loop.
    for i = 1:n_of_trials
        
        index = index+1;
        
        [y_1,y_2,s1,s2,decision_module_crossed,...
            y_mc_lu, initiation_time,...
            initiation_time_eye] = nonlinear_decision_module_and_mc_integrate...
            (coh,decision_module_threshold);
        
        [y_3, y_4] = ...
            eye_module_integrate(y_1,y_2,initiation_time_eye);
        
        
        [y_5,y_6] = ...
            hand_module_integrate(y_1,y_2,initiation_time);
        
        
        % Set these values in case functions don't execute due to
        % nondecision
        motor_decision_made=false;
        movement_duration = 0;
        is_motor_correct = false;
        is_motor_com = false;
        is_late_com = false;
        is_not_com_eye= false;
        com_initiation_point_hand = 0;
        com_initiation_point_eye = 0;
        
        %%%%%%%%%%
        if(~(isempty(y_5) || isempty(y_6)))
            [is_motor_correct, motor_decision_made, movement_duration] = ...
                check_if_motor_target_reached...
                (y_5,y_6,...
                motor_target_threshold,initiation_time);
            
            [is_motor_com, is_late_com, com_initiation_point_hand, com_initiation_point_eye, is_not_com_eye] = ...
                check_com(y_5,y_6,y_4,y_3,motor_decision_made,motor_target_threshold,is_motor_correct);
        end
        
        if(motor_decision_made==0)
            temp=3;
        end
        dynamics_and_results(index).block_no=k;
        dynamics_and_results(index).block_size=n_of_trials;
        dynamics_and_results(index).trial_no=i;
        dynamics_and_results(index).coherence_level=coh;
        dynamics_and_results(index).timestep_size=dt;
        dynamics_and_results(index).trial_length=trial_length;
        dynamics_and_results(index).stim_onset=stim_onset;
        dynamics_and_results(index).stim_duration=stim_duration;
        dynamics_and_results(index).stim_offset=stim_onset+stim_duration;
        dynamics_and_results(index).s_1=s1;
        dynamics_and_results(index).s_2=s2;
        dynamics_and_results(index).y_1=y_1;
        dynamics_and_results(index).y_2=y_2;
        dynamics_and_results(index).y_3=y_3;
        dynamics_and_results(index).y_4=y_4;
        dynamics_and_results(index).y_5=y_5;
        dynamics_and_results(index).y_6=y_6;
        dynamics_and_results(index).y_7=zeros(1,trial_length);
        dynamics_and_results(index).y_8=zeros(1,trial_length);
        dynamics_and_results(index).y_mc_hu=y_mc_lu;
        dynamics_and_results(index).y_mc_lu=y_mc_lu;
        dynamics_and_results(index).is_not_com_eye = is_not_com_eye;
        dynamics_and_results(index).com_initiation_point_hand = com_initiation_point_hand;
        dynamics_and_results(index).com_initiation_point_eye = com_initiation_point_eye;
        dynamics_and_results(index).decision_module_threshold = decision_module_threshold;
        dynamics_and_results(index).motor_target_threshold = motor_target_threshold;
        dynamics_and_results(index).motor_maximum_value_left = max(y_5);
        dynamics_and_results(index).motor_maximum_value_right = max(y_6);
        dynamics_and_results(index).decision_module_crossed = decision_module_crossed;
        dynamics_and_results(index).motor_decision_made = motor_decision_made;
        dynamics_and_results(index).is_motor_correct = is_motor_correct;
        dynamics_and_results(index).movement_duration = movement_duration * dt;
        dynamics_and_results(index).eye_initiation_time= (initiation_time_eye * dt) - stim_offset;
        dynamics_and_results(index).initiation_time =  (initiation_time * dt) - stim_offset;
        %             dynamics_and_results(index).hand_response_time = total_response_time * dt;
        dynamics_and_results(index).is_motor_com = is_motor_com;
        dynamics_and_results(index).is_late_com= is_late_com;
        %             dynamics_and_results(index).hand_module_delay= hand_module_delay;
        %             dynamics_and_results(index).click_delay= click_delay;
        %             dynamics_and_results(index).mc_module_delay= mc_module_delay;
        
        %%%%%%%%%%%
        
        %%%% Clear vars before next trial
        clearvars -except dynamics_and_results k i dt trial_length stim_onset...
            stim_duration stim_offset decision_module_threshold ...
            motor_preparation_module_threshold motor_target_threshold ...
            hand_module_delay mc_module_delay click_delay ...
            coh n_of_trials tStart filename coherences  ...
            index across_trial_effect no_of_blocks eye_module_delay...
            x_gather motor_preparation_module_threshold_eye saving_mode decision_module_crossed_hand
        %%%%
        
        
    end
    
end

clearvars -except dynamics_and_results tStart filename

tElapsed=toc(tStart);

fprintf('Time taken to run this: %f \n',tElapsed)

clearvars tStart tElapsed;

%old save function doesn't work with large variables.
%save(filename,'-v7.3');

function [y_1,y_2,s1,s2,decision_module_crossed,...
    ...
    y_mc_lu,...
    initiation_time,...
    initiation_time_eye] = ...
    nonlinear_decision_module_and_mc_integrate(coh,decision_module_threshold)

global dt; global trial_length; global stim_onset;
global stim_offset;

%%%%%%%%%%%% DECISION PARAMETERS
%%%% Synaptic time and other constants


tnmda = 100;    % NMDAr
tampa = 2;      % AMPAr
gamma = 0.641;  % Gamma

% FI curve parameters

a = 270; b = 108; d = 0.1540;  % Parameters for excitatory cells

g = 1.12;
% Paramters to be varied

mu0       = 30.0;      % External stimulus strength
noise_amp = 0.028;      % Noise amplitude into selective populations


%---- Initial conditions and clearing variables -----------
s1_in=0.1; s2_in=0.1;
I_eta1_in = noise_amp*randn ; I_eta2_in = noise_amp*randn ;


% Intialise and vectorise variables to be used in loops below

s1 = s1_in.*ones(1,trial_length); s2 = s2_in.*ones(1,trial_length);
I_eta1 = I_eta1_in.*ones(1,trial_length);
I_eta2 = I_eta2_in.*ones(1,trial_length);
%%%%%%%%%%%%


% Initialise state vectors with zeros (for better performance)
y_1 = zeros(1,trial_length);
y_2 = zeros(1,trial_length);

% Initialise state vectors with zeros (for better performance)
Isyn1 = zeros(1,trial_length);
Isyn2 = zeros(1,trial_length);

decision_module_crossed = false;
decision_module_crossed_hand = false;

gain_mc_lu = 1;     % Gain of input-output function (cf. Wong & Wang, 2006)
tau_mc_lu = 150;    % Membrane time constant (cf. Wilson and Cowan, 1972)

j0_mc_hu = 0.02;   % (excitation) Coupling constant from HU to eye module
j_mc_dec_lu = 1;    % Coupling from decision module to excitatory mc
j_self_mc = 0;      % Self excitation constant for MC.
%%%%%%%%%%%%


% Initialise state vectors with zeros (for better performance)
y_mc_lu = zeros(1,trial_length);


initiation_time = 0;
initiation_time_eye = 0;


for t=1:trial_length-1
    %Constant effective external current input
    I0E1 = 0.3255; I0E2 = 0.3255;
    
    % External stimulus
    JAext = 0.00052; % Synaptic coupling constant to external inputs
    
    I_stim_1 = (stim_onset/dt<t & t<(stim_offset)/dt)*...
        (JAext * mu0 * (1-coh/100)); % To population 1
    I_stim_2 = (stim_onset/dt<t & t<(stim_offset)/dt)*...
        (JAext * mu0 * (1+coh/100)); % To population 2
    
    % Recurrent synaptic coupling constants
%     JN11 = 0.2609; JN22 = 0.2609;
    JN11 = 0.248; JN22 = 0.248; % works except for 51.2% correct.
    JN12 = 0.0497; JN21 = 0.0497;
    
    % Resonse function of competiting excitatory population 1
    Isyn1(t) = JN11 .* s1(t) - JN12 .* s2(t) + I0E1 + I_stim_1 ...
        + I_eta1(t)+ (j0_mc_hu * y_mc_lu(t));

    y_1(t)  = g * ((a .* Isyn1(t) - b) ./ (1 ...
        - exp(-d .* (a .* Isyn1(t)-b))));
    
    % Response function of competiting excitatory population 2
    Isyn2(t) = JN22 .* s2(t) - JN21 .* s1(t) + I0E2 + I_stim_2 ...
        + I_eta2(t)+ (j0_mc_hu * y_mc_lu(t));
    

    y_2(t)  = g * ((a .* Isyn2(t) - b) ./ (1 ...
        - exp(-d.*(a.*Isyn2(t)-b))));
    
    % Dynamical equations
    
    % Mean NMDA-receptor dynamics
    s1(t+1) = s1(t) + dt * (-(s1(t)/tnmda) ...
        + (1 - s1(t)) * gamma * y_1(t)/1000);
    s2(t+1) = s2(t) + dt*(-(s2(t)/tnmda) ...
        + (1 - s2(t)) * gamma * y_2(t)/1000);
    
    % Noise through synaptic currents of pop1 and 2
    I_eta1(t+1) = I_eta1(t) + (dt/tampa) * (-I_eta1(t))...
        + sqrt(dt/tampa) * noise_amp*randn ;
    I_eta2(t+1) = I_eta2(t) + (dt/tampa) * (-I_eta2(t))...
        + sqrt(dt/tampa) * noise_amp*randn ;
    
    % To ensure firing rates are always positive
    if (y_1(t) < 0 )
        y_1(t) = 0;
    end
    if (y_2(t) < 0)
        y_2(t) = 0;
    end
    
    %to record moment of threshold crossing for motor preparation
    %this is for 'more natural threshold crossing'
    if ((y_1(t) > decision_module_threshold ...
            || y_2(t) > decision_module_threshold) ...
            && ~decision_module_crossed)
        decision_module_crossed = true;
     
        initiation_time_eye = t;
    end
    
    if ((y_1(t) > decision_module_threshold+5 ...
            || y_2(t) > decision_module_threshold+5) ...
            && ~decision_module_crossed_hand)
        decision_module_crossed_hand = true;
     
        initiation_time = t;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%MC MODULE INTEGRATE:
    % Conditional inhibitory control
    hu_top_down_inhibition = ((stim_onset+600)/dt>t) * 1000;
    
    %         custom_top_down_inhibition = (((delayed-400)>response_time) && (response_time~=0)) * 3000;
    % %
    custom_top_down_inhibition = (decision_module_crossed_hand) * 3000;
    
    % Total input coming in to MC population (LU and HU)
    i_lu_total = gain_mc_lu * (j_mc_dec_lu * (y_1(t) +...
        y_2(t)) + j_self_mc * y_mc_lu(t)) - hu_top_down_inhibition - custom_top_down_inhibition;
    
    
    % Input-Output function
    f_i_mc_lu = heaviside(i_lu_total) *  i_lu_total;
    
    % Dynamical equations.
    y_mc_lu(t+1) = y_mc_lu(t) + (dt/tau_mc_lu) * ...
        (-y_mc_lu(t) +f_i_mc_lu);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%MC MODULE INTEGRATE END
end
return;

end

function [y_3,y_4] =  eye_module_integrate(y_7,y_8,initiation_time)

global dt; global trial_length;


if(initiation_time==0)
    y_3=[];
    y_4=[];
    return;
end

j_dec_eye = 1.5;        % Coupling strength from decision module to eye module
eye_inhibition = 1;   % Inhibition strength
j_self_eye = 0;        % Self excitation strength
tau_eye = 20;          % Coupling constant for eye
gain_eye = 1;          % Gain of input-output function

% Initialise state vectors with zeros (for better performance)
y_3 = zeros(1,trial_length);
y_4 = zeros(1,trial_length);


% Single trial loop start
for t=1:trial_length-1
    
    %TODO:Check this
    inhibitory_control = (t<initiation_time) * 5000 ;
    
    % Total input coming in to left eye neural population
    i3_total = gain_eye * (-eye_inhibition * y_4(t) + j_self_eye ...
        * y_3(t) + j_dec_eye* y_7(t)) - inhibitory_control;
    
    % Input-output function
    f_i3_total = heaviside(i3_total) * i3_total;
    
    
    % Dynamical equation for left eye neural population
    y_3(t+1) = y_3(t) + ((dt/tau_eye) * (-y_3(t) + f_i3_total));
    
    % Total input coming in to left eye neural population
    i4_total = gain_eye* (-eye_inhibition * y_3(t)+ j_self_eye ...
        * y_4(t) + j_dec_eye * y_8(t)) - inhibitory_control;
    
    
    % Input-output function
    f_i4_total = heaviside(i4_total) * i4_total;
    
    
    % Dynamical equation for left eye neural population
    y_4(t+1) = y_4(t) + ((dt/tau_eye) * (-y_4(t) + f_i4_total));
    
    
end % Single trial loop end

return;



end % Function end

function [y_5,y_6] =  hand_module_integrate(y_7,y_8,initiation_time)

global dt; global trial_length;


if(initiation_time==0)
    y_5=[];
    y_6=[];
    return;
end

j_dec_hand = 1.5;     % Coupling strength from decision module to eye module
hand_inhibition = 1;% Inhibition strength
j_self_hand = 0;    % Self excitation strength
tau_hand = 50;      % Coupling constant for eye
gain_hand = 1;      % Gain of input-output function

% Initialise state vectors with zeros (for better performance)
y_5 = zeros(1,trial_length);
y_6 = zeros(1,trial_length);


% Single trial loop start
for t=1:trial_length-1
    
    %TODO:Check this
    inhibitory_control = (t<initiation_time) * 5000;
    
    % Total input coming in to left eye neural population
    i5_total = gain_hand * (-hand_inhibition * y_6(t) + j_self_hand ...
        * y_5(t) + j_dec_hand* y_7(t)) - inhibitory_control;
    
    % Input-output function
    f_i5_total = heaviside(i5_total) * i5_total;
    
    % Dynamical equation for left eye neural population
    y_5(t+1) = y_5(t) + ((dt/tau_hand) * (-y_5(t) + f_i5_total));
    
    
    % Total input coming in to left eye neural population
    i6_total = gain_hand* (-hand_inhibition * y_5(t)+ j_self_hand ...
        * y_6(t) + j_dec_hand * y_8(t)) - inhibitory_control;
    
    
    f_i6_total = heaviside(i6_total) * i6_total;
    
    
    % Dynamical equation for left eye neural population
    y_6(t+1) = y_6(t) + ((dt/tau_hand) * (-y_6(t) + f_i6_total));
    
end % Single trial loop end

return;
end % Function end

function [is_motor_correct, motor_decision_made, movement_duration] =  check_if_motor_target_reached(y_5,y_6,motor_target_threshold,initiation_time)
motor_decision_made = false;
is_motor_correct = false;
movement_duration = 0;

left_reached = find(y_5>=motor_target_threshold,1);
right_reached = find(y_6>=motor_target_threshold,1);

if(isempty(left_reached))
    left_reached=0;
end

if(isempty(right_reached))
    right_reached=0;
end

if(right_reached > left_reached)
    is_motor_correct = true;
    motor_decision_made=true;
    movement_duration = movement_duration+ right_reached-initiation_time;
elseif(left_reached > right_reached)
    motor_decision_made=true;
    movement_duration = movement_duration + left_reached-initiation_time;
end

return;

end

function [is_motor_com, is_late_com, com_initiation_point_hand, com_initiation_point_eye, is_not_com_eye] = check_com(y_5,y_6,y_4,y_3,motor_decision_made,motor_target_threshold,is_motor_correct)
global trial_length;

is_motor_com = false;
is_not_com_eye = false;
is_late_com = false;
com_initiation_point_hand= 0;
com_initiation_point_eye= 0;
if(~motor_decision_made)
    return;
end
x_traj = y_5-y_6;

x_traj_eye = y_3-y_4;

smoothed_trajectory = filter(ones(1,50)/50,1,x_traj);

delta_of_trajectory = diff(sign(smoothed_trajectory));

left_reached = find(y_5>=motor_target_threshold,1);
right_reached = find(y_6>=motor_target_threshold,1);

if(isempty(left_reached))
    left_reached=0;
end

if(isempty(right_reached))
    right_reached=0;
end

points_of_change = find(delta_of_trajectory);

if(size(points_of_change,2)<2)
    return;
end





%take the last two points of change.
point_of_change = points_of_change(end);
point_before_point_of_change=points_of_change(end-1);



%% Eye
smoothed_trajectory_eye = filter(ones(1,50)/50,1,x_traj_eye);

delta_of_trajectory_eye = diff(sign(smoothed_trajectory_eye));

points_of_change_eye = find(delta_of_trajectory_eye);





%difference between last two points of change is 50, then something is
%wrong.
% if(point_of_change-point_before_point_of_change < 50)
%     return;
% end

% check if the maximum amplitude of signall is less than 1 between the two
% points of change- then the change isn't significant.
% if(max(abs(x_traj(point_before_point_of_change:point_of_change)))<1)
%     return;
% end

% check if Change-of-Mind (after the point of change, is the threshold
% actually reached?)
for i = point_of_change:trial_length-1
    if(y_5(i)>=motor_target_threshold || y_6(i)>=motor_target_threshold)
        is_motor_com = true;
        break;
    end
end

%check if correct Change-of-Mind
if(is_motor_com && is_motor_correct && point_of_change > left_reached && left_reached ~=0)
    is_late_com = true;
end

%check if incorrect Change-of-Mind
if(is_motor_com && ~is_motor_correct && point_of_change > right_reached && right_reached ~=0)
    is_late_com = true;
end

com_initiation_point_hand = point_of_change;
if(size(points_of_change_eye,2)<2)
    is_not_com_eye = true;
    return;
end

points_of_change_eye = find(delta_of_trajectory);
point_of_change_eye = points_of_change_eye(end);
com_initiation_point_eye = point_of_change_eye;

end

