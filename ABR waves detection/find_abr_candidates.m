function [waves_indices] = find_abr_candidates(signal, samplerate)
%ABR_WAVES - from literature ABR waves appears beetwen 1 ms - 9,5 ms so...
%   INPUT:
%   signal - signal
%   samplerate - samplerate 

    T1 = 1 * samplerate / 1000;
    T2 = 9.5 *samplerate / 1000;
    
    maximas = find_local_maxima(signal);
    waves_indices = maximas(maximas > T1 & maximas < T2);
end

function [maxima_indices] = find_local_maxima(signal)
% find_local_maxima
%   finds local maxima in given signal with stationary wavlet transformation
%   usage
%   INPUT: 
%   signal - given signal to find maxima
%   OUTPUT: 
%   maxima_indices - indices of sginal's local maxima  

    [swa, swd] = swt(signal, 3, 'rbio3.1');
    SWD = swd(3,:);
    maxima_indices = find(diff(SWD>=0)<0);
end

