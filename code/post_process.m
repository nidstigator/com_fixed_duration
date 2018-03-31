% 
% %call functions to test:
close all;
% clearvars -except dynamics_and_results dynamics_and_results_2nddecision;

global legends;
global titles;
global export;
global figures_path;

figures_path = './figures/Fixed_duration/';

legends = true;
titles = false;
export = false;


is_first_correct= true;
normalised = true;

% calculate_eye_hand_lag(dynamics_and_results);

%calculate_reward_rate(dynamics_and_results);
% 
%plot_accuracies_and_pcom(dynamics_and_results,is_first_correct,normalised);
%plot_x_pattern(dynamics_and_results,normalised);
% %  
%plot_confidence_vs_accuracy(dynamics_and_results,normalised);


% coherences = get_coherence_levels(dynamics_and_results);
% for i=1:size(coherences,2)
% 
% coherence= coherences(i);
% 
% is_motor_correct = true;
% is_motor_com = false;
% 
% [y_1, y_2, y_3,y_4,y_mc_hu, y_mc_lu, y_5,...
%     y_6, y_7, y_8] = ...
%     calculate_mean_activity(dynamics_and_results, coherence, ...
%     is_motor_correct, is_motor_com);
% 
% is_single_trial = false;
% 
% y_1_averaged = calculate_time_window(y_1,100,10);
% y_2_averaged = calculate_time_window(y_2,100,10);
% 
% plot_main_panel(y_1,y_2,y_3,y_4,y_5,y_6,y_7,y_8,y_mc_hu,y_mc_lu,true,0)
% 
% end

is_motor_correct = true;
is_motor_com = false;

[y_1, y_2, y_3, y_4, y_mc_hu, y_mc_lu, y_5, y_6, y_7, y_8] = ...
    calculate_mean_activity(dynamics_and_results, 3.2, ...
    is_motor_correct, is_motor_com);

[y_1_25, y_2_25,y_3_25, y_4_25, y_mc_hu_25, y_mc_lu_25, y_5_25, y_6_25, y_7_25, y_8_25] = ...
    calculate_mean_activity(dynamics_and_results, 51.2, ...
    is_motor_correct, is_motor_com);

is_single_trial = false;


plot_main_panel_modified(dynamics_and_results,y_1,y_2,y_3,y_4,y_5,y_6,y_mc_hu,y_mc_lu,y_7,y_8,y_1_25,y_2_25,y_3_25,y_4_25,y_5_25,y_6_25,y_mc_hu_25,y_mc_lu_25, y_7_25, y_8_25)

%  
% any = false;
% is_motor_com = true;
% is_motor_correct = true;
% coherence=3.2;
% is_late_com = false;
% plot_random_trial(dynamics_and_results, coherence, any, is_motor_com, is_motor_correct,is_late_com)

% % coherences = get_coherence_levels(dynamics_and_results);
% % for i=1:size(coherences,2)
% %
% %     coherence= coherences(i);
% %     x_traj_com_correct_mean(1,:)= mean(gather_trajectories(dynamics_and_results,coherence, true, true));
% %     x_traj_com_incorrect_mean(1,:) = mean(gather_trajectories(dynamics_and_results,coherence, true, false));
% %     x_traj_noncom_correct_mean(1,:) = mean(gather_trajectories(dynamics_and_results,coherence, false, true));
% %     x_traj_noncom_incorrect_mean(1,:) = mean(gather_trajectories(dynamics_and_results,coherence, false, false));
% %     plot_trajectory(x_traj_com_correct_mean, coherence, false, true, true);
% %     plot_trajectory(x_traj_com_incorrect_mean, coherence, false, true, false);
% %     plot_trajectory(x_traj_noncom_correct_mean, coherence, false, false, true);
% %     plot_trajectory(x_traj_noncom_incorrect_mean, coherence, false, false, false);
% % end
% 
% % coherence = 0;
% % is_motor_correct = true;
% % all_com = false;
% % is_motor_com = true;
% % is_late_com = false;
% % 
% % 
% % com_correct_gather= gather_trajectories(dynamics_and_results,coherence,...
% %     is_motor_com, is_motor_correct,all_com, is_late_com);
% % 
% % plot_all_trajectories(com_correct_gather,0,is_motor_com,is_motor_correct);
% % 

%% plotting functions

function plot_confidence_vs_accuracy(dynamics_and_results, normalised)

global legends;
global titles;
global export;
global figures_path;
coherences = get_coherence_levels(dynamics_and_results);
n_of_coherences= size(coherences,2);

x_correct_max = zeros(1,n_of_coherences);
x_incorrect_max = zeros(1,n_of_coherences);

x_correct_max_std = zeros(1,n_of_coherences);
x_incorrect_max_std = zeros(1,n_of_coherences);

x_correct_integral = zeros(1,n_of_coherences);
x_incorrect_integral = zeros(1,n_of_coherences);

is_motor_com= false;

for i=1:n_of_coherences
    coherence = coherences(i);
    [x_correct_max(i), ~, x_correct_max_std(i), ~,...
        x_correct_integral(i), ~] = ...
        calculate_x_pattern(dynamics_and_results, coherence, is_motor_com, true);
    
    [x_incorrect_max(i), ~, x_incorrect_max_std(i), ~,...
        x_incorrect_integral(i), ~] = ...
        calculate_x_pattern(dynamics_and_results, coherence, is_motor_com, false);
end

confidence_max(1,:)= nanmean([x_correct_max; x_incorrect_max]);
confidence_std(1,:) = nanmean([x_correct_max_std; x_incorrect_max_std]);

confidence_integral(1,:) = nanmean([x_correct_integral;x_incorrect_integral]);


if(normalised)
    confidence_max = normalise_custom(confidence_max,max(confidence_max),min(confidence_max));  
    confidence_integral = normalise_custom(confidence_integral,max(confidence_integral), min(confidence_integral));
end
%%%%%%%%Plot1: Accuracy v.s Uncertainty using Peak.

title_string = 'Uncertainty v.s coherence level using peak value';
y_string = 'Peak firing rate of mean HU activity (Hz)';

if(normalised)
    title_string = 'Uncertainty v.s coherence level using peak value (Normalised)';
    y_string= 'Normalised Peak firing rate of mean HU activity (Hz)';
end
figure1=figure;
axes1 = axes('Parent',figure1);
hold on;
if(normalised)
    plot(confidence_max, 'LineWidth', 2,'DisplayName',...
        'uncertainty','Color',[0 0 1])
else
    errorbar(confidence_max,confidence_std, 'LineWidth', 2,'DisplayName',...
        'uncertainty','Color',[0 0 1])
