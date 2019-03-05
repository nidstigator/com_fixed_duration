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


% plot_accuracies_and_pcom(dynamics_and_results);
calculate_eye_hand_lag(dynamics_and_results)

function[] = calculate_eye_hand_lag(dynamics_and_results)
global figures_path;
global experiment_string;

counter = 0;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).com_initiation_point_hand ~=0 && dynamics_and_results(i).com_initiation_point_eye ~=0)
        counter = counter+1;
    end 
end


hand_gather = zeros(1,counter);
eye_gather = zeros(1,counter);

j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).is_not_com_eye == 0 && dynamics_and_results(i).motor_decision_made && dynamics_and_results(i).is_motor_com && ~dynamics_and_results(i).is_not_com_eye)
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

data_file_name=[figures_path 'Fig3_c' experiment_string '.mat'];
data_file_name_csv=[figures_path 'Fig3_c_' experiment_string '.txt'];
header = {'lag'};

fig3_c = lag';

save(data_file_name, 'lag');

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig3_c(1:end,:), '-append') ;

end

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

p_late_com_correct = zeros(1,n_of_coherences);
p_late_com_incorrect = zeros(1,n_of_coherences);

late_com_correct = zeros(1,n_of_coherences);
late_com_incorrect = zeros(1,n_of_coherences);

p_correct = zeros(1,n_of_coherences);
p_correct_noncom = zeros(1,n_of_coherences);
p_nondecision = zeros(1,n_of_coherences);

for i=1:n_of_coherences
    coherence= coherences(i);
    
    [noncom_correct_counter, noncom_incorrect_counter,...
        com_correct_counter, com_incorrect_counter, com_late_correct_counter, com_late_incorrect_counter, nondecision_counter] = ...
        calculate_accuracies(dynamics_and_results, coherence);
    
    
    
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

data_file_name=[figures_path 'Fig3_ab_' experiment_string '.mat'];
data_file_name_csv=[figures_path 'Fig3_ab_' experiment_string '.txt'];
header = {'p_com_all,p_com_correct,pcom_incorrect'};

fig3_ab_data = [p_com',...
    p_com_correct',p_com_incorrect'];

save(data_file_name, 'p_com',...
    'p_com_correct','p_com_incorrect');

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
    com_correct_counter, com_incorrect_counter, com_late_correct_counter, com_late_incorrect_counter,nondecision_counter] = ...
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

com_late_correct_counter = 0;
com_late_incorrect_counter = 0;


for i = 1:size(dynamics_and_results,1)
    if(coherence==dynamics_and_results(i).coherence_level)
        if(dynamics_and_results(i).motor_decision_made)
            if(dynamics_and_results(i).is_motor_correct)
                if(dynamics_and_results(i).is_motor_com)
                    if(check_com_advanced_condition(dynamics_and_results, i))
                        com_correct_counter = com_correct_counter+1;
                        if(dynamics_and_results(i).is_late_com)
                            com_late_correct_counter= com_late_correct_counter +1;
                        end
                    end
                else
                    noncom_correct_counter = noncom_correct_counter+1;
                end
            elseif(dynamics_and_results(i).is_motor_com)
                if(check_com_advanced_condition(dynamics_and_results, i))
                    com_incorrect_counter = com_incorrect_counter+1;
                    if(dynamics_and_results(i).is_late_com)
                        com_late_incorrect_counter= com_late_incorrect_counter +1;
                    end
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

 