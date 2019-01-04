function [dist] = point_line_dist(x, y, coeff)
    dist = (coeff(2)*x - y + coeff(1))/sqrt(coeff(2)^2 + 1);
end

