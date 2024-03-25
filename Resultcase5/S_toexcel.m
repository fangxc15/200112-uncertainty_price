%% Power
excelname = 'case5_power';
sheetname = 'method1_std2';
xlswrite(excelname,result.Gexp,sheetname,'B2');
xlswrite(excelname,result.generatorRup,sheetname,'B3');
xlswrite(excelname,result.generatorRdown,sheetname,'B4');

xlswrite(excelname,result.Pl,sheetname,'B6');
xlswrite(excelname,result.PlRup,sheetname,'B7');
xlswrite(excelname,result.PlRdown,sheetname,'B8');
%% Revenue
xlsname = 'case5_revenue';
sheetname = 'method1_std0';

xlswrite(xlsname,result.Gexp,sheetname,'B2'); %写入期望出力
xlswrite(xlsname,result.beta,sheetname,'B3'); %写入期望调整因子
xlswrite(xlsname,generatorenergyR,sheetname,'B4');
xlswrite(xlsname,generatorRupR,sheetname,'B5');
xlswrite(xlsname,generatorRdownR,sheetname,'B6');
xlswrite(xlsname,[generator.averagerevenue],sheetname,'B7');

%% Price
excelname = 'case5_price';
sheetname = 'method1_std1';
xlswrite(excelname,LMP_E,sheetname,'B2');
xlswrite(excelname,LMP_GIdown,sheetname,'B3');
xlswrite(excelname,LMP_GIup,sheetname,'B4');
for nodeno = 2:4
    demandno = find([demand.bus] == nodeno);
    renewableno = find([renewable.bus] == nodeno);
    demandno(length(demandno)) = [];
    renewableno(length(renewableno)) = [];
    Averageprice = [LMP_E(nodeno) abs([demand(demandno).averagecost]) [renewable(renewableno).averagerevenue]];
    xlswrite(excelname,Averageprice,sheetname,['B' num2str(nodeno+3)]);

end
% xlswrite(excelname,result.PlRup,sheetname,'B7');
% xlswrite(excelname,result.PlRdown,sheetname,'B8');

%% 汇总

excelname = 'case5_sum';
sheetname = 'method1_std0';
demandtotalEcost = sum(- LMP.Dexp .* [demand.Dexp]); 
demandtotalGIcost = sum(- LMP.Ddmax .* [demand.dPmax] - LMP.Ddmin .* [demand.dPmin]);
renewabletotalErevenue = sum(- LMP.Pexp .* [renewable.Pexp]);
renewabletotalGIcost = sum(- LMP.Pdmax .* [renewable.dPmax] - LMP.Pdmin .* [renewable.dPmin]);
generatortotalErevenue = sum(generatorenergyR);
generatortotalGIrevenue = sum(generatorRdownR + generatorRupR);
writeout = [result.origincost;demandtotalEcost;demandtotalGIcost;renewabletotalErevenue;...
    renewabletotalGIcost;generatortotalErevenue;generatortotalGIrevenue];
xlswrite(excelname,writeout,sheetname,'B2');


