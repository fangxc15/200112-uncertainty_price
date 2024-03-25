% 鲁棒优化的市场出清
% 原版的没有考虑reserve的市场出清
%% 定义aconst,P,b
for i = 1:nl
    aconst.Lmax(i).value = [GSDFG_lg(i,:)';zeros(ng,1);0];
    Pconst.Lmax(i).value = [zeros(ng,np) zeros(ng,nd);-GSDFG_lg(i,:)'*ones(1,np) GSDFG_lg(i,:)'*ones(1,nd);GSDFP_lp(i,:) -GSDFD_ld(i,:)];
    aconst.Lmin(i).value = [-GSDFG_lg(i,:)';zeros(ng,1);0];
    Pconst.Lmin(i).value = [zeros(ng,np) zeros(ng,nd);GSDFG_lg(i,:)'*ones(1,np) -GSDFG_lg(i,:)'*ones(1,nd);-GSDFP_lp(i,:) GSDFD_ld(i,:)];
    bconst.Lmax(i).value = branch(i).Pmax - GSDFP_lp(i,:) * [renewable.Pexp]' + GSDFD_ld(i,:) * [demand.Dexp]';
    bconst.Lmin(i).value = branch(i).Pmax + GSDFP_lp(i,:) * [renewable.Pexp]' - GSDFD_ld(i,:) * [demand.Dexp]';
end

M = eye(ng);
for i = 1:ng
    aconst.Gmax(i).value = [M(:,i);zeros(ng,1);0];
    Pconst.Gmax(i).value = [zeros(ng,np) zeros(ng,nd);-M(:,i)*ones(1,np) M(:,i)*ones(1,nd);zeros(1,np) zeros(1,nd)];
    aconst.Gmin(i).value = [-M(:,i);zeros(ng,1);0];
    Pconst.Gmin(i).value = [zeros(ng,np) zeros(ng,nd);M(:,i)*ones(1,np) -M(:,i)*ones(1,nd);zeros(1,np) zeros(1,nd)];
    bconst.Gmax(i).value = generator(i).Pmax;
    bconst.Gmin(i).value = -generator(i).Pmin;
end

%% 定义D和q,可根据误差分布的特性进行部分调整
umin = [[renewable.dPmin]';[demand.dPmin]'];
umax = [[renewable.dPmax]';[demand.dPmax]'];
Dconst = [eye(np+nd); -eye(np+nd)];
Qconst = [-umin;umax];
S_DQconst_modify;
nq = length(Qconst);
%% 定义决策变量，主要是Gexp和beta
Gexp = sdpvar(ng,1);
beta = sdpvar(ng,1);
% u是有一个，D只有一个，但是不同的Du+Q问题里对应的那个内嵌Max问题不同，所以还是要做。
for i = 1:nl
    w.Lmax(i).varible = sdpvar(nq,1);
    w.Lmin(i).varible = sdpvar(nq,1);
end 
for i = 1:ng
    w.Gmax(i).varible = sdpvar(nq,1);
    w.Gmin(i).varible = sdpvar(nq,1);
end
anx = sdpvar(1,1); %这两个是干嘛的？
x = [Gexp;beta;anx];
anx2 = sdpvar(1,1); %这两个是干嘛的？
%% 写出约束
Cons = [];
Cons = [Cons, anx == 1];
Cons = [Cons, anx2 == 0];
%平衡约束
Cons = [Cons, sum(Gexp) + sum([renewable.Pexp]) - sum([demand.Dexp]) >= 0]; 
Dual.price = length(Cons);
%机组beta约束
Cons = [Cons, sum(beta) >= 1]; 
Dual.consbeta_more = length(Cons);
Cons = [Cons, sum(beta) <= 1];
Dual.consbeta_less = length(Cons);
% 线路功率不能超过上线的鲁棒约束
for i = 1:nl
    Cons = [Cons, aconst.Lmax(i).value' * x + Qconst' * w.Lmax(i).varible + anx2 <= bconst.Lmax(i).value];
    Dual.Lmax(i) = length(Cons);
    Cons = [Cons, aconst.Lmin(i).value' * x + Qconst' * w.Lmin(i).varible + anx2 <= bconst.Lmin(i).value];
    % 其实这里本质寻找的是一个可行解，只要有一个可行解小于它就行，而不是一定要找到最优解！
    % 所以我们用来计算的
    Dual.Lmin(i) = length(Cons);
    Cons = [Cons, Dconst' * w.Lmax(i).varible + Pconst.Lmax(i).value' * x == 0];
    Cons = [Cons, Dconst' * w.Lmin(i).varible + Pconst.Lmin(i).value' * x == 0];
    Cons = [Cons, w.Lmax(i).varible >=0];
    Cons = [Cons, w.Lmin(i).varible >=0];
    if i>=182
        fprintf('到了');
    end 
end 
% 机组功率不能超过上下限的鲁棒约束
for i = 1:ng
    Cons = [Cons, aconst.Gmax(i).value' * x + Qconst' * w.Gmax(i).varible <= bconst.Gmax(i).value];
        Dual.Gmax(i) = length(Cons);
    Cons = [Cons, aconst.Gmin(i).value' * x + Qconst' * w.Gmin(i).varible <= bconst.Gmin(i).value];   
        Dual.Gmin(i) = length(Cons);
    Cons = [Cons, Dconst' * w.Gmax(i).varible + Pconst.Gmax(i).value' * x == 0]; % 还好程序里没写错，这里都是相加
    Cons = [Cons, Dconst' * w.Gmin(i).varible + Pconst.Gmin(i).value' * x == 0];
    Cons = [Cons, w.Gmax(i).varible >=0];
    Cons = [Cons, w.Gmin(i).varible >=0];
end
%% 目标函数
obj = [generator.cost] * Gexp;
solution = optimize(Cons,obj,ops);
