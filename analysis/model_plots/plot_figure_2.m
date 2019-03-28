%First plot: Psychometric function, split CoM/NON-CoM.
%Second plot: Mouse-IT (z_scored).

global legends;
global titles;
global export;
global figures_path;
global experiment_string;

experiment_string = '';
figures_path = '../figures_output/csv/';

legends = true;
titles = false;
export = false;

is_first_correct= true;
normalised = true;



plot_accuracies_and_pcom(dynamics_and_results);


function coherences = get_coherence_levels(dynamics_and_results)


coherences = zeros(1,size(dynamics_and_results,1));
for i=1:size(dynamics_and_results)
    coherences(i) = dynamics_and_results(i).coherence_level;
end

coherences = unique(coherences);

return
end


function plot_accuracies_and_pcom(dynamics_and_results)
global legends;
global titles;
global export;
global figures_path;
global experiment_string;

coherences = get_coherence_levels(dynamics_and_results);
n_of_coherences= size(coherences,2);

p_correct = zeros(1,n_of_coherences);
p_correct_noncom = zeros(1,n_of_coherences);
p_nondecision = zeros(1,n_of_coherences);
p_correct_com = zeros(1,n_of_coherences);

initiation_time_noncom_correct_mean_gather = zeros(1,n_of_coherences);
initiation_time_noncom_incorrect_mean_gather = zeros(1,n_of_coherences);
initiation_time_com_correct_mean_gather = zeros(1,n_of_coherences);
initiation_time_com_incorrect_mean_gather = zeros(1,n_of_coherences);

initiation_time_noncom_correct_std_gather = zeros(1,n_of_coherences);
initiation_time_noncom_incorrect_std_gather = zeros(1,n_of_coherences);
initiation_time_com_correct_std_gather = zeros(1,n_of_coherences);
initiation_time_com_incorrect_std_gather = zeros(1,n_of_coherences);



for i=1:n_of_coherences
    coherence= coherences(i);
    
    [noncom_correct_counter, noncom_incorrect_counter,...
        com_correct_counter, com_incorrect_counter, nondecision_counter] = ...
        calculate_accuracies(dynamics_and_results, coherence);
    
    all_trials = noncom_correct_counter+ noncom_incorrect_counter ...
        +com_correct_counter + com_incorrect_counter;
   
    p_correct(i) = (noncom_correct_counter)/(noncom_correct_counter+noncom_incorrect_counter);
    p_correct_noncom(i) = (noncom_correct_counter)/all_trials;
    p_correct_com(i) = (com_correct_counter)/(com_correct_counter+com_incorrect_counter);
    p_nondecision(i)= nondecision_counter/all_trials;
    
    
end


%%%%%%%%Fig1: Psychometric function for CoM/non-com.

