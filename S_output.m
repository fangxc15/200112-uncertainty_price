%% 鲁棒优化结果输出
result.Gexp = value(Gexp); result.Gexp = result.Gexp(:)';

if exist('Dexp_curt') == 1
    result.Dexp_curt = value(Dexp_curt);
    result.Dexp_curt = result.Dexp_curt(:)';
    result.D_use = [demand.Dexp] - result.Dexp_curt;
else
    result.D_use = [demand.Dexp];
end

if exist('origin_reserve') && origin_reserve == 1
    result.GR = value(GR);
    result.reserve_price = dual(Cons(Dual.reserve_price));
end

fprintf('*******\n');
fprintf('机组出力为');
F_fprintfarray(result.Gexp);
fprintf('机组所在的节点为');
success = F_fprintfarray([generator.bus]);
fprintf('机组的成本为');
F_fprintfarray([generator.cost]);
result.beta = value(beta);
result.beta = result.beta(:)';
for i = 1:nl
    result.w.Lmax(i).value = value([w.Lmax(i).varible]);
    result.w.Lmin(i).value = value([w.Lmin(i).varible]);
end 
for i = 1:ng
    result.w.Gmax(i).value = value([w.Gmax(i).varible]);
    result.w.Gmin(i).value = value([w.Gmin(i).varible]);
end 


result.x = [result.Gexp result.beta 1]; result.x = result.x(:)';
fprintf('******\n');
fprintf('调整因子');
F_fprintfarray(result.beta);

result.Pl = GSDFG_lg * value(Gexp) + GSDFP_lp * [renewable.Pexp]' - GSDFD_ld * result.D_use'; result.Pl = result.Pl(:)';
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

result.dualbeta_more =  dual(Cons(Dual.consbeta_more));
fprintf('*********\n');
fprintf('beta_more的边际价格为%f\n',result.dualbeta_more);
result.dualbeta_less =  dual(Cons(Dual.consbeta_less));
fprintf('beta_less的边际价格为%f\n',result.dualbeta_less);
result.dualLmax =  result.dualLmax(:)';result.dualLmin =  result.dualLmin(:)';result.dualGmax =  result.dualGmax(:)';result.dualGmin =  result.dualGmin(:)';
%% 校验计算得到的直流潮流是否正确
S_DCcheck;
% if DCcheck 
%     demandvalue = [demand.Dexp];
%     renewablevalue = [renewable.Pexp];
%     for i = 1:nb
%         demandno = find([demand.bus] == i);
%         renewableno = find([renewable.bus] == i);
%         mpc.bus(i,3) = - sum(renewablevalue(renewableno)) + sum(demandvalue(demandno));
%     end 
% %     mpc.bus(:,3) = [0;150;150;450;0];
%     mpc.gen(:,2) = result.Gexp;
%     output = F_calculate_DC(mpc);
%     if sum(abs([output.branch.P] - result.Pl'))<1e-5
%         fprintf('********\n');
%         fprintf('通过直流潮流校验\n\n');
%     end 
% end
%% 鲁棒校验
if robustcheck 
    ops = sdpsettings('verbose',0);
    for i = 1:nl
        u = sdpvar(np+nd,1);
        ConsLmax = [];
        ConsLmax = [ConsLmax, Dconst * u + Qconst >=0];
        objLmax = (aconst.Lmax(i).value + Pconst.Lmax(i).value * u)' *  result.x' - bconst.Lmax(i).value;
        solution.Lmax(i) = optimize(ConsLmax,-objLmax,ops);
        check.Lmaxvalue(i) = value(objLmax); 
        check.Lmaxcomp(i) = result.dualLmax(i) * value(objLmax); 

        u = sdpvar(np+nd,1);
        ConsLmin = [];
        ConsLmin = [ConsLmin, Dconst * u + Qconst >=0];
        objLmin = (aconst.Lmin(i).value + Pconst.Lmin(i).value * u)' *  result.x' - bconst.Lmin(i).value;
        solution.Lmin(i) = optimize(ConsLmin,-objLmin,ops);
        check.Lminvalue(i) = value(objLmin); 
        check.Lmincomp(i) = result.dualLmin(i) * value(objLmin); 
    end 

    for i = 1:ng
        u = sdpvar(np+nd,1);
        ConsGmax = [];
        ConsGmax = [ConsGmax, Dconst * u + Qconst >=0];
        objGmax = (aconst.Gmax(i).value + Pconst.Gmax(i).value * u)' *  result.x' - bconst.Gmax(i).value;
        solution.Gmax(i) = optimize(ConsGmax,-objGmax,ops);

        check.Gmaxvalue(i) = value(objGmax); 
        check.Gmaxcomp(i) = result.dualGmax(i) * value(objGmax); 

        u = sdpvar(np+nd,1);
        ConsGmin = [];
        ConsGmin = [ConsGmin, Dconst * u + Qconst >=0];
        objGmin = (aconst.Gmin(i).value + Pconst.Gmin(i).value * u)' *  result.x' - bconst.Gmin(i).value;
        solution.Gmin(i) = optimize(ConsGmin,-objGmin,ops);

        check.Gminvalue(i) = value(objGmin); 
        check.Gmincomp(i) = result.dualGmin(i) * value(objGmin); 
    end 
    robustcheck = 0;
    if (max(check.Gmaxvalue) <= 1e-4) &&  (max(abs(check.Gmaxcomp)) <= 1e-4)
        if (max(check.Gminvalue) <= 1e-4) &&  (max(abs(check.Gmincomp)) <= 1e-4)
            if (max(check.Lmaxvalue) <= 1e-4) &&  (max(abs(check.Lmaxcomp)) <= 1e-4)
                if (max(check.Lminvalue) <= 1e-4) &&  (max(abs(check.Lmincomp)) <= 1e-4)
                    fprintf('********\n');
                    fprintf('通过鲁棒校验\n\n');
                    robustcheck = 1;
                end 
            end 
        end 
    end
    if robustcheck == 0
            fprintf('!!!!!!!!!!!!\n');
            fprintf('不通过鲁棒校验\n\n');
    end
end

%% 阻塞的潮流
congestline = union(find(result.dualLmax),find(result.dualLmin));
fprintf('阻塞的线路有');
F_fprintfarray(congestline);
%% 阻塞的机组
congestGup = find(result.dualGmax);
fprintf('上阻塞的机组有');
F_fprintfarray(congestGup);
congestGdown = find(result.dualGmin);
fprintf('下阻塞的机组有');
F_fprintfarray(congestGdown);

%% 求预留的上下备用. 这个值其实不一定准确。有可能根本没有那么多！
for i = 1:ng
    result.generatorRup(i) =   Qconst' * result.w.Gmax(i).value;
    result.generatorRdown(i) =  Qconst' * result.w.Gmin(i).value;
end 
for i = 1:nl
    result.PlRup(i) =  Qconst' * result.w.Lmax(i).value;
    result.PlRdown(i) =  Qconst' * result.w.Lmin(i).value;
end 


