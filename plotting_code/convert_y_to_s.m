function [s1,s2]= convert_y_to_s(y_1,y_2) 
tnmda = 100;    % NMDAr
tampa = 2;      % AMPAr
gamma = 0.641;  % Gamma

s1_in=0.1; s2_in=0.1;
% Intialise and vectorise variables to be used in loops below
s1 = s1_in.*ones(1,8000); s2 = s2_in.*ones(1,8000);
for t = 1: size(y_1,2)
s1(t+1) = s1(t) + 0.5 * (-(s1(t)/tnmda) ...
+ (1 - s1(t)) * gamma * y_1(t)/1000);
s2(t+1) = s2(t) + 0.5*(-(s2(t)/tnmda) ...
+ (1 - s2(t)) * gamma * y_2(t)/1000);
end
end