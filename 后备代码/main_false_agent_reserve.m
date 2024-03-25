% �����������������Щɶ������ɶ��û��
% ��ǰ���Ǹ���BB-IC��Ȩ�⡣�൱��VCG/LMP���ơ��ڻѱ���ʱ�򣬴�ʱspreadû�б䡣
% һ��ά���ǻѱ���һ��ά����IC�Ĵ�С�����ﲻ������spread���ǹ̶�Ϊ0�ġ����Ժ�����ͬIC֮�»���λѱ�. 
% �ѱ���Ӱ��Ԥ���SW,Ԥ���BB

% �����ڲ�ͬ��IC֮�£�����ͻ��Ӧ��ͬ��SW(Ҳ����spread).�������һ��IC(�����ж�Ӧ��spread)��
% ȥ�������ѱ������ĸ�����ʱ�򣬾�Ҫ�����spread/IC�����ȥ���㡣����Ҳ�ڸ�spread�¼��㸣����


% 
clear
mpc = case118;
nnode = 118;
Setting.new_version = 11;
version_suffix = '_V11';
Filename = 'IEEE118_V1';

if nnode == 118
    Setting.NumP = 10;
    Setting.costmax = 70 * ones(1,54);
    falseagent = 1:30;
    Setting.falseagent = falseagent;
    spread_array = 0:0.5:10; %ֻ�Ի��ɱ������ӣ���ֹ���ֻ���
else
    Setting.NumP = 10;
    Setting.costmax = [42 45 90 105 50];
    falseagent = 3:5;
    Setting.falseagent = falseagent;
    spread_array = 0; %ֻ�Ի��ɱ������ӣ���ֹ���ֻ���
end
%% �������������
if nnode == 5
    mpc.gen(1,9) = 110;
    mpc.gen(2,9) = 100;
    mpc.gencost(4,5) = 35;
end 
%% 
warning('off');
bigM = 100000;

methodchoose = 1;  %1ѡ��³���Ż� 2ѡ�����Լ���Ż�

Psheet = 'P1.0';
Dsheet = 'D1.0';

robustcheck = 0;
DCcheck = 0;
LMPcheck = 0;


DQconstmodify = 0; % �������������ģ�
stdrange = 1; %���������������Interval������Ҫ�೤��. 

% ���������Щ�ط����ã�
% Ksig = 1.645; %Gauss 1.645, Sys Dist Robust 3.1623, Dist.Robust 4.3589.
% ���ֻ�ڻ���Լ���滮�����Ҫ��

allocatestrategy = 2; % 1 ����beta���䣬2 �������±��÷���

%% ���뷢������ڵ����ݣ�����GSDF
ng = size(mpc.gen,1);
nb = size(mpc.bus,1);
nl = size(mpc.branch,1);
for i = 1:ng
    generator(i).bus =  mpc.gen(i,1);
%     generator(i).Pmax = mpc.gen(i,9)/2; % ����118�ڵ�����
    generator(i).Pmax = mpc.gen(i,9); %����5�ڵ�����
    if nnode == 118
        generator(i).Pmax = generator(i).Pmax/2;
    end 
    generator(i).Pmin = mpc.gen(i,10);
    if nnode == 5
          generator(i).cost = mpc.gencost(i,5);
    else 
        generator(i).cost = mpc.gencost(i,6) + mpc.gencost(i,5) * generator(i).Pmax / 2;
    end 

end
for i = 1:nl
    if mpc.branch(i,6) ~=0
        branch(i).Pmax = mpc.branch(i,6);
    else 
        if nnode ==5 
            branch(i).Pmax = bigM;
        else 
            branch(i).Pmax = 250;
            
        end
    end
end
%�����н���118�ڵ�����
if nnode == 118
    branch(37).Pmax = 450;
    branch(36).Pmax = 450;branch(51).Pmax = 450;branch(54).Pmax = 450;branch(141).Pmax = 450;
