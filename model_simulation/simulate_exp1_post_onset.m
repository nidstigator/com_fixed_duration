global dt; global trial_length; global stim_onset; global stim_duration;
global stim_offset;

dt = 0.5;
trial_length = 4000/dt;
stim_duration = 800;


% % % % % % CHANGE THE THRESHOLD VALUE NEXT. 

%%%%Threshold values:
decision_module_threshold = 42.5;
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

clearvars -except n_of_trials coherences coherence_string...
    motor_target_threshold decision_module_threshold stim_offset ...
    stim_duration trial_length dt stim_onset;
close all;

tStart=tic;


trial_type_string = 'fixed_duration';

filename = [ 'data' '_' coherence_string '_' trial_type_string  '_'  num2str(n_of_trials) '_' strrep(strrep(datestr(now, 'dd-mm-yyyy HH-MM-SS'),' ', '_'), '-','_') '.mat' ];


dynamics_and_results = repmat(struct('block_no',0,'block_size',0,...
    'trial_no',0,'coherence_level',0,'timestep_size',0,'trial_length',0,...
    'stim_onset',0,'stim_duration',0,'stim_offset',0,...
    'y_1',[],'y_2',[],'y_3',[],'y_4',[],'s_1',[],'s_2',[],'y_5',[],'y_6',[],...
    'y_mc_hu',[], 'y_7',[],'y_8',[],...
    'decision_module_threshold',0,...
    'motor_target_threshold',0,'motor_maximum_value_left',0,...
    'motor_maximum_value_right',0,...
    'decision_module_crossed',false,...
    'is_motor_correct',false,...
    'initation_time',0,...
    'movement_duration',0,...
    'is_motor_com',false,'motor_decision_made',false)...
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
            ] = nonlinear_decision_module_and_mc_integrate...
            (coh,decision_module_threshold);

        [y_5,y_6] = ...
            hand_module_integrate(y_1,y_2,initiation_time);
        
        
        % Set these values in case functions don't execute due to
        % nondecision
        motor_decision_made=false;
        movement_duration = 0;
        is_motor_correct = false;
        is_motor_com = false;      
        %%%%%%%%%%
        if(~(isempty(y_5) || isempty(y_6)))
            [is_motor_correct, motor_decision_made, movement_duration] = ...
                check_if_motor_target_reached...
                (y_5,y_6,...
                motor_target_threshold,initiation_time);
            
            [is_motor_com] = ...
                check_com(y_5,y_6,motor_decision_made,motor_target_threshold);
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
        dynamics_and_results(index).y_5=y_5;
        dynamics_and_results(index).y_6=y_6;
        dynamics_and_results(index).y_mc_hu=y_mc_lu;
        dynamics_and_results(index).decision_module_threshold = decision_module_threshold;
        dynamics_and_results(index).motor_target_threshold = motor_target_threshold;
        dynamics_and_results(index).motor_maximum_value_left = max(y_5);
        dynamics_and_results(index).motor_maximum_value_right = max(y_6);
        dynamics_and_results(index).decision_module_crossed = decision_module_crossed;
        dynamics_and_results(index).motor_decision_made = motor_decision_made;
        dynamics_and_results(index).is_motor_correct = is_motor_correct;
        dynamics_and_results(index).movement_duration = movement_duration * dt;
        dynamics_and_results(index).initiation_time =  (initiation_time * dt) - stim_offset;
        dynamics_and_results(index).is_motor_com = is_motor_com;
        %%%%%%%%%%%
        
        %%%% Clear vars before next trial
        clearvars -except dynamics_and_results k i dt trial_length stim_onset...
            stim_duration stim_offset decision_module_threshold ...
            motor_preparation_module_threshold motor_target_threshold ...
            hand_module_delay mc_module_delay click_delay ...
            coh n_of_trials tStart filename coherences  ...
            index across_trial_effect no_of_blocks ...
            x_gather saving_mode decision_module_crossed_hand
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
    initiation_time]= ...
    nonlinear_decision_module_and_mc_integrate(coh,decision_module_threshold)

global dt; global trial_length; global stim_onset;
global stim_offset; global stim_duration;

stim_onset =  randi([700 1000]);
stim_offset = stim_duration+stim_onset;
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

gain_mc_lu = 1;     % Gain of input-output function (cf. Wong & Wang, 2006)
tau_mc_lu = 150;    % Membrane time constant (cf. Wilson and Cowan, 1972)

j0_mc_hu = 0.002;   % (excitation) Coupling constant from HU to SM module
j_mc_dec_lu = 10;    % Coupling from decision module to excitatory mc
j_self_mc = 0;      % Self excitation constant for MC.
%%%%%%%%%%%%


