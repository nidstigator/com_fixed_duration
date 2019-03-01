% 
% %call functions to test:
close all;
clearvars -except dynamics_and_results dynamics_and_results_2nddecision;

global legends;
global titles;
global export;
global figures_path;
global experiment_string;

experiment_string = 'exp2';
figures_path = '../figures_output/';

legends = true;
titles = false;
export = false;


is_first_correct= true;
normalised = true;

tertiles_plot_prep(dynamics_and_results)

function tertiles_plot_prep(dynamics_and_results)
global figures_path;
global experiment_string;

[counter, decision_result_gather, coherence_gather] = ...
    get_decision_result(dynamics_and_results);


[initiation_time_com_incorrect_mean_gather] = ...
    calculate_mean_times(dynamics_and_results);

V0 = counter;
V1 = decision_result_gather;
V2 = coherence_gather;
V3 = normalise_custom(initiation_time_com_incorrect_mean_gather,max(initiation_time_com_incorrect_mean_gather),min(initiation_time_com_incorrect_mean_gather));

matrix_work = [V0;V1;V2;V3]';

%%%%WRITE to FILE:


data_file_name=[figures_path 'Fig6_' experiment_string '.mat'];
data_file_name_csv=[figures_path 'Fig6_' experiment_string '.txt'];

header = {'is_com,coherence,hand_IT'};


x = matrix_work;
fig_1_data = x;

save(data_file_name, 'x');

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_1_data(1:end,:), '-append') ;


%%%%DONE WRITING
end
function[trial_number, decision_result_gather, coherence_gather] = ...
    get_decision_result(dynamics_and_results)



counter = 0;

for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).motor_decision_made)
        counter = counter+1;
    end
end

decision_result_gather = zeros(1, counter);
coherence_gather = zeros(1, counter);
trial_number = zeros(1, counter);
j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).motor_decision_made)
        decision_result_gather(j) = dynamics_and_results(i).is_motor_com;
        coherence_gather(j) = dynamics_and_results(i).coherence_level;
        trial_number(j) = j;
        j=j+1;
    end
end


return;

end

function[initiation_time_gather] = ...
    calculate_mean_times(dynamics_and_results)



counter = 0;


for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).motor_decision_made)
        counter = counter+1;
    end
end


initiation_time_gather = zeros(1,counter);

j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).motor_decision_made)
        initiation_time_gather(j)=dynamics_and_results(i).initiation_time -dynamics_and_results(i).stim_onset ;
        j=j+1;
    end
end

return;
end

function [normalised_vector] = normalise_custom(vector,max,min)

normalised_vector = zeros(1,size(vector,2));

for i=1:size(vector,2)
    normalised_vector(i) = (vector(i)-min)/(max-min);
end
return;
end