end
xlim(axes1,[1 6]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

ylabel(y_string);
xlabel(['Coherence level (c %)']);
pubgraph(figure1,18,4,'w')
if(legends)
    %legend('show');
end
if(titles)
    title(title_string);
end

if(export)
export_path = [figures_path 'uncertaintyvscoherence_peak' ];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end
%%%%%%%%

%%%%%%%%Plot2: Uncertainty v.s Coherence using Integral

title_string = 'Uncertainty v.s coherence level using area under Curve of HU Activity';
y_string='Area under the curve of mean HU activity';

figure2=figure;
axes1 = axes('Parent',figure2);
hold on;

plot(confidence_integral, 'LineWidth', 2,'DisplayName',...
    'uncertainty','Color',[0 0 1])

xlim(axes1,[1 6]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

ylabel(y_string);
xlabel(['Coherence level (c %)']);
pubgraph(figure2,18,4,'w')
if(legends)
    %legend('show');
end
if(titles)
    title(title_string);
end

if(export)
export_path = [figures_path  'uncertaintyvscoherence_integral'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

end

function plot_trajectory(x_traj,coherence,is_single_trial,is_motor_com, is_motor_correct)
global legends;
global titles;
global export;
global figures_path;
correct = ' Incorrect';
com = ' Non CoM';

if(is_motor_correct)
    correct = ' Correct';
end

if(is_motor_com)
    com = ' CoM';
end

if(is_single_trial)
    title_string = ['X-Trajectory' sprintf('- Single trial %s %s c`=: %0.1f',correct, com, coherence)];
else
    title_string = ['X-Trajectory' sprintf('- Mean %s %s c`=: %0.1f',correct, com, coherence)];
end
figure;
hold on;
plot(x_traj(1:2:end));
xlabel('Time (ms)');
ylabel('Difference in firing rate (Hz)');
if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end

pubgraph(gcf,18,4,'w')
if(export)
export_path = [figures_path  title_string];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

end

function plot_all_trajectories(x_traj,coherence,is_motor_com,is_motor_correct)
global legends;
global titles;
global export;
global figures_path;
correct = ' Incorrect';
com = ' Non CoM';

if(is_motor_correct)
    correct = ' Correct';
end

if(is_motor_com)
    com = ' CoM';
end

title_string = ['X-Trajectory' sprintf('- %d %s %s Trajectories c`=: %0.1f',size(x_traj,1),correct, com, coherence)];

figure;
hold on;
for i=1:size(x_traj,1)
    plot(x_traj(i,(1:2:end)));
end
xlabel('Time (ms)');
ylabel('Hand Position (X)');

if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end


pubgraph(gcf,18,4,'w')
if(export)
export_path = [figures_path  title_string];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

end

function plot_random_trial(dynamics_and_results, coherence, any, is_motor_com, is_motor_correct,is_late_com)

coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

counter = 0;
%get number of each type, before initialising vectors.


for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com && dynamics_and_results(i).is_late_com == is_late_com)
        counter = counter+1;
    end
end

indecies = zeros(1,counter);
j=1;

if(any)
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == coherence)
            indecies(j) = i;
            j=j+1;
        end
    end
else
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == coherence &&...
                dynamics_and_results(i).is_motor_correct == is_motor_correct...
                && dynamics_and_results(i).is_motor_com == is_motor_com && dynamics_and_results(i).is_late_com ==is_late_com)
            indecies(j) = i;
            j=j+1;
        end
    end
end

%pick a random element

index_to_plot= indecies(randi(numel(indecies)));

y_1 = dynamics_and_results(index_to_plot).y_1;
y_2 = dynamics_and_results(index_to_plot).y_2;
y_mc_hu = dynamics_and_results(index_to_plot).y_mc_hu;
y_mc_lu = dynamics_and_results(index_to_plot).y_mc_lu;
y_3 = dynamics_and_results(index_to_plot).y_3;
y_4 = dynamics_and_results(index_to_plot).y_4;
y_5 = dynamics_and_results(index_to_plot).y_5;
y_6 = dynamics_and_results(index_to_plot).y_6;
y_7 = dynamics_and_results(index_to_plot).y_7;
y_8 = dynamics_and_results(index_to_plot).y_8;

y_1_averaged = calculate_time_window(y_1,100,10);
y_2_averaged = calculate_time_window(y_2,100,10);

plot_main_panel(y_1,y_2,y_3,y_4,y_5,y_6,y_7,y_8,y_mc_hu,y_mc_lu,true,coherence);

plot_time_window(dynamics_and_results, index_to_plot, y_1_averaged,y_2_averaged,100,10);



end

function plot_x_pattern(dynamics_and_results,normalised)

global legends;
global titles;
global export;

global figures_path;
coherences = get_coherence_levels(dynamics_and_results);
n_of_coherences= size(coherences,2);

x_correct_max = zeros(1,n_of_coherences);
x_incorrect_max = zeros(1,n_of_coherences);
x_correct_max_std = zeros(1,n_of_coherences);
x_incorrect_max_std = zeros(1,n_of_coherences);

x_correct_integral = zeros(1,n_of_coherences);
x_correct_integral_std = zeros(1,n_of_coherences);
x_incorrect_integral = zeros(1,n_of_coherences);
x_incorrect_integral_std = zeros(1,n_of_coherences);

x_correct_max_lu = zeros(1,n_of_coherences);
x_incorrect_max_lu = zeros(1,n_of_coherences);
x_correct_max_lu_std = zeros(1,n_of_coherences);
x_incorrect_max_lu_std = zeros(1,n_of_coherences);

x_correct_integral_lu = zeros(1,n_of_coherences);
x_correct_integral_lu_std = zeros(1,n_of_coherences);
x_incorrect_integral_lu = zeros(1,n_of_coherences);
x_incorrect_integral_lu_std = zeros(1,n_of_coherences);

is_motor_com= false;

for i=1:n_of_coherences
    coherence = coherences(i);
    [x_correct_max(i), x_correct_max_lu(i), x_correct_max_std(i), x_correct_max_lu_std(i),...
        x_correct_integral(i), x_correct_integral_std(i), x_correct_integral_lu(i), x_correct_integral_lu_std(i)] = ...
        calculate_x_pattern(dynamics_and_results, coherence, is_motor_com, true);
        
    [x_incorrect_max(i), x_incorrect_max_lu(i), x_incorrect_max_std(i), x_incorrect_max_lu_std(i),...
        x_incorrect_integral(i),x_incorrect_integral_std(i), x_incorrect_integral_lu(i), x_incorrect_integral_lu_std(i)] = ...
        calculate_x_pattern(dynamics_and_results, coherence, is_motor_com, false);
end

%%%% HU stuff:
x_max_all = [x_correct_max,x_incorrect_max];
max_bound_peak = max(x_max_all);
min_bound_peak = min(x_max_all);

integral_all = [x_correct_integral,x_incorrect_integral];
max_bound_integral = max(integral_all);
min_bound_integral = min(integral_all);

x_correct_max = normalise_custom(x_correct_max,max_bound_peak,min_bound_peak);
x_correct_max_std = normalise_std(x_correct_max_std,max_bound_peak,min_bound_peak);

x_incorrect_max = normalise_custom(x_incorrect_max,max_bound_peak,min_bound_peak);
x_incorrect_max_std = normalise_std(x_incorrect_max_std,max_bound_peak,min_bound_peak);

x_correct_integral = normalise_custom(x_correct_integral,max_bound_integral,min_bound_integral);
x_correct_integral_std = normalise_std(x_correct_integral_std,max_bound_integral,min_bound_integral);

x_incorrect_integral = normalise_custom(x_incorrect_integral,max_bound_integral,min_bound_integral);
x_incorrect_integral_std = normalise_std(x_incorrect_integral_std,max_bound_integral,min_bound_integral);
%%%%%

%%%LU stuff


x_max_lu_all = [x_correct_max_lu,x_incorrect_max_lu];
max_bound_peak_lu = max(x_max_lu_all);
min_bound_peak_lu = min(x_max_lu_all);

integral_all_lu = [x_correct_integral_lu,x_incorrect_integral_lu];
max_bound_integral_lu = max(integral_all_lu);
min_bound_integral_lu = min(integral_all_lu);

x_correct_max_lu = normalise_custom(x_correct_max_lu,max_bound_peak_lu,min_bound_peak_lu);
x_correct_max_lu_std = normalise_std(x_correct_max_lu_std,max_bound_peak_lu,min_bound_peak_lu);

