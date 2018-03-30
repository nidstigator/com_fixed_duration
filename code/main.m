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
decision_module_threshold = 35.5;
motor_preparation_module_threshold = 37.5;
motor_preparation_module_threshold_eye = 33;
motor_target_threshold = 40;
%%%%%%%%%%%%%%%%%%%%%%

%%%%%Delays:
hand_module_delay=1;
eye_module_delay=180;
mc_module_delay=100;
click_delay=35;
%%%%%

prompt = 'Enter 1 for text output mode (for python scripts), 0 for normal mode:\n';
saving_mode = logical(input(prompt));

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


if(saving_mode)
    psychophyiscs_dynamics = repmat(struct('subj_id',0,'session_no',0,...
        'block_no',0,'trial_no',0,'timestamp',0,'mouse_x',0,...
        'mouse_y',0,'eye_x',0,'eye_y',0,...
        'pupil_size',0), 1*(trial_length-1), 1);
    
    psychophyiscs_raw_choices = repmat(struct('subj_id',0,'session_no',0,...
        'block_no',0,'trial_no',0,'is_practice',false,'direction',0,...
        'coherence',0,'duration',800,'response',0,...
        'response_time',0), 1*size(coherences,2), 1);
    
    dynamics= ['../data/txt_format' filename '_dynamics.txt'];
    choices= ['../data/txt_format'  filename '_choices.txt'];
    fid_choices = fopen(choices,'W');
    fid_dynamics = fopen(dynamics,'W');
    
    field_ns = fieldnames(psychophyiscs_raw_choices);
    
    C = field_ns{1};
    for i =2:size(field_ns,1)
        C= [C, ',',field_ns{i}];
    end
    
    fprintf(fid_choices,C);
    fprintf(fid_choices,'\n');
    
    
    
    field_ns_dynamics = fieldnames(psychophyiscs_dynamics);
    
    C = field_ns_dynamics{1};
    for i =2:size(field_ns_dynamics,1)
        C= [C, ',',field_ns_dynamics{i}];
    end
    
    fprintf(fid_dynamics,C);
    fprintf(fid_dynamics,'\n');
    row2 = strings(trial_length-1,1);
    row = strings(n_of_trials,1);

else
    dynamics_and_results = repmat(struct('block_no',0,'block_size',0,...
        'trial_no',0,'coherence_level',0,'timestep_size',0,'trial_length',0,...
        'stim_onset',0,'stim_duration',0,'stim_offset',0,...
        'y_1',[],'y_2',[],'y_3',[],'y_4',[],'s_1',[],'s_2',[],'y_5',[],'y_6',[],...
        'y_7',[],'y_8',[],'y_mc_hu',[], 'y_mc_lu',[], ...
        'decision_module_threshold',0,...
        'motor_target_threshold',0,'motor_maximum_value_left',0,...
        'motor_maximum_value_right',0,'hand_module_delay',0,...
        'mc_module_delay',0,'click_delay',0,'decision_module_crossed',false,...
        'is_motor_correct',false,...
        'initation_time',0,'eye_initiation_time',0,'internal_response_time',0,'hand_response_time',0,...
        'movement_duration',0,...
        'is_motor_com',false,'is_late_com',false,'motor_decision_made',false,...
        'com_initiation_point_hand',0,'com_initiation_point_eye',0)...
        , n_of_trials*size(coherences,2), 1);
    
end

% coherences for loop
index = 0;
no_of_blocks = size(coherences,2);

