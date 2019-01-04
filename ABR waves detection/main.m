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

amplitudeThreshold = 1; 

%% main task

% indices of waves with higher intensity 
higherIntensityWaves = [0, 0, 0];

figure()    
for i=1:length(abr_signal3)
    signal = abr_signal3{i}.data;
    intensity = abr_signal3{i}.dB;
    filtered = bandpass_filter(signal, fs, filter_order, low_cut_fq, high_cut_fq);
    plot(filtered + intensity)
    hold on
    
    % find abr wave
    localMaxima = find_abr_candidates(filtered, fs);
    
    % we need to find 3 waves
    wavesIndices = [0, 0, 0];
    for j=1:3
        previousWave = wavesIndices(max([1, j-1]));
        minSample = higherIntensityWaves(j);
        wavesIndices(j) = abr_wave_detection(localMaxima, previousWave, ...
                                             minSample, 1, fs);
    end
    
    % from litereture: if there is no 5th wave detected, then signal is not
    % detected
    if isnan(wavesIndices(end)) || filtered(wavesIndices(end)) < amplitudeThreshold
        wavesIndices = [nan, nan, nan];
        fprintf("hearing threshold %i[dB] \n", intensity)
    else
        toPlotIndices = wavesIndices(~isnan(wavesIndices));
        scatter(toPlotIndices(1), filtered(toPlotIndices(1)) + intensity, ...
                                           'go', 'filled', ... 
                                           'MarkerEdgeColor', 'k', ...
                                           'HandleVisibility', 'off')
        scatter(toPlotIndices(2), filtered(toPlotIndices(2)) + intensity, ...
                                           'rs', 'filled', ... 
                                           'MarkerEdgeColor', 'k', ...
                                           'HandleVisibility', 'off')
        scatter(toPlotIndices(3), filtered(toPlotIndices(3)) + intensity, ...
                                           'm^', 'filled', ... 
                                           'MarkerEdgeColor', 'k', ...
                                           'HandleVisibility', 'off')
    end
    higherIntensityWaves = wavesIndices;
end
ylabel('Amplitude [uV]')
xlabel('Samples') 
