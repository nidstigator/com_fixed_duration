%First plot: Psychometric function, split CoM/NON-CoM.
%Second plot: Mouse-IT (z_scored).
%Third plot: Eye-IT (z_scored).

global legends;
global titles;
global export;
global figures_path;

figures_path = '../figures_output/';

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
p_correct_com = zeros(1,n_of_coherences);

initiation_time_noncom_correct_mean_gather = zeros(1,n_of_coherences);
initiation_time_noncom_incorrect_mean_gather = zeros(1,n_of_coherences);
initiation_time_com_correct_mean_gather = zeros(1,n_of_coherences);
initiation_time_com_incorrect_mean_gather = zeros(1,n_of_coherences);

initiation_time_noncom_correct_std_gather = zeros(1,n_of_coherences);
initiation_time_noncom_incorrect_std_gather = zeros(1,n_of_coherences);
initiation_time_com_correct_std_gather = zeros(1,n_of_coherences);
initiation_time_com_incorrect_std_gather = zeros(1,n_of_coherences);


eye_initiation_time_noncom_correct_mean_gather = zeros(1,n_of_coherences);
eye_initiation_time_noncom_incorrect_mean_gather = zeros(1,n_of_coherences);
eye_initiation_time_com_correct_mean_gather = zeros(1,n_of_coherences);
eye_initiation_time_com_incorrect_mean_gather = zeros(1,n_of_coherences);

eye_initiation_time_noncom_correct_std_gather = zeros(1,n_of_coherences);
eye_initiation_time_noncom_incorrect_std_gather = zeros(1,n_of_coherences);
eye_initiation_time_com_correct_std_gather = zeros(1,n_of_coherences);
eye_initiation_time_com_incorrect_std_gather = zeros(1,n_of_coherences);



coupled = isfield(dynamics_and_results,'is_first_correct');

for i=1:n_of_coherences
    coherence= coherences(i);
    
    [noncom_correct_counter, noncom_incorrect_counter,...
        com_correct_counter, com_incorrect_counter, com_late_correct_counter, com_late_incorrect_counter, nondecision_counter] = ...
        calculate_accuracies(dynamics_and_results, coherence, is_first_correct, coupled);
    
    all_trials = noncom_correct_counter+ noncom_incorrect_counter ...
        +com_correct_counter + com_incorrect_counter;
   
    p_correct(i) = (noncom_correct_counter)/(noncom_correct_counter+noncom_incorrect_counter);
    p_correct_noncom(i) = (noncom_correct_counter)/all_trials;
    p_correct_com(i) = (com_correct_counter)/(com_correct_counter+com_incorrect_counter);
    p_nondecision(i)= nondecision_counter/all_trials;
    

 com_correct_counter
    
end


%%%%%%%%Fig1: Psychometric function for CoM/non-com.

