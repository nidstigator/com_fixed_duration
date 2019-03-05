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

coherence = 3.2;
is_motor_correct = true;
all_com = true;
is_motor_com = true;
is_late_com = true;


[com_correct_gather, com_correct_gather_eye]= gather_trajectories(dynamics_and_results,coherence,...
    is_motor_com, is_motor_correct,all_com, is_late_com);

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


data_file_name=[figures_path 'Fig4b_' experiment_string '.mat'];
data_file_name_csv=[figures_path 'Fig4b_' experiment_string '.txt'];

header = {'timestamp,eye_x'};


x = com_correct_gather_eye(traj_index,:); 
fig_1_data = [linspace(1,8000,8000); x]';

save(data_file_name, 'x');

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_1_data(1:end,:), '-append') ;



function [x_traj_gather, x_traj_gather_eye] = gather_trajectories(dynamics_and_results,...
    coherence, is_motor_com, is_motor_correct, all_com, is_late_com)

x_lim=1920; %pixels.
resp_AOI_radius = 200;


target_x_position = (x_lim/2-resp_AOI_radius);
    
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

y_3_gather = zeros(counter,trial_length);
y_4_gather = zeros(counter,trial_length);

j=1;
if(all_com)
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com)
            y_5_gather(j,:)=dynamics_and_results(i).y_5;
            y_6_gather(j,:)=dynamics_and_results(i).y_6;
            
            y_3_gather(j,:)=dynamics_and_results(i).y_3;
            y_4_gather(j,:)=dynamics_and_results(i).y_4;
            
            j=j+1;
        end
    end
else
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com && dynamics_and_results(i).is_late_com == is_late_com)
            y_5_gather(j,:)=dynamics_and_results(i).y_5;
            y_6_gather(j,:)=dynamics_and_results(i).y_6;
            
            y_3_gather(j,:)=dynamics_and_results(i).y_3;
            y_4_gather(j,:)=dynamics_and_results(i).y_4;
            j=j+1;
        end
    end
end
if(is_motor_correct)
    tempo = (y_6_gather-y_5_gather);
    tempo_eye = (y_4_gather-y_3_gather);
    x_traj_gather = tempo * (target_x_position/max(tempo(:)));
    x_traj_gather_eye = tempo_eye * (target_x_position/max(tempo(:)));
else
    tempo = (y_5_gather-y_6_gather);
    tempo_eye = (y_3_gather-y_4_gather);
    x_traj_gather = tempo * (target_x_position/max(tempo(:)));
    x_traj_gather_eye = tempo_eye * (target_x_position/max(tempo(:)));
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



function coherences = get_coherence_levels(dynamics_and_results)


coherences = zeros(1,size(dynamics_and_results,1));
for i=1:size(dynamics_and_results)
    coherences(i) = dynamics_and_results(i).coherence_level;
end

coherences = unique(coherences);

return
end