x_incorrect_max_lu = normalise_custom(x_incorrect_max_lu,max_bound_peak_lu,min_bound_peak_lu);
x_incorrect_max_lu_std = normalise_std(x_incorrect_max_lu_std,max_bound_peak_lu,min_bound_peak_lu);

x_correct_integral_lu = normalise_custom(x_correct_integral_lu,max_bound_integral_lu,min_bound_integral_lu);
x_correct_integral_lu_std = normalise_std(x_correct_integral_lu_std,max_bound_integral_lu,min_bound_integral_lu);

x_incorrect_integral_lu = normalise_custom(x_incorrect_integral_lu,max_bound_integral_lu,min_bound_integral_lu);
x_incorrect_integral_lu_std = normalise_std(x_incorrect_integral_lu_std,max_bound_integral_lu,min_bound_integral_lu);

%%%

%%%%%%%%Plot1: Confidence (X-Pattern) using Peak.


figure1=figure;
axes1 = axes('Parent',figure1);
hold on;
errorbar(x_correct_integral*100, x_correct_integral_std*100, 'LineStyle','--','LineWidth', 2,'DisplayName',...
    'using area, correct','Color',[0         0    0.5430]);

errorbar(x_incorrect_integral*100, x_incorrect_integral_std*100,'LineStyle','--','LineWidth', 2,'DisplayName',...
    'using area, error','Color',[0.9375    0.5000    0.5000]);

errorbar(x_correct_max*100,x_correct_max_std*100, 'LineWidth', 2,'DisplayName',...
    'using peak, correct','Color',[0.1172    0.5625    1.0000]);
errorbar(x_incorrect_max*100,x_incorrect_max_std*100, 'LineWidth', 2,'DisplayName',...
    'using peak, error','Color',[0.8594    0.0781    0.2344]);