% Initialise state vectors with zeros (for better performance)
y_mc_lu = zeros(1,trial_length);
initiation_time = 0;
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
%     JN11 = 0.2440182353; JN22 = 0.2440182353;
    JN11 = 0.248; JN22 = 0.248;
%     JN11 = 0.2609; JN22 = 0.2609;
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
     
        initiation_time = t;
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%MC MODULE INTEGRATE:
    % Conditional gating
%     if(t>(stim_offset+100)/dt && ~decision_module_crossed_again)
%     if(t>(stim_onset+700)/dt && t<(stim_onset+800)/dt)
    hu_top_down_inhibition = ((stim_onset+600)/dt>t) * 1000;
    
    %         custom_top_down_inhibition = (((delayed-400)>response_time) && (response_time~=0)) * 3000;
    % %
    custom_top_down_inhibition = (decision_module_crossed) * 3000;    
    % Total input coming in to MC population (LU and HU)
    i_lu_total = gain_mc_lu * (j_mc_dec_lu * (y_1(t) +...
        y_2(t)) + j_self_mc * y_mc_lu(t)) - hu_top_down_inhibition - custom_top_down_inhibition;


    % Input-Output function
    f_i_mc_lu = heaviside(i_lu_total) *  i_lu_total;

    % Dynamical equations.
    y_mc_lu(t+1) = y_mc_lu(t) + (dt/tau_mc_lu) * ...
        (-y_mc_lu(t) +f_i_mc_lu);
    %%%%%%%%%%%%%%%%%%%%%%%%%%MC MODULE INTEGRATE END

%     end
    
end
return;

end

function [y_5,y_6] =  hand_module_integrate(y_7,y_8,initiation_time)

global dt; global trial_length;


if(initiation_time==0)
    y_5=[];
    y_6=[];
    return;
end

j_dec_hand = 1.5;     % Coupling strength from decision module to hand module
hand_inhibition = 1;% Inhibition strength
j_self_hand = 0;    % Self excitation strength
tau_hand = 50;      % Coupling constant for hand
gain_hand = 1;      % Gain of input-output function

% Initialise state vectors with zeros (for better performance)
y_5 = zeros(1,trial_length);
y_6 = zeros(1,trial_length);


% Single trial loop start
for t=1:trial_length-1
    
    %TODO:Check this
    if(t>initiation_time)
        % Total input coming in to left hand neural population
        i5_total = gain_hand * (-hand_inhibition * y_6(t) + j_self_hand ...
            * y_5(t) + j_dec_hand* y_7(t)) ;
        
        % Input-output function
        f_i5_total = heaviside(i5_total) * i5_total;
        
        % Dynamical equation for left hand neural population
        y_5(t+1) = y_5(t) + ((dt/tau_hand) * (-y_5(t) + f_i5_total));
        
        
        % Total input coming in to left hand neural population
        i6_total = gain_hand* (-hand_inhibition * y_5(t)+ j_self_hand ...
            * y_6(t) + j_dec_hand * y_8(t)) ;
        
        
        f_i6_total = heaviside(i6_total) * i6_total;
        
        
        % Dynamical equation for left hand neural population
        y_6(t+1) = y_6(t) + ((dt/tau_hand) * (-y_6(t) + f_i6_total));
    end
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

function [is_motor_com] = check_com(y_5,y_6,motor_decision_made,motor_target_threshold)
global trial_length;

is_motor_com = false;
if(~motor_decision_made)
    return;
end
x_traj = y_5-y_6;

smoothed_trajectory = filter(ones(1,50)/50,1,x_traj);

% smoothed_trajectory = x_traj;
delta_of_trajectory = diff(sign(smoothed_trajectory));

points_of_change = find(delta_of_trajectory);

if(size(points_of_change,2)<2)
    return;
end


%take the last two points of change. 
point_of_change = points_of_change(end);

for i = point_of_change:trial_length-1
    if(y_5(i)>=motor_target_threshold || y_6(i)>=motor_target_threshold)
        is_motor_com = true;
        break;
    end
end


% if(is_motor_com)
%     it_is_really_com = false;
%     firing_rate_threshold_com = 2;
%     for i=size(points_of_change,2):-1:2
%         if(max(smoothed_trajectory(points_of_change(i-1):points_of_change(i)))>0)
%             sign_of_response = sign(smoothed_trajectory(((movement_duration*dt) + (initiation_time*dt) + stim_duration+ stim_onset)/dt));
%             sign_of_max_point_in_bump =  sign(max(smoothed_trajectory(points_of_change(i-1):points_of_change(i))));
%   
%             if(sign_of_response *  sign_of_max_point_in_bump == -1)
%                 if(max(abs(smoothed_trajectory(points_of_change(i-1):points_of_change(i))))>firing_rate_threshold_com)
%                     it_is_really_com=true;
%                 end     
%             end
%             
%         end
%         is_motor_com = it_is_really_com;
%     end
% end

end

