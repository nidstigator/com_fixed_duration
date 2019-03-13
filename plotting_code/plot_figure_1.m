% 
% %call functions to test:
close all;
% clearvars -except dynamics_and_results dynamics_and_results_2nddecision;

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
normalised = true;


is_motor_correct = true;
is_motor_com = false;

[y_1, y_2, y_mc_hu, y_5, y_6] = ...
    calculate_mean_activity(dynamics_and_results, 3.2, ...
    is_motor_correct, is_motor_com);

[y_1_25, y_2_25, y_mc_hu_25, y_5_25, y_6_25] = ...
    calculate_mean_activity(dynamics_and_results, 25.6, ...
    is_motor_correct, is_motor_com);

is_single_trial = false;


plot_main_panel_modified(y_1,y_2,y_5,y_6,y_mc_hu,y_1_25,y_2_25,y_5_25,y_6_25,y_mc_hu_25)

plot_x_pattern(dynamics_and_results,normalised);

plot_accuracy_vs_uncertainty(dynamics_and_results,normalised)

function plot_accuracy_vs_uncertainty(dynamics_and_results,normalised)
global titles;
global export;
global figures_path;
global experiment_string;


coherences = get_coherence_levels(dynamics_and_results);
n_of_coherences= size(coherences,2);

p_correct = zeros(1,n_of_coherences);
x_correct_max = zeros(1,n_of_coherences);
x_incorrect_max = zeros(1,n_of_coherences);

x_correct_max_std = zeros(1,n_of_coherences);
x_incorrect_max_std = zeros(1,n_of_coherences);

for i=1:n_of_coherences
   coherence= coherences(i);
    
    [noncom_correct_counter, noncom_incorrect_counter,...
        com_correct_counter, com_incorrect_counter, ~, ~, ~] = ...
        calculate_accuracies(dynamics_and_results, coherence);
    
    all_trials = noncom_correct_counter+ noncom_incorrect_counter ...
        +com_correct_counter + com_incorrect_counter;
    [noncom_correct_counter, ~,...
        com_correct_counter, ~, ~, ~, ~] = ...
        calculate_accuracies(dynamics_and_results, coherence);
    
    p_correct(i) = (noncom_correct_counter+com_correct_counter)/all_trials;
    [x_correct_max(i), x_correct_max_std(i), ~,~] = ...
        calculate_x_pattern(dynamics_and_results, coherence, true);
    
    [x_incorrect_max(i), x_incorrect_max_std(i), ~,~] = ...
        calculate_x_pattern(dynamics_and_results, coherence, false);
    
end

confidence_max(1,:)= nanmean([x_correct_max; x_incorrect_max]);
if(normalised)
    confidence_max = normalise_custom(confidence_max, max(confidence_max), min(confidence_max));
end

%%%%%%%%Plot7: Accuracy v.s Uncertainty using peak.

title_string = 'Accuracy v.s uncertainty';
x_string = 'Uncertainty \upsilon (%)';


% [fitObject, gof] = fit(confidence_max',p_correct','poly1');

confidence_max(:,6) = [];
p_correct(:,6) = [];

% Set up fittype and options.
ft = fittype( 'smoothingspline' );
opts = fitoptions( 'Method', 'SmoothingSpline' );
opts.Normalize = 'on';
opts.SmoothingParam = 0.914519350220469;

% Fit model to data.
[fitObject, ~] = fit( confidence_max', p_correct', ft, opts );

%%% extract data from fitted curve
figuretemp = figure;
plot(fitObject);
h = findobj(figuretemp,'Type','line');
x=get(h,'Xdata');
y=get(h,'Ydata');
close;
%%%%%%%


figure7=figure;

plot(x,y,'LineWidth', 2,'Color',[0 0 0]);
hold on;

scatter(confidence_max,p_correct,'o','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor', [0 0 0]);
yticklabels({'60','65','70','75','80','85','90','100'})
ylim([0.6,1.01])
xlim([0.79, 1.0])
xticklabels({'80','85','90','95','100'});
xticks([0.8, 0.85, 0.9, 0.95, 1])
ylabel('Accuracy p (%)');
xlabel(x_string);
pubgraph(figure7,18,4,'w')


