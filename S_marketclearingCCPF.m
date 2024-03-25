
renewablestdmatrix = diag(([renewable.Pstd] .* [renewable.Pexp]).^2);
demandstdmatrix = diag(([demand.Dstd] .* [demand.Dexp]).^2);
% for i = 1:np
%     renewable(i).Pstdabs = renewable(i).Pstd * renewable(i).Pexp;
% end
% 
% for i = 1:nd
%     demand(i).Dstdabs = demand(i).Dstd * demand(i).Dexp;
% end


%% 定义决策变量，主要是Gexp和beta
Gexp = sdpvar(ng,1);
beta = sdpvar(ng,1);
a_lp = sdpvar(nl,np);
a_ld = sdpvar(nl,nd);
b_gp = sdpvar(ng,np);
b_gd = sdpvar(ng,nd);
yita_l = sdpvar(nl,1);
yita_g = sdpvar(ng,1);





%% 写出约束
Cons = [];
%平衡约束(3b)
Cons = [Cons, sum(Gexp) + sum([renewable.Pexp]) - sum([demand.Dexp]) >= 0]; Dual.price = length(Cons);
%a_lp,a_ld表示(7)(8)
for nnl = 1:nl
    for nnp = 1:np
        Cons = [Cons, a_lp(nnl,nnp) == GSDFP_lp(nnl,nnp) - GSDFG_lg(nnl,:) * beta];
    end
    for nnd = 1:nd
        Cons = [Cons, a_ld(nnl,nnd) == GSDFD_ld(nnl,nnd) + GSDFG_lg(nnl,:) * beta];
    end 
end 
%b_gp,b_gd表示(14)(15)
Cons = [Cons, b_gp == -beta * ones(1,np)]; 
Cons = [Cons, b_gd == beta * ones(1,nd)];
% 约束(20)(21),分别表示线路上潮流的标准差和机组出力的标准差
normmatrix = [renewablestdmatrix^(1/2) zeros(np,nd);zeros(nd,np) demandstdmatrix^(1/2)];
for nnl = 1:nl
    Cons = [Cons, norm(normmatrix * [a_lp(nnl,:) a_ld(nnl,:)]') <= yita_l(nnl)]; Dual.rouPF_l(nnl) = length(Cons);
end 
for nng = 1:ng
    Cons = [Cons, norm(normmatrix * [b_gp(nng,:) b_gd(nng,:)]') <= yita_g(nng)]; Dual.phaiG_i(nng) = length(Cons);
end 
%约束(22c)(22d),还可以加入一项偏差的期望项目
for nnl = 1:nl
    Cons = [Cons, - (GSDFG_lg(nnl,:) * Gexp + GSDFP_lp(nnl,:) * [renewable.Pexp]' - GSDFD_ld(nnl,:) * [demand.Dexp]') - Ksig * yita_l(nnl) >= -branch(nnl).Pmax];
    Dual.Lmax(nnl) = length(Cons);
    Cons = [Cons,  (GSDFG_lg(nnl,:) * Gexp + GSDFP_lp(nnl,:) * [renewable.Pexp]' - GSDFD_ld(nnl,:) * [demand.Dexp]') - Ksig * yita_l(nnl) >= -branch(nnl).Pmax];
    Dual.Lmin(nnl) = length(Cons);
end 
%约束(22e)(22f),还可以加入偏差的期望项目
for nng = 1:ng
    Cons = [Cons, - Gexp(nng) - Ksig * yita_g(nng) >= -generator(nng).Pmax];
    Dual.Gmax(nng) = length(Cons);
    Cons = [Cons,   Gexp(nng) - Ksig * yita_g(nng) >= generator(nng).Pmin];
    Dual.Gmin(nng) = length(Cons);
end 

Cons = [Cons, sum(beta) >= 1]; Dual.consbeta_more = length(Cons);
Cons = [Cons, sum(beta) <= 1]; Dual.consbeta_less = length(Cons);

obj = [generator.cost] * Gexp;
solution = optimize(Cons,obj,ops);
% model = export(Cons,obj,ops);
% params.QCPDual = 1;
% resultCCPF = gurobi(model, params);



