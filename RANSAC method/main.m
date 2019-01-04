%% clean up
clear all 
close all
clc

%% setup
addpath('./RANSACdata/');

data_array(1) = {importdata('data1.mat')};
data_array(2) = {importdata('data2.mat')};
data_array(3) = {importdata('data3.mat')};
load('eng_signals');

%% OLS data

for i=1:length(data_array)
    data = data_array{i};
    x = data(1,:);
    y = data(2,:);
    OLS_coeff = ols_method(x, y);
    fig = figure();
    scatter(x, y)
    hold on
    plot(x, x*OLS_coeff(2)+OLS_coeff(1), 'Linewidth',1)
    grid on
    txt1 = ['y = (' num2str(OLS_coeff(2)) ')x + (' num2str(OLS_coeff(1)) ')'];
    legend({'Chmura danych', strcat('Dopasowanie metod¹ OLS', ' ', txt1) }, 'Location', 'southoutside')
    savedir = strcat('./report/data', int2str(i), '_OLS.png');
    saveas(fig, savedir)
    close(fig)
end

%% RANSAC parameters
k = 0.2;
t = 0.8;
M = 2;
max_iter = 1000000;

%% RANSAC data 
for i=1:length(data_array)

    data = data_array{i};
    x = data(1,:);
    y = data(2,:);
    RANSAC_coeff = ransac_method(data, M, k, t, max_iter);

    fig = figure();
    scatter(data(1,:), data(2,:))
    hold on
    plot(x, x*RANSAC_coeff(2)+RANSAC_coeff(1), 'Color', 'm', 'Linewidth',1)
    OLS_coeff = ols_method(x, y);
    plot(x, x*OLS_coeff(2) + OLS_coeff(1), 'Linewidth',1)
    grid on
    txt1 = [' y = (' num2str(RANSAC_coeff(2)) ')x + (' num2str(RANSAC_coeff(1)) ')'];
    txt2 = [' y = (' num2str(OLS_coeff(2)) ')x + (' num2str(OLS_coeff(1)) ')'];
    legend({'Chmura danych', ...
            strcat('Dopasowanie metod¹ RANSAC',' ', txt1), ... 
            strcat('Dopasowanie metod¹ OLS ',' ', txt2)}, 'Location', 'southoutside')
    savedir = strcat('./report/data', int2str(i), '_RANSAC.png');
    saveas(fig, savedir)
    close(fig)
end 

%% eng signals 
%ransac parameters
k = 1;
t = 0.8;
M = 2;
max_iter = 100000;

eng = eng_signal3;
fig = figure();
plot(eng)
title('PRESS ESC WHEN FINISH MARKING')
hold on
% works till press ESC
[starts, ends] = mark_waves();
title('')
xlabel('Próbki')
ylabel('Amplituda')

ransac_metrics = zeros(size(2, length(starts))); 
ols_metrics = zeros(size(2, length(starts)));

for i=1:size(starts, 1)
    
    f = waitbar(i/length(starts));
    
    % select indices colest to marked and corresponding values
    engIdx = int16(starts(i,1)):int16(ends(i,1));
    engValues = eng(engIdx);
    
    % transform indices and values to model likely 
    modelIdx = 1:length(engIdx);
    modelValues = engValues';
    
    % calculate and plot RANSAC model
    RANSAC_coeff = ransac_method([modelIdx; modelValues], M, k, t, max_iter);
    plot(engIdx, modelIdx*RANSAC_coeff(2) + RANSAC_coeff(1), 'Color', 'm', 'Linewidth', 1)
    
    % calculate and plot OLS model
    OLS_coeff = ols_method(modelIdx, modelValues);
    plot(engIdx, modelIdx*OLS_coeff(2) + OLS_coeff(1), 'Color', 'k', 'Linewidth',1, 'Linestyle', '--')
    
    % calculate distances and metrices for RANSAC model
    ransac_dist = point_line_dist(modelIdx, modelValues, RANSAC_coeff); 
    ransac_metrics(1, i) = mean(ransac_dist);
    ransac_metrics(2, i) = std(ransac_dist);

    % calculate distances and metrices for OLS model
    ols_dist = point_line_dist(modelIdx, modelValues, OLS_coeff); 
    ols_metrics(1, i) = mean(ols_dist);
    ols_metrics(2, i) = std(ols_dist);
    
end

close(f)

legend({'Sygna³ ENG z zaznaczonymi falami wolnymi', ...
        'Dopasowania metod¹ RANSAC', ... 
        'Dopasowania metod¹ OLS'}, ...
        'Location', 'southoutside')

savedir = strcat('./report/eng_1_RANSAC.png');