data_file_name_1=[figures_path 'Fig1_d1_' experiment_string '.mat'];
data_file_name_2=[figures_path 'Fig1_d2_' experiment_string '.mat'];
data_file_name_csv_1=[figures_path 'Fig1_d1_' experiment_string '.txt'];
data_file_name_csv_2=[figures_path 'Fig1_d2_' experiment_string '.txt'];
header_1 = {'x_fit,y_fit'};
header_2 = {'x_real,y_real'};

fig_1_data_1 = [x',y'];
fig_1_data_2 = [confidence_max',p_correct'];

save(data_file_name_1, 'x','y');
save(data_file_name_2, 'confidence_max','p_correct');

fid = fopen(data_file_name_csv_1, 'w') ;
fprintf(fid, '%s,', header_1{1,1:end-1}) ;
fprintf(fid, '%s\n', header_1{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv_1, fig_1_data_1(1:end,:), '-append') ;

fid = fopen(data_file_name_csv_2, 'w') ;
fprintf(fid, '%s,', header_2{1,1:end-1}) ;
fprintf(fid, '%s\n', header_2{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv_2, fig_1_data_2(1:end,:), '-append') ;

if(titles)
    title(title_string);
end

if(export)
export_path = [figures_path  'accuracyvsuncertainty'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end
%%%%%%%%

end
function plot_x_pattern(dynamics_and_results,normalised)

global legends;
global titles;
global export;
global experiment_string;

global figures_path;
coherences = get_coherence_levels(dynamics_and_results);
n_of_coherences= size(coherences,2);

x_correct_max = zeros(1,n_of_coherences);
x_incorrect_max = zeros(1,n_of_coherences);
x_correct_max_std = zeros(1,n_of_coherences);
x_incorrect_max_std = zeros(1,n_of_coherences);

x_correct_integral = zeros(1,n_of_coherences);
x_correct_integral_std = zeros(1,n_of_coherences);
x_incorrect_integral = zeros(1,n_of_coherences);
x_incorrect_integral_std = zeros(1,n_of_coherences);

for i=1:n_of_coherences
    coherence = coherences(i);
    [x_correct_max(i), x_correct_max_std(i),...
        x_correct_integral(i), x_correct_integral_std(i)] = ...
        calculate_x_pattern(dynamics_and_results, coherence, true);
        
    [x_incorrect_max(i), x_incorrect_max_std(i),...
        x_incorrect_integral(i),x_incorrect_integral_std(i)] = ...
        calculate_x_pattern(dynamics_and_results, coherence, false);
end

%%%% HU stuff:
x_max_all = [x_correct_max,x_incorrect_max];
max_bound_peak = max(x_max_all);
min_bound_peak = min(x_max_all);

integral_all = [x_correct_integral,x_incorrect_integral];
max_bound_integral = max(integral_all);
min_bound_integral = min(integral_all);

x_correct_max = normalise_custom(x_correct_max,max_bound_peak,min_bound_peak);
x_correct_max_std = normalise_std(x_correct_max_std,max_bound_peak,min_bound_peak);

x_incorrect_max = normalise_custom(x_incorrect_max,max_bound_peak,min_bound_peak);
x_incorrect_max_std = normalise_std(x_incorrect_max_std,max_bound_peak,min_bound_peak);

x_correct_integral = normalise_custom(x_correct_integral,max_bound_integral,min_bound_integral);
x_correct_integral_std = normalise_std(x_correct_integral_std,max_bound_integral,min_bound_integral);

x_incorrect_integral = normalise_custom(x_incorrect_integral,max_bound_integral,min_bound_integral);
x_incorrect_integral_std = normalise_std(x_incorrect_integral_std,max_bound_integral,min_bound_integral);
%%%%%


%%%%%%%%Plot1: Confidence (X-Pattern) using Peak.


figure1=figure;
axes1 = axes('Parent',figure1);
hold on;
errorbar(x_correct_max*100,x_correct_max_std*100, 'LineWidth', 2,'DisplayName',...
    'correct','Color',[0.1172    0.5625    1.0000]);
errorbar(x_incorrect_max*100,x_incorrect_max_std*100, 'LineWidth', 2,'DisplayName',...
    'error','Color',[0.8594    0.0781    0.2344]);

xlim(axes1,[1 6]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

xlabel('Coherence leve? c` (%)');

title_string = 'Uncertainty v.s Accuracy using Peak';
y_string = 'Peak firing rate of Mean HU Activity (Hz)';

if(normalised)
    title_string = 'Uncertainty v.s Accuracy using Peak Value (Normalised)';
    y_string= 'Uncertainty \upsilon (%)';
end

ylabel(y_string);
pubgraph(figure1,18,4,'w')
ylim([-1,110]);

data_file_name=[figures_path 'Fig1_c_' experiment_string '.mat'];
data_file_name_csv=[figures_path 'Fig1_c_' experiment_string '.txt'];
header = {'x_correct,x_correct_sem,x_error,x_error_sem'};

fig_1_data = [x_correct_max'*100,x_correct_max_std'*100,x_incorrect_max'*100,x_incorrect_max_std'*100,];

save(data_file_name, 'x_correct_max','x_correct_max_std','x_incorrect_max','x_incorrect_max_std');

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_1_data(1:end,:), '-append') ;


if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end

if(export)
export_path = [figures_path  'uncertaintyusingpeak'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end
%%%%%%%%

end

function plot_main_panel_modified(y_1,y_2,y_5,y_6,y_mc_hu,y_1_25,y_2_25,y_5_25,y_6_25,y_mc_hu_25)

global legends;
global titles;
global export;
global figures_path;
global experiment_string;

large_left= 'c`=25.6%, left';
large_right = 'c`=25.6%, right';

small_left= 'c`=3.2%, left';
small_right = 'c`=3.2%, right';


large = 'c`=51.2%';
small = 'c`=3.2%';

figure1=figure;
subplot(3,1,1);
title('Sensorimotor');
hold on;
plot(y_1_25(1:2:end),'Color',[0.1172    0.5625    1.0000],'DisplayName',large_left);
plot(y_2_25(1:2:end),'Color',[1.0000    0.4961    0.3125],'DisplayName',large_right);
plot(y_1(1:2:end),'LineStyle','--','Color',[0.1172    0.5625    1.0000],'DisplayName',small_left);
plot(y_2(1:2:end),'LineStyle','--','Color',[1.0000    0.4961    0.3125],'DisplayName',small_right);
xlim([700,2500]);
xticks(['','',''])
xticklabels({'','',''})
if(legends)
    legend('show');
end
if(titles)
   title(['Decision' title_string]);
end


subplot(3,1,2);
title('Uncertainty Monitoring');
hold on;
plot(y_mc_hu_25(1:2:end),'Color',[1 0 0],'DisplayName',large);
plot(y_mc_hu(1:2:end),'LineStyle','--','Color',[1 0 0],'DisplayName',small);
xlim([700,2500]);
xticks(['','',''])
xticklabels({'','',''})
if(legends)
    legend('show');
end
if(titles)
    title(['Uncertainty monitoring' title_string]);
end
ylabel('Firing rate (Hz)');

subplot(3,1,3);
title('Hand');
hold on;
plot(y_5_25(1:2:end),'Color',[0.1172    0.5625    1.0000]);
plot(y_6_25(1:2:end),'Color',[1.0000    0.4961    0.3125]);
plot(y_5(1:2:end),'LineStyle','--','Color',[0.1172    0.5625    1.0000]);
plot(y_6(1:2:end),'LineStyle','--','Color',[1.0000    0.4961    0.3125]);
xlim([700,2500]);
xticks(['','',''])
xticklabels({'','',''})
xticks([700,1500,2500])
xticklabels({'0','1500', '2500'})
pubgraph(figure1,18,4,'w');

if(titles)
    title(['Motor output' title_string]);
end




data_file_name=[figures_path 'Fig1_b_' experiment_string '.mat'];
data_file_name_csv=[figures_path 'Fig1_b_' experiment_string '.txt'];
header = {'y_1_25','y_2_25','y_5_25','y_6_25','y_mc_hu_25','y_1','y_2','y_5','y_6','y_mc_hu'};

fig_1_data = [y_1_25', y_2_25', y_5_25', y_6_25', y_mc_hu_25', y_1', y_2', y_5', y_6', y_mc_hu'];

save(data_file_name, 'y_1_25','y_2_25','y_5_25'...
    ,'y_5_25','y_6_25','y_mc_hu_25','y_1','y_2',...
    'y_5','y_6','y_mc_hu');

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_1_data(1:end,:), '-append') ;


if(export)
export_path = [figures_path  'new_panel'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end
end

function[y_1_mean, y_2_mean, y_mc_hu_mean, y_5_mean,...
    y_6_mean] = ...
    calculate_mean_activity(dynamics_and_results, coherence, ...
    is_motor_correct, is_motor_com)

coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

counter = 0;
trial_length =  dynamics_and_results(1).trial_length;

%get number of each type, before initialising vectors.


for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).motor_decision_made && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com)
        counter = counter+1;
    end
end

y_1_gather = zeros(counter,trial_length);
y_2_gather = zeros(counter,trial_length);
y_mc_hu_gather = zeros(counter,trial_length);
y_5_gather = zeros(counter,trial_length);
y_6_gather = zeros(counter,trial_length);


j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).motor_decision_made && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com)
        y_1_gather(j,:)=dynamics_and_results(i).y_1;
        y_2_gather(j,:)=dynamics_and_results(i).y_2;
        y_mc_hu_gather(j,:)=dynamics_and_results(i).y_mc_hu;
        y_5_gather(j,:)=dynamics_and_results(i).y_5;
        y_6_gather(j,:)=dynamics_and_results(i).y_6;
        j=j+1;
    end
