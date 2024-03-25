set(groot,'defaultfigurePosition',[150 150 550 300]);
set(groot,'defaultLegendFontName','Times New Roman');
set(groot,'defaultLegendFontSize',12);
set(groot,'defaultAxesFontSize',11);
set(groot,'defaultAxesFontWeight','bold');
% set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultAxesFontName',['SimSun']);

set(0,'defaultfigurecolor','w'); %���ñ�����ɫΪ��ɫ
%%
% X0=LMP_E;
% loadһ��ֵ
result_std0 = load('Method1_Allocate2_Std0_P1.0D1.020240205T155421.mat');
load('Method1_Allocate2_Std1_P1.0D1.020240205T145340.mat')
X0 = result_std0.LMP_E;
X1 = LMP_E;
b = bar([X0' X1']);
% ch = get(b,'children'); 
set(b(1),'FaceColor',[0 0.95 1]);
set(b(2),'FaceColor',[1 0.7 0.75]);

legend('S1','S2','Location','Northwest');
xlabel('�ڵ���');
ylabel('�����߼ʼ۸� ($/MWh)');
set(gca,'XTickLabel',{'A','B','C','D','E'});
legend('boxoff');
grid on
print('-dpng','-r1000','�ڵ�������۶Ա�.png');
saveas(gcf,'�ڵ�������۶Ա�','bmp');
%%

for nodeno = 2
    
    % if nodeno == 2
    %     legendname = {'ELMP' 'Load1','Load2','Load3','R1','R2','R3'};
    % elseif nodeno == 3
    %     legendname = {'ELMP' 'Load4','Load5','Load6','R4','R5','R6'};
    % else 
    %     legendname = {'ELMP' 'Load7','Load8','Load9'};
    % end 

    if nodeno == 2
        legendname = {'�����۸�' '����1','����2','����3','����Դ1','����Դ2','����Դ3'};
    elseif nodeno == 3
        legendname = {'�����۸�' '����4','����5','����6','����Դ4','����Դ5','����Դ6'};
    else 
        legendname = {'�����۸�' '����7','����8','����9'};
    end 

    demandno = find([demand.bus] == nodeno);
    renewableno = find([renewable.bus] == nodeno);

    demandno(length(demandno)) = [];
    renewableno(length(renewableno)) = [];

    Averageprice0 = [LMP_E(nodeno) abs([demand(demandno).averagecost]) [renewable(renewableno).averagerevenue]];
    Averageprice = diag(Averageprice0);
    if nodeno == 2|| nodeno ==3
        color_background=['k' 'b' 'b' 'b' 'm' 'm' 'm'];
    elseif nodeno == 4
        color_background=['k' 'b' 'b' 'b'];
    end 
    figure(nnode)
    for i = 1:size(Averageprice,1)
        b = bar( Averageprice(i,:),'FaceColor',color_background(i),'BarWidth',0.3);
        if i < size(Averageprice,1)
            hold on
    
        end
    end
    xlowrange = floor(min(Averageprice0)/2) * 2;
    xuprange = ceil(max(Averageprice0)/2) * 2;
    ylim([xlowrange xuprange]);

    set(gca,'XTickLabel',legendname);
    % ylabel('The Overall Price ($/MWh)');
    ylabel('�ȵ�۸� ($/MWh)');
    grid on 
    % 
    print('-dpng','-r1000',['�ڵ�' num2str(nodeno) '�۸�','.png']);
    saveas(nnode,['�ڵ�' num2str(nodeno) '�۸�'],'bmp');
    

    % 
end
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
result.generatorRup % ������ṩ����
%%
result_std0.generatorenergyR
result_std0.generatorenergyR - result_std0.generatorC

demandtotalEcost = sum(- LMP.Dexp .* [demand.Dexp]); 
demandtotalGIcost = sum(- LMP.Ddmax .* [demand.dPmax] - LMP.Ddmin .* [demand.dPmin]);
renewabletotalErevenue = sum(- LMP.Pexp .* [renewable.Pexp]);
renewabletotalGIcost = sum(- LMP.Pdmax .* [renewable.dPmax] - LMP.Pdmin .* [renewable.dPmin]);
generatortotalErevenue = sum(generatorenergyR);
generatortotalGIrevenue = sum(generatorRdownR + generatorRupR);