xlim(axes1,[1 5]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

xlabel(['Coherence level (c %)']);

title_string = 'Uncertainty v.s Accuracy using Peak';
y_string = 'Peak firing rate of Mean HU Activity (Hz)';

if(normalised)
    title_string = 'Uncertainty v.s Accuracy using Peak Value (Normalised)';
    y_string= 'Uncertainty (\upsilon %)';
end

ylabel(y_string);
pubgraph(figure1,18,4,'w')
ylim([-1,110]);
if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end

if(export)
export_path = [figures_path  'uncertaintyusingpeak'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end
%%%%%%%%

%%%%%%%%Plot2: Confidence (X-Pattern) using AUC.
figure2=figure;

axes2 = axes('Parent',figure2);
errorbar(x_correct_integral*100, x_correct_integral_std*100, 'LineWidth', 2,'DisplayName',...
    'correct','Color',[0.1172    0.5625    1.0000]);
hold on;
errorbar(x_incorrect_integral*100, x_incorrect_integral_std*100,'LineWidth', 2,'DisplayName',...
    'error','Color',[0.8594    0.0781    0.2344]);

xlim(axes2,[1 5]);
set(axes2,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

title_string = 'Uncertainty v.s Accuracy using Area Under Curve of HU Activity';
y_string= 'Area under curve of mean HU Activity';

if(normalised)
    title_string = 'Uncertainty v.s Accuracy using Area Under Curve of HU Activity (Normalised)';
    y_string= 'Uncertainty (\upsilon %)';
end
xlabel(['Coherence level (c %)']);
ylabel(y_string);
pubgraph(figure2,18,4,'w')
ylim([-1,110]);
if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end

%%%%%%%%
if(export)
export_path = [figures_path  'uncertaintyusingintegral'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

end

function plot_accuracies_and_pcom(dynamics_and_results, is_first_correct,normalised)
global legends;
global titles;
global export;
global figures_path;
coherences = get_coherence_levels(dynamics_and_results);
n_of_coherences= size(coherences,2);

p_com = zeros(1,n_of_coherences);
p_com_correct = zeros(1,n_of_coherences);
p_com_incorrect = zeros(1,n_of_coherences);

com_correct = zeros(1,n_of_coherences);
com_incorrect = zeros(1,n_of_coherences);

p_late_com_correct = zeros(1,n_of_coherences);
p_late_com_incorrect = zeros(1,n_of_coherences);

late_com_correct = zeros(1,n_of_coherences);
late_com_incorrect = zeros(1,n_of_coherences);

p_correct = zeros(1,n_of_coherences);
p_correct_noncom = zeros(1,n_of_coherences);
p_nondecision = zeros(1,n_of_coherences);

initiation_time_noncom_correct_mean_gather = zeros(1,n_of_coherences);
initiation_time_noncom_incorrect_mean_gather = zeros(1,n_of_coherences);
initiation_time_com_correct_mean_gather = zeros(1,n_of_coherences);
initiation_time_com_incorrect_mean_gather = zeros(1,n_of_coherences);

initiation_time_noncom_correct_std_gather = zeros(1,n_of_coherences);
initiation_time_noncom_incorrect_std_gather = zeros(1,n_of_coherences);
initiation_time_com_correct_std_gather = zeros(1,n_of_coherences);
initiation_time_com_incorrect_std_gather = zeros(1,n_of_coherences);

response_time_noncom_correct_mean_gather = zeros(1,n_of_coherences);
response_time_noncom_incorrect_mean_gather = zeros(1,n_of_coherences);
response_time_com_correct_mean_gather = zeros(1,n_of_coherences);
response_time_com_incorrect_mean_gather = zeros(1,n_of_coherences);

response_time_noncom_correct_std_gather = zeros(1,n_of_coherences);
response_time_noncom_incorrect_std_gather = zeros(1,n_of_coherences);
response_time_com_correct_std_gather = zeros(1,n_of_coherences);
response_time_com_incorrect_std_gather = zeros(1,n_of_coherences);

x_correct_max = zeros(1,n_of_coherences);
x_incorrect_max = zeros(1,n_of_coherences);

x_correct_max_std = zeros(1,n_of_coherences);
x_incorrect_max_std = zeros(1,n_of_coherences);

x_correct_integral = zeros(1,n_of_coherences);
x_incorrect_integral = zeros(1,n_of_coherences);
is_motor_com= false;

coupled = isfield(dynamics_and_results,'is_first_correct');

for i=1:n_of_coherences
    coherence= coherences(i);
    
    [noncom_correct_counter, noncom_incorrect_counter,...
        com_correct_counter, com_incorrect_counter, com_late_correct_counter, com_late_incorrect_counter, nondecision_counter] = ...
        calculate_accuracies(dynamics_and_results, coherence, is_first_correct, coupled);
    
    
    
    all_trials = noncom_correct_counter+ noncom_incorrect_counter ...
        +com_correct_counter + com_incorrect_counter;
    p_com_incorrect(i) = com_incorrect_counter/all_trials;
    p_com_correct(i) = com_correct_counter/all_trials;
    com_correct(i) = com_correct_counter;
    com_incorrect(i) = com_incorrect_counter;
    p_late_com_correct(i) = com_late_correct_counter/all_trials;
    p_late_com_incorrect(i) = com_late_incorrect_counter/all_trials;
    late_com_correct(i) = com_late_correct_counter;
    late_com_incorrect(i) = com_late_incorrect_counter;
    p_com(i)=(com_correct_counter+com_incorrect_counter)/all_trials;
    p_correct(i) = (noncom_correct_counter+com_correct_counter)/all_trials;
    p_correct_noncom(i) = (noncom_correct_counter)/all_trials;
    p_nondecision(i)= nondecision_counter/all_trials;
    
    [initiation_time_noncom_correct_mean_gather(i),initiation_time_noncom_correct_std_gather(i),...
        response_time_noncom_correct_mean_gather(i),response_time_noncom_correct_std_gather(i)] = ...
        calculate_mean_times(dynamics_and_results, coherence, ...
        true, false, is_first_correct, coupled);
    
    [initiation_time_noncom_incorrect_mean_gather(i),initiation_time_noncom_incorrect_std_gather(i),...
        response_time_noncom_incorrect_mean_gather(i),response_time_noncom_incorrect_std_gather(i)] = ...
        calculate_mean_times(dynamics_and_results, coherence, ...
        false, false, is_first_correct, coupled);
    
    [initiation_time_com_correct_mean_gather(i),initiation_time_com_correct_std_gather(i),...
        response_time_com_correct_mean_gather(i),response_time_com_correct_std_gather(i)] = ...
        calculate_mean_times(dynamics_and_results, coherence, ...
        true, true, is_first_correct, coupled);
    
    [initiation_time_com_incorrect_mean_gather(i),initiation_time_com_incorrect_std_gather(i),...
        response_time_com_incorrect_mean_gather(i),response_time_com_incorrect_std_gather(i)] = ...
        calculate_mean_times(dynamics_and_results, coherence, ...
        false, true, is_first_correct, coupled);
    
        [x_correct_max(i), ~, x_correct_max_std(i), ~,...
        x_correct_integral(i), ~] = ...
        calculate_x_pattern(dynamics_and_results, coherence, is_motor_com, true);
    
    [x_incorrect_max(i), ~, x_incorrect_max_std(i), ~,...
        x_incorrect_integral(i), ~] = ...
        calculate_x_pattern(dynamics_and_results, coherence, is_motor_com, false);
    
    
end

early_com_correct = com_correct - late_com_correct;
early_com_incorrect = com_incorrect - late_com_incorrect;

p_early_com_correct = early_com_correct./all_trials;
p_early_com_incorrect = early_com_incorrect./all_trials;
confidence_max(1,:)= nanmean([x_correct_max; x_incorrect_max]);
confidence_std(1,:) = nanmean([x_correct_max_std; x_incorrect_max_std]);

confidence_integral(1,:) = nanmean([x_correct_integral;x_incorrect_integral]);

if(normalised)
    confidence_max = normalise_custom(confidence_max, max(confidence_max), min(confidence_max));  
    confidence_integral = normalise_custom(confidence_integral,max(confidence_integral),min(confidence_integral));
end


%%%%%%%%Plot 1: PCoM related results
figure1=figure;
axes1 = axes('Parent',figure1);
plot(p_com, 'LineWidth', 6,'DisplayName',...
    'all','Color',[0 0 0]);
hold on;
plot(p_com_correct, 'LineWidth', 6,'DisplayName',...
    'correct','Color',[0 1 0]);
plot(p_com_incorrect, 'LineWidth', 6,'DisplayName',...
    'error','Color',[1 0 0]);
xlim(axes1,[1 6]);

set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});
xlabel(['Coherence level (c %)']);
ylabel('Probability of change-of-mind');
pubgraph(figure1,18,4,'w')

title_string= 'Probability of change-of-mind';
if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end

if(export)
export_path = [figures_path  title_string];
export_fig(export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end
%%%%%%%%
%%%%%%%Plot3: Choice accuracy

% 
% %%%% fit method and options
ft = fittype( '1-0.5*exp(-(x/a).^b)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.466045564080483 0.980323689974669];

 % Fit model to data.
[fitresult, gof] = fit( [0,3.2,6.4,12.8,25.6,51.2]', p_correct', ft, opts );

%%% extract data from fitted curve
figuretemp = figure;
plot(fitresult);
h = findobj(figuretemp,'Type','line');
x=get(h,'Xdata');
y=get(h,'Ydata');
close;
%%%%%%%


figure3=figure;
plot(x,y,'LineWidth', 6,'Color',[0 0 0]);
hold on;
scatter([0,3.2,6.4,12.8,25.6,51.2],p_correct,'o','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor', [0 0 0]);
xlabel(['Coherence level (c %)']);
ylabel('Probability correct');
xlim([0,51.2]);
pubgraph(figure3,18,4,'w')
title_string = 'Choice accuracy';


figure3=figure;
plot(p_correct);
hold on;
xlabel(['Coherence level (c %)']);
ylabel('Probability correct');
pubgraph(figure3,18,4,'w')
xlim(axes1,[1 6]);

set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});
xlabel(['Coherence level (c %)']);
ylabel('Probability of change-of-mind');
pubgraph(figure1,18,4,'w')

title_string= 'Choice accuracy';
if(legends)
    %legend('show');
end
if(titles)
    title(title_string);
end

if(export)
export_path = [figures_path  title_string];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

%%%%%%%%

%%%%%%%%Plot4: initiation time
figure4=figure;
axes1 = axes('Parent',figure4);
hold on;

plot(my_zscore(initiation_time_noncom_correct_mean_gather)...
    ,'LineWidth', 2,'DisplayName',...
    'non-com, correct','Color',[0 0 1]);
plot(my_zscore(initiation_time_noncom_incorrect_mean_gather)...
    ,'LineWidth', 2,'DisplayName',...
    'non-com, error','Color',[1 0 0]);
plot(my_zscore(initiation_time_com_correct_mean_gather)...
    ,'LineWidth', 2,'DisplayName',...
    'non-com, correct','Color',[0  0.3906  0]);
plot(my_zscore(initiation_time_com_incorrect_mean_gather)...
    ,'LineWidth', 2,'DisplayName',...
    'non-com, error','Color',[0.5430  0   0]);

xlim(axes1,[1 6]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

xlabel(['Coherence level (c %)']);
ylabel('Initiation time (ms)');
pubgraph(figure4,18,4,'w')
title_string = 'Initiation times v.s coherence level';
if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end

if(export)
export_path = [figures_path  'responsetimesvscoherence'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

%%%%%%%%

%%%%%%%%Plot 5: Late PCoM related results
figure5=figure;
axes1 = axes('Parent',figure5);
hold on;
plot(p_late_com_correct, 'LineWidth', 6,'DisplayName',...
    'late, correct','Color',[0.1250    0.6953    0.6641]);

plot(p_late_com_incorrect, 'LineWidth', 6,'DisplayName',...
    'late, error','Color',[0.9102    0.5859    0.4766]);

plot(p_early_com_correct, 'LineStyle','--','LineWidth', 6,'DisplayName',...
    'early, correct','Color',[0.4844    0.9875         0]);

plot(p_early_com_incorrect,'LineStyle','--', 'LineWidth', 6,'DisplayName',...
    'early, error','Color',[0.5430         0         0]);


xlim(axes1,[1 6]);

set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});
xlabel(['Coherence level (c %)']);
ylabel('Probability of change-of-mind');
pubgraph(figure5,18,4,'w')
title_string = 'probability of late change';
if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end

if(export)
export_path = [figures_path  title_string];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end


%%%%%%%%


% %%%%%%%%Plot 6: Early PCoM related results
% figure6=figure;
% axes1 = axes('Parent',figure6);
% hold on;
% plot(p_early_com_correct, 'LineWidth', 6,'DisplayName',...
%     'early, correct','Color',[0 1 0]);
% plot(p_early_com_incorrect, 'LineWidth', 6,'DisplayName',...
%     'early, error','Color',[1 0 0]);
% 
% xlim(axes1,[1 6]);
% 
% set(axes1,'FontSize',20,'XTickLabel',...
%     {'0','3.2','6.4','12.8','25.6','51.2'});
% xlabel(['Coherence level (c %)']);
% ylabel('Probability of change-of-mind');
% pubgraph(figure6,18,4,'w')
% title_string = 'Probabiltiy of early change';
% if(legends)
%     legend('show');
% end
% if(titles)
%     title(title_string);
% end
% 
% if(export)
% export_path = [figures_path  title_string];
% export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
% savefig(export_path);
% end
% %%%%%%%%

%%%%%%%%Plot7: Accuracy v.s Uncertainty using peak.

title_string = 'Accuracy v.s uncertainty';
x_string = 'Uncertainty (\upsilon %)';


[fitObject, gof] = fit(confidence_max',p_correct','poly1');


%%% extract data from fitted curve
figuretemp = figure;
plot(fitObject);
h = findobj(figuretemp,'Type','line');
x=get(h,'Xdata');
y=get(h,'Ydata');
close;
%%%%%%%


figure7=figure;
plot(x,y,'LineWidth', 2,'Color',[0 0 0]);
ylim([0.75,1])
yticklabels({'50','60','70','80','90','100'})
xticklabels({'0','10','20','30','40','50','60','70','80','90'});
ylabel('Accuracy (%)');
xlabel(x_string);
pubgraph(figure7,18,4,'w')

if(titles)
    title(title_string);
end

if(export)
export_path = [figures_path  'accuracyvsuncertainty'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end
%%%%%%%%

% %%%%%%%% Plot 8: Response time
% figure8=figure;
% axes1 = axes('Parent',figure8);
% hold on;
% errorbar(response_time_noncom_correct_mean_gather,...
%     response_time_noncom_correct_std_gather...
%     ,'LineWidth', 2,'DisplayName',...
%     'non-com, correct','Color',[0 0 1]);
% errorbar(response_time_noncom_incorrect_mean_gather,...
%     response_time_noncom_incorrect_std_gather...
%     ,'LineWidth', 2,'DisplayName',...
%     'non-com, error','Color',[1 0 0]);
% errorbar(response_time_com_correct_mean_gather,...
%     response_time_com_correct_std_gather...
%     ,'LineWidth', 2,'DisplayName',...
%     'com, correct','Color',[0  0.3906  0]);
% errorbar(response_time_com_incorrect_mean_gather,...
%     response_time_com_incorrect_std_gather...
%     ,'LineWidth', 2,'DisplayName',...
%     'com, error','Color',[0.5430  0   0]);
% 
% xlim(axes1,[1 6]);
% set(axes1,'FontSize',20,'XTickLabel',...
%     {'0','3.2','6.4','12.8','25.6','51.2'});
% 
% xlabel(['Coherence level (c %)']);
% ylabel('Response time (ms)');
% pubgraph(figure8,18,4,'w')
% title_string = 'Response time v.s coherence level';
% if(legends)
%     legend('show');
% end
% if(titles)
%     title(title_string);
% end
% 
% if(export)
% export_path = [figures_path  'responsetimevscoherence'];
% export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
% savefig(export_path);
% end

%%%%%%%%Plot7: Times (non com)
figure9=figure;
axes1 = axes('Parent',figure9);
hold on;
errorbar(initiation_time_noncom_correct_mean_gather,...
    initiation_time_noncom_correct_std_gather...
    ,'LineWidth', 2,'DisplayName',...
    'initiation, correct','Color',[0 0 1]);
errorbar(initiation_time_noncom_incorrect_mean_gather,...
    initiation_time_noncom_incorrect_std_gather...
    ,'LineWidth', 2,'DisplayName',...
    'initiation, error','Color',[1 0 0]);

xlim(axes1,[1 6]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

xlabel(['Coherence level (c %)']);
ylabel('Time (ms)');
pubgraph(figure9,18,4,'w')
title_string = 'Times v.s coherence level';
if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end
if(export)
export_path = [figures_path  'overalltime-noncom'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

%%%%%%%%
end

function plot_main_panel(y_1,y_2,y_3,y_4,y_5,y_6,y_7,y_8,y_mc_hu,y_mc_lu,is_single_trial,coherence)

global export;

if(is_single_trial)
    title_string = sprintf('- Single trial c`=: %0.1f',coherence);
else
    title_string = sprintf('- Mean activity c`=: %0.1f',coherence);
end
figure;
title(title_string);
subplot(6,1,1);
hold on;
plot(y_1(1:2:end));
plot(y_2(1:2:end));
legend('Left','Right');
title(['Decision Module ' title_string]);

subplot(6,1,2);
hold on;
plot(y_mc_hu(1:2:end));
plot(y_mc_lu(1:2:end));
legend('High Uncertainty'....
    ,'Low Uncertainty');
title(['Uncertainty Module ' title_string]);

subplot(6,1,3);
hold on;
plot(y_3(1:2:end));
plot(y_4(1:2:end));
legend('Left','Right');
title(['Eye Module ' title_string]);

subplot(6,1,4);
hold on;
plot(y_5(1:2:end));
plot(y_6(1:2:end));
legend('Left','Right');
title(['Hand Module ' title_string]);

subplot(6,1,5);
hold on;
plot(y_7(1:2:end));
plot(y_8(1:2:end));
legend('Left','Right');
title(['Motor Preperation Module ' title_string]);

subplot(6,1,6);
hold on;
plot(y_5(1:2:end) - y_6(1:2:end),'b');
title(['X-Trajectory ' title_string]);

if(export)
export_path = [figures_path  'old_panel'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

end

function plot_main_panel_modified(dynamics_and_results,y_1,y_2,y_3,y_4,y_5,y_6,y_mc_hu,y_mc_lu,y_7,y_8,y_1_25,y_2_25,y_3_25,y_4_25,y_5_25,y_6_25,y_mc_hu_25,y_mc_lu_25,y_7_25,y_8_25)

global legends;
global titles;
global export;
global figures_path;

large_left= 'c`=51.2%, left';
large_right = 'c`=51.2%, right';

small_left= 'c`=3.2%, left';
small_right = 'c`=3.2%, right';


large = 'c`=51.2%';
small = 'c`=3.2%';

figure1=figure;
subplot(5,1,1);
title('Sensorimotor');
hold on;
plot(y_1_25(1:2:end),'Color',[0.1172    0.5625    1.0000],'DisplayName',large_left);
plot(y_2_25(1:2:end),'Color',[1.0000    0.4961    0.3125],'DisplayName',large_right);
plot(y_1(1:2:end),'LineStyle','--','Color',[0.1172    0.5625    1.0000],'DisplayName',small_left);
plot(y_2(1:2:end),'LineStyle','--','Color',[1.0000    0.4961    0.3125],'DisplayName',small_right);
xlim([700,2500]);
xticks(['','',''])
xticklabels({'','',''})
if(legends)
    legend('show');
end
if(titles)
   title(['Decision' title_string]);
end


%xlabel('Time (ms)');
subplot(5,1,2);
title('Motor Preparation');
hold on;
plot(y_7_25(1:2:end),'Color',[0.1172    0.5625    1.0000],'DisplayName',large_left);
plot(y_8_25(1:2:end),'Color',[1.0000    0.4961    0.3125],'DisplayName',large_right);
plot(y_7(1:2:end),'LineStyle','--','Color',[0.1172    0.5625    1.0000],'DisplayName',small_left);
plot(y_8(1:2:end),'LineStyle','--','Color',[1.0000    0.4961    0.3125],'DisplayName',small_right);
xlim([700,2500]);
xticks(['','',''])
xticklabels({'','',''})
if(titles)
   title(['Decision' title_string]);
end


subplot(5,1,3);
title('Uncertainty Monitoring');
hold on;
plot(y_mc_hu_25(1:2:end),'Color',[1 0 0],'DisplayName',large);
plot(y_mc_hu(1:2:end),'LineStyle','--','Color',[1 0 0],'DisplayName',small);
%plot(y_mc_lu_25(1:2:end),'Color',[0.1328    0.5430    0.1328]);
%plot(y_mc_lu(1:2:end),'LineStyle','--','Color',[0.1328    0.5430    0.1328]);
xlim([700,2500]);
xticks(['','',''])
xticklabels({'','',''})
if(legends)
    legend('show');
end
if(titles)
    title(['Uncertainty monitoring' title_string]);
end
ylabel('Firing rate (Hz)');

subplot(5,1,4);
title('Hand');
hold on;
plot(y_5_25(1:2:end),'Color',[0.1172    0.5625    1.0000]);
plot(y_6_25(1:2:end),'Color',[1.0000    0.4961    0.3125]);
plot(y_5(1:2:end),'LineStyle','--','Color',[0.1172    0.5625    1.0000]);
plot(y_6(1:2:end),'LineStyle','--','Color',[1.0000    0.4961    0.3125]);
xlim([700,2500]);
xticks(['','',''])
xticklabels({'','',''})



if(legends)
    %legend('Left','Right');
end
if(titles)
    title(['Motor output' title_string]);
end

subplot(5,1,5);
title('Eye');
hold on;
plot(y_3_25(1:2:end),'Color',[0.1172    0.5625    1.0000]);
plot(y_4_25(1:2:end),'Color',[1.0000    0.4961    0.3125]);
plot(y_3(1:2:end),'LineStyle','--','Color',[0.1172    0.5625    1.0000]);
plot(y_4(1:2:end),'LineStyle','--','Color',[1.0000    0.4961    0.3125]);
xlabel('Time (ms)');
xlim([700,2500]);
xticks([700,1500,2500])
xticklabels({'0','1500', '2500'})
pubgraph(figure1,18,4,'w');


if(export)
export_path = [figures_path  'new_panel'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

end

function plot_time_window(dynamics_and_results,index_to_plot,activity_vector1,activity_vector2,time_wind,slide_wind)
global legends;
global titles;
global export;
global figures_path;

%this shouldn't be static
dt = dynamics_and_results(index_to_plot).timestep_size;
trial_length = dynamics_and_results(index_to_plot).trial_length;
stim_onset =  dynamics_and_results(index_to_plot).stim_onset;

stim_offset =  dynamics_and_results(index_to_plot).stim_offset;


figure;
subplot(2,1,1)
plot((dt*time_wind:dt*slide_wind:dt*(trial_length-time_wind)),activity_vector1(1:end-10));hold on;
plot((dt*time_wind:dt*slide_wind:dt*(trial_length-time_wind)),activity_vector2(1:end-10));hold on;
line1=get(gca,'ylim');
plot([stim_onset stim_onset],line1)
plot([stim_offset stim_offset],line1)
ylabel('Firing rate (Hz)');

if(legends)
    legend('Left','Right');
end
if(titles)
    title('Timecourse of single-trial firing rates (using time window)');
end

subplot(2,1,2)
plot((dt*time_wind:dt*slide_wind:dt*(trial_length-time_wind)),activity_vector1(1:end-10) - activity_vector2(1:end-10));hold on;
line1=get(gca,'ylim');
plot([stim_onset stim_onset],line1)

xlabel('Time (ms)'); ylabel('Firing rate (Hz)');
pubgraph(gcf,18,4,'w')

if(legends)
    legend('Left','Right');
end
if(titles)
    title('Difference of firing rates in a single-trial (using time window)');
end



if(export)
export_path = [figures_path + 'time_window'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

end

%% Analysis functions


function[] = calculate_eye_hand_lag(dynamics_and_results)

counter = 0;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).com_initiation_point_hand ~=0)
        counter = counter+1;
    end 

    
end




counter2 = 0;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).com_initiation_point_hand ==-1)
        counter2 = counter2+1;
    end 
end


hand_gather = zeros(1,counter);
eye_gather = zeros(1,counter);

j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).com_initiation_point_hand ~=0&& dynamics_and_results(i).is_motor_com)
        hand_gather(j) = dynamics_and_results(i).com_initiation_point_hand;
        eye_gather(j) = dynamics_and_results(i).com_initiation_point_eye;
        j=j+1;
    end 
end


lag = hand_gather - eye_gather;

lag = lag/2;


mean(lag)
figure
histfit(lag,40,'normal')


end

function[noncom_correct_counter, noncom_incorrect_counter,...
    com_correct_counter, com_incorrect_counter, com_late_correct_counter, com_late_incorrect_counter,nondecision_counter] = ...
    calculate_accuracies(dynamics_and_results, coherence, is_first_correct, coupled)

coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

noncom_correct_counter = 0;
noncom_incorrect_counter = 0;
com_correct_counter = 0;
com_incorrect_counter = 0;

nondecision_counter = 0;

com_late_correct_counter = 0;
com_late_incorrect_counter = 0;

if(~coupled)
for i = 1:size(dynamics_and_results,1)
    if(coherence==dynamics_and_results(i).coherence_level)
        if(dynamics_and_results(i).motor_decision_made)
            if(dynamics_and_results(i).is_motor_correct)
                if(dynamics_and_results(i).is_motor_com)
                    com_correct_counter = com_correct_counter+1;
                    if(dynamics_and_results(i).is_late_com)
                        com_late_correct_counter= com_late_correct_counter +1;
                    end
                else
                    noncom_correct_counter = noncom_correct_counter+1;
                end
            elseif(dynamics_and_results(i).is_motor_com)
                com_incorrect_counter = com_incorrect_counter+1;
                if(dynamics_and_results(i).is_late_com)
                    com_late_incorrect_counter= com_late_incorrect_counter +1;
                end
            else
                noncom_incorrect_counter = noncom_incorrect_counter+1;
            end
        else
            nondecision_counter = nondecision_counter+1;
        end
    end
end
return;
end

for i = 1:size(dynamics_and_results,1)
    if(coherence==dynamics_and_results(i).coherence_level)
        if(is_first_correct==dynamics_and_results(i).is_first_correct)
            if(dynamics_and_results(i).motor_decision_made)
                if(dynamics_and_results(i).is_motor_correct)
                    if(dynamics_and_results(i).is_motor_com)
                        com_correct_counter = com_correct_counter+1;
                        if(dynamics_and_results(i).is_late_com)
                            com_late_correct_counter= com_late_correct_counter +1;
                        end
                    else
                        noncom_correct_counter = noncom_correct_counter+1;
                    end
                elseif(dynamics_and_results(i).is_motor_com)
                    com_incorrect_counter = com_incorrect_counter+1;
                    if(dynamics_and_results(i).is_late_com)
                        com_late_incorrect_counter= com_late_incorrect_counter +1;
                    end
                else
                    noncom_incorrect_counter = noncom_incorrect_counter+1;
                end
            else
                nondecision_counter = nondecision_counter+1;
            end
        end
    end
end
return;


end


function[max_hu, max_lu, std_hu, std_lu, integral_hu,integral_hu_std, integral_lu,integral_lu_std] = ...
    calculate_x_pattern(dynamics_and_results, coherence, is_motor_com, is_motor_correct)

coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

counter = 0;

trial_length =  dynamics_and_results(1).trial_length;


for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence &&...
            dynamics_and_results(i).is_motor_com == is_motor_com && ...
            dynamics_and_results(i).is_motor_correct == is_motor_correct)
        counter = counter+1;
    end
end

y_mc_hu_gather = zeros(counter,trial_length);
y_mc_lu_gather = zeros(counter,trial_length);

j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence &&...
            dynamics_and_results(i).is_motor_com == is_motor_com && ...
            dynamics_and_results(i).is_motor_correct == is_motor_correct)
        y_mc_hu_gather(j,:)=dynamics_and_results(i).y_mc_hu;
        y_mc_lu_gather(j,:)=dynamics_and_results(i).y_mc_lu;
        j=j+1;
    end
