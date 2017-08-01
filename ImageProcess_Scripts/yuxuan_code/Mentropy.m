function E = Mentropy(W, n)
Wmin = min(W(:));
Wmax = max(W(:));
NW = uint8((double(W-Wmin)/double(Wmax-Wmin))*n);
H = zeros(1,n+1);
for i = 0:n
    H(i+1) = sum(sum(NW == i));
end
H = H / sum(H);
E = sum(-H.*log2(H + eps));
end