end 
GSDF_lb = makePTDF(mpc);
%% ���븺�ɡ�����Դ���������ɸ��ɡ�����Դ�������GSDF
[Rawdata_P,Name_P] = xlsread(Filename,Psheet);
[Rawdata_D,Name_D] = xlsread(Filename,Dsheet);

np = max(Rawdata_P(:,1));

for i = 1:np
    renewable(i).bus = Rawdata_P(i,2);
    renewable(i).Pexp = Rawdata_P(i,3);
    renewable(i).Pstd = Rawdata_P(i,4);
    renewable(i).Pstdabs = renewable(i).Pstd * renewable(i).Pexp;
    renewable(i).dPmax = renewable(i).Pexp * renewable(i).Pstd * stdrange;
    renewable(i).dPmin = - renewable(i).Pexp * renewable(i).Pstd * stdrange;
end


if nnode == 5
    nd = max(Rawdata_D(:,1));
    util_column = find(strcmp(Name_D, 'util'));
    for i = 1:nd
        
        demand(i).bus = Rawdata_D(i,2);
        demand(i).Dexp = Rawdata_D(i,3);
        demand(i).Dstd = Rawdata_D(i,4);
        demand(i).Dstdabs = demand(i).Dstd * demand(i).Dexp;
        demand(i).dPmax = demand(i).Dexp * demand(i).Dstd * stdrange;
        demand(i).dPmin = - demand(i).Dexp * demand(i).Dstd * stdrange;
        if isempty(util_column)
            demand(i).Duti = 50;
        else
            demand(i).Duti = Rawdata_D(i,util_column);
        end
    end
else
    nd = size(mpc.bus,1);
    for i = 1:nd
        demand(i).bus = mpc.bus(i,1);
        demand(i).Dexp = mpc.bus(i,3) * (1-0.002);
        demand(i).Dstd = 0.026;
        demand(i).Dstdabs = demand(i).Dstd * demand(i).Dexp;
        demand(i).dPmax = demand(i).Dexp * demand(i).Dstd * stdrange;
        demand(i).dPmin = - demand(i).Dexp * demand(i).Dstd * stdrange;
        demand(i).Duti = 40+10 * rand();
%         demand(i).Duti = Rawdata_D(i,util_column);

    end 
end


% demand(10).DPmax = 0.01;
GSDFG_lg = GSDF_lb(:,[generator.bus]);
GSDFP_lp = GSDF_lb(:,[renewable.bus]);
GSDFD_ld = GSDF_lb(:,[demand.bus]);


%% ���濪ʼִ�г������
% �����ǵ����г����壬��������������...

real_cost = [generator.cost];
Setting.otheragent = setdiff(1:ng,falseagent);
Setting.Qmax = sum([generator(falseagent).Pmax]);
Setting.Qmaxq = [generator.Pmax];

% clear newPara_gen

for pno = 0:Setting.NumP
    temp_para = F_generator_temppara(generator,pno,falseagent,Setting);
    Para.gen_Point(:,pno+1) = [temp_para.cost]';  
end

Para.gen_Interval_len = Para.gen_Point(:,1:Setting.NumP) - Para.gen_Point(:,2:Setting.NumP+1);
%%
ops = sdpsettings('solver','gurobi','verbose',1,'saveyalmipmodel',1);

outIC = zeros(1,length(spread_array));
outSW = zeros(1,length(spread_array));
checkbalance = zeros(1,length(spread_array));
for j = 1:length(spread_array)
    
    spread = spread_array(j); 
    for pno = 0:Setting.NumP
        spread = spread_array(j); 
        for g = 1:ng 
            % ����Ҫ��ʾ����𣬲��ܵ�����ḣ���в��Ҫ��Ȼmerit order��һ��
            % Ҫ��ʾ������𣿱����о���ûʲô���
            % ����ط��о�����Ҫ����ḣ��Ϊ��
            % Ҫ������ط�����걨����ô����
           
            % �ֶε�Ŀ�Ļ��ǿ�����������걨��ʱ�����ô��
            generator(g).cost = Para.gen_Point(g,pno+1) + spread;

            % ����о���ȷ�ǳ�����������.������ô��.
