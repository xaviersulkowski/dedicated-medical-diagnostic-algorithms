function [ coeff ] = ransac_method( data, M, k, t, max_iter )
% ransac_method 
%   data - 2D double array with data points 
%   M - points needed to estimate model (in linear case M = 2)
%   k - distance tolerance 
%   t - ratio threshold, one of stop condition, if len(inliners)/len(data) > t STOP
%   max_iter - next stop condition if t not reached, if 0 or nan - method
%   works untill threshold condition not reached

    if size(data) ~= 2
        error('data must be 2D double array')
    end 
    if max_iter == 0
        max_iter = nan;
    end
    
    x = data(1, :);
    y = data(2, :);
    
    ratio = 0;
    bestRatio = 0;
    coefficients = [];
    inlierIdx = [];
    
    iterator = 0;
    while ratio < t
        iterator = iterator + 1;
        if iterator > max_iter
            % to not repeat stop condition I decided to use brake  
            sprintf('Best ratio obtained: %d', bestRatio*100)
            break
        end
        
        idx = randperm(length(x),M);
        randomX = x(idx);
        randomY = y(idx); 
        
        B = ols_method(randomX, randomY);
        dist = point_line_dist(x, y, B);
        ratio = sum(abs(dist) < k)/length(x);

        if ratio>bestRatio
            bestRatio = ratio;
            coefficients = B;
            inlierIdx = find(abs(dist) < k);
        end 
    end
    
    if isempty(coefficients)
        error('No model found.');
    else
        inlierX = x(inlierIdx);
        inlierY = y(inlierIdx);
        coeff = ols_method(inlierX, inlierY);
    end
    
end