end


% Max of each trial

maxes_hu_of_each_trial =zeros(1,size(y_mc_hu_gather,1));
maxes_lu_of_each_trial =zeros(1,size(y_mc_hu_gather,1));
for i = 1:size(y_mc_hu_gather,1)
    maxes_hu_of_each_trial(i) = max(y_mc_hu_gather(i,:));
    maxes_lu_of_each_trial(i) = max(y_mc_lu_gather(i,:));
end


%%% calculate x_pattern by peak
max_hu = nanmean(maxes_hu_of_each_trial);
std_hu = nanstd(maxes_hu_of_each_trial)/sqrt(size(maxes_hu_of_each_trial,2));
max_lu = nanmean(maxes_lu_of_each_trial);
std_lu = nanstd(maxes_lu_of_each_trial)/sqrt(size(maxes_lu_of_each_trial,2));



y_mc_hu_mean(1,:) = mean(y_mc_hu_gather);
y_mc_lu_mean(1,:) = mean(y_mc_lu_gather);

%%% calculate x_pattern by integral (trapz)

% Integral of each trial

% integral_hu = trapz(y_mc_hu_mean);
% integral_lu = trapz(y_mc_lu_mean);
integral_hu_of_each_trial =zeros(1,size(y_mc_hu_gather,1));
integral_lu_of_each_trial =zeros(1,size(y_mc_hu_gather,1));
for i = 1:size(y_mc_hu_gather,1)
    integral_hu_of_each_trial(i) = trapz(y_mc_hu_gather(i,:));
    integral_lu_of_each_trial(i) = trapz(y_mc_lu_gather(i,:));
