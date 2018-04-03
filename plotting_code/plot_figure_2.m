%First plot: Psychometric function, split CoM/NON-CoM.
%Second plot: Mouse-IT (z_scored).
%Third plot: Eye-IT (z_scored).

global legends;
global titles;
global export;
global figures_path;

figures_path = './figures/';

legends = true;
titles = false;
export = false;

is_first_correct= true;
normalised = true;



plot_accuracies_and_pcom(dynamics_and_results,is_first_correct,normalised);


function coherences = get_coherence_levels(dynamics_and_results)


coherences = zeros(1,size(dynamics_and_results,1));
for i=1:size(dynamics_and_results)
    coherences(i) = dynamics_and_results(i).coherence_level;
end

coherences = unique(coherences);

return
end


function plot_accuracies_and_pcom(dynamics_and_results, is_first_correct,normalised)
global legends;
global titles;
global export;
global figures_path;
coherences = get_coherence_levels(dynamics_and_results);
n_of_coherences= size(coherences,2);

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


coupled = isfield(dynamics_and_results,'is_first_correct');

for i=1:n_of_coherences
    coherence= coherences(i);
    
    [noncom_correct_counter, noncom_incorrect_counter,...
        com_correct_counter, com_incorrect_counter, com_late_correct_counter, com_late_incorrect_counter, nondecision_counter] = ...
        calculate_accuracies(dynamics_and_results, coherence, is_first_correct, coupled);
    
    all_trials = noncom_correct_counter+ noncom_incorrect_counter ...
        +com_correct_counter + com_incorrect_counter;
   
    p_correct(i) = (noncom_correct_counter+com_correct_counter)/all_trials;
    p_correct_noncom(i) = (noncom_correct_counter)/all_trials;
    p_nondecision(i)= nondecision_counter/all_trials;
    

 
    
end


all_times=[initiation_time_noncom_correct_mean_gather initiation_time_noncom_incorrect_mean_gather initiation_time_com_correct_mean_gather initiation_time_com_correct_mean_gather];
times_mean = nanmean(all_times);
times_std = nanstd(all_times);


all_stds=[initiation_time_noncom_correct_std_gather initiation_time_noncom_incorrect_std_gather initiation_time_com_correct_std_gather initiation_time_com_incorrect_std_gather];
stds_mean = nanmean(all_stds);
stds_std = nanstd(all_stds);

% %%%%%%%%Fig1: Psychometric function for CoM/non-com.
% 
% %%%% fit method and options
% ft = fittype( '1-0.5*exp(-(x/a).^b)', 'independent', 'x', 'dependent', 'y' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [0.614470693004768 0.576683497398345];
% 
% % Fit model to data.
% [fitresult, gof] = fit( [0,3.2,6.4,12.8,25.6,51.2]', p_correct', ft, opts );
% 
% %%% extract data from fitted curve
% figuretemp = figure;
% plot(fitresult);
% h = findobj(figuretemp,'Type','line');
% x=get(h,'Xdata');
% y=get(h,'Ydata');
% close;
% %%%%%%%
% 
% 
% figure3=figure;
% plot(x,y,'LineWidth', 6,'Color',[0 0 0]);
% hold on;
% scatter([0,3.2,6.4,12.8,25.6,51.2],p_correct,'o','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor', [0 0 0]);
% xlabel('Coherence level c` (%)');
% ylabel('Probability correct');
% xlim([0,51.2]);
% pubgraph(figure3,18,4,'w')
% title_string = 'Choice accuracy';
% 
% 
% if(legends)
%     %legend('show');
% end
% if(titles)
%     title(title_string);
% end
% 
% if(export)
% export_path = [figures_path  title_string];
% export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-r300','-q101', '-cmyk','-painters');
% savefig(export_path);
% end
% 
% %%%%%%%%

%%%%%%%%Figure2: Initiation times (z-scored)

[times_mean,times_std]=mean_z_std_all_times(dynamics_and_results);


for i=1:n_of_coherences
    coherence= coherences(i);
    [initiation_time_noncom_correct_mean_gather(i),initiation_time_noncom_correct_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        true, false, is_first_correct, coupled,times_mean,times_std);
    
    [initiation_time_noncom_incorrect_mean_gather(i),initiation_time_noncom_incorrect_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        false, false, is_first_correct, coupled,times_mean,times_std);
    
    [initiation_time_com_correct_mean_gather(i),initiation_time_com_correct_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        true, true, is_first_correct, coupled,times_mean,times_std);
    
    [initiation_time_com_incorrect_mean_gather(i),initiation_time_com_incorrect_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        false, true, is_first_correct, coupled,times_mean,times_std);
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

% scatter([0,3.2,6.4,12.8,25.6,51.2],normalised_initiation_time_noncom_correct,'o','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor', [0 0 1]);
% scatter([0,3.2,6.4,12.8,25.6,51.2],normalised_initiation_time_noncom_incorrect,'o','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor', [1 0 0]);

xlim(axes1,[1 6]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

xlabel('Coherence level c` (%)');
ylabel('Initiation time z-score');
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


function[initiation_time_mean, initiation_time_std] = ...
    mean_z_std_all_times(dynamics_and_results)


counter = 0;


for i = 1:size(dynamics_and_results,1)
    counter = counter+1;
end

initiation_time_gather = zeros(1,counter);

j=1;

for i = 1:size(dynamics_and_results,1)
    initiation_time_gather(j)=dynamics_and_results(i).initiation_time;
    j=j+1;
end


initiation_time_mean = nanmean(initiation_time_gather);
initiation_time_std = nanstd(initiation_time_gather);

return;
end

function [normalised_vector] = normalise_custom(vector,max,min)

normalised_vector = zeros(1,size(vector,2));

for i=1:size(vector,2)
    normalised_vector(i) = (vector(i)-min)/(max-min);
end
return;
end

function [initiation_time_mean,initiation_time_std] = calculate_z_score(dynamics_and_results, coherence, ...
    is_motor_correct, is_motor_com, is_first_correct, coupled,times_mean,times_std)

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

j=1;
if(~coupled)
    for i = 1:size(dynamics_and_results,1)
        if(dynamics_and_results(i).coherence_level == ...
                coherence && dynamics_and_results(i).is_motor_correct ==...
                is_motor_correct && dynamics_and_results(i).is_motor_com ==...
                is_motor_com)
            initiation_time_gather(j)=(dynamics_and_results(i).initiation_time - times_mean)/times_std;
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
            initiation_time_gather(j)=(dynamics_and_results(i).initiation_time - times_mean)/times_std;
            j=j+1;
        end
    end
end

initiation_time_mean = mean(initiation_time_gather);
initiation_time_std = std(initiation_time_gather)/sqrt(size(initiation_time_gather,2));


return;
end


function [normalised_std] = normalise_std(std,max,min)

normalised_std= std/(max-min);


return;

end