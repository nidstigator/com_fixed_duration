% 
% %call functions to test:
close all;
clearvars -except dynamics_and_results dynamics_and_results_2nddecision;

global legends;
global titles;
global export;
global figures_path;
global experiment_string;

experiment_string = '';
figures_path = '../../output/csv/';

legends = true;
titles = false;
export = false;


is_first_correct= true;
normalised = true;

tertiles_plot_prep(dynamics_and_results)

function tertiles_plot_prep(dynamics_and_results)
global figures_path;
global experiment_string;

[counter, decision_result_gather, uncertainty_gather,...
    coherence_gather] = ...
    get_decision_uncertainty(dynamics_and_results);

V0 = counter;
V1 = decision_result_gather;
V2 = coherence_gather;
V3 = normalise_custom(uncertainty_gather, max(uncertainty_gather), min(uncertainty_gather));

matrix_work = [V0;V1;V2;V3]';

%%%%WRITE to FILE:


data_file_name_csv=[figures_path 'model_tertiles_uncertainty' experiment_string '.txt'];

header = {'is_com,coherence,uncertainty'};


x = matrix_work;
fig_1_data = x;


fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_1_data(1:end,:), '-append') ;


%%%%DONE WRITING

end
function[trial_number, decision_result_gather, uncertainty_gather, coherence_gather] = ...
    get_decision_uncertainty(dynamics_and_results)



counter = 0;

for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).motor_decision_made)
        counter = counter+1;
    end
end

decision_result_gather = zeros(1, counter);
uncertainty_gather = zeros(1, counter);
coherence_gather = zeros(1, counter);
trial_number = zeros(1, counter);
j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).motor_decision_made)
        if(dynamics_and_results(i).is_motor_com)
            if(check_com_advanced_condition(dynamics_and_results, i))
                decision_result_gather(j) = dynamics_and_results(i).is_motor_com;
            else
                decision_result_gather(j) = false;
            end
        else
            decision_result_gather(j) = false;
        end
        uncertainty_gather(j) = max(dynamics_and_results(i).y_mc_hu);
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
        initiation_time_gather(j)=dynamics_and_results(i).initiation_time;
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

plot(smoothed_trajectory)
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
                itiscom=true;
                return;
            end
        end

    end
    
end

return

end