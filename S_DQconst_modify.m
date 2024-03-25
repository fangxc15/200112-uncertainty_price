if DQconstmodify == 1
    Dconst = [Dconst;0 1 1 zeros(1,np+nd-3);0 -1 -1 zeros(1,np+nd-3)];
    Qconst = [Qconst;-(umin(2)+umin(3))/2;(umax(2)+umax(3))/2]; 
end

% 增加了两项是干啥的？ 是为了表现u1+u2不超过某个上限