% %%% fit method and options
% % Set up fittype and options.
% ft = fittype( '1-0.5*exp(-(x/a).^b)', 'independent', 'x', 'dependent', 'y' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Algorithm = 'Levenberg-Marquardt';
% opts.Display = 'Off';
% opts.Robust = 'LAR';
% opts.StartPoint = [0.260248081354927 0.756869845818142];
% 
% 
% % Fit model to data.
% 
% [fitresult, ~] = fit( [0,3.2,6.4,12.8,25.6,51.2]', p_correct', ft, opts );
% 
% %%% extract data from fitted curve
% figuretemp = figure;
% plot(fitresult);
% h = findobj(figuretemp,'Type','line');
% x=get(h,'Xdata');
% y=get(h,'Ydata');
% close;
% %%%%%%%


%%%% COM FIT: 

% % Set up fittype and options.
% ft_2 = fittype( 'poly2' );
% opts_2 = fitoptions( 'Method', 'LinearLeastSquares' );
% opts_2.Robust = 'LAR';
% 
% p_correct_com(:,6)=[]; %delete NAN
% % p_correct_com(:,5)=[];
% % Fit model to data.
% [fitresult, ~] = fit( [0,3.2,6.4,12.8,25.6]', p_correct_com', ft_2, opts_2 );
% 
% % Plot fit with data.
% figuretemp2 = figure;
% plot( fitresult);
% h = findobj(figuretemp2,'Type','line');
% x_com=get(h,'Xdata');
% y_com=get(h,'Ydata');
% close;
% 

% figure3=figure;
% hold on;
% plot(x,y,'LineWidth', 6,'Color',[0 0 0]);
% plot(x_com,y_com,'LineWidth', 6,'Color',[0 0 0],'LineStyle','--');
% scatter([0,3.2,6.4,12.8,25.6,51.2],p_correct,'o','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor', [0 0 0]);
% scatter([0,3.2,6.4,12.8,25.6],p_correct_com,'x','LineWidth',4,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor', [1 0 0]);
% xlabel('Coherence level c` (%)');
% ylabel('Probability correct');
% xlim([0,51.2]);
% pubgraph(figure3,18,4,'w')
% title_string = 'Choice accuracy';


if(legends)
    %legend('show');
end
if(titles)
    title(title_string);
end
data_file_name_2=[figures_path 'psychometric_function' experiment_string '.mat'];
% data_file_name_csv_1=[figures_path 'Fig2_a1_' experiment_string '.txt'];
data_file_name_csv_2=[figures_path 'psychometric_function' experiment_string '.txt'];
% header_1 = {'pcorrect_x_fit,pcorrect_y_fit'};
header_2 = {'pcorrect_x_real,pcorrect_y_real'};

coherences = [0,3.2,6.4,12.8,25.6,51.2];

% fig_1_data_1 = [x',y'];
fig_1_data_2 = [coherences',p_correct'];


% fid = fopen(data_file_name_csv_1, 'w') ;
% fprintf(fid, '%s,', header_1{1,1:end-1}) ;
% fprintf(fid, '%s\n', header_1{1,end}) ;
% fclose(fid) ;
% dlmwrite(data_file_name_csv_1, fig_1_data_1(1:end,:), '-append') ;

fid = fopen(data_file_name_csv_2, 'w') ;
fprintf(fid, '%s,', header_2{1,1:end-1}) ;
fprintf(fid, '%s\n', header_2{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv_2, fig_1_data_2(1:end,:), '-append') ;


%%% COM save:

% data_file_name_csv_1=[figures_path 'Fig2_b1_' experiment_string '.txt'];
data_file_name_csv_2=[figures_path 'psychometric_function_com' experiment_string '.txt'];
% header_1 = {'pcorrect_com_x_fit,pcorrect_com_y_fit'};
header_2 = {'pcorrect_x_real,pcorrect_y_real'};

coherences = [0,3.2,6.4,12.8,25.6,51.2];

% fig_1_data_1 = [x_com',y_com'];
fig_1_data_2 = [coherences',p_correct_com'];


% fid = fopen(data_file_name_csv_1, 'w') ;
% fprintf(fid, '%s,', header_1{1,1:end-1}) ;
% fprintf(fid, '%s\n', header_1{1,end}) ;
% fclose(fid) ;
% dlmwrite(data_file_name_csv_1, fig_1_data_1(1:end,:), '-append') ;

fid = fopen(data_file_name_csv_2, 'w') ;
fprintf(fid, '%s,', header_2{1,1:end-1}) ;
fprintf(fid, '%s\n', header_2{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv_2, fig_1_data_2(1:end,:), '-append') ;
if(export)
export_path = [figures_path  title_string];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-r300','-q101', '-cmyk','-painters');
savefig(export_path);
end

%%%%%%%

%%%%%%%%Figure2: Initiation times (z-scored)

[times_mean_hand,times_std_hand]=mean_z_std_all_times(dynamics_and_results);

coherences = [0,3.2,6.4,12.8,25.6,51.2];
for i=1:n_of_coherences
    coherence= coherences(i);
    [initiation_time_noncom_correct_mean_gather(i),initiation_time_noncom_correct_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        true, false, times_mean_hand,times_std_hand);
    
    [initiation_time_noncom_incorrect_mean_gather(i),initiation_time_noncom_incorrect_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        false, false, times_mean_hand,times_std_hand);
    
    [initiation_time_com_correct_mean_gather(i),initiation_time_com_correct_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        true, true, times_mean_hand,times_std_hand);
    
    [initiation_time_com_incorrect_mean_gather(i),initiation_time_com_incorrect_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        false, true, times_mean_hand,times_std_hand);
        
end

figure4=figure;
axes1 = axes('Parent',figure4);
hold on;

errorbar(initiation_time_noncom_correct_mean_gather,...
    initiation_time_noncom_correct_std_gather...
    ,'LineWidth', 2,'DisplayName',...
    'correct','Color',[0 0 1]);
errorbar(initiation_time_noncom_incorrect_mean_gather,...
    initiation_time_noncom_correct_std_gather...
    ,'LineWidth', 2,'DisplayName',...
    'error','Color',[1 0 0]);


xlim(axes1,[1 6]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

xlabel('Coherence level c` (%)');
ylabel('Hand initiation time z-score');
pubgraph(figure4,18,4,'w')
title_string = 'Initiation times v.s coherence level';
if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end


data_file_name_csv=[figures_path 'response_times_non_com' experiment_string '.txt'];
header = {'init_z_correct,init_z_correct_sem,init_z_error,init_z_error_sem'};

fig_2c_data = [initiation_time_noncom_correct_mean_gather',...
    initiation_time_noncom_correct_std_gather',initiation_time_noncom_incorrect_mean_gather',initiation_time_noncom_incorrect_std_gather'];

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_2c_data(1:end,:), '-append') ;


%%% COM: 

data_file_name_csv=[figures_path 'response_times_com' experiment_string '.txt'];
header = {'init_z_correct,init_z_correct_sem,init_z_error,init_z_error_sem'};

fig_2c_data = [initiation_time_com_correct_mean_gather',...
    initiation_time_com_correct_std_gather',initiation_time_com_incorrect_mean_gather',initiation_time_com_incorrect_std_gather'];

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_2c_data(1:end,:), '-append') ;





if(export)
export_path = [figures_path  'responsetimesvscoherence'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end
end

function[noncom_correct_counter, noncom_incorrect_counter,...
    com_correct_counter, com_incorrect_counter,nondecision_counter] = ...
    calculate_accuracies(dynamics_and_results, coherence)

coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

noncom_correct_counter = 0;
noncom_incorrect_counter = 0;
com_correct_counter = 0;
com_incorrect_counter = 0;
nondecision_counter = 0;


for i = 1:size(dynamics_and_results,1)
    if(coherence==dynamics_and_results(i).coherence_level)
        if(dynamics_and_results(i).motor_decision_made)
            if(dynamics_and_results(i).is_motor_correct)
                if(dynamics_and_results(i).is_motor_com)
                    if(check_com_advanced_condition(dynamics_and_results, i))
                        com_correct_counter = com_correct_counter+1;
                    end
                else
                    noncom_correct_counter = noncom_correct_counter+1;
                end
            elseif(dynamics_and_results(i).is_motor_com)
                if(check_com_advanced_condition(dynamics_and_results, i))
                    com_incorrect_counter = com_incorrect_counter+1;
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

 
function [itiscom] = check_com_advanced_condition(dynamics_and_results, index)

itiscom = false;
reached = find(dynamics_and_results(index).y_5>=17.4,1);
if(dynamics_and_results(index).is_motor_correct)
    reached = find(dynamics_and_results(index).y_6>=17.4,1);
end

x_traj = dynamics_and_results(index).y_6-dynamics_and_results(index).y_5;

if(dynamics_and_results(index).is_motor_correct)
    x_traj = dynamics_and_results(index).y_5-dynamics_and_results(index).y_6;
end

smoothed_trajectory = filter(ones(1,200)/200,1,x_traj);
delta_of_trajectory = diff(sign(smoothed_trajectory));

points_of_change = find(delta_of_trajectory);

if(size(points_of_change,2)<2)
    return;
end

for i=size(points_of_change,2):-1:2
    if(max(smoothed_trajectory(points_of_change(i-1):points_of_change(i)))>2)
        sign_of_response = sign(x_traj(reached));
        sign_of_max_point_in_bump =  sign(max(smoothed_trajectory(points_of_change(i-1):points_of_change(i))));
        
        
        if(sign_of_response *  sign_of_max_point_in_bump == -1)
            if(max(abs(smoothed_trajectory(points_of_change(i-1):points_of_change(i))))>2)
%                 figure;
%                 plot(smoothed_trajectory)
                itiscom=true;
                return;
            end

        end

    end
    
end

return

end

function[hand_initiation_time_mean, hand_initiation_time_std] = ...
    mean_z_std_all_times(dynamics_and_results)


counter = 0;


for i = 1:size(dynamics_and_results,1)
    counter = counter+1;
end

hand_initiation_time_gather = NaN(1,counter);
j=1;


for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).motor_decision_made)
        hand_initiation_time_gather(j)=dynamics_and_results(i).initiation_time;
    end
    j=j+1;
end

hand_initiation_time_mean = nanmean(hand_initiation_time_gather);
hand_initiation_time_std = nanstd(hand_initiation_time_gather);

return;
end


function [initiation_time_mean,initiation_time_std] = calculate_z_score(dynamics_and_results, coherence, ...
    is_motor_correct, is_motor_com, times_mean,times_std)

coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

counter = 0;

for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level ==...
            coherence && dynamics_and_results(i).is_motor_correct ==...
                 is_motor_correct && dynamics_and_results(i).motor_decision_made ...
                 && is_motor_com == dynamics_and_results(i).is_motor_com)
        counter = counter+1;
    end
end


initiation_time_gather = zeros(1,counter);

j=1;

for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == ...
            coherence && dynamics_and_results(i).is_motor_correct ==...
            is_motor_correct && dynamics_and_results(i).motor_decision_made ...
            && is_motor_com == dynamics_and_results(i).is_motor_com)
        
        value = dynamics_and_results(i).initiation_time;
        initiation_time_gather(j)=(value - times_mean)/times_std;
        
        j=j+1;
    end
end

initiation_time_mean = nanmean(initiation_time_gather);
initiation_time_std = nanstd(initiation_time_gather)/sqrt(size(initiation_time_gather,2));


return;
end