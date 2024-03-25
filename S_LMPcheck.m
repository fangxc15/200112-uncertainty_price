if LMPcheck == 1
    smallm = 1e-4;
    ops = sdpsettings('verbose',0','solver','gurobi');
    for nn = 1:nnode
        demand(nd-nnode+nn).Dexp = smallm;
        if methodchoose == 1
             S_marketclearing;
        else 
            S_marketclearingCCPF;
        end
        newcost = value(obj);
        LMP_Echeck(nn) = (newcost - result.origincost)/smallm;
        demand(nd-nnode+nn).Dexp = 0;
    end
    LMP_E;
    LMP_Echeck;

    if methodchoose == 2
        for nnnd = 1:nd
            demand(nnnd).Dexp = demand(nnnd).Dexp + smallm;
            demand(nnnd).Dstdabs = demand(nnnd).Dexp * demand(nnnd).Dstd; %表示方差也随着出力期望的增大而增大
            S_marketclearingCCPF;
            newcost = value(obj);
            LMP_EDmodifycheck(nnnd) = (newcost - result.origincost)/smallm;
            demand(nnnd).Dexp = demand(nnnd).Dexp - smallm;
            demand(nnnd).Dstdabs = demand(nnnd).Dexp * demand(nnnd).Dstd; %表示方差也随着出力期望的增大而增大
        end 
        for nnnp = 1:np
            renewable(nnnp).Pexp = renewable(nnnp).Pexp + smallm;
            renewable(nnnp).Pstdabs = renewable(nnnp).Pexp * renewable(nnnp).Pstd; %表示方差也随着出力期望的增大而增大
            S_marketclearingCCPF;
            newcost = value(obj);
            LMP_EPmodifycheck(nnnp) = (newcost - result.origincost)/smallm;
            renewable(nnnp).Pexp = renewable(nnnp).Pexp - smallm;
            renewable(nnnp).Pstdabs = renewable(nnnp).Pexp * renewable(nnnp).Pstd; %表示方差也随着出力期望的增大而增大
        end    
    end 
    % LMP_EDmodifycheck
    % LMP.Dmodify
    % LMP_EPmodifycheck
    % LMP.Pmodify


    if methodchoose == 1
        smallM = 1e-4;
        for nn = 1:nnode
            demand(nd-nnode+nn).dPmin = -smallm; %demand有一个微小的变小，相当于节点注入变大
            S_marketclearing;
            newcost = value(obj);
            LMP_GIupcheck(nn) = (newcost - result.origincost)/(smallm);
            demand(nd-nnode+nn).dPmin = 0;
        end
        LMP_GIup;
        LMP_GIupcheck;

        for nn = 1:nnode
            demand(nd-nnode+nn).dPmax = smallm;
            S_marketclearing;
            newcost = value(obj);
            LMP_GIdowncheck(nn) = (newcost - result.origincost)/smallm;
            demand(nd-nnode+nn).dPmax = 0;
        end
        LMP_GIdown;
        LMP_GIdowncheck;
    end


    LMPcheck = 0;
    if (norm(LMP_E - LMP_Echeck) <= 1e-3) 
        if methodchoose == 2
            if (norm(LMP_EDmodifycheck - LMP.Dmodify)<=1e-2) && (norm(LMP_EPmodifycheck - LMP.Pmodify) <= 1e-2) 
                LMPcheck = 1;
                fprintf('*******\n');
                fprintf('通过LMP校验\n');
            end 
        else 
            if (norm(LMP_GIdown - LMP_GIdowncheck)<=1e-3) && (norm(LMP_GIup - LMP_GIupcheck) <= 1e-3) 
                fprintf('*******\n');
                fprintf('通过LMP校验\n');
                LMPcheck = 1;
            end
        end 
    end 
    if LMPcheck == 0 
        fprintf('!!!!!!!!!!!!!!!!\n');
        fprintf('不通过LMP校验\n');
    end 
end 