function [ filtered_signal ] = bandpass_filter( signal, samplerate, order, low_cut_fq, high_cut_fq)

    d = designfilt('bandpassfir','FilterOrder',order, ...
                   'CutoffFrequency1',low_cut_fq,'CutoffFrequency2',high_cut_fq, ...
                   'SampleRate',samplerate);
               
    filtered_signal = filtfilt(d,signal);
end

