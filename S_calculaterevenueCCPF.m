%% 计算每个人的收益
% totalGImoney = sum(- LMP.Ddmax .* [demand.dPmax] - LMP.Ddmin .* [demand.dPmin]) + sum(- LMP.Pdmax .* [renewable.dPmax] - LMP.Pdmin .* [renewable.dPmin]);
demandtotalcost = - LMP.Dexp .* [demand.Dexp] - LMP.Dsigma .* [demand.Dstdabs];
demandaveragecost = demandtotalcost ./[demand.Dexp];
for i = 1:nd
    demand(i).totalcost = demandtotalcost(i);
    demand(i).averagecost = demandaveragecost(i);
end 

renewabletotalrevenue = - LMP.Pexp .* [renewable.Pexp] - LMP.Psigma .* [renewable.Pstdabs];
renewableaveragerevenue = renewabletotalrevenue ./[renewable.Pexp];
for i = 1:np
    renewable(i).totalrevenue = renewabletotalrevenue(i);
    renewable(i).averagerevenue = renewableaveragerevenue(i);
end 
%% 机组节点电价的确定，策略1，按照beta分配GI，按照能量电价进行结算
totalstdcost = sum(- LMP.Dsigma .* [demand.Dstdabs]) - sum(LMP.Psigma .* [renewable.Pstdabs]);
totalstdrevenue = - totalstdcost;
generatortotalrevenue =  LMP_E([generator.bus]) .* result.Gexp + result.beta * totalstdrevenue;
generatoraveragerevenue = generatortotalrevenue ./ result.Gexp;
for i = 1:ng
    generator(i).totalrevneue = generatortotalrevenue(i);
    generator(i).averagerevenue = generatoraveragerevenue(i);
end 