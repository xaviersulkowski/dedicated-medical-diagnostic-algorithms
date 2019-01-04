function [qrs_onset,qrs_offset] = qrs_detection(ecg, r_peaks_idx, fs)
    
    qrs_onset = zeros(size(r_peaks_idx));
    qrs_offset = zeros(size(r_peaks_idx));
    shift = 0.5*fs;
    
    for i=1:length(r_peaks_idx)
        input_peak = r_peaks_idx(i);
        window = get_window(ecg, input_peak, shift);
        
        frame_size = 50;
        frame = frame_size*fs/1000;  % frame size in samples
      
        [local_r_zr_idx, local_r_idx, zr_idx] = find_local_r(window, shift);

        onset = max([local_r_zr_idx - 1, 1]); 
        offset = min([local_r_zr_idx + 1, length(zr_idx)]); 
        
        qrs_onset(i) = max([r_peaks_idx(i) - max([local_r_idx-zr_idx(onset),1]),0]);
        qrs_offset(i) = min([r_peaks_idx(i) + max([zr_idx(offset) - local_r_idx,1]),length(ecg)]);
    end

end