for k = 1: no_of_blocks
    coh = coherences(k);
    % Trials for loop.
    for i = 1:n_of_trials
        
        index = index+1;
        
        [y_1,y_2,s1,s2,y_mc_hu,y_mc_lu,decision_module_crossed,...
            internal_response_time, energy] = nonlinear_decision_module_and_mc_integrate...
            (coh,decision_module_threshold,mc_module_delay);
        
        [y_7, y_8, motor_preparation_crossed, initiation_time, initiation_time_eye] = ...
            nonlinear_motor_decision_integrate(s1,s2,internal_response_time,decision_module_crossed,motor_preparation_module_threshold,motor_preparation_module_threshold_eye);
        
        
        [y_3, y_4] = ...
            eye_module_integrate(y_7,y_8,initiation_time_eye,eye_module_delay);
        
        
        [y_5,y_6] = ...
            hand_module_integrate(y_7,y_8,initiation_time,hand_module_delay);
        
        
        % Set these values in case functions don't execute due to
        % nondecision
        motor_decision_made=false;
        movement_duration = 0;
        is_motor_correct = false;
        is_motor_com = false;
        is_late_com = false;
        %%%%%%%%%%
        if(~(isempty(y_5) || isempty(y_6)))
            [is_motor_correct, motor_decision_made, movement_duration, total_response_time] = ...
                check_if_motor_target_reached...
                (y_5,y_6,hand_module_delay,click_delay,...
                motor_target_threshold,initiation_time);
            
            [is_motor_com,is_late_com, com_initiation_point_hand, com_initiation_point_eye] = ...
                check_com(y_5,y_6,y_4,y_3,motor_decision_made,motor_target_threshold,is_motor_correct);
        end
        %%%% Save in struct:
        if(saving_mode)
            if(is_motor_correct)
                row(i,1) = [num2str(1),',',num2str(1),',',num2str(1), ',',num2str(index) ...
                    ,',','FALSE',',',num2str(0),',',num2str(coh/100),',', ...
                    num2str(800),',',num2str(0),',',num2str(total_response_time*dt)];
            else
                row(i,1) = [num2str(1),',',num2str(1),',',num2str(1), ',',num2str(index) ...
                    ,',','FALSE',',',num2str(0),',',num2str(coh/100),',', ...
                    num2str(800),',',num2str(180),',',num2str(total_response_time*dt)];
            end
            
            
            timestamp=1;
            for h=1:2:trial_length-1
                
                row2(timestamp,1) = [num2str(1),',',num2str(1),',',num2str(1), ',',num2str(index) ...
                    ,',',num2str(timestamp),',',num2str((y_5(timestamp)-y_6(timestamp)) * 27),',',num2str(0),',' ...
                    ,num2str((y_3(timestamp)-y_4(timestamp)) * 27),',',num2str(0),',',num2str(0)];
                timestamp = timestamp+1;
            end
            
            
            fprintf(fid_dynamics,'%s\n', row2(1:end));
                    %%%% Clear vars before next trial
        clearvars -except k i dt trial_length stim_onset...
            stim_duration stim_offset decision_module_threshold ...
            motor_preparation_module_threshold motor_target_threshold ...
            hand_module_delay mc_module_delay click_delay ...
            coh n_of_trials tStart filename coherences  ...
            index across_trial_effect no_of_blocks eye_module_delay...
            x_gather motor_preparation_module_threshold_eye psychophyiscs_dynamics ...
            psychophyiscs_raw_choices field_ns row2 row ...
            field_ns_dynamics fid_choices fid_dynamics saving_mode
        %%%%    
        else
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
            dynamics_and_results(index).y_7=y_7;
            dynamics_and_results(index).y_8=y_8;
            dynamics_and_results(index).y_mc_hu=y_mc_hu;
            dynamics_and_results(index).y_mc_lu=y_mc_lu;
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
            dynamics_and_results(index).internal_response_time = internal_response_time * dt;
            dynamics_and_results(index).eye_initiation_time= (initiation_time_eye * dt) - stim_offset;
            dynamics_and_results(index).initiation_time =  (initiation_time * dt) - stim_offset;
            dynamics_and_results(index).hand_response_time = total_response_time * dt;
            dynamics_and_results(index).is_motor_com = is_motor_com;
            dynamics_and_results(index).is_late_com= is_late_com;
            dynamics_and_results(index).hand_module_delay= hand_module_delay;
            dynamics_and_results(index).click_delay= click_delay;
            dynamics_and_results(index).mc_module_delay= mc_module_delay;
            
            %%%%%%%%%%%
            
            %%%% Clear vars before next trial
            clearvars -except dynamics_and_results k i dt trial_length stim_onset...
                stim_duration stim_offset decision_module_threshold ...
                motor_preparation_module_threshold motor_target_threshold ...
                hand_module_delay mc_module_delay click_delay ...
                coh n_of_trials tStart filename coherences  ...
                index across_trial_effect no_of_blocks eye_module_delay...
                x_gather motor_preparation_module_threshold_eye saving_mode
            %%%%
            
        end
        
    end
    if(saving_mode)
        fprintf(fid_choices,'%s\n', row(1:end));
    end
    
end
if(saving_mode)
    fclose(fid_dynamics);
    fclose(fid_choices);
end
clearvars -except dynamics_and_results tStart filename

tElapsed=toc(tStart);

fprintf('Time taken to run this: %f \n',tElapsed)

clearvars tStart tElapsed;

