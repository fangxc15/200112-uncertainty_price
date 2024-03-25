re%% 计算每个人的收益
% 按照LMP结算
totalGImoney = sum(- LMP.Ddmax .* [demand.dPmax] - LMP.Ddmin .* [demand.dPmin]) + sum(- LMP.Pdmax .* [renewable.dPmax] - LMP.Pdmin .* [renewable.dPmin]);
demandtotalcost = - LMP.Dexp .* result.D_use - LMP.Ddmax .* [demand.dPmax] - LMP.Ddmin .* [demand.dPmin];
demandaveragecost = demandtotalcost ./result.D_use;
for i = 1:nd
    demand(i).totalcost = demandtotalcost(i);
    demand(i).averagecost = demandaveragecost(i);
end 

% 按照LMP结算
renewabletotalrevenue = - LMP.Pexp .* [renewable.Pexp] - LMP.Pdmax .* [renewable.dPmax] - LMP.Pdmin .* [renewable.dPmin];
renewableaveragerevenue = renewabletotalrevenue ./[renewable.Pexp];
for i = 1:np
    renewable(i).totalrevenue = renewabletotalrevenue(i);
    renewable(i).averagerevenue = renewableaveragerevenue(i);
end 


%% 机组节点电价的确定，策略1，按照beta分配GI，按照能量电价进行结算
for i = 1:ng
    generatorC(i) = result.Gexp(i) * generator(i).cost;
    if exist('spread')
        generatorenergyR(i) = (LMP_E(generator(i).bus) - spread) * result.Gexp(i);
    else
        generatorenergyR(i) = LMP_E(generator(i).bus) * result.Gexp(i);
    end
end

if exist('origin_reserve') && origin_reserve == 1   
    for i = 1:ng
        generator_originreserve_R(i) = result.reserve_price * result.GR(i);
        generatortotalrevenue(i) = generatorenergyR(i) + generator_originreserve_R(i);
        generatoraveragerevenue(i) = generatortotalrevenue(i)/result.Gexp(i);

        generator(i).totalrevneue = generatortotalrevenue(i);
        generator(i).averagerevenue = generatoraveragerevenue(i);
        generator(i).totalcost = generatorC(i);
        generator(i).energyR = generatorenergyR(i);
        generator(i).reserveR = generator_originreserve_R(i);
    end
else
    if allocatestrategy == 1
        totalGIcost = LMP.Ddmax * [demand.dPmax]' + LMP.Ddmin * [demand.dPmin]' +  LMP.Pdmax * [renewable.dPmax]' + LMP.Pdmin * [renewable.dPmin]';
        for i = 1:ng
    %         generatorC(i) = result.Gexp(i) * generator(i).cost;
    %         if exist('spread')
    %             generatorenergyR(i) = (LMP_E(generator(i).bus) - spread) * result.Gexp(i);
    %         else
    %             generatorenergyR(i) = LMP_E(generator(i).bus) * result.Gexp(i);
    %         end
            generatorRR(i) =  result.beta(i) * totalGIcost;
            generatortotalrevenue(i) = generatorenergyR(i) + generatorRR(i);
            generatoraveragerevenue(i) = generatortotalrevenue(i)/result.Gexp(i);

            generator(i).totalrevneue = generatortotalrevenue(i);
            generator(i).averagerevenue = generatoraveragerevenue(i);
            generator(i).totalcost = generatorC(i);
            generator(i).energyR = generatorenergyR(i);
        end 
    else 
    %% 策略2，按照提供的上下备用进行分配
        for i = 1:ng
    %         generatorC(i) = result.Gexp(i) * generator(i).cost;
    %         if exist('spread')
    %             generatorenergyR(i) = (LMP_E(generator(i).bus) - spread) * result.Gexp(i);
    %         else
    %             generatorenergyR(i) = LMP_E(generator(i).bus) * result.Gexp(i);
    %         end
            generatorRupR(i) = result.dualGmax(i) * Qconst' * result.w.Gmax(i).value;
            generatorRdownR(i) = result.dualGmin(i) * Qconst' * result.w.Gmin(i).value;
            generatortotalrevenue(i) = generatorenergyR(i) + generatorRupR(i) + generatorRdownR(i);
            generatoraveragerevenue(i) = generatortotalrevenue(i)/result.Gexp(i);

            generator(i).totalrevneue = generatortotalrevenue(i);
            generator(i).averagerevenue = generatoraveragerevenue(i);
            generator(i).totalcost = generatorC(i);
            generator(i).energyR = generatorenergyR(i);
            generator(i).RupR = generatorRupR(i);
            generator(i).RdownR = generatorRdownR(i);
        end
    end
end

%% 查看congestion_revenue是多少？
for i = 1:nl
    branch_congestion = result.Pl .* result.dualLmax - result.Pl .* result.dualLmin;
    branch_reserve = result.PlRup .* result.dualLmax + result.PlRdown .* result.dualLmin;
    branch_all = (result.dualLmax + result.dualLmin) .* [branch.Pmax];
end