end

integral_hu = nanmean(integral_hu_of_each_trial);
integral_hu_std = nanstd(integral_hu_of_each_trial)/sqrt(size(integral_hu_of_each_trial,2));

integral_lu = nanmean(integral_lu_of_each_trial);
integral_lu_std = nanstd(integral_lu_of_each_trial)/sqrt(size(integral_lu_of_each_trial,2));

return;

end


function[y_1_mean, y_2_mean,y_3_mean,y_4_mean, y_mc_hu_mean, y_mc_lu_mean, y_5_mean,...
    y_6_mean,y_7_mean, y_8_mean ] = ...
    calculate_mean_activity(dynamics_and_results, coherence, ...
    is_motor_correct, is_motor_com)

coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

counter = 0;
trial_length =  dynamics_and_results(1).trial_length;

%get number of each type, before initialising vectors.


for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com)
        counter = counter+1;
    end
end

y_1_gather = zeros(counter,trial_length);
y_2_gather = zeros(counter,trial_length);
y_3_gather = zeros(counter,trial_length);
y_4_gather = zeros(counter,trial_length);
y_mc_hu_gather = zeros(counter,trial_length);
y_mc_lu_gather = zeros(counter,trial_length);
y_5_gather = zeros(counter,trial_length);
y_6_gather = zeros(counter,trial_length);
y_7_gather = zeros(counter,trial_length);
y_8_gather = zeros(counter,trial_length);


