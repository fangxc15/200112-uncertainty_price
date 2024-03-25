function output = F_calculate_DC(mpc)
% �ú�����������ֱ������
% ��Ҫ����mpc.bus,
nnode = size(mpc.bus,1);
% fh = str2func(['case' num2str(nnode)]); %���캯�����
% mpc = fh();
% matY = full(makeYbus(mpc));
[~,matB] = F_generateDCB(nnode); %ֻ��x_ij����B����
matB = imag(matB);
nbranch = size(mpc.branch,1);
% RESULTS = runpf('case30');


%% ���±��
refset = find(mpc.bus(:,2) == 3);
PVset = find(mpc.bus(:,2) == 2);
PQset = find(mpc.bus(:,2) == 1);

% refset = 22;
% PVset = [1;2;13;23;27];
% 
PQPVset = [PQset;PVset];
% PVrefset = [PVset;refset];
n = nnode - 1;
% r = length(PVset);

%% ��ȡ����
givenPload = [mpc.bus(PQset,3);mpc.bus(PVset,3)];
% givenQload =  mpc.bus(PQset,4);

Pgen = zeros(nnode,1);
% Qgen = zeros(nnode,1);
for i = 1:nnode
    Pgen(i) = sum(mpc.gen(mpc.gen(:,1) == i,2));
%     Qgen(i) = sum(mpc.gen(mpc.gen(:,1) == i,3));
end
givenP = (- givenPload + Pgen(PQPVset))/mpc.baseMVA;
% givenQ = (- givenQload + Pgen(PQset)) /mpc.baseMVA;
% givenV = [mpc.bus(PVset,8);mpc.bus(refset,8)];
giventheta = mpc.bus(refset,9);
fbus = mpc.branch(:,1);
tbus = mpc.branch(:,2);
%% 
% �����������

% theta = RESULTS.bus(:,9);
% V =     RESULTS.bus(:,8);
theta = zeros(nnode,1);
% V = ones(nnode,1);
theta(refset) = giventheta;
% V([PVset;refset]) = givenV;

%%
%���theta
theta(PQPVset) = - inv(matB(PQPVset,PQPVset)) * givenP + theta(refset); %����Ӹ�������ΪPij = -B(thetai - thetaj)
V = ones(nnode,1);
calculateP = - matB * theta;
calculateQ = zeros(nbranch,1);
%% �����ÿ�����ϵĳ����������
for m = 1:nbranch
    f = fbus(m);
    t = tbus(m);
%     g = real(-matY(t,f));
    b = -matB(t,f);
    bc = mpc.branch(m,5);
    power(m).fP =  - b * (theta(f) - theta(t));
    power(m).fQ = 0;
    power(m).tP =  - b * (theta(t) - theta(f));
    power(m).tQ = 0;
    power(m).P = (power(m).fP - power(m).tP)/2;
    power(m).Q = 0;
    power(m).Ploss = power(m).fP + power(m).tP;
    power(m).Qloss =  0;
    power(m).fP =  power(m).fP * mpc.baseMVA;
%     power(m).fQ = power(m).fQ * mpc.baseMVA;
    power(m).tP = power(m).tP * mpc.baseMVA;
%     power(m).tQ = power(m).tQ * mpc.baseMVA;
    power(m).P = power(m).P  * mpc.baseMVA;
%     power(m).Q = power(m).Q * mpc.baseMVA;
    power(m).Ploss = power(m).Ploss * mpc.baseMVA;
    power(m).Qloss =  power(m).Qloss * mpc.baseMVA;
    
end 
%% ���������ʽ
for i = 1:nnode
    output.bus(i).voltage = V(i);
    output.bus(i).theta = theta(i) * 360/2/pi; %ת��Ϊ������
    output.bus(i).calculateP = calculateP(i) * mpc.baseMVA;
    output.bus(i).calculateQ = calculateQ(i) * mpc.baseMVA;
end
output.branch = power;
end
