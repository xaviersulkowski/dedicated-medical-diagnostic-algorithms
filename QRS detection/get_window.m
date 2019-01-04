function [window] = get_window(signal, reference_point, shift)
    window = signal(max([1,reference_point-shift])...
                    :min([reference_point+shift,length(signal)]));
    if mod(length(window), 2) ~= 0
        window = [0;window];
    end
end

