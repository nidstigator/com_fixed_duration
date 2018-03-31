% 
% %call functions to test:
close all;
% clearvars -except dynamics_and_results dynamics_and_results_2nddecision;

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


is_motor_correct = true;
is_motor_com = false;

[y_1, y_2, y_3, y_4, y_mc_hu, y_mc_lu, y_5, y_6, y_7, y_8] = ...
    calculate_mean_activity(dynamics_and_results, 3.2, ...
    is_motor_correct, is_motor_com);

[y_1_25, y_2_25,y_3_25, y_4_25, y_mc_hu_25, y_mc_lu_25, y_5_25, y_6_25, y_7_25, y_8_25] = ...
    calculate_mean_activity(dynamics_and_results, 51.2, ...
    is_motor_correct, is_motor_com);

is_single_trial = false;


plot_main_panel_modified(dynamics_and_results,y_1,y_2,y_3,y_4,y_5,y_6,y_mc_hu,y_mc_lu,y_7,y_8,y_1_25,y_2_25,y_3_25,y_4_25,y_5_25,y_6_25,y_mc_hu_25,y_mc_lu_25, y_7_25, y_8_25)

function plot_main_panel_modified(dynamics_and_results,y_1,y_2,y_3,y_4,y_5,y_6,y_mc_hu,y_mc_lu,y_7,y_8,y_1_25,y_2_25,y_3_25,y_4_25,y_5_25,y_6_25,y_mc_hu_25,y_mc_lu_25,y_7_25,y_8_25)

global legends;
global titles;
global export;
global figures_path;

large_left= 'c`=51.2%, left';
large_right = 'c`=51.2%, right';

small_left= 'c`=3.2%, left';
small_right = 'c`=3.2%, right';


large = 'c`=51.2%';
small = 'c`=3.2%';

figure1=figure;
subplot(5,1,1);
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


%xlabel('Time (ms)');
subplot(5,1,2);
title('Motor Preparation');
hold on;
plot(y_7_25(1:2:end),'Color',[0.1172    0.5625    1.0000],'DisplayName',large_left);
plot(y_8_25(1:2:end),'Color',[1.0000    0.4961    0.3125],'DisplayName',large_right);
plot(y_7(1:2:end),'LineStyle','--','Color',[0.1172    0.5625    1.0000],'DisplayName',small_left);
plot(y_8(1:2:end),'LineStyle','--','Color',[1.0000    0.4961    0.3125],'DisplayName',small_right);
xlim([700,2500]);
xticks(['','',''])
xticklabels({'','',''})
if(titles)
   title(['Decision' title_string]);
end


subplot(5,1,3);
title('Uncertainty Monitoring');
hold on;
plot(y_mc_hu_25(1:2:end),'Color',[1 0 0],'DisplayName',large);
plot(y_mc_hu(1:2:end),'LineStyle','--','Color',[1 0 0],'DisplayName',small);
%plot(y_mc_lu_25(1:2:end),'Color',[0.1328    0.5430    0.1328]);
%plot(y_mc_lu(1:2:end),'LineStyle','--','Color',[0.1328    0.5430    0.1328]);
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

subplot(5,1,4);
title('Hand');
hold on;
plot(y_5_25(1:2:end),'Color',[0.1172    0.5625    1.0000]);
plot(y_6_25(1:2:end),'Color',[1.0000    0.4961    0.3125]);
plot(y_5(1:2:end),'LineStyle','--','Color',[0.1172    0.5625    1.0000]);
plot(y_6(1:2:end),'LineStyle','--','Color',[1.0000    0.4961    0.3125]);
xlim([700,2500]);
xticks(['','',''])
xticklabels({'','',''})



if(legends)
    %legend('Left','Right');
end
if(titles)
    title(['Motor output' title_string]);
end