%%%% fit method and options
% Set up fittype and options.
ft = fittype( '1-0.6*exp(-(x/a).^b)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.14646767384734 0.727853824810345];

% Fit model to data.
[fitresult, gof] = fit( [0,3.2,6.4,12.8,25.6,51.2]', p_correct', ft, opts );

%%% extract data from fitted curve
figuretemp = figure;
plot(fitresult);
h = findobj(figuretemp,'Type','line');
x=get(h,'Xdata');
y=get(h,'Ydata');
close;
%%%%%%%


%%%% COM FIT: 

% Set up fittype and options.
ft_2 = fittype( 'poly2' );
opts_2 = fitoptions( 'Method', 'LinearLeastSquares' );
opts_2.Robust = 'LAR';

p_correct_com(:,6)=[]; %delete NAN
% Fit model to data.
[fitresult, gof] = fit( [0,3.2,6.4,12.8,25.6]', p_correct_com', ft_2, opts_2 );

% Plot fit with data.
figuretemp2 = figure;
plot( fitresult);
h = findobj(figuretemp2,'Type','line');
x_com=get(h,'Xdata');
y_com=get(h,'Ydata');
close;


figure3=figure;
hold on;
plot(x,y,'LineWidth', 6,'Color',[0 0 0]);
plot(x_com,y_com,'LineWidth', 6,'Color',[0 0 0],'LineStyle','--');
scatter([0,3.2,6.4,12.8,25.6,51.2],p_correct,'o','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor', [0 0 0]);
scatter([0,3.2,6.4,12.8,25.6],p_correct_com,'x','LineWidth',4,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor', [1 0 0]);
xlabel('Coherence level c` (%)');
ylabel('Probability correct');
xlim([0,51.2]);
pubgraph(figure3,18,4,'w')
title_string = 'Choice accuracy';


if(legends)
    %legend('show');
end
if(titles)
    title(title_string);
end
data_file_name_1=[figures_path 'fig2_a_1.mat'];
data_file_name_2=[figures_path 'fig2_a_2.mat'];
data_file_name_csv_1=[figures_path 'fig2_a_1.txt'];
data_file_name_csv_2=[figures_path 'fig2_a_2.txt'];
header_1 = {'pcorrect_x_fit,pcorrect_y_fit'};
header_2 = {'pcorrect_x_real,pcorrect_y_real'};

coherences = [0,3.2,6.4,12.8,25.6,51.2];

fig_1_data_1 = [x',y'];
fig_1_data_2 = [coherences',p_correct'];

save(data_file_name_1, 'x','y');
save(data_file_name_2, 'coherences','p_correct');

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


%%% COM save:

data_file_name_1=[figures_path 'fig2_b_1.mat'];
data_file_name_2=[figures_path 'fig2_b_2.mat'];
data_file_name_csv_1=[figures_path 'fig2_b_1.txt'];
data_file_name_csv_2=[figures_path 'fig2_b_2.txt'];
header_1 = {'pcorrect_com_x_fit,pcorrect_com_y_fit'};
header_2 = {'pcorrect_x_real,pcorrect_y_real'};

coherences = [0,3.2,6.4,12.8,25.6];

fig_1_data_1 = [x_com',y_com'];
fig_1_data_2 = [coherences',p_correct_com'];

save(data_file_name_1, 'x_com','y_com');
save(data_file_name_2, 'coherences','p_correct_com');

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
if(export)
export_path = [figures_path  title_string];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-r300','-q101', '-cmyk','-painters');
savefig(export_path);
end

%%%%%%%%

%%%%%%%%Figure2: Initiation times (z-scored)

[times_mean_hand,times_std_hand, times_mean_eye,times_std_eye]=mean_z_std_all_times(dynamics_and_results);


for i=1:n_of_coherences
    coherence= coherences(i);
    [initiation_time_noncom_correct_mean_gather(i),initiation_time_noncom_correct_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        true, false, is_first_correct, coupled,times_mean_hand,times_std_hand);
    
    [initiation_time_noncom_incorrect_mean_gather(i),initiation_time_noncom_incorrect_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        false, false, is_first_correct, coupled,times_mean_hand,times_std_hand);
    
    [initiation_time_com_correct_mean_gather(i),initiation_time_com_correct_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        true, true, is_first_correct, coupled,times_mean_hand,times_std_hand);
    
    [initiation_time_com_incorrect_mean_gather(i),initiation_time_com_incorrect_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        false, true, is_first_correct, coupled,times_mean_hand,times_std_hand);
        
    
    
    [eye_initiation_time_noncom_correct_mean_gather(i),eye_initiation_time_noncom_correct_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        true, false, is_first_correct, coupled,times_mean_eye,times_std_eye);
    
    [eye_initiation_time_noncom_incorrect_mean_gather(i),eye_initiation_time_noncom_incorrect_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        false, false, is_first_correct, coupled,times_mean_eye,times_std_eye);
    
    [eye_initiation_time_com_correct_mean_gather(i),eye_initiation_time_com_correct_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        true, true, is_first_correct, coupled,times_mean_eye,times_std_eye);
    
    [eye_initiation_time_com_incorrect_mean_gather(i),eye_initiation_time_com_incorrect_std_gather(i)] = ...
        calculate_z_score(dynamics_and_results, coherence, ...
        false, true, is_first_correct, coupled,times_mean_eye,times_std_eye);
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
ylabel('Hand initiation time z-score');
pubgraph(figure4,18,4,'w')
title_string = 'Initiation times v.s coherence level';
if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end
data_file_name=[figures_path 'fig2_c.mat'];
data_file_name_csv=[figures_path 'fig2_c.txt'];
header = {'init_z_correct,init_z_correct_sem,init_z_error,init_z_error_sem'};

fig_2c_data = [initiation_time_noncom_correct_mean_gather',...
    initiation_time_noncom_correct_std_gather',initiation_time_noncom_incorrect_mean_gather',initiation_time_noncom_incorrect_std_gather'];

save(data_file_name, 'initiation_time_noncom_correct_mean_gather',...
    'initiation_time_noncom_correct_std_gather','initiation_time_noncom_incorrect_mean_gather','initiation_time_noncom_incorrect_std_gather');

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_2c_data(1:end,:), '-append') ;


if(export)
export_path = [figures_path  'responsetimesvscoherence'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end

figure5=figure;
axes1 = axes('Parent',figure5);
hold on;

errorbar(eye_initiation_time_noncom_correct_mean_gather,...
    eye_initiation_time_noncom_correct_std_gather...
    ,'LineWidth', 2,'DisplayName',...
    'correct','Color',[0 0 1]);
errorbar(eye_initiation_time_noncom_incorrect_mean_gather,...
    eye_initiation_time_noncom_correct_std_gather...
    ,'LineWidth', 2,'DisplayName',...
    'error','Color',[1 0 0]);

% scatter([0,3.2,6.4,12.8,25.6,51.2],normalised_initiation_time_noncom_correct,'o','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor', [0 0 1]);
% scatter([0,3.2,6.4,12.8,25.6,51.2],normalised_initiation_time_noncom_incorrect,'o','LineWidth',4,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor', [1 0 0]);

xlim(axes1,[1 6]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

xlabel('Coherence level c` (%)');
ylabel('Eye initiation time z-score');
pubgraph(figure5,18,4,'w')
title_string = 'Initiation times v.s coherence level';
if(legends)
    legend('show');
end
if(titles)
    title(title_string);
end

data_file_name=[figures_path 'fig2_d.mat'];
data_file_name_csv=[figures_path 'fig2_d.txt'];
header = {'eye_init_z_correct,eye_init_z_correct_sem,eye_init_z_error,eye_init_z_error_sem'};

fig_2d_data = [eye_initiation_time_noncom_correct_mean_gather',...
    eye_initiation_time_noncom_correct_std_gather',eye_initiation_time_noncom_incorrect_mean_gather',eye_initiation_time_noncom_incorrect_std_gather'];

save(data_file_name, 'eye_initiation_time_noncom_correct_mean_gather',...
    'eye_initiation_time_noncom_correct_std_gather','eye_initiation_time_noncom_incorrect_mean_gather','eye_initiation_time_noncom_incorrect_std_gather');

fid = fopen(data_file_name_csv, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(data_file_name_csv, fig_2d_data(1:end,:), '-append') ;


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


function[hand_initiation_time_mean, hand_initiation_time_std, eye_initiation_time_mean, eye_initiation_time_std] = ...
    mean_z_std_all_times(dynamics_and_results)


counter = 0;


for i = 1:size(dynamics_and_results,1)
    counter = counter+1;
end

hand_initiation_time_gather = zeros(1,counter);

eye_initiation_time_gather = zeros(1,counter);

j=1;


for i = 1:size(dynamics_and_results,1)
    hand_initiation_time_gather(j)=dynamics_and_results(i).initiation_time;
    eye_initiation_time_gather(j)=dynamics_and_results(i).eye_initiation_time;
    
    if(dynamics_and_results(i).initiation_time == 0)
       hand_initiation_time_gather(j)=nan;
    end
    
    if(dynamics_and_results(i).eye_initiation_time == 0)
        eye_initiation_time_gather(j)=nan;
    end      

    j=j+1;
end

hand_initiation_time_mean = nanmean(hand_initiation_time_gather);
hand_initiation_time_std = nanstd(hand_initiation_time_gather);

eye_initiation_time_mean = nanmean(eye_initiation_time_gather);
eye_initiation_time_std = nanstd(eye_initiation_time_gather);



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