%old save function doesn't work with large variables.
%save(filename,'-v7.3');

function [y_1,y_2,s1,s2,y_mc_hu,y_mc_lu,decision_module_crossed,internal_response_time, energy] = nonlinear_decision_module_and_mc_integrate(coh,decision_module_threshold,mc_module_delay)

global dt; global trial_length; global stim_onset;
global stim_offset;

%%%%%%%%%%%% DECISION PARAMETERS
%%%% Synaptic time and other constants


tnmda = 100;    % NMDAr
tampa = 2;      % AMPAr
gamma = 0.641;  % Gamma

% FI curve parameters

a = 270; b = 108; d = 0.1540;  % Parameters for excitatory cells

% Parameters to be varied

mu0       = 30.0;      % External stimulus strength
noise_amp = 0.02;      % Noise amplitude into selective populations


%---- Initial conditions and clearing variables -----------
s1_in=0.1; s2_in=0.1;
I_eta1_in = noise_amp*randn ; I_eta2_in = noise_amp*randn ;


% Intialise and vectorise variables to be used in loops below

s1 = s1_in.*ones(1,trial_length); s2 = s2_in.*ones(1,trial_length);
I_eta1 = I_eta1_in.*ones(1,trial_length);
I_eta2 = I_eta2_in.*ones(1,trial_length);
%%%%%%%%%%%%

%%%%%%%%%%%% MC PARAMETERS:

gain_mc_hu = 1;     % Gain of input-output function (cf. Wong & Wang, 2006)
tau_mc_hu = 150;    % Membrane time constant (cf. Wilson and Cowan, 1972)
gain_mc_lu = 1;     % Gain of input-output function (cf. Wong & Wang, 2006)
tau_mc_lu = 150;    % Membrane time constant (cf. Wilson and Cowan, 1972)

j0_mc_hu = 0.002;   % (excitation) Coupling constant from HU to eye module
j_mc_dec_lu = 1;    % Coupling from decision module to excitatory mc
constant_input= 30; % Constant input used for HU I-O function.
inhibition_lu = 0.5;% Inhibition from LU to HU neural population
j_self_mc = 0;      % Self excitation constant for MC.
delayed = 100;
orig_time = 1;      % Initialise time used for decision module
%%%%%%%%%%%%

% Initialise state vectors with zeros (for better performance)
y_1 = zeros(1,trial_length);
y_2 = zeros(1,trial_length);
% Initialise state vectors with zeros (for better performance)
y_mc_lu = zeros(1,trial_length);
y_mc_hu = zeros(1,trial_length);

Isyn1 = zeros(1,trial_length);
Isyn2 = zeros(1,trial_length);

motor_preparation = 0;
decision_module_crossed = false;
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
    JN11 = 0.2609; JN22 = 0.2609;
    JN12 = 0.0497; JN21 = 0.0497;
    
    % Resonse function of competiting excitatory population 1
    Isyn1(t) = JN11 .* s1(t) - JN12 .* s2(t) + I0E1 + I_stim_1 ...
        + I_eta1(t)+ (j0_mc_hu * y_mc_hu(delayed));
    %
    %     Isyn1(t) = JN11 .* s1(t) - JN12 .* s2(t) + I0E1 + I_stim_1 ...
    %         + I_eta1(t)+ (j0_mc_hu * threshold(delayed));
    %
    y_1(t)  = (a .* Isyn1(t) - b) ./ (1 ...
        - exp(-d .* (a .* Isyn1(t)-b)));
    
    % Response function of competiting excitatory population 2
    Isyn2(t) = JN22 .* s2(t) - JN21 .* s1(t) + I0E2 + I_stim_2 ...
        + I_eta2(t) + (j0_mc_hu * y_mc_hu(delayed));
    
    %     Isyn2(t) = JN22 .* s2(t) - JN21 .* s1(t) + I0E2 + I_stim_2 ...
    %         + I_eta2(t) + (j0_mc_hu * threshold(delayed));
    %
    y_2(t)  = (a .* Isyn2(t) - b) ./ (1 ...
        - exp(-d.*(a.*Isyn2(t)-b)));
    
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
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%MC MODULE INTEGRATE:
    if(t>mc_module_delay)
        
        % Conditional inhibitory control.
        lu_top_down_inhibition = ((stim_offset - 500)/dt>delayed) * 1000;
        hu_top_down_inhibition = ((stim_offset - 600)/dt>delayed) * 1000;
        
        custom_top_down_inhibition = (delayed>=1850/dt) * 3000;
        
        % Total input coming in to MC population (LU and HU)
        i_hu_total = gain_mc_hu * (constant_input - ...
            inhibition_lu * y_mc_lu(delayed)) - lu_top_down_inhibition - custom_top_down_inhibition;
        
        i_lu_total = gain_mc_lu * (j_mc_dec_lu * (y_1(orig_time) +...
            y_2(orig_time)) + j_self_mc * y_mc_lu(delayed)) - hu_top_down_inhibition;
        
        % Input-Output function
        f_i_mc_hu = heaviside(i_hu_total) *  i_hu_total;
        f_i_mc_lu = heaviside(i_lu_total) *  i_lu_total;
        
        % Dynamical equations.
        y_mc_hu(delayed+1) = y_mc_hu(delayed) + (dt/tau_mc_hu) * ...
            (-y_mc_hu(delayed) +f_i_mc_hu);
        y_mc_lu(delayed+1) = y_mc_lu(delayed) + (dt/tau_mc_lu) * ...
            (-y_mc_lu(delayed) +f_i_mc_lu);
        
        delayed = delayed+1;
    end
    orig_time = orig_time+1;
