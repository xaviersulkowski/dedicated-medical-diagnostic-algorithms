function [ filtered_signal ] = bandpass_filter( signal, samplerate, M, low_cut_fq, high_cut_fq)
    I = 360*0.05;
    N = -M:M;
    
    nyq_freq = samplerate / 2;  
    lowcut = low_cut_fq / nyq_freq;  
    highcut = high_cut_fq / nyq_freq;
    
    h1p = sin(2*pi*highcut*N)./(pi*N);
    h1p(M+1) = 2*highcut;
    h2p = -sin(2*pi*lowcut*N)./(pi*N);
    h2p(M+1) = 1 - 2*lowcut;
    
    n = 0:2*M;
    w = 0.54 - 0.46*cos((2*pi*n)./(2*M)); % Hamming window
    
    h1p
    h2p
    
    h1p_w = h1p.*w;
    h2p_w = h2p.*w;

    splot1 = conv(signal, h1p_w);
    filtered_signal = conv(splot1, h2p_w);

end

