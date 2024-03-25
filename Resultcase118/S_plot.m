%% 
set(groot,'defaultfigurePosition',[200 200 800 400]);
set(groot,'defaultLegendFontName','����');
set(groot,'defaultLegendFontSize',10);
set(groot,'defaultAxesFontSize',10);
set(groot,'defaultAxesFontWeight','bold');
% set(groot,'defaultAxesFontName','����');
set(groot,'defaultAxesFontName',['SimSun']);

set(0,'defaultfigurecolor','w'); %���ñ�����ɫΪ��ɫ
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
% ylabel('ƽ�������/�۵��,$/MWh');
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
set(0,'defaultfigurecolor','w'); %���ñ�����ɫΪ��ɫ

clear
result_std0 = load('Method1_Allocate2_Std0_P1.0D1.020240205T174736.mat');
% result_std0 = load('Method1_originR_P1.0D1.020240206T194057.mat');
load('Method1_Allocate2_Std1_P1.0D1.020240205T165755.mat')
%load��һ��
% X0 = -LMP_E;
%load�ڶ���
X0 = result_std0.LMP_E;
X1 = LMP_E;
X2 = LMP_GIup;
X3 = LMP_GIdown;

%% չ�ֳ�S2�µļ۸�
F_plotcomparebusbranch(nnode,X1,X2,X3,[],'�ڵ���','�ڵ�۸� ($/MWh)',[],[],'*','o','+','x',...
    {'�����߼ʼ۸�','ע�빦����ƫ��۸�','ע�빦����ƫ��۸�'},'��ȷ������չʾ')
% (N,X1,X2,X3,X4,xlabelname,ylabelname,titlename,yrange,marker1,marker2,marker3,marker4,legendname)
%% չ�ֳ�S1/S2�����Ա�

% F_plotcomparebusbranch(nl,result_std0.result.Pl,result.Pl,[],[],'��·���','��·���� (MW)',[],[],'*','o','+','x',...
%     {'����S1�µ���·����','����S2�µ���·����'},'��·���ʶԱ�')
F_plot_interval(nl,result_std0.result.Pl,[],[],...
                    result.Pl,result.Pl + result.PlRup , result.Pl - result.PlRdown ,...
                '��·���','��·���� (MW)',[],[],'*','o',...
    {'����S1�µ���·����','����S2�µ���·����'},'��·���ʶԱ�_����')

%% չ�ֳ�����Ĺ��������� ������о���̫һ����
% F_plotcomparebusbranch(ng,result_std0.result.Gexp,result.Gexp,[],[],'������','����������� (MW)',[],[],'*','o','+','x',...
%     {'����S1�µĻ������','����S2�µĻ������'},'��������Ա�')
F_plot_interval(ng,result_std0.result.Gexp,[],[],...
                    result.Gexp,...
                    result.Gexp + result.generatorRup , ...
                    result.Gexp - result.generatorRdown ,...
                    '������','����������� (MW)',[],[],'*','o',...
                    {'����S1�µĻ������','����S2�µĻ������'},'��������Ա�_����')


%%

hold on
% saveas(gcf,'������������','bmp');

h = bar([generatorenergyR' generatorRdownR' generatorRupR'],'stack');
h(1).FaceColor = [193/256,210/256, 240/256];
ylim([0 20000]);
xlim([0,ng+0.5]);
xlabel('��������');
ylabel('�������,$');
legend('��������','�±�������','�ϱ�������','Location','Best');
legend('boxoff');
grid on;
savename = '������������';
print('-dpng','-r1000',[savename,'.png']);
saveas(gcf,savename ,'bmp');