subplot(5,1,5);
title('Eye');
hold on;
plot(y_3_25(1:2:end),'Color',[0.1172    0.5625    1.0000]);
plot(y_4_25(1:2:end),'Color',[1.0000    0.4961    0.3125]);
plot(y_3(1:2:end),'LineStyle','--','Color',[0.1172    0.5625    1.0000]);
plot(y_4(1:2:end),'LineStyle','--','Color',[1.0000    0.4961    0.3125]);
xlabel('Time (ms)');
xlim([700,2500]);
xticks([700,1500,2500])
xticklabels({'0','1500', '2500'})
pubgraph(figure1,18,4,'w');

data_file_name=[figures_path 'fig1b.mat'];
data_file_name_csv=[figures_path 'fig1b.txt'];

fig_1_data = [y_1', y_2', y_3', y_4', y_mc_hu', y_mc_lu', y_5', y_6', y_7', y_8',y_1_25', y_2_25',y_3_25', y_4_25', y_mc_hu_25', y_mc_lu_25', y_5_25', y_6_25', y_7_25', y_8_25']

save(data_file_name, 'y_1_25','y_2_25','y_3_25','y_4_25','y_5_25'...
    ,'y_5_25','y_6_25','y_7_25','y_8_25','y_mc_hu_25','y_mc_lu_25','y_1','y_2','y_3','y_4',...
    'y_5','y_6','y_7','y_8','y_mc_hu','y_mc_lu');

csvwrite(data_file_name,fig_1_data)

if(export)
export_path = [figures_path  'new_panel'];
export_fig (export_path, '-nofontswap', '-linecaps','-png', '-transparent','-m10','-q101', '-cmyk','-painters');
savefig(export_path);
end
end

function[y_1_mean, y_2_mean,y_3_mean,y_4_mean, y_mc_hu_mean, y_mc_lu_mean, y_5_mean,...
    y_6_mean,y_7_mean, y_8_mean ] = ...
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
    if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com)
        counter = counter+1;
    end
end

y_1_gather = zeros(counter,trial_length);
y_2_gather = zeros(counter,trial_length);
y_3_gather = zeros(counter,trial_length);
y_4_gather = zeros(counter,trial_length);
y_mc_hu_gather = zeros(counter,trial_length);
y_mc_lu_gather = zeros(counter,trial_length);
y_5_gather = zeros(counter,trial_length);
y_6_gather = zeros(counter,trial_length);
y_7_gather = zeros(counter,trial_length);
y_8_gather = zeros(counter,trial_length);


j=1;
for i = 1:size(dynamics_and_results,1)
    if(dynamics_and_results(i).coherence_level == coherence && dynamics_and_results(i).is_motor_correct == is_motor_correct && dynamics_and_results(i).is_motor_com == is_motor_com)
        y_1_gather(j,:)=dynamics_and_results(i).y_1;
        y_2_gather(j,:)=dynamics_and_results(i).y_2;
        y_3_gather(j,:) = dynamics_and_results(i).y_3;
        y_4_gather(j,:) = dynamics_and_results(i).y_4;
        y_mc_hu_gather(j,:)=dynamics_and_results(i).y_mc_hu;
        y_mc_lu_gather(j,:)=dynamics_and_results(i).y_mc_lu;
        y_5_gather(j,:)=dynamics_and_results(i).y_5;
        y_6_gather(j,:)=dynamics_and_results(i).y_6;
        y_7_gather(j,:) = dynamics_and_results(i).y_7;
        y_8_gather(j,:) = dynamics_and_results(i).y_8;


        j=j+1;
    end
end


% Non CoM Correct Mean
y_1_mean(1,:) = mean(y_1_gather);
y_2_mean(1,:) = mean(y_2_gather);
y_3_mean(1,:) = mean(y_3_gather);
y_4_mean(1,:) = mean(y_4_gather);
y_mc_hu_mean(1,:) = mean(y_mc_hu_gather);
y_mc_lu_mean(1,:) = mean(y_mc_lu_gather);
y_5_mean(1,:) = mean(y_5_gather);
y_6_mean(1,:) = mean(y_6_gather);
y_7_mean(1,:) = mean(y_7_gather);
y_8_mean(1,:) = mean(y_8_gather);
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