j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com)
        y_1_gather(j,:)=dynamics_and_results(i).y_1;
        y_2_gather(j,:)=dynamics_and_results(i).y_2;
        y_3_gather(j,:) = dynamics_and_results(i).y_3;
        y_4_gather(j,:) = dynamics_and_results(i).y_4;
        y_mc_hu_gather(j,:)=dynamics_and_results(i).y_mc_hu;
        y_mc_lu_gather(j,:)=dynamics_and_results(i).y_mc_lu;
        y_5_gather(j,:)=dynamics_and_results(i).y_5;
        y_6_gather(j,:)=dynamics_and_results(i).y_6;
        y_7_gather(j,:) = dynamics_and_results(i).y_7;
        y_8_gather(j,:) = dynamics_and_results(i).y_8;


        j=j+1;
    end
end


% Non CoM Correct Mean
y_1_mean(1,:) = mean(y_1_gather);
y_2_mean(1,:) = mean(y_2_gather);
y_3_mean(1,:) = mean(y_3_gather);
y_4_mean(1,:) = mean(y_4_gather);
y_mc_hu_mean(1,:) = mean(y_mc_hu_gather);
y_mc_lu_mean(1,:) = mean(y_mc_lu_gather);
y_5_mean(1,:) = mean(y_5_gather);
y_6_mean(1,:) = mean(y_6_gather);
y_7_mean(1,:) = mean(y_7_gather);
y_8_mean(1,:) = mean(y_8_gather);
return;
end

function[initiation_time_mean, initiation_time_std, ...
    response_time_mean, response_time_std] = ...
    calculate_mean_times(dynamics_and_results, coherence, ...
    is_motor_correct, is_motor_com, is_first_correct, coupled)

coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

counter = 0;

if(~coupled)
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level ==...
                coherence && dynamics_and_results(i).is_motor_correct ==...
                is_motor_correct && dynamics_and_results(i).is_motor_com == ...
                is_motor_com)
            counter = counter+1;
        end
    end
else
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level ==...
                coherence && dynamics_and_results(i).is_motor_correct ==...
                is_motor_correct && dynamics_and_results(i).is_motor_com == ...
                is_motor_com && dynamics_and_results(i).is_first_correct == ...
                is_first_correct)
            counter = counter+1;
        end
    end
end

initiation_time_gather = zeros(1,counter);
response_time_gather = zeros(1,counter);

j=1;
if(~coupled)
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == ...
                coherence && dynamics_and_results(i).is_motor_correct ==...
                is_motor_correct && dynamics_and_results(i).is_motor_com ==...
                is_motor_com)
            initiation_time_gather(j)=dynamics_and_results(i).initiation_time;
            response_time_gather(j)=dynamics_and_results(i).initiation_time;
            j=j+1;
        end
    end
else
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == ...
                coherence && dynamics_and_results(i).is_motor_correct ==...
                is_motor_correct && dynamics_and_results(i).is_motor_com ==...
                is_motor_com && dynamics_and_results(i).is_first_correct ==...
                is_first_correct)
                 initiation_time_gather(j)=dynamics_and_results(i).initiation_time;
            response_time_gather(j)=dynamics_and_results(i).initiation_time;            
            j=j+1;
        end
    end
end

initiation_time_mean = mean(initiation_time_gather);
initiation_time_std = std(initiation_time_gather)/sqrt(size(initiation_time_gather,2));
response_time_mean = mean(response_time_gather);
response_time_std = std(response_time_gather)/sqrt(size(response_time_gather,2));


return;
end

function [x_traj_gather] = gather_trajectories(dynamics_and_results,...
    coherence, is_motor_com, is_motor_correct, all_com, is_late_com)

target_x_position=1080; %pixels.
coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

counter = 0;
trial_length =  dynamics_and_results(1).trial_length;

%get number of each type, before initialising vectors.


if(all_com)
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com)
            counter = counter+1;
        end
    end
else
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com && dynamics_and_results(i).is_late_com == is_late_com)
            counter = counter+1;
        end
    end
    
end

y_5_gather = zeros(counter,trial_length);
y_6_gather = zeros(counter,trial_length);

j=1;
if(all_com)
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com)
            y_5_gather(j,:)=dynamics_and_results(i).y_5;
            y_6_gather(j,:)=dynamics_and_results(i).y_6;
            j=j+1;
        end
    end
