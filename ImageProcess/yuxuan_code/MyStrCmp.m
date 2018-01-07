function Diff = MyStrCmp(S1, S2)

Len = length(S1);
Diff = 0;

for i = 1 : Len
    if S1(i) < S2(i)
        Diff = -1;
        return;
    else
        if S1(i) > S2(i)
            Diff = 1;
            return;
        end
    end
end
    
