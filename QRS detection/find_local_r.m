function [r_peak_idx, local_r_idx, zr_idx] = find_local_r(window, shift)
        local_r_idx = length(window)-shift-1;
        SWT = swt(window, 1, 'rbio3.1');
        SWT = SWT(1,:);
        zr_idx = find(diff(SWT>0)); % zero crossings
        [r_peak_value, r_peak_idx] = min(abs(zr_idx-local_r_idx));
end

