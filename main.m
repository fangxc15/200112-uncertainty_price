clear
mpc = case118;
nnode = 118;
Filename = 'IEEE118_V1';

origin_reserve = 1;% �Ƿ�Ҫ��reserve�г�

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
    for i = 1:nd
        demand(i).bus = Rawdata_D(i,2);
        demand(i).Dexp = Rawdata_D(i,3);
        demand(i).Dstd = Rawdata_D(i,4);
        demand(i).util = Rawdata_D(i,5);
        demand(i).Dstdabs = demand(i).Dstd * demand(i).Dexp;
        demand(i).dPmax = demand(i).Dexp * demand(i).Dstd * stdrange;
        demand(i).dPmin = - demand(i).Dexp * demand(i).Dstd * stdrange;
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
    end 
end


% demand(10).DPmax = 0.01;
GSDFG_lg = GSDF_lb(:,[generator.bus]);
GSDFP_lp = GSDF_lb(:,[renewable.bus]);
GSDFD_ld = GSDF_lb(:,[demand.bus]);


%% ���濪ʼִ�г������
ops = sdpsettings('solver','gurobi','verbose',1,'saveyalmipmodel',1);
fprintf('\n\n\n\n\n\n');
if methodchoose == 1
    fprintf('*******��³���Ż��������,stdrangeѡ��Ϊ%f********************\n',stdrange);
    S_marketclearing;
    S_output;
    
elseif methodchoose ==2
     fprintf('*******�û���Լ���������,Ksigѡ��Ϊ%f**************************\n',Ksig);
    ops = sdpsettings('solver','gurobi','verbose',0,'gurobi.QCPdual',1);
    S_marketclearingCCPF;
    S_outputCCPF;
end 
result.origincost = value(obj);    
fprintf('*******\n');
fprintf('�ܳɱ�Ϊ%f\n',result.origincost);
if methodchoose == 1
%% ����LMP
 S_calculateLMP;
%% ��������
 S_calculaterevenue;
end 
%% �ڵ��۵�У��
for nn = 1:nnode
    bus(nn).demand = find([demand.bus] == nn);
    bus(nn).renewable = find([renewable.bus] == nn);
end 

LMPright = 1;
for nn = 1:nnode
    temparray = [LMP.Dexp(bus(nn).demand) -LMP.Pexp(bus(nn).renewable)];
    if length(unique([LMP.Dexp(bus(nn).demand) -LMP.Pexp(bus(nn).renewable)])) ~= 1
        LMPright = 0;
    end 
    if methodchoose == 1
        temparray = [LMP.Pdmax(bus(nn).renewable) -LMP.Ddmin(bus(nn).demand)];
        if length(unique([LMP.Pdmax(bus(nn).renewable) -LMP.Ddmin(bus(nn).demand)])) ~= 1
            LMPright = 0;
        end 
        temparray = [LMP.Ddmax(bus(nn).demand)  -LMP.Pdmin(bus(nn).renewable)];
        if length(unique([LMP.Ddmax(bus(nn).demand)  -LMP.Pdmin(bus(nn).renewable)])) ~= 1
            LMPright = 0;
        end 
    end 
end 
%% ����ڵ���������
S_LMPcheck;
if exist('origin_reserve') && origin_reserve == 1
    chooserelax = 'Line';
    S_marketclearing_rebalance
    chooserelax = 'Demand';
    S_marketclearing_rebalance
end

S_save;

%% ������Ҫ˵��ʵʱ�����޽�
% S_marketclearing_rebalance;
% save('Method1_originR_P1.0D1.020240206T194057.mat')
