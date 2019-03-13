global legends;
global titles;
global export;
global figures_path;
global experiment_string;

experiment_string = 'exp1';
figures_path = '../figures_output/';

legends = true;
titles = false;
export = false;

is_first_correct= true;

coherence = 3.2;
is_motor_correct = true;
is_motor_com = true;
is_late_com = true;


[com_correct_gather]= gather_trajectories(dynamics_and_results,coherence,...
    is_motor_com, is_motor_correct);

% plot_all_trajectories(com_correct_gather,0,is_motor_com,is_motor_correct);

data_file_name=[figures_path 'Fig4_' experiment_string '.mat'];
data_file_name_csv=[figures_path 'Fig4_' experiment_string '.txt'];

header = {'timestamp,mouse_x'};


traj_index = randi([1 size(com_correct_gather,1)]);

x = com_correct_gather(traj_index,:); 
fig_1_data = [linspace(1,8000,8000); x]';

save(data_file_name, 'x');

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_1_data(1:end,:), '-append') ;

function [x_traj_gather] = gather_trajectories(dynamics_and_results,...
    coherence, is_motor_com, is_motor_correct)

x_lim=1920; %pixels.
resp_AOI_radius = 200;


target_x_position = (x_lim/2-resp_AOI_radius);
    
coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

counter = 0;
trial_length =  dynamics_and_results(1).trial_length;

for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com && dynamics_and_results(i).motor_decision_made)
        if(is_motor_com)
            if(check_com_advanced_condition(dynamics_and_results, i))
                counter = counter+1;
            end
        end
    end
end


y_5_gather = zeros(counter,trial_length);
y_6_gather = zeros(counter,trial_length);


j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com && dynamics_and_results(i).motor_decision_made)
        if(is_motor_com)
            if(check_com_advanced_condition(dynamics_and_results, i))
                y_5_gather(j,:)=dynamics_and_results(i).y_5;
                y_6_gather(j,:)=dynamics_and_results(i).y_6;
            end
        end
        j=j+1;
    end
end

if(is_motor_correct)
    tempo = (y_6_gather-y_5_gather);
    x_traj_gather = tempo * (target_x_position/max(tempo(:)));
else
    tempo = (y_5_gather-y_6_gather);
    x_traj_gather = tempo * (target_x_position/max(tempo(:)));
end

return;
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


function coherences = get_coherence_levels(dynamics_and_results)


coherences = zeros(1,size(dynamics_and_results,1));
for i=1:size(dynamics_and_results)
    coherences(i) = dynamics_and_results(i).coherence_level;
end

coherences = unique(coherences);

return
end