end

internal_response_time = stim_offset/dt;
energy = mean(y_mc_hu(1,(stim_onset/dt):motor_preparation));
%energy = trapz(y_mc_hu);
return;

end % Function end

function [y_7, y_8, motor_preparation_crossed, initiation_time, initiation_time_eye] =  nonlinear_motor_decision_integrate (s_1,s_2,internal_response_time,decision_module_crossed,motor_preparation_module_threshold,motor_preparation_module_threshold_eye)

global dt; global trial_length;
global stim_offset;

if(~decision_module_crossed)
    initiation_time=0;
    motor_preparation_crossed=0;
    y_8=[];
    y_7=[];
    return;
end

%%%%%%%%%%%% DECISION PARAMETERS
%%%% Synaptic time and other constants

tnmda = 100;    % NMDAr
tampa = 2;      % AMPAr
gamma = 0.641;  % Gamma

% FI curve parameters

a = 270; b = 108; d = 0.1540;  % Parameters for excitatory cells

% Parameters to be varied
noise_amp = 0.02;      % Noise amplitude into selective populations


%---- Initial conditions and clearing variables -----------
s1_in=0.1; s2_in=0.1;
I_eta1_in = noise_amp*randn ; I_eta2_in = noise_amp*randn ;


% Intialise and vectorise variables to be used in loops below

s1 = s1_in.*ones(1,trial_length); s2 = s2_in.*ones(1,trial_length);
I_eta1 = I_eta1_in.*ones(1,trial_length);
I_eta2 = I_eta2_in.*ones(1,trial_length);

%%%%%%%%%%%%

%Constant effective external current input
I0E1 = 0.3255; I0E2 = 0.3255;

% Recurrent synaptic coupling constants
JN11 = 0.2609; JN22 = 0.2609;
JN12 = 0.0497; JN21 = 0.0497;

JVM = 0.09;

% Initialise state vectors with zeros (for better performance)
y_7 = zeros(1,trial_length);
y_8 = zeros(1,trial_length);

Isyn1= zeros(1,trial_length);
Isyn2= zeros(1,trial_length);