else
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com && dynamics_and_results(i).is_late_com == is_late_com)
            y_5_gather(j,:)=dynamics_and_results(i).y_5;
            y_6_gather(j,:)=dynamics_and_results(i).y_6;
            j=j+1;
        end
    end
end
if(is_motor_correct)
    x_traj_gather = (y_6_gather-y_5_gather) *   (target_x_position/dynamics_and_results(1).motor_target_threshold);
else
    x_traj_gather = (y_5_gather-y_6_gather) * (target_x_position/dynamics_and_results(1).motor_target_threshold);
end

return;
end

function[time_window_averaged] = ...
    calculate_time_window(activity_vector, time_wind, slide_wind)


trial_length = size(activity_vector,2);

time_window_averaged = zeros(1,(trial_length/slide_wind)-9);
time_window_averaged(1) = (mean(activity_vector(1:time_wind))) ;



for t = 2:(trial_length-time_wind)/slide_wind
    time_window_averaged(t) = ...
        (mean(activity_vector(slide_wind*t:slide_wind*t+time_wind))) ;
end


end


function reward_rate = calculate_reward_rate(dynamics_and_results)


coherences = get_coherence_levels(dynamics_and_results);
n_of_coherences= size(coherences,2);

p_com = zeros(1,n_of_coherences);
p_com_correct = zeros(1,n_of_coherences);
p_com_incorrect = zeros(1,n_of_coherences);

com_correct = zeros(1,n_of_coherences);
com_incorrect = zeros(1,n_of_coherences);

p_late_com_correct = zeros(1,n_of_coherences);
p_late_com_incorrect = zeros(1,n_of_coherences);

late_com_correct = zeros(1,n_of_coherences);
late_com_incorrect = zeros(1,n_of_coherences);

p_correct = zeros(1,n_of_coherences);
p_correct_noncom = zeros(1,n_of_coherences);
p_nondecision = zeros(1,n_of_coherences);
noncom_correct_all_coh = zeros(1,n_of_coherences);

coherence_total_expected_time = zeros(1,n_of_coherences);

initiation_time_noncom_correct_mean_gather = zeros(1,n_of_coherences);
initiation_time_noncom_incorrect_mean_gather = zeros(1,n_of_coherences);
initiation_time_com_correct_mean_gather = zeros(1,n_of_coherences);
initiation_time_com_incorrect_mean_gather = zeros(1,n_of_coherences);

initiation_time_noncom_correct_std_gather = zeros(1,n_of_coherences);
initiation_time_noncom_incorrect_std_gather = zeros(1,n_of_coherences);
initiation_time_com_correct_std_gather = zeros(1,n_of_coherences);
initiation_time_com_incorrect_std_gather = zeros(1,n_of_coherences);

response_time_noncom_correct_mean_gather = zeros(1,n_of_coherences);
response_time_noncom_incorrect_mean_gather = zeros(1,n_of_coherences);
response_time_com_correct_mean_gather = zeros(1,n_of_coherences);
response_time_com_incorrect_mean_gather = zeros(1,n_of_coherences);

response_time_noncom_correct_std_gather = zeros(1,n_of_coherences);
response_time_noncom_incorrect_std_gather = zeros(1,n_of_coherences);
response_time_com_correct_std_gather = zeros(1,n_of_coherences);
response_time_com_incorrect_std_gather = zeros(1,n_of_coherences);

for i=1:n_of_coherences  
    coherence= coherences(i);
    coupled = false;
    is_first_correct = true;
    
    [noncom_correct_counter, noncom_incorrect_counter,...
        com_correct_counter, com_incorrect_counter, com_late_correct_counter, com_late_incorrect_counter, nondecision_counter] = ...
        calculate_accuracies(dynamics_and_results, coherence, is_first_correct, coupled);
    
    
    
    all_trials = noncom_correct_counter+ noncom_incorrect_counter ...
        +com_correct_counter + com_incorrect_counter;
    p_com_incorrect(i) = com_incorrect_counter/all_trials;
    p_com_correct(i) = com_correct_counter/all_trials;
    com_correct(i) = com_correct_counter;
    com_incorrect(i) = com_incorrect_counter;
    p_late_com_correct(i) = com_late_correct_counter/all_trials;
    p_late_com_incorrect(i) = com_late_incorrect_counter/all_trials;
    late_com_correct(i) = com_late_correct_counter;
    late_com_incorrect(i) = com_late_incorrect_counter;
    p_com(i)=(com_correct_counter+com_incorrect_counter)/all_trials;
    p_correct(i) = (noncom_correct_counter+com_correct_counter)/all_trials;
    p_correct_noncom(i) = (noncom_correct_counter)/all_trials;
    p_nondecision(i)= nondecision_counter/all_trials;
    
    noncom_correct_all_coh(i)= noncom_correct_counter;
    
    [initiation_time_noncom_correct_mean_gather(i),initiation_time_noncom_correct_std_gather(i),...
        response_time_noncom_correct_mean_gather(i),response_time_noncom_correct_std_gather(i)] = ...
        calculate_mean_times(dynamics_and_results, coherence, ...
        true, false, is_first_correct, coupled);
    
    [initiation_time_noncom_incorrect_mean_gather(i),initiation_time_noncom_incorrect_std_gather(i),...
        response_time_noncom_incorrect_mean_gather(i),response_time_noncom_incorrect_std_gather(i)] = ...
        calculate_mean_times(dynamics_and_results, coherence, ...
        false, false, is_first_correct, coupled);
    
    [initiation_time_com_correct_mean_gather(i),initiation_time_com_correct_std_gather(i),...
        response_time_com_correct_mean_gather(i),response_time_com_correct_std_gather(i)] = ...
        calculate_mean_times(dynamics_and_results, coherence, ...
        true, true, is_first_correct, coupled);
    
    [initiation_time_com_incorrect_mean_gather(i),initiation_time_com_incorrect_std_gather(i),...
        response_time_com_incorrect_mean_gather(i),response_time_com_incorrect_std_gather(i)] = ...
        calculate_mean_times(dynamics_and_results, coherence, ...
        false, true, is_first_correct, coupled);
    
    

end

iti_correct = 1;
iti_error = 2;
mean_time_correct = (response_time_noncom_correct_mean_gather + iti_correct) ;
mean_time_incorrect = (response_time_noncom_incorrect_mean_gather + iti_error);

mean_mean_correct = mean(mean_time_correct);
mean_mean_incorrect = nanmean(mean_time_incorrect);

total_time = (mean_mean_correct * noncom_correct_counter) + (mean_mean_incorrect * noncom_incorrect_counter);
reward_rate = sum(noncom_correct_all_coh)/total_time;

end

%% helper functions:

function coherences = get_coherence_levels(dynamics_and_results)


coherences = zeros(1,size(dynamics_and_results,1));
for i=1:size(dynamics_and_results)
    coherences(i) = dynamics_and_results(i).coherence_level;
end

coherences = unique(coherences);

return
end

function [normalised_vector] = normalise_custom(vector,max,min)

normalised_vector = zeros(1,size(vector,2));

for i=1:size(vector,2)
    normalised_vector(i) = (vector(i)-min)/(max-min);
end
return;
end

function [normalised_std] = normalise_std(std,max,min)

normalised_std= std/(max-min);


return;

end


function [zscored_data] = my_zscore(x)

if any(isnan(x(:)))
    xmu=nanmean(x);
    xsigma=nanstd(x);
    zscored_data=(x-repmat(xmu,length(x),1))./repmat(xsigma,length(x),1);
    zscored_data = zscored_data(1,:);
else
    zscored_data=zscore(x);
end

return;

end