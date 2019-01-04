function [ filtered_signal ] = bandpass_filter2( signal, samplerate, M, low_cut_fq, high_cut_fq)
    d = designfilt('bandpassfir','FilterOrder',M, ...
                   'CutoffFrequency1',low_cut_fq, ...
                   'CutoffFrequency2',high_cut_fq,...
                   'SampleRate',samplerate);
     
    filtered_signal = filtfilt(d, signal);
    
end

