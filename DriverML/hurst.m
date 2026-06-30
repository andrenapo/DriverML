function hurst = hurst(x)

    x = x(:)';
    N = length(x);

    max_k = floor(log2(N));
    RS = zeros(max_k - 1, 1);
    L = zeros(max_k - 1, 1);

    for k = 2:max_k
        m = 2^k;
        xk = x(1:m);

        mean_x = mean(xk);
        Y = cumsum(xk - mean_x);

        R = max(Y) - min(Y);

        S = std(xk);

        RS(k-1) = R/S;
        L(k-1) = m;
    end

    p = polyfit(log(L), log(RS), 1);
    hurst = p(1);

end