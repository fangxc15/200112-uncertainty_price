%% 下面开始计算LMP
LMP.Ddmax = zeros(1,nd);
LMP.Ddmin = zeros(1,nd);

for i = 1:nd
    LMP.Dexp(i) = result.price - result.dualLmax * GSDFD_ld(:,i) + result.dualLmin * GSDFD_ld(:,i);
    for l = 1:nl
        LMP.Ddmax(i) = LMP.Ddmax(i) + result.w.Lmax(l).value(np+nd+np+i) * result.dualLmax(l);
        LMP.Ddmax(i) = LMP.Ddmax(i) + result.w.Lmin(l).value(np+nd+np+i) * result.dualLmin(l);
    end
    for g = 1:ng
        LMP.Ddmax(i) = LMP.Ddmax(i) + result.w.Gmax(g).value(np+nd+np+i) * result.dualGmax(g);
        LMP.Ddmax(i) = LMP.Ddmax(i) + result.w.Gmin(g).value(np+nd+np+i) * result.dualGmin(g);
    end
    
    for l = 1:nl
        LMP.Ddmin(i) = LMP.Ddmin(i) - result.w.Lmax(l).value(np+i) * result.dualLmax(l);
        LMP.Ddmin(i) = LMP.Ddmin(i) - result.w.Lmin(l).value(np+i) * result.dualLmin(l);
    end
    for g = 1:ng
        LMP.Ddmin(i) = LMP.Ddmin(i) - result.w.Gmax(g).value(np+i) * result.dualGmax(g);
        LMP.Ddmin(i) = LMP.Ddmin(i) - result.w.Gmin(g).value(np+i) * result.dualGmin(g);
    end
    
end

LMP.Pdmax = zeros(1,np);
LMP.Pdmin = zeros(1,np);

for i = 1:np
    LMP.Pexp(i) = -result.price - result.dualLmin * GSDFP_lp(:,i) + result.dualLmax * GSDFP_lp(:,i);
    for l = 1:nl
        LMP.Pdmax(i) = LMP.Pdmax(i) + result.w.Lmax(l).value(np+nd+i) * result.dualLmax(l);
        LMP.Pdmax(i) = LMP.Pdmax(i) + result.w.Lmin(l).value(np+nd+i) * result.dualLmin(l);
    end
    for g = 1:ng
        LMP.Pdmax(i) = LMP.Pdmax(i) + result.w.Gmax(g).value(np+nd+i) * result.dualGmax(g);
        LMP.Pdmax(i) = LMP.Pdmax(i) + result.w.Gmin(g).value(np+nd+i) * result.dualGmin(g);       
    end
    
    for l = 1:nl
        LMP.Pdmin(i) = LMP.Pdmin(i) - result.w.Lmax(l).value(i) * result.dualLmax(l);
        LMP.Pdmin(i) = LMP.Pdmin(i) - result.w.Lmin(l).value(i) * result.dualLmin(l);

    end
    for g = 1:ng
        LMP.Pdmin(i) = LMP.Pdmin(i) - result.w.Gmax(g).value(i) * result.dualGmax(g);
        LMP.Pdmin(i) = LMP.Pdmin(i) - result.w.Gmin(g).value(i) * result.dualGmin(g);
    end
end 
LMP.Ddmax = LMP.Ddmax(:)';LMP.Ddmin = LMP.Ddmin(:)';LMP.Dexp = LMP.Dexp(:)';LMP.Pdmax = LMP.Pdmax(:)';LMP.Pdmin = LMP.Pdmin(:)';LMP.Pexp = LMP.Pexp(:)';
S_DQconst_modify_calculateLMP;
if nnode == 5
    fprintf('******\n');
    fprintf('节点能量电价为');
    LMP_E = LMP.Dexp(nd-4:nd);
    F_fprintfarray(LMP_E);

    fprintf('******\n');
    fprintf('节点注入上升GI价格为');
    LMP_GIup = LMP.Pdmax(np-4:np);
    F_fprintfarray(LMP_GIup);

    fprintf('节点注入下降GI价格为');
    LMP_GIdown = - LMP.Pdmin(np-4:np);
    F_fprintfarray(LMP_GIdown);
else
    fprintf('******\n');
    fprintf('节点能量电价为');
    LMP_E = LMP.Dexp; %
    F_fprintfarray(LMP_E);

    fprintf('******\n');
    fprintf('节点注入上升GI价格为');
    LMP_GIup = - LMP.Ddmin;
    F_fprintfarray(LMP_GIup);

    fprintf('节点注入下降GI价格为');
    LMP_GIdown =  LMP.Ddmax;
    F_fprintfarray(LMP_GIdown);

    
    
    
end 



%
%再求出对偶变量即可，关于负荷的、关于风电的，关于它们不确定性上下限的
%写一个市场出清模型