initiation_time = 0;
initiation_time_eye = 0;
motor_preparation_crossed=false;
motor_preparation_crossed_eye=false;
for t=1:trial_length-1
    if(t>internal_response_time)
        % Resonse function of competiting excitatory population 1
        Isyn1(t) = JN11 .* s1(t) - JN12 .* s2(t) + I0E1 ...
            + I_eta1(t) + JVM * s_1(t);
        
        y_7(t)  = (a .* Isyn1(t) - b) ./ (1 ...
            - exp(-d .* (a .* Isyn1(t)-b)));
        
        % Response function of competiting excitatory population 2
        Isyn2(t) = JN22 .* s2(t) - JN21 .* s1(t) + I0E2 ...
            + I_eta2(t) + JVM * s_2(t);
        
        y_8(t)  = (a .* Isyn2(t) - b) ./ (1 ...
            - exp(-d.*(a.*Isyn2(t)-b)));
        
        % Dynamical equations
        
        % Mean NMDA-receptor dynamics
        s1(t+1) = s1(t) + dt * (-(s1(t)/tnmda) ...
            + (1 - s1(t)) * gamma * y_7(t)/1000);
        s2(t+1) = s2(t) + dt*(-(s2(t)/tnmda) ...
            + (1 - s2(t)) * gamma * y_8(t)/1000);
        
        % Noise through synaptic currents of pop1 and 2
        I_eta1(t+1) = I_eta1(t) + (dt/tampa) * (-I_eta1(t))...
            + sqrt(dt/tampa) * noise_amp*randn ;
        I_eta2(t+1) = I_eta2(t) + (dt/tampa) * (-I_eta2(t))...
            + sqrt(dt/tampa) * noise_amp*randn ;
        
        % To ensure firing rates are always positive
        if (y_7(t) < 0 )
            y_7(t) = 0;
        end
        if (y_8(t) < 0)
            y_8(t) = 0;
        end
        if(t>stim_offset/dt && ~motor_preparation_crossed_eye)
            if(y_7(t)>=motor_preparation_module_threshold_eye || y_8(t)>=motor_preparation_module_threshold_eye)
                initiation_time_eye = t;
                motor_preparation_crossed_eye = true;
            end
        end
        %Motor Preparation module threshold crossing check
        if(t>stim_offset/dt && ~motor_preparation_crossed)
            if(y_7(t)>=motor_preparation_module_threshold || y_8(t)>=motor_preparation_module_threshold)
                initiation_time = t;
                motor_preparation_crossed = true;
            end
        end
        
    end
end

return;

end % Function end


function [y_3,y_4] =  eye_module_integrate(y_7,y_8,initiation_time,eye_module_delay)

global dt; global trial_length;


j_dec_eye = 1.5;        % Coupling strength from decision module to eye module
eye_inhibition = 1;   % Inhibition strength
j_self_eye = 0;        % Self excitation strength
tau_eye = 20;          % Coupling constant for eye
gain_eye = 1;          % Gain of input-output function

orig_time = 1;          % Initialise time used for decision module


% Initialise state vectors with zeros (for better performance)
y_3 = zeros(1,trial_length);
y_4 = zeros(1,trial_length);


% Single trial loop start
for t=eye_module_delay:trial_length-1
    
    %TODO:Check this
    inhibitory_control = (t<initiation_time) * 5000 ;
    
    % Total input coming in to left eye neural population
    i3_total = gain_eye * (-eye_inhibition * y_4(t) + j_self_eye ...
        * y_3(t) + j_dec_eye* y_7(orig_time)) - inhibitory_control;
    
    % Input-output function
    f_i3_total = heaviside(i3_total) * i3_total;
    
    
    % Dynamical equation for left eye neural population
    y_3(t+1) = y_3(t) + ((dt/tau_eye) * (-y_3(t) + f_i3_total));
    
    % Total input coming in to left eye neural population
    i4_total = gain_eye* (-eye_inhibition * y_3(t)+ j_self_eye ...
        * y_4(t) + j_dec_eye * y_8(orig_time)) - inhibitory_control;
    
    
    % Input-output function
    f_i4_total = heaviside(i4_total) * i4_total;
    
    
    % Dynamical equation for left eye neural population
    y_4(t+1) = y_4(t) + ((dt/tau_eye) * (-y_4(t) + f_i4_total));
    
    orig_time = orig_time +1; % Increment time for decision module
    
end % Single trial loop end

return;



end % Function end

function [y_5,y_6] =  hand_module_integrate(y_7,y_8,initiation_time,hand_module_delay)

global dt; global trial_length;



j_dec_hand = 1.5;     % Coupling strength from decision module to eye module
hand_inhibition = 1;% Inhibition strength
j_self_hand = 0;    % Self excitation strength
tau_hand = 50;      % Coupling constant for eye
gain_hand = 1;      % Gain of input-output function

orig_time = 1; % Initialise time used for decision module

% Initialise state vectors with zeros (for better performance)
y_5 = zeros(1,trial_length);
y_6 = zeros(1,trial_length);


% Single trial loop start
for t=hand_module_delay:trial_length-1
    
    %TODO:Check this
    inhibitory_control = (t<initiation_time) * 5000;
    
    % Total input coming in to left eye neural population
    i5_total = gain_hand * (-hand_inhibition * y_6(t) + j_self_hand ...
        * y_5(t) + j_dec_hand* y_7(orig_time)) - inhibitory_control;
    
    % Input-output function
    f_i5_total = heaviside(i5_total) * i5_total;
    
    % Dynamical equation for left eye neural population
    y_5(t+1) = y_5(t) + ((dt/tau_hand) * (-y_5(t) + f_i5_total));
    
    
    % Total input coming in to left eye neural population
    i6_total = gain_hand* (-hand_inhibition * y_5(t)+ j_self_hand ...
        * y_6(t) + j_dec_hand * y_8(orig_time)) - inhibitory_control;
    
    
    f_i6_total = heaviside(i6_total) * i6_total;
    
    
    % Dynamical equation for left eye neural population
    y_6(t+1) = y_6(t) + ((dt/tau_hand) * (-y_6(t) + f_i6_total));
    
    orig_time = orig_time +1; % Increment time for decision module
    
