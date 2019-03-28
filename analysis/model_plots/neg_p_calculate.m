coherences = get_coherence_levels(dynamics_and_results);
n_of_coherences= size(coherences,2);

neg_p = zeros(1,n_of_coherences);
non_neg_p = zeros(1,n_of_coherences);

neg_p_error = zeros(1,n_of_coherences);
non_neg_p_error = zeros(1,n_of_coherences);



for i=1:n_of_coherences
    coherence= coherences(i);
    
    [neg_p_number_correct, non_neg_p_number_correct,...
        neg_p_number_error, non_neg_p_number_error] =...
        calculate_proportion_of_negative_IT_trials(dynamics_and_results,...
        coherence);
    
    neg_p(i) = neg_p_number_correct/4000;
    non_neg_p(i) = non_neg_p_number_correct/4000;
    neg_p_error(i) = neg_p_number_error/4000;
    non_neg_p_error(i) = non_neg_p_number_error/4000;
end

figure4=figure;
axes1 = axes('Parent',figure4);
hold on;


plot(neg_p+neg_p_error,...
    'LineWidth', 2,'DisplayName',...
    'correct','Color',[0 0 1]);
% plot(neg_p_error,...
%     'LineWidth', 2,'DisplayName',...
%     'error','Color',[1 0 1]);

xlim(axes1,[1 6]);
set(axes1,'FontSize',20,'XTickLabel',...
    {'0','3.2','6.4','12.8','25.6','51.2'});

xlabel('Coherence level c` (%)');
ylabel('P(neg IT)');
legend();
pubgraph(figure4,18,4,'w')


function [neg_p, non_neg_p, neg_p_error, non_neg_p_error] = calculate_proportion_of_negative_IT_trials(dynamics_and_results,coherence)

neg_p = 0;
non_neg_p = 0;

neg_p_error = 0;
non_neg_p_error = 0;

for i = 1:size(dynamics_and_results,1)
    if(coherence==dynamics_and_results(i).coherence_level && dynamics_and_results(i).motor_decision_made)
        if(dynamics_and_results(i).is_motor_correct)
            if(sign(dynamics_and_results(i).initiation_time) == -1)
                neg_p = neg_p+1;
            else
                non_neg_p = non_neg_p + 1;
            end
        end
        if(~dynamics_and_results(i).is_motor_correct)
            if(sign(dynamics_and_results(i).initiation_time) == -1)
                neg_p_error = neg_p_error + 1;
            else
                non_neg_p_error = non_neg_p_error + 1;
            end
        end
    end
end

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
