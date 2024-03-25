result.Gexp = value(Gexp); result.Gexp = result.Gexp(:)';
fprintf('*******\n');
fprintf('机组出力为');
F_fprintfarray(result.Gexp);

fprintf('机组所在的节点为');
success = F_fprintfarray([generator.bus]);

fprintf('机组的成本为');
F_fprintfarray([generator.cost]);

result.beta = value(beta);
result.beta = result.beta(:)';
fprintf('******\n');
fprintf('调整因子');
F_fprintfarray(result.beta);

result.a_lp = value(a_lp);
result.a_ld = value(a_ld);
result.b_gp = value(b_gp);
result.b_gd = value(b_gd);



result.Pl = GSDFG_lg * value(Gexp) + GSDFP_lp * [renewable.Pexp]' - GSDFD_ld * [demand.Dexp]'; result.Pl = result.Pl(:)';
fprintf('******\n');
fprintf('基准状态下的潮流分布');
F_fprintfarray(result.Pl);

result.price =  dual(Cons(Dual.price));
fprintf('*******\n');
fprintf('系统边际电价为%f\n\n',result.price);
result.dualLmax =  dual(Cons(Dual.Lmax));
result.dualLmin =  dual(Cons(Dual.Lmin));
result.dualGmax =  dual(Cons(Dual.Gmax));
result.dualGmin =  dual(Cons(Dual.Gmin));



% result.dualbeta_more =  dual(Cons(Dual.consbeta_more));
% fprintf('*********\n');
% fprintf('beta_more的边际价格为%f\n',result.dualbeta_more);
% result.dualbeta_less =  dual(Cons(Dual.consbeta_less));
% fprintf('beta_less的边际价格为%f\n',result.dualbeta_less);
result.dualLmax =  result.dualLmax(:)';result.dualLmin =  result.dualLmin(:)';result.dualGmax =  result.dualGmax(:)';result.dualGmin =  result.dualGmin(:)';

result.dualbeta_more =  dual(Cons(Dual.consbeta_more));
fprintf('*********\n');
fprintf('beta_more的边际价格为%f\n',result.dualbeta_more);
result.dualbeta_less =  dual(Cons(Dual.consbeta_less));
fprintf('beta_less的边际价格为%f\n',result.dualbeta_less);

result.rouPF_l = dual(Cons(Dual.rouPF_l)); 
result.phaiG_i = dual(Cons(Dual.phaiG_i));

for nnl = 1:nl
    result.yita_l(nnl) = norm(normmatrix * [value(a_lp(nnl,:)) value(a_ld(nnl,:))]');
end 

for nng = 1:ng
    result.yita_g(nng) = norm(normmatrix * [value(b_gp(nng,:)) value(b_gd(nng,:))]');
end 


%% 直流潮流校验
S_DCcheck;
%% 机会约束校验？
for nnl = 1:nl
    violation.Lmax(nnl) = 1 - normcdf((branch(nnl).Pmax - result.Pl(nnl)) /result.yita_l(nnl)); 
    violation.Lmin(nnl) = 1 - normcdf((branch(nnl).Pmax + result.Pl(nnl)) /result.yita_l(nnl));
end
for nng = 1:ng
    violation.Gmax(nng) = 1 - normcdf((generator(nng).Pmax - result.Gexp(nng)) /result.yita_g(nng)); 
    violation.Gmin(nng) = 1 - normcdf((-generator(nng).Pmin + result.Gexp(nng)) /result.yita_g(nng));
end
%% 下面求解LMP和各类收益
% 计算LMP
LMP.Dexp = zeros(1,nd); LMP.Pexp = zeros(1,np);
for i = 1:nd
    LMP.Dexp(i) = result.price - result.dualLmax * GSDFD_ld(:,i) + result.dualLmin * GSDFD_ld(:,i);
end
for i = 1:np
    LMP.Pexp(i) = -result.price - result.dualLmin * GSDFP_lp(:,i) + result.dualLmax * GSDFP_lp(:,i);
end 
LMP_E = LMP.Dexp(nd-nnode+1:nd);
fprintf('******\n');
fprintf('节点能量电价为');
LMP_E = LMP.Dexp(nd-4:nd);
F_fprintfarray(LMP_E);

% 文章2的式（7）

LMP.Psigma_l = zeros(1,np);
LMP.Dsigma_l = zeros(1,nd);
for nnl = 1:nl
    for nnp = 1:np
        LMP.Psigma_l(nnp) = LMP.Psigma_l(nnp) + result.rouPF_l(nnl) * renewable(nnp).Pstdabs * result.a_lp(nnl,nnp)^ 2 / yita_l(nnl);
    end 
    for nnd = 1:nd
        LMP.Dsigma_l(nnd) = LMP.Dsigma_l(nnd) + result.rouPF_l(nnl) * demand(nnd).Dstdabs * result.a_ld(nnl,nnd)^ 2 / yita_l(nnl);
    end 
end 
LMP.Psigma_g = zeros(1,np);
LMP.Dsigma_g = zeros(1,nd);
for nng = 1:ng
    for nnp = 1:np
        LMP.Psigma_g(nnp) = LMP.Psigma_g(nnp) + result.phaiG_i(nng) * renewable(nnp).Pstdabs * result.b_gp(nng,nnp)^ 2 / yita_g(nng);
    end 
    for nnd = 1:nd
        LMP.Dsigma_g(nnd) = LMP.Dsigma_g(nnd) + result.phaiG_i(nng) * demand(nnd).Dstdabs * result.b_gd(nng,nnd)^ 2 / yita_g(nng);
    end 
end 

LMP.Psigma = LMP.Psigma_l + LMP.Psigma_g;
LMP.Dsigma = LMP.Dsigma_l + LMP.Dsigma_g;

LMP.Pmodify = LMP.Pexp + [renewable.Pstd] .* LMP.Psigma;
LMP.Dmodify = LMP.Dexp + [demand.Dstd] .* LMP.Dsigma;
%% 计算各类收益
S_calculaterevenueCCPF;
%% 阻塞的潮流
congestline = union(find(result.dualLmax > 1e-3),find(result.dualLmin > 1e-3));
fprintf('阻塞的线路有');
F_fprintfarray(congestline);
%% 阻塞的机组
congestGup = find(result.dualGmax > 1e-3);
fprintf('上阻塞的机组有');
F_fprintfarray(congestGup);
congestGdown = find(result.dualGmin > 1e-3);
fprintf('下阻塞的机组有');
F_fprintfarray(congestGdown);