end % Single trial loop end

return;
end % Function end

function [is_motor_correct, motor_decision_made, movement_duration,total_response_time] =  check_if_motor_target_reached(y_5,y_6,hand_module_delay,click_delay,motor_target_threshold,initiation_time)

global stim_offset;
global dt;

motor_decision_made = false;
is_motor_correct = false;
movement_duration = hand_module_delay+click_delay;

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
    movement_duration = movement_duration+ right_reached-initiation_time - (stim_offset/dt);
elseif(left_reached > right_reached)
    motor_decision_made=true;
    movement_duration = movement_duration + left_reached-initiation_time - (stim_offset/dt);
end

total_response_time = movement_duration+(initiation_time - (stim_offset/dt));

return;
end

function [is_motor_com, is_late_com, com_initiation_point_hand, com_initiation_point_eye] = check_com(y_5,y_6,y_4,y_3,motor_decision_made,motor_target_threshold,is_motor_correct)

global trial_length;
global x_gather;

firing_rate_threshold_com= 3;
com_initiation_point_hand=0;
com_initiation_point_eye=0;
is_motor_com = false;
is_eye_com = false;

is_late_com = false;
if(~motor_decision_made)
    return;
end

x_traj_hand = y_5-y_6;


for i=2:trial_length-1
    if(is_motor_com)
        break;
    end
    previousSign = sign(x_traj_hand(i-1));
    currentSign = sign(x_traj_hand(i));
    if(currentSign * previousSign == -1 && abs(max(x_traj_hand(1:i)))>=firing_rate_threshold_com)
        potential_initiation_point=i;
        for j=i+1:trial_length-1
            previousSign2 = sign(x_traj_hand(j-1));
            currentSign2 = sign(x_traj_hand(j));
            if(currentSign2 * previousSign2 == -1)
                break;
            end
            if(abs(x_traj_hand(j))>=motor_target_threshold)
                com_initiation_point_hand=potential_initiation_point;
                is_motor_com = true;
                break;
            end
        end
    end
end

x_traj_eye = y_3-y_4;




for i=2:trial_length-1
    if(is_eye_com)
        break;
    end
    previousSign = sign(x_traj_eye(i-1));
    currentSign = sign(x_traj_eye(i));
    if(currentSign * previousSign == -1 && abs(max(x_traj_eye(1:i)))>=firing_rate_threshold_com)
        potential_initiation_point=i;
        for j=i+1:trial_length-1
            previousSign2 = sign(x_traj_eye(j-1));
            currentSign2 = sign(x_traj_eye(j));
            if(currentSign2 * previousSign2 == -1)
                break;
            end
            if(abs(x_traj_eye(j))>=motor_target_threshold)
                com_initiation_point_eye=potential_initiation_point;
                is_eye_com = true;
                break;
            end
        end
        
    end
end


if(is_motor_com && is_eye_com)
    com_initiation_point_hand - com_initiation_point_eye
end

if(is_motor_com ~= is_eye_com)
    com_initiation_point_hand=-1;
    com_initiation_point_eye=-1;
end

if(~is_motor_com)
    return;
end

%lag = com_initiation_point_hand - com_initiation_point_eye

left_reached = find(y_5>=motor_target_threshold,1);
right_reached = find(y_6>=motor_target_threshold,1);

if(isempty(left_reached))
    left_reached=0;
end

if(isempty(right_reached))
    right_reached=0;
end

if(is_motor_com && is_motor_correct && com_initiation_point_hand > left_reached && left_reached ~=0)
    is_late_com = true;
end

if(is_motor_com && ~is_motor_correct && com_initiation_point_hand > right_reached && right_reached ~=0)
    is_late_com = true;
end



end

function [c] =calculate_control_value(energy)
lambda = 0.5;
alpha =4.41;
beta = 1.08;

c=(lambda * energy) + (1-lambda)*((alpha*energy)+beta);
return;

end

