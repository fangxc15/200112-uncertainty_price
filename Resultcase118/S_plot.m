%% 
set(groot,'defaultfigurePosition',[200 200 800 400]);
set(groot,'defaultLegendFontName','黑体');
set(groot,'defaultLegendFontSize',10);
set(groot,'defaultAxesFontSize',10);
set(groot,'defaultAxesFontWeight','bold');
% set(groot,'defaultAxesFontName','黑体');
set(groot,'defaultAxesFontName',['SimSun']);

set(0,'defaultfigurecolor','w'); %设置背景颜色为白色
% nodeno = 4;
% 
% if nodeno == 2
%     legendname = {'LMP-E' 'Load1','Load2','Load3','WF1','WF2','WF3'};
% elseif nodeno == 3
%     legendname = {'LMP-E' 'Load4','Load5','Load6','WF4','WF5','WF6'};
% else 
%     legendname = {'LMP-E' 'Load7','Load8','Load9'};
% end 
% 
% demandno = find([demand.bus] == nodeno);
% renewableno = find([renewable.bus] == nodeno);
% 
% demandno(length(demandno)) = [];
% renewableno(length(renewableno)) = [];
% 
% Averageprice0 = [LMP_E(nodeno) abs([demand(demandno).averagecost]) [renewable(renewableno).averagerevenue]];
% Averageprice = diag(Averageprice0);
% if nodeno == 2|| nodeno ==3
%     color_background=['k' 'b' 'b' 'b' 'm' 'm' 'm'];
% elseif nodeno == 4
%     color_background=['k' 'b' 'b' 'b'];
% end 
% for i = 1:size(Averageprice,1)
%     b = bar( Averageprice(i,:),'FaceColor',color_background(i),'BarWidth',0.3);
%     hold on
% end 
% xlowrange = floor(min(Averageprice0)/2) * 2;
% xuprange = ceil(max(Averageprice0)/2) * 2;
% ylim([xlowrange xuprange]);
% 
% set(gca,'XTickLabel',legendname);
% ylabel('平均购电价/售电价,$/MWh');
% grid on 
% 
% saveas(gcf,['node' num2str(nodeno)],'bmp');

%% 
set(groot,'defaultfigurePosition',[200 200 950 400]);
set(groot,'defaultLegendFontName','Times New Roman');
set(groot,'defaultLegendFontSize',12);
set(groot,'defaultAxesFontSize',14);
set(groot,'defaultAxesFontWeight','bold');
% set(groot,'defaultAxesFontName','Times New Roman');
set(0,'defaultfigurecolor','w'); %设置背景颜色为白色

clear
result_std0 = load('Method1_Allocate2_Std0_P1.0D1.020240205T174736.mat');
% result_std0 = load('Method1_originR_P1.0D1.020240206T194057.mat');
load('Method1_Allocate2_Std1_P1.0D1.020240205T165755.mat')
%load第一个
% X0 = -LMP_E;
%load第二个
X0 = result_std0.LMP_E;
X1 = LMP_E;
X2 = LMP_GIup;
X3 = LMP_GIdown;

%% 展现出S2下的价格
F_plotcomparebusbranch(nnode,X1,X2,X3,[],'节点编号','节点价格 ($/MWh)',[],[],'*','o','+','x',...
    {'能量边际价格','注入功率上偏差价格','注入功率下偏差价格'},'不确定定价展示')
% (N,X1,X2,X3,X4,xlabelname,ylabelname,titlename,yrange,marker1,marker2,marker3,marker4,legendname)
%% 展现出S1/S2潮流对比

% F_plotcomparebusbranch(nl,result_std0.result.Pl,result.Pl,[],[],'线路编号','线路潮流 (MW)',[],[],'*','o','+','x',...
%     {'场景S1下的线路功率','场景S2下的线路功率'},'线路功率对比')
F_plot_interval(nl,result_std0.result.Pl,[],[],...
                    result.Pl,result.Pl + result.PlRup , result.Pl - result.PlRdown ,...
                '线路编号','线路潮流 (MW)',[],[],'*','o',...
    {'场景S1下的线路功率','场景S2下的线路功率'},'线路功率对比_区间')

%% 展现出机组的功率上下限 （这个感觉不太一样）
% F_plotcomparebusbranch(ng,result_std0.result.Gexp,result.Gexp,[],[],'机组编号','机组出力潮流 (MW)',[],[],'*','o','+','x',...
%     {'场景S1下的机组出力','场景S2下的机组出力'},'机组出力对比')
F_plot_interval(ng,result_std0.result.Gexp,[],[],...
                    result.Gexp,...
                    result.Gexp + result.generatorRup , ...
                    result.Gexp - result.generatorRdown ,...
                    '机组编号','机组出力功率 (MW)',[],[],'*','o',...
                    {'场景S1下的机组出力','场景S2下的机组出力'},'机组出力对比_区间')


%%

hold on
% saveas(gcf,'机组的利润情况','bmp');

h = bar([generatorenergyR' generatorRdownR' generatorRupR'],'stack');
h(1).FaceColor = [193/256,210/256, 240/256];
ylim([0 20000]);
xlim([0,ng+0.5]);
xlabel('发电机编号');
ylabel('火电收入,$');
legend('能量收入','下备用收入','上备用收入','Location','Best');
legend('boxoff');
grid on;
savename = '机组的利润情况';
print('-dpng','-r1000',[savename,'.png']);
saveas(gcf,savename ,'bmp');





