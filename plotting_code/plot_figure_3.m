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


plot_accuracies_and_pcom(dynamics_and_results);

function plot_accuracies_and_pcom(dynamics_and_results)
global legends;
global titles;
global export;
global figures_path;
global experiment_string;

coherences = get_coherence_levels(dynamics_and_results);
n_of_coherences= size(coherences,2);

p_com = zeros(1,n_of_coherences);
p_com_correct = zeros(1,n_of_coherences);
p_com_incorrect = zeros(1,n_of_coherences);

com_correct = zeros(1,n_of_coherences);
com_incorrect = zeros(1,n_of_coherences);

p_correct = zeros(1,n_of_coherences);
p_correct_noncom = zeros(1,n_of_coherences);
p_nondecision = zeros(1,n_of_coherences);

for i=1:n_of_coherences
    coherence= coherences(i);
    
    [noncom_correct_counter, noncom_incorrect_counter,...
        com_correct_counter, com_incorrect_counter, nondecision_counter] = ...
        calculate_accuracies(dynamics_and_results, coherence);
    
    
    
    all_trials = noncom_correct_counter+ noncom_incorrect_counter ...
        +com_correct_counter + com_incorrect_counter;
    p_com_incorrect(i) = com_incorrect_counter/all_trials;
    p_com_correct(i) = com_correct_counter/all_trials;
    com_correct(i) = com_correct_counter;
    com_incorrect(i) = com_incorrect_counter;
    p_com(i)=(com_correct_counter+com_incorrect_counter)/all_trials;
    p_correct(i) = (noncom_correct_counter+com_correct_counter)/all_trials;
    p_correct_noncom(i) = (noncom_correct_counter)/all_trials;
    p_nondecision(i)= nondecision_counter/all_trials;
   
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
xlabel(['Evidence quality ',char(949), ' (%)']);
ylabel('Change-of-mind trials (%)');
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

data_file_name_csv=[figures_path 'p_com' experiment_string '.txt'];
header = {'p_com_all,p_com_correct,pcom_incorrect'};

fig3_ab_data = [p_com',...
    p_com_correct',p_com_incorrect'];

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig3_ab_data(1:end,:), '-append') ;



%%%%%%%%
end
function coherences = get_coherence_levels(dynamics_and_results)


coherences = zeros(1,size(dynamics_and_results,1));
for i=1:size(dynamics_and_results)
    coherences(i) = dynamics_and_results(i).coherence_level;
end

coherences = unique(coherences);

return
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
                itiscom=true;
                return;
            end
        end

    end
    
end

return

end