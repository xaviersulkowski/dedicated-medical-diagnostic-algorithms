function [ B ] = ols_method( x, y )
    y = y';
    X = [ones(size(x')), x'];
    B = inv(X'*X)*X'*y;
end

