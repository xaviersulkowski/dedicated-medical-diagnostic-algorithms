function [starts, ends] = mark_waves()
    button = 0;
    starts = [];
    ends = [];
    iterator = 1;
    % ESC == 27
    while button ~= 27
        [xt, yt, button] = ginput(1);
        if button ~= 27
            if mod(iterator, 2) ~= 0
                starts = [starts; [xt, yt]];
            else
                ends = [ends; [xt, yt]];
            end
            plot_handler = plot(xt, yt, 'ro','HandleVisibility','off');
        end
        iterator = iterator + 1;
    end    
end

