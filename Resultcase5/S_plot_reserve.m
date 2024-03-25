% 这个是修改后的，考虑了reserve的出清

set(groot,'defaultfigurePosition',[150 150 550 300]);
set(groot,'defaultLegendFontName','Times New Roman');
set(groot,'defaultLegendFontSize',12);
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultAxesFontWeight','bold');
% set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultAxesFontName',['SimSun']);

set(0,'defaultfigurecolor','w'); %设置背景颜色为白色
%%
% X0=LMP_E;
% load一个值
figure(1)

result_std0 = load('Method1_originR_P1.0D1.020240206T193947.mat')
load('Method1_Allocate2_Std1_P1.0D1.020240205T145340.mat')
X0 = result_std0.LMP_E;
X1 = LMP_E;
b = bar([X0' X1']);
% ch = get(b,'children'); 
set(b(1),'FaceColor',[0 0.95 1]);
set(b(2),'FaceColor',[1 0.7 0.75]);

legend('S1','S2','Location','Northwest');
xlabel('节点编号');
ylabel('能量边际价格 ($/MWh)');
set(gca,'XTickLabel',{'A','B','C','D','E'});
set(gca,'Ticklength',[0,0])

legend('boxoff');
grid on
print('-dpng','-r1000','节点能量电价对比(reserve).png');
saveas(1,'节点能量电价对比(reserve)','bmp');

%% 机组出力绘图
figure(2)
h = bar([result_std0.result.Gexp(:) result_std0.result.GR],'stack','BarWidth',0.5);
h(1).FaceColor = [143/256,160/256, 250/256];
h(2).FaceColor = [193/256,210/256, 240/256];
% h(2).HandleVisibility = 'off';
hold on
scatter(1:nnode,result.Gexp,'filled','r')
hold on
for i = 1:nnode
    plot([i i],[result.Gexp(i)+result.generatorRup(i) result.Gexp(i)-result.generatorRdown(i)],'r-','Linewidth',2)
end
grid on 
h = legend('场景S1下的出力','场景S1下的备用','场景S2的出力基线','场景S2的上下调节空间','Location','NorthWest');
legend('boxoff');
xlabel('机组编号');
ylabel('机组出力 (MW)');
set(gca,'XGrid','off');
set(gca,'Ticklength',[0,0])

% legend('boxoff');
% h.string = {'场景S1','','场景S2'}
ylim([0, 800])

print('-dpng','-r1000','机组出力对比(reserve).png');
saveas(2,'机组出力对比(reserve)','bmp');

%% 线路功率
figure(3)
h = bar(result_std0.result.Pl(:),'BarWidth',0.5);
h(1).FaceColor = [143/256,160/256, 250/256];
% h(2).FaceColor = [193/256,210/256, 240/256];
% h(2).HandleVisibility = 'off';
hold on
scatter(1:nl,result.Pl,'filled','r')
hold on
for i = 1:nl
    plot([i i],[min(branch(i).Pmax,result.Pl(i)+ result.PlRup(i)) ...
                max(-branch(i).Pmax,result.Pl(i)-result.PlRup(i))],'r-','Linewidth',2)
end
grid on 
h = legend('场景S1下的线路功率','场景S2下的线路功率','场景S2下的线路功率上下调区间','Location','NorthEast');
legend('boxoff');
xlabel('线路编号');
ylabel('线路功率 (MW)');
set(gca,'XGrid','off');
set(gca,'Ticklength',[0,0])

% legend('boxoff');
% h.string = {'场景S1','','场景S2'}
% ylim([0, 800])
print('-dpng','-r1000','线路功率对比(reserve).png');
saveas(3,'线路功率对比(reserve)','bmp');

%% 线路功率再平衡
set(groot,'defaultfigurePosition',[150 150 550 400]);

figure(4)
h = bar([ result_std0.result.Pl(:)  result_std0.result_relaxline.Pl(:) - result_std0.result.Pl(:)],'stacked','BarWidth',0.5);
% result_std0.result_relaxline

h1 = bar(result_std0.result.Pl(:) ,'BarWidth',0.5);
h1.FaceColor = [143/256,160/256, 250/256];
h1.FaceAlpha = 0.8;

hold on
h2 = bar(result_std0.result_relaxline.Pl(:),'BarWidth',0.5);
h2.FaceColor = [193/256,210/256, 240/256];
h2.FaceAlpha = 0.8;
% h2.HandleVisibility = 'off';
hold on
scatter(1:nl,result.Pl,'filled','r')
hold on
i = 1;
p1 = plot([i i],[min(branch(i).Pmax,result.Pl(i)+ result.PlRup(i)) ...
                max(-branch(i).Pmax,result.Pl(i)-result.PlRup(i))],'r-','Linewidth',2);
hold on 
for i = 1:nl
    p = plot([i i],[min(branch(i).Pmax,result.Pl(i)+ result.PlRup(i)) ...
                max(-branch(i).Pmax,result.Pl(i)-result.PlRup(i))],'r-','Linewidth',2);
    hold on
    p.HandleVisibility = 'off';
end
% for i = 2:nl

for i = 1:nl
    if branch(i).Pmax < 1000
        plot([i-0.5 i+0.5],[branch(i).Pmax branch(i).Pmax],'k--','Linewidth',2);
        hold on
        plot([i-0.5 i+0.5],[-branch(i).Pmax -branch(i).Pmax],'k--','Linewidth',2);
        hold on
    end
end
% end
grid on 
h = legend('场景S1下的线路功率','场景S1下线路功率实时调节量','场景S2下的线路功率','场景S2下的线路功率实时调节量','功率上限',...
    'Location','NorthEast');
ylim([-800 800]);
legend('boxoff');
xlabel('线路编号');
ylabel('线路功率 (MW)');
set(gca,'XGrid','off');
set(gca,'Ticklength',[0,0])

% legend('boxoff');
% h.string = {'场景S1','','场景S2'}
print('-dpng','-r1000','线路功率再平衡(reserve).png');
saveas(4,'线路功率再平衡(reserve)','bmp');
%%
LMP
LMP_E
LMP_GIdown
LMP_GIup
result
result.dualGmax
result.dualGmin
result.dualLmax
result.dualLmin
[generator.bus]


result.beta
generatorenergyR
generatorRupR
generatorRdownR
generatoraveragerevenue
generatortotalrevenue-generatorC
result.generatorRup % 这个是提供的量
%% 原先的reserve机制导致的切负荷情况

%% 数据统计
result_std0.generatorenergyR
result_std0.generatorenergyR - result_std0.generatorC
result_std0.result_rebalance.curt_ratio
result_std0.result_rebalance.D_curt
result_std0.result_relaxline.Plrelax_minus


demandtotalEcost = sum(- LMP.Dexp .* [demand.Dexp]); 
demandtotalGIcost = sum(- LMP.Ddmax .* [demand.dPmax] - LMP.Ddmin .* [demand.dPmin]);
renewabletotalErevenue = sum(- LMP.Pexp .* [renewable.Pexp]);
renewabletotalGIcost = sum(- LMP.Pdmax .* [renewable.dPmax] - LMP.Pdmin .* [renewable.dPmin]);
generatortotalErevenue = sum(generatorenergyR);
generatortotalGIrevenue = sum(generatorRdownR + generatorRupR);
FTRotalGIrevenue = sum(branch_reserve);
sum(generatorC)
% 这里还可以拿出std=2的统计

sum(result_std0.generatorC)
