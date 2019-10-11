%First plot: Psychometric function, split CoM/NON-CoM.
%Second plot: Mouse-IT (z_scored).

global legends;
global titles;
global export;
global figures_path;
global experiment_string;

experiment_string = '';
figures_path = '../../../output/csv/';

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

init_times = zeros(1,n_of_coherences);

init_times_std = zeros(1,n_of_coherences);

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

data_file_name_csv_2=[figures_path 'eDDM_psychometric' experiment_string '.txt'];
header_2 = {'pcorrect_x_real,pcorrect_y_real'};

coherences = [0,3.2,6.4,12.8,25.6,51.2];

fig_1_data_2 = [coherences',p_correct'];


fid = fopen(data_file_name_csv_2, 'w') ;
fprintf(fid, '%s,', header_2{1,1:end-1}) ;
fprintf(fid, '%s\n', header_2{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv_2, fig_1_data_2(1:end,:), '-append') ;


%%% COM save:

data_file_name_csv_2=[figures_path 'eDDM_psychometric_CoM' experiment_string '.txt'];
header_2 = {'pcorrect_x_real,pcorrect_y_real'};

coherences = [0,3.2,6.4,12.8,25.6,51.2];

fig_1_data_2 = [coherences',p_correct_com'];

fid = fopen(data_file_name_csv_2, 'w') ;
fprintf(fid, '%s,', header_2{1,1:end-1}) ;
fprintf(fid, '%s\n', header_2{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv_2, fig_1_data_2(1:end,:), '-append') ;

%%%%%%%

%%%%%%%%Figure2: Initiation times

coherences = [0,3.2,6.4,12.8,25.6,51.2];
for i=1:n_of_coherences
    coherence= coherences(i);
    [init_times(i),init_times_std(i)] = ...
        calculate_init_times(dynamics_and_results, coherence);  
end

figure4=figure;
axes1 = axes('Parent',figure4);
hold on;

errorbar(init_times,...
    init_times_std...
    ,'LineWidth', 2,'DisplayName',...
    'correct','Color',[0 0 0]);

xlim(axes1,[1 6]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

xlabel('Coherence level c` (%)');
ylabel('Response time (ms)');
pubgraph(figure4,18,4,'w')
title_string = 'Initiation times v.s coherence level';
if(legends)
end
if(titles)
    title(title_string);
end


data_file_name_csv=[figures_path 'eDDM_response_times' experiment_string '.txt'];
header = {'init_times,init_times_sem'};

fig_2c_data = [init_times',...
    init_times_std'];

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_2c_data(1:end,:), '-append') ;

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

itiscom = true;
return;

end


function [initiation_time_mean,initiation_time_std] = ...
    calculate_init_times(dynamics_and_results, coherence)

coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

counter = 0;

for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level ==...
            coherence && dynamics_and_results(i).motor_decision_made)
        counter = counter+1;
    end
end


initiation_time_gather = zeros(1,counter);

j=1;

for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level ==...
            coherence && dynamics_and_results(i).motor_decision_made)
        
        value = dynamics_and_results(i).initiation_time;
        initiation_time_gather(j)=value;
        
        j=j+1;
    end
end

initiation_time_mean = nanmean(initiation_time_gather);
initiation_time_std = nanstd(initiation_time_gather)/sqrt(size(initiation_time_gather,2));


return;
end