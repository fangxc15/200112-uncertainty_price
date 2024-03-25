%% �������еĻ�ͼ���ǻ�����ƵĻ���Ҫ�أ�ֻ�ǲ�ͬ��kIC/spread���ѣ�ȡPareto Frontier�ϵĲ�ͬ��
%% ��������һ�� Std1,���Ǵ�ͳ�ı߼ʶ��۷�ʽ
%% result_choose������kIC = 0.12, spread=2֮�µ�ģʽ
%% ֮��Ϊ����֤kIC��ר�Ÿ�����һ��falsebidding�������Ϊ�˾�ȷ��ȡSetting.NumP=25��������һ��Result_choose2

set(groot,'defaultfigurePosition',[200 200 800 400]);
set(groot,'defaultLegendFontName','����');
set(groot,'defaultLegendFontSize',10);
set(groot,'defaultAxesFontSize',10);
set(groot,'defaultAxesFontWeight','bold');
% set(groot,'defaultAxesFontName','����');
set(groot,'defaultAxesFontName',['SimSun']);

set(0,'defaultfigurecolor','w'); %���ñ�����ɫΪ��ɫ

%% 
set(groot,'defaultfigurePosition',[200 200 950 400]);
set(groot,'defaultLegendFontName','Times New Roman');
set(groot,'defaultLegendFontSize',12);
set(groot,'defaultAxesFontSize',14);
set(groot,'defaultAxesFontWeight','bold');
% set(groot,'defaultAxesFontName','Times New Roman');
set(0,'defaultfigurecolor','w'); %���ñ�����ɫΪ��ɫ

clear
result_std1 = load('Method1_Allocate2_Std1_P1.0D1.020240205T165755.mat');
load('IEEE118_V1_choose_result.mat');
%load��һ��
% X0 = -LMP_E;
%load�ڶ���
result_std1.result.Gexp
result_choose.Gexp

% X0 = result_std0.LMP_E;
% X1 = LMP_E;
% X2 = LMP_GIup;
% X3 = LMP_GIdown;

%% չ�ֳ�S1/SW�ĳ��������Ա� ������
figure(1)
F_plotcompare_two(ng,result_std1.result.Gexp,result_choose.Gexp,...
        [],[],'������','������� (MW)',[],[],'*','o','+','x',...
    {'��ḣ������µĻ������','Ȩ����ḣ���µĻ������'},'Ȩ����ḣ���µĻ������')

figure(2)
F_plotcompare_two(nl,result_std1.result.Pl,result_choose.Pl,...
        [],[],'��·���','��·���� (MW)',[],[],'*','o','+','x',...
    {'��ḣ������µ���·����','Ȩ����ḣ���µ���·����'},'Ȩ����ḣ���µ���·����')

% (N,X1,X2,X3,X4,xlabelname,ylabelname,titlename,yrange,marker1,marker2,marker3,marker4,legendname)

%% չ�ֳ�S1/S2�����Ա�

% F_plotcomparebusbranch(nl,result_std0.result.Pl,result.Pl,[],[],'��·���','��·���� (MW)',[],[],'*','o','+','x',...
%     {'����S1�µ���·����','����S2�µ���·����'},'��·���ʶԱ�')
F_plot_interval(nl,[],result_choose.Pl,...
                    result_choose.Pl + result_choose.PlRup , ...
                    result_choose.Pl - result_choose.PlRdown ,...
                '��·���','��·���� (MW)',[],[],'*','o',...
    {'��·��������'},'choosekIC��·����_����')

%% չ�ֳ�����Ĺ��������� ������о���̫һ����
% F_plotcomparebusbranch(ng,result_std0.result.Gexp,result.Gexp,[],[],'������','����������� (MW)',[],[],'*','o','+','x',...
%     {'����S1�µĻ������','����S2�µĻ������'},'��������Ա�')
F_plot_interval(ng,[],result_choose.Gexp,...
                    result_choose.Gexp + result_choose.generatorRup , ...
                    result_choose.Gexp - result_choose.generatorRdown ,...
                    '������','����������� (MW)',[],[],'*','o',...
                    {'�����������'},'choosekIC�������_����')
%% �۸�չ�ּ۸�Աȡ�����ط��о�û�м۸�ĸ��

% hold on
% saveas(gcf,'������������','bmp');

% h = bar([result_std1.generatorenergyR' result_std1.generatorRdownR' result_std1.generatorRupR'],'stack');
% h(1).FaceColor = [193/256,210/256, 240/256];
% ylim([0 20000]);
% xlim([0,ng+0.5]);
% xlabel('��������');
% ylabel('�������,$');
% legend('��������','�±�������','�ϱ�������','Location','Best');
% legend('boxoff');
% grid on;
% savename = '������������';
% print('-dpng','-r1000',[savename,'.png']);
% saveas(gcf,savename ,'bmp');

% ѡ����������
sum([result_std1.generator(Setting.falseagent).totalrevneue])
result_choose.GstrategicR
%70834 %66198(66291) ��ʵû�������. ��Ϊ����Pareto��ʱ��ʹ�õ�Setting.NumP = 10����25

% ������������
sum([result_std1.generator(Setting.otheragent).totalrevneue])
sum([result_choose.GtotalR(Setting.otheragent)])
%47635 41502
sum([result_choose.GenergyR(Setting.otheragent)])%41469
sum([result_choose.GRupR(Setting.otheragent)]) +sum([result_choose.GRdownR(Setting.otheragent)])%33.9



% ����Դ����
sum([result_std1.renewable.totalrevenue])
sum([result_choose.RtotalR])
%25168 25978
sum(-[result_choose.LMP.Pexp] .* [renewable.Pexp])
%28195
sum([result_choose.LMP.Pdmax] .* [renewable.dPmax]) + sum(result_choose.LMP.Pdmin .* [renewable.dPmin])
%2217.3

% ��������
sum([result_std1.demand.totalcost])
sum([result_choose.DtotalC])
%165390 153290
sum([result_choose.LMP.Dexp] .* [result_choose.D_use])
%151620
sum([result_choose.LMP.Ddmax] .* [demand.dPmax])+sum([result_choose.LMP.Ddmin] .* [demand.dPmin])
%1672.7


% ��������
sum([result_std1.branch_all])
sum([result_choose.branch_all])
%21755 19614
sum([result_choose.branch_congestion]) %17028
sum([result_choose.branch_reserve]) %2586

%% ���ҿ���չʾ��һ��ͨ���ѱ��ܻ�ö���Ǯ. ���Ҳ�ǿ��Ե�
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
