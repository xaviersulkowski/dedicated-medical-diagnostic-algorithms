%% clear 
close all
clear 
clc

%% setup 
addpath('EKGdata')
% signal = load('-ascii', '100_MLII.dat');
signal = load('-ascii', '100_V5.dat');
% signal = load('-ascii', '102_V2.dat');
% signal = load('-ascii', '102_V5.dat');
% signal = load('-ascii', '228_MLII.dat');
% signal = load('-ascii', '228_V1.dat');

% signal_part = signal(5089:5300);
signal_part = signal;
Fs = 360;

% filter parameters 
filter_order = 20;
low_cut_fq = 5;     % [Hz]
high_cut_fq = 15;   % [Hz]

% peak detection
pt_window = 100;        % [miliseconds]
pt_window = pt_window*Fs/1000;  % [samples}
minHeighLimit = 0.02;
minDistanceLimit = 0.5*Fs;

%% find peaks  
ECG_filtered = bandpass_filter2(signal_part, Fs, filter_order, low_cut_fq, high_cut_fq);
[pt_peaks, integral, r_peaks] = find_r_peaks(ECG_filtered, Fs, pt_window, minDistanceLimit, ...
                                             minHeighLimit, true, true);
                                         
[qrs_onsets, qrs_offsets] = qrs_detection(ECG_filtered, r_peaks, Fs);

figure()
plot(integral)
hold on
scatter(pt_peaks, integral(pt_peaks), 'ro')

figure()
plot(ECG_filtered)
hold on
scatter(r_peaks, ECG_filtered(r_peaks), 'ro', 'filled')
% scatter(pt_peaks, ECG_filtered(pt_peaks))
scatter(qrs_onsets, ECG_filtered(qrs_onsets), 'm^', 'filled')
scatter(qrs_offsets, ECG_filtered(qrs_offsets), 'k^', 'filled')