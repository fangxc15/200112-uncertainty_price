%% 这里所有的画图都是基于设计的机制要素，只是不同的kIC/spread而已，取Pareto Frontier上的不同点
%% 这里算了一个 Std1,就是传统的边际定价方式
%% result_choose，就是kIC = 0.12, spread=2之下的模式
%% 之后为了验证kIC，专门给算了一个falsebidding的情况。为了精确，取Setting.NumP=25，重算了一个Result_choose2

set(groot,'defaultfigurePosition',[200 200 800 400]);
set(groot,'defaultLegendFontName','黑体');
set(groot,'defaultLegendFontSize',10);
set(groot,'defaultAxesFontSize',10);
set(groot,'defaultAxesFontWeight','bold');
% set(groot,'defaultAxesFontName','黑体');
set(groot,'defaultAxesFontName',['SimSun']);

set(0,'defaultfigurecolor','w'); %设置背景颜色为白色

%% 
set(groot,'defaultfigurePosition',[200 200 950 400]);
set(groot,'defaultLegendFontName','Times New Roman');
set(groot,'defaultLegendFontSize',12);
set(groot,'defaultAxesFontSize',14);
set(groot,'defaultAxesFontWeight','bold');
% set(groot,'defaultAxesFontName','Times New Roman');
set(0,'defaultfigurecolor','w'); %设置背景颜色为白色

clear
result_std1 = load('Method1_Allocate2_Std1_P1.0D1.020240205T165755.mat');
load('IEEE118_V1_choose_result.mat');
%load第一个
% X0 = -LMP_E;
%load第二个
result_std1.result.Gexp
result_choose.Gexp

% X0 = result_std0.LMP_E;
% X1 = LMP_E;
% X2 = LMP_GIup;
% X3 = LMP_GIdown;

%% 展现出S1/SW的出力潮流对比 （量）
figure(1)
F_plotcompare_two(ng,result_std1.result.Gexp,result_choose.Gexp,...
        [],[],'机组编号','机组出力 (MW)',[],[],'*','o','+','x',...
    {'社会福利最大化下的机组出力','权衡社会福利下的机组出力'},'权衡社会福利下的机组出力')

figure(2)
F_plotcompare_two(nl,result_std1.result.Pl,result_choose.Pl,...
        [],[],'线路编号','线路潮流 (MW)',[],[],'*','o','+','x',...
    {'社会福利最大化下的线路潮流','权衡社会福利下的线路潮流'},'权衡社会福利下的线路潮流')

% (N,X1,X2,X3,X4,xlabelname,ylabelname,titlename,yrange,marker1,marker2,marker3,marker4,legendname)

%% 展现出S1/S2潮流对比

% F_plotcomparebusbranch(nl,result_std0.result.Pl,result.Pl,[],[],'线路编号','线路潮流 (MW)',[],[],'*','o','+','x',...
%     {'场景S1下的线路功率','场景S2下的线路功率'},'线路功率对比')
F_plot_interval(nl,[],result_choose.Pl,...
                    result_choose.Pl + result_choose.PlRup , ...
                    result_choose.Pl - result_choose.PlRdown ,...
                '线路编号','线路潮流 (MW)',[],[],'*','o',...
    {'线路功率区间'},'choosekIC线路功率_区间')

%% 展现出机组的功率上下限 （这个感觉不太一样）
% F_plotcomparebusbranch(ng,result_std0.result.Gexp,result.Gexp,[],[],'机组编号','机组出力潮流 (MW)',[],[],'*','o','+','x',...
%     {'场景S1下的机组出力','场景S2下的机组出力'},'机组出力对比')
F_plot_interval(ng,[],result_choose.Gexp,...
                    result_choose.Gexp + result_choose.generatorRup , ...
                    result_choose.Gexp - result_choose.generatorRdown ,...
                    '机组编号','机组出力功率 (MW)',[],[],'*','o',...
                    {'机组出力区间'},'choosekIC机组出力_区间')
%% 价格、展现价格对比。这个地方感觉没有价格的概念。

% hold on
% saveas(gcf,'机组的利润情况','bmp');

% h = bar([result_std1.generatorenergyR' result_std1.generatorRdownR' result_std1.generatorRupR'],'stack');
% h(1).FaceColor = [193/256,210/256, 240/256];
% ylim([0 20000]);
% xlim([0,ng+0.5]);
% xlabel('发电机编号');
% ylabel('火电收入,$');
% legend('能量收入','下备用收入','上备用收入','Location','Best');
% legend('boxoff');
% grid on;
% savename = '机组的利润情况';
% print('-dpng','-r1000',[savename,'.png']);
% saveas(gcf,savename ,'bmp');

% 选定发电主体
sum([result_std1.generator(Setting.falseagent).totalrevneue])
result_choose.GstrategicR
%70834 %66198(66291) 其实没多大区别. 因为计算Pareto的时候使用的Setting.NumP = 10而非25

% 其他发电主体
sum([result_std1.generator(Setting.otheragent).totalrevneue])
sum([result_choose.GtotalR(Setting.otheragent)])
%47635 41502
sum([result_choose.GenergyR(Setting.otheragent)])%41469
sum([result_choose.GRupR(Setting.otheragent)]) +sum([result_choose.GRdownR(Setting.otheragent)])%33.9



% 新能源主体
sum([result_std1.renewable.totalrevenue])
sum([result_choose.RtotalR])
%25168 25978
sum(-[result_choose.LMP.Pexp] .* [renewable.Pexp])
%28195
sum([result_choose.LMP.Pdmax] .* [renewable.dPmax]) + sum(result_choose.LMP.Pdmin .* [renewable.dPmin])
%2217.3

% 负荷主体
sum([result_std1.demand.totalcost])
sum([result_choose.DtotalC])
%165390 153290
sum([result_choose.LMP.Dexp] .* [result_choose.D_use])
%151620
sum([result_choose.LMP.Ddmax] .* [demand.dPmax])+sum([result_choose.LMP.Ddmin] .* [demand.dPmin])
%1672.7


% 阻塞费用
sum([result_std1.branch_all])
sum([result_choose.branch_all])
%21755 19614
sum([result_choose.branch_congestion]) %17028
sum([result_choose.branch_reserve]) %2586

%% 但我可以展示它一共通过谎报能获得多少钱. 这个也是可以的
% result_Pareto = load('IEEE118_V1_falsestrategy.mat');

result_choose_false = load('IEEE118_V1_choose_false_2.mat');
result_choose = load('IEEE118_V1_choose_result_2.mat');


result_choose.result_choose.GstrategicP % 21359
result_choose_false.result_choose_false.GstrategicP % 22336
agentno = result_choose_false.Setting.falseagent;
sum(result_choose_false.Setting.Qmaxq(agentno) .* result_choose_false.Setting.false_volume(agentno)) %8960

(22336-21359)/8960 %0.1090/0.1218


% false_Para = result_choose_false.Para.gen_Point;
% real_Para = result_choose.Para.gen_Point;
% 
% false_Gexp = []; real_Gexp = [];
% for i = 1:result_choose_false.Setting.NumP
%     false_Gexp = [false_Gexp result_choose_false.result_input(i).Gexp'];
%     real_Gexp = [real_Gexp result_choose.result_input(i).Gexp'];
% end