end


% Non CoM Correct Mean
y_1_mean(1,:) = mean(y_1_gather);
y_2_mean(1,:) = mean(y_2_gather);
y_mc_hu_mean(1,:) = mean(y_mc_hu_gather);
y_5_mean(1,:) = mean(y_5_gather);
y_6_mean(1,:) = mean(y_6_gather);
return;
end


function coherences = get_coherence_levels(dynamics_and_results)


coherences = zeros(1,size(dynamics_and_results,1));
for i=1:size(dynamics_and_results)
    coherences(i) = dynamics_and_results(i).coherence_level;
end

coherences = unique(coherences);

return
end

function[max_hu, std_hu, integral_hu, integral_hu_std] = ...
    calculate_x_pattern(dynamics_and_results, coherence, is_motor_correct)

coherences = get_coherence_levels(dynamics_and_results);

if(~ismember(coherence,coherences))
    error('coherence level not found in data');
end

counter = 0;

trial_length =  dynamics_and_results(1).trial_length;


for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence &&...
            dynamics_and_results(i).is_motor_correct == is_motor_correct...
            && dynamics_and_results(i).motor_decision_made)
        counter = counter+1;
    end
end

y_mc_hu_gather = zeros(counter,trial_length);

j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence &&...
            dynamics_and_results(i).is_motor_correct == is_motor_correct...
            && dynamics_and_results(i).motor_decision_made)
        y_mc_hu_gather(j,:)=dynamics_and_results(i).y_mc_hu;
        j=j+1;
    end