%             if isempty(find([Setting.falseagent] == g))
%                 generator(g).cost = Para.gen_Point(g,pno+1);
%             else
%                 generator(g).cost = Para.gen_Point(g,pno+1) + spread;
%             end
        end
        S_marketclearing_bilateral;
        S_output; 
        S_calculateLMP;
        result.LMP = LMP;
        result.LMP_E = LMP_E;
        result.LMP_GIup = LMP_GIup;
        result.LMP_GIdown = LMP_GIdown;
        result.ref_cost = [generator.cost];
        % ��������
        for g = 1:ng
            generator(g).cost = real_cost(g);
        end
        
        S_calculaterevenue;

        result.DtotalC = demandtotalcost;
        result.RtotalR = renewabletotalrevenue;
        result.Gcost = generatorC;
        result.GenergyR = generatorenergyR;
        result.GRupR = generatorRupR;
        result.GRdownR = generatorRdownR;
        result.GtotalR = generatortotalrevenue;
        result.branch_congestion = branch_congestion;
        result.branch_reserve = branch_reserve;
        result.branch_all = branch_all;
        
        result.obj = -value(obj);
        result.welfare = [demand.Duti] * result.D_use' - [generator.cost] * result.Gexp';
%         result.origincost = sum(result.Gcost);
%         result.welfare = sum([demand.Dexp]) * Setting.Duti - result.origincost;
         
        result_collect(j,pno+1) = result;
    end
    [outIC(j),checkbalance(j)] = F_find_properIC(result_collect(j,:),Setting, ...
        Para,generator, spread);
%     outcost(j) = result_collect(j,1).origincost;
    outSW(j) = result_collect(j,1).welfare;
end
% outmatrix = [outIC' outSW' spread_array'];
% qualify_set = [1];
% for i = 2:length(outmatrix)
%     if outmatrix(i,1) > min(outmatrix(1:i-1,1))
%         continue
%     else
%         qualify_set = [qualify_set i];
%     end
% end
% 
% outall.RelaxIC = outIC(qualify_set);
% outall.SW = outSW(qualify_set);
% outall.RelaxSW = (outSW(1)-outSW)/outSW(1);
% outall.RelaxSW = outall.RelaxSW(qualify_set);
% outall.spread = spread_array(qualify_set);
% F_plot_Pareto(1, outall,Filename)
mkdir('falseagent')
save(['falseagent','//',Filename])


%% ��η����ѱ�
for pno = 0:Setting.NumP
    temp_revenue(pno+1) = sum(result_collect(1,pno+1).GtotalR(Setting.falseagent) ...
         - result_collect(1,pno+1).Gcost(Setting.falseagent));
end


%% ����LMP

% %% �ڵ��۵�У��
% for nn = 1:nnode
%     bus(nn).demand = find([demand.bus] == nn);
%     bus(nn).renewable = find([renewable.bus] == nn);
% end 
% 
% LMPright = 1;
% for nn = 1:nnode
%     temparray = [LMP.Dexp(bus(nn).demand) -LMP.Pexp(bus(nn).renewable)];
%     if length(unique([LMP.Dexp(bus(nn).demand) -LMP.Pexp(bus(nn).renewable)])) ~= 1
%         LMPright = 0;
%     end 
%     if methodchoose == 1
%         temparray = [LMP.Pdmax(bus(nn).renewable) -LMP.Ddmin(bus(nn).demand)];
%         if length(unique([LMP.Pdmax(bus(nn).renewable) -LMP.Ddmin(bus(nn).demand)])) ~= 1
%             LMPright = 0;
%         end 
%         temparray = [LMP.Ddmax(bus(nn).demand)  -LMP.Pdmin(bus(nn).renewable)];
%         if length(unique([LMP.Ddmax(bus(nn).demand)  -LMP.Pdmin(bus(nn).renewable)])) ~= 1
%             LMPright = 0;
%         end 
%     end 
% end 
% %% ����ڵ���������
% S_LMPcheck;
% % S_save;
% 
% 
% 
