%% clean up
close all
clear
clc

%% open
addpath('EKGdata')
signal = load('-ascii', '100_MLII.dat');
% signal = load('-ascii', '100_V5.dat');
attr = open_annotations('100_attr.dat');

% signal = load('-ascii', '102_V2.dat');
% signal = load('-ascii', '102_V5.dat');
% attr = open_annotations('102_attr.dat');

% signal = load('-ascii', '228_MLII.dat');
% signal = load('-ascii', '228_V1.dat');
% attr = open_annotations('228_attr.dat');
annotations = attr.VarName1;

%% setup

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

%% raw signal 

raw = signal(1:1200);
raw_linspace = linspace(0,length(raw)/Fs, length(raw));

% fig = figure('Position', get(0, 'Screensize'));
fig = figure();
plot(raw_linspace, raw)
title('Raw ECG')
xlabel('Time [s]')
ylabel('Amplitude [mV]')
legend('ECG signal', 'Location', 'southoutside')
% saveas(fig, './report/raw_signal.png')
% close(fig)
%% filtered signal 
 
ECG_filtered = bandpass_filter2(raw, Fs, filter_order, low_cut_fq, high_cut_fq);
filtered_linspace = linspace(0, length(ECG_filtered)/Fs, length(ECG_filtered));

% fig = figure('Position', get(0, 'Screensize'));
fig = figure();
plot(filtered_linspace, ECG_filtered)
title('Filtered ECG')
xlabel('Time [s]')
ylabel('Amplitude [mV]')
legend('ECG signal', 'Location', 'southoutside')
% saveas(fig, './report/filtered_signal.png')
% close(fig)

%% raw and filtered 
% fig = figure('Position', get(0, 'Screensize'));
fig = figure();
subplot(2, 1, 1)
plot(raw_linspace, raw)
title('Raw ECG')
xlabel('Time [s]')
ylabel('Amplitude [mV]')
subplot(2, 1, 2)
plot(filtered_linspace, ECG_filtered)
title('Filtered ECG')
xlabel('Time [s]')
ylabel('Amplitude [mV]')
legend('ECG signal', 'Location', 'southoutside')
% saveas(fig, './report/raw_filtered_signal.png')
% close(fig)

%% SWT on PanTompkins

sig = ECG_filtered(250:451);

diffed = diff(sig);
diffed = [0;diffed];    % differentiation remove one sample, so we add zero to keep size
powered = diffed.^2;
sig = conv(powered, ones(1, pt_window), 'same');
    

fig = figure();
plot(sig)
hold on
SWT = swt(sig, 1, 'rbio3.1');
SWT = SWT(1,:);
zr = find(diff(SWT>0));
plot(SWT)
scatter(zr, zeros(size(zr)), 'ko', 'filled')
xlabel('Samples')
ylabel('Amplitdues [mV]')
legend('QRS after Pan-Tompkinsa', 'SWD', 'Points of intersection with Y axis', 'Location','southoutside')
% saveas(fig, './report/SWT.png')
% close(fig)
%% SWT on QRS

sig = ECG_filtered(250:501);

fig = figure();
plot(sig)
hold on
SWT = swt(sig, 1, 'rbio3.1');
SWT = SWT(1,:);
zr = find(diff(SWT>0));
plot(SWT)
scatter(zr, zeros(size(zr)), 'ko', 'filled')
xlabel('Samples')
ylabel('Amplitude [mV]')
legend('QRS complex', 'SWD', 'Points of intersection with Y axis')
% saveas(fig, './report/SWT_onQRS.png')
% close(fig)
%% Pan-Tompkins results 

[pt_peaks, PT, r_peaks] = find_r_peaks(ECG_filtered, Fs, pt_window, minDistanceLimit, ...
                                       minHeighLimit, true, true);
PT_linspace = linspace(0, length(PT)/Fs, length(PT));

% fig = figure('Position', get(0, 'Screensize'));
fig = figure();
plot(PT_linspace,PT)
hold on
scatter(PT_linspace(pt_peaks), PT(pt_peaks), 'ro')
% title('ECG signal after Pan-Tompkins algorithm')
xlabel('Time [s]')
ylabel('Amplitude [mV]')
legend('ECG signal after Pan-Tompkins algorithm', 'R peak', 'Location', 'southoutside')
% saveas(fig, './report/PT_signal.png')
% close(fig)
%% R-peaks detection

ecg_linspace = linspace(0, length(ECG_filtered)/Fs, length(ECG_filtered));

% fig = figure('Position', get(0, 'Screensize'));
fig = figure();
plot(ecg_linspace,ECG_filtered)
hold on
scatter(ecg_linspace(r_peaks), ECG_filtered(r_peaks), 'ro') 
% title('Za³amki R znalezione metod¹ Pan-Tompkinsa')
xlabel('Time [s]')
ylabel('Ampplitude [mV]')
legend('ECG signal', 'R peak', 'Location', 'southoutside')
% saveas(fig, './report/r_peaks.png')
% close(fig)
%% QRS onset, offset detection

[pt_peaks, PT, r_peaks] = find_r_peaks(ECG_filtered, Fs, pt_window, minDistanceLimit, ...
                                       minHeighLimit, true, true);
[qrs_onsets, qrs_offsets] = qrs_detection(ECG_filtered, r_peaks, Fs);

% fig = figure('Position', get(0, 'Screensize'));
fig = figure();
plot(ecg_linspace,ECG_filtered)
hold on
scatter(ecg_linspace(r_peaks), ECG_filtered(r_peaks), 'ro')
scatter(ecg_linspace(qrs_onsets), ECG_filtered(qrs_onsets), 'm^', 'filled')
scatter(ecg_linspace(qrs_offsets), ECG_filtered(qrs_offsets), 'k^', 'filled')
% title('Zespo³y QRS znalezione w sygnale')
xlabel('Time [s]')
ylabel('Ampplitude [mV]')
legend('ECG signal', 'R peak', 'QRS onset', 'QRS offset', 'Location', 'southoutside')
% saveas(fig, './report/qrs_on_off.png')
% close(fig)
%% R-peak detection in whole signal 

ECG_filtered = bandpass_filter2(signal, Fs, filter_order, low_cut_fq, high_cut_fq);
ecg_linspace = linspace(0, length(ECG_filtered)/Fs, length(ECG_filtered));

[pt_peaks, PT, r_peaks] = find_r_peaks(ECG_filtered, Fs, pt_window, minDistanceLimit, ...
                                       minHeighLimit, true, true);
                                   

                                   
properly_detected = 0;
badly_detected = [];
for i=1:length(r_peaks)
    if sum(abs(annotations - r_peaks(i)) < (0.15*Fs)) == 1
        properly_detected = properly_detected + 1;
    else
        badly_detected = [badly_detected, r_peaks(i)];
    end 
end

figure()
plot(ECG_filtered)
hold on
scatter(badly_detected, ECG_filtered(badly_detected), 'ro', 'filled')
scatter(annotations, ECG_filtered(annotations), 'g^')
% title('Zespo³y QRS nieporawnie znalezione w sygnale')
xlabel('Time [s]')
ylabel('Amplitude [mV]')
legend('ECG signal', 'Badly detected R-peaks', 'Ref. R-peaks')
