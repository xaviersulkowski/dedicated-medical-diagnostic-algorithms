function [pt_peaks, varargout] = find_r_peaks(signal, smaplerate, frame, ...
                                              minPeakDistance, minPeakHeight, ... 
                                              returnPantompkinsed, adjustPeaks)
    
    % find_r_peaks  finds peaks in ecg signal 
    % INPUTS: 
    %   signal - 1-D array, ECG signal
    %
    %   samplerate - Int, ECG signal samplerate  
    %   
    %   frame - Int, pan-tompkins frame size in samples
    %
    %   MinPeakDistance - distance beetwen peaks
    %
    %   MinPeakHeight - minimum height of peak for pantompkinsed signal 
    %
    %   return_pantompkinsed - boolen if return signal after Pan-Tompkins
    %   transformations, then returns are [PT_peaks, PT_signal]
    %
    %   adjus_peaks - boolen Pan-Tompkins may transform signal and affect 
    %   to peaks locations then returns are [PT_peaks, ..., r_signal]
    
    if class(returnPantompkinsed) ~= class(true)
        error('return_pantompkinsed must be boolen!')
    end
    
    if class(adjustPeaks) ~= class(true)
        error('adjust_peaks must be boolen!')
    end
    
    pantompkinsed_signal = pan_tompkins(signal, frame);
    pt_peaks = find_peaks(pantompkinsed_signal, minPeakDistance, minPeakHeight);
    
    outputsize = 0;
    if returnPantompkinsed == true
        outputsize = outputsize + 1;
        varargout{outputsize} = pantompkinsed_signal;
    end
    
    if adjustPeaks == true
        r_peaks = adjust_peaks(signal, pt_peaks, smaplerate);
        outputsize = outputsize + 1;
        varargout{outputsize} = r_peaks;
    end                           
end


function [pantompkinsed_signal] = pan_tompkins(signal, frame)

    diffed = diff(signal);
    diffed = [0;diffed];    % differentiation remove one sample, so we add zero to keep size
    powered = diffed.^2;
    pantompkinsed_signal = conv(powered, ones(1, frame), 'same');
    
end


function [ peaks ] = find_peaks(signal, MinPeakDistance, MinPeakHeight)
    
    % find peaks with discrete stationary wavelet transform
    SWT = swt(signal, 1, 'rbio3.1');
    SWT = SWT(1,:);
    zr = find(diff(SWT>0)); % zero crossings
    
    % use MinPeakHeight to select peaks
    zr = zr(signal(zr) > MinPeakHeight);
 
    % use MinPeakDistance to select peaks
    peaks = [];
    for i=1:length(zr)
        loc = zr(i);
        
        lower_limit = max([loc-MinPeakDistance, 1]);
        upper_limit = min([loc+MinPeakDistance, length(signal)]);
        
        peak_candidate = zr(zr>=lower_limit & zr<=upper_limit);
      
        if sum(peak_candidate) ~= 0          
            [peaks_values, peaks_locations] = max(signal(peak_candidate));
            peaks = [peaks, peak_candidate(peaks_locations)];
        end
    end
    peaks = unique(peaks);    
end


function [peaks] = adjust_peaks(original_signal, input_peaks, samplerate)
    % adjust_peaks - takes inputted peaks and finds peaks in their
    % neighbourhood in orignial signal
    
    shift = 0.3*samplerate;
    peaks = zeros(size(input_peaks));
    
    for i=1:length(input_peaks)       
        peak = input_peaks(i);
        window = get_window(original_signal, peak, shift);
        [r_peak_idx, local_r_idx, zr_idx] = find_local_r(window, shift);
        
        peaks(i) = min([max(peak + (zr_idx(r_peak_idx) - local_r_idx),1),length(original_signal)]); 
    end 
end 
