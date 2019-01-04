%% clean up
clear 
clc
close all

%% setup 
addpath('ABRdata')
load('abr_signal3.mat');

fs = 100*1000;         % [Hz]
low_cut_fq = 0.3*1000; % [Hz]
high_cut_fq = 3*1000;  % [Hz]
filter_order = 25;

signal = abr_signal3{1}.data;

%% filtering
filtered = bandpass_filter(signal, fs, filter_order, low_cut_fq, high_cut_fq);

figure()
plot(signal, 'LineWidth', 1)
hold on
plot(filtered, 'LineWidth', 1)
ylabel('Amplituda [uA]')
xlabel('Próbki')
legend({'Surowy sygna³', 'Sygna³ przefiltrowany'}, 'Location', 'southoutside')

%% zero crossing

zr = find_abr_candidates(filtered, fs);

figure()
plot(filtered, 'LineWidth', 1)
hold on 
scatter(zr, filtered(zr), 'ro', 'filled')
ylabel('Amplituda [uA]')
xlabel('Próbki')
legend({'Sygna³ przefiltrowany', '"Kandydaci" fal ABR'}, 'Location', 'southoutside')