end


% Max of each trial

maxes_hu_of_each_trial =zeros(1,size(y_mc_hu_gather,1));
for i = 1:size(y_mc_hu_gather,1)
    maxes_hu_of_each_trial(i) = max(y_mc_hu_gather(i,:));
end


%%% calculate x_pattern by peak
max_hu = nanmean(maxes_hu_of_each_trial);
std_hu = nanstd(maxes_hu_of_each_trial)/sqrt(size(maxes_hu_of_each_trial,2));

y_mc_hu_mean(1,:) = mean(y_mc_hu_gather);

integral_hu_of_each_trial =zeros(1,size(y_mc_hu_gather,1));
for i = 1:size(y_mc_hu_gather,1)
    integral_hu_of_each_trial(i) = trapz(y_mc_hu_gather(i,:));
end

integral_hu = nanmean(integral_hu_of_each_trial);
integral_hu_std = nanstd(integral_hu_of_each_trial)/sqrt(size(integral_hu_of_each_trial,2));
return;

end


function [normalised_vector] = normalise_custom(vector,max,min)

normalised_vector = zeros(1,size(vector,2));

for i=1:size(vector,2)
    normalised_vector(i) = (vector(i)-min)/(max-min);
end
return;
end

function [normalised_std] = normalise_std(std,max,min)

normalised_std= std/(max-min);


return;

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
                    com_correct_counter = com_correct_counter+1;
                else
                    noncom_correct_counter = noncom_correct_counter+1;
                end
            elseif(dynamics_and_results(i).is_motor_com)
                com_incorrect_counter = com_incorrect_counter+1;
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