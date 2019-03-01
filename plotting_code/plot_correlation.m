% 
clearvars -except dynamics_and_results dynamics_and_results_2nddecision;

global legends;
global titles;
global export;
global figures_path;

figures_path = '../figures_output/Figure3/';

legends = true;
titles = false;
export = false;


is_first_correct= true;
normalised = true;

plot_response_time_uncertainty_correlation(dynamics_and_results)

function plot_response_time_uncertainty_correlation(dynamics_and_results)

[x_max] = ...
    calculate_x_pattern(dynamics_and_results);


[initiation_time_com_incorrect_mean_gather] = ...
    calculate_mean_times(dynamics_and_results);

corrcoef(x_max,initiation_time_com_incorrect_mean_gather)

V1 = normalise_custom(x_max,max(x_max),min(x_max));
V2 = normalise_custom(initiation_time_com_incorrect_mean_gather,max(initiation_time_com_incorrect_mean_gather),min(initiation_time_com_incorrect_mean_gather));



[~, c] = find(V1 == 0);
V1(c) = NaN;
V2(c) = NaN;

mdl = fitlm(V1,V2);
mdl.plot;

title(strcat('R² = ', num2str(sprintf('%.3f',mdl.Rsquared.Ordinary))))
pubgraph(gcf,28,1,'w');
xlabel('Normalised uncertainty')
ylabel('RT')
set(gcf, 'Position', [79 422 560 420])

end
function[maxes_hu_of_each_trial] = ...
    calculate_x_pattern(dynamics_and_results)


counter = 0;

trial_length =  dynamics_and_results(1).trial_length;


for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).motor_decision_made)
        counter = counter+1;
    end
end

y_mc_hu_gather = zeros(counter,trial_length);

j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).motor_decision_made)
        y_mc_hu_gather(j,:)=dynamics_and_results(i).y_mc_hu;
        j=j+1;
    end
end


% Max of each trial

maxes_hu_of_each_trial =zeros(1,size(y_mc_hu_gather,1));
for i = 1:size(y_mc_hu_gather,1)
    maxes_hu_of_each_trial(i) = max(y_mc_hu_gather(i,:));
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

