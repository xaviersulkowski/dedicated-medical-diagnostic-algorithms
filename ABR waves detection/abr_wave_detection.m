function [abrWave] = abr_wave_detection(wavesCandidates, previousWaveIdx, ... 
                                        minSample, tolerance, samplerate)
%ABR_WAVE_DETECTION from literature - Waves are detected in 1 ms delay 
%   INPUT:
%   wavesCandidates - indices of local maximas in signal 
%   previousWaveIdx - previos wave index
%   minSample - in next stimulation (decreasing stimulation intensity) abr
%   appears latern then in previous ones but... sametimes we need some tolerance
%   tolerance - in samples
%   samplerate - samplerate 
%   OUTPUT:
%   abrWave - index of wabWave

    one_ms = 1 * samplerate / 1000; 
    minDistanceLimit = previousWaveIdx + one_ms - tolerance;
    abrWave = wavesCandidates(wavesCandidates >= minDistanceLimit... 
                              & wavesCandidates >= minSample );
    if ~isempty(abrWave)
        abrWave = abrWave(1);
    else
        abrWave = nan;
    end
end