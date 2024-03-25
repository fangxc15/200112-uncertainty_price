% ³���Ż����г�����
% ԭ���û�п���reserve���г�����
%% ����aconst,P,b
for i = 1:nl
    aconst.Lmax(i).value = [GSDFG_lg(i,:)';zeros(ng,1);0];
    Pconst.Lmax(i).value = [zeros(ng,np) zeros(ng,nd);-GSDFG_lg(i,:)'*ones(1,np) GSDFG_lg(i,:)'*ones(1,nd);GSDFP_lp(i,:) -GSDFD_ld(i,:)];
    aconst.Lmin(i).value = [-GSDFG_lg(i,:)';zeros(ng,1);0];
    Pconst.Lmin(i).value = [zeros(ng,np) zeros(ng,nd);GSDFG_lg(i,:)'*ones(1,np) -GSDFG_lg(i,:)'*ones(1,nd);-GSDFP_lp(i,:) GSDFD_ld(i,:)];
    bconst.Lmax(i).value = branch(i).Pmax - GSDFP_lp(i,:) * [renewable.Pexp]' + GSDFD_ld(i,:) * [demand.Dexp]';
    bconst.Lmin(i).value = branch(i).Pmax + GSDFP_lp(i,:) * [renewable.Pexp]' - GSDFD_ld(i,:) * [demand.Dexp]';
end

M = eye(ng);
for i = 1:ng
    aconst.Gmax(i).value = [M(:,i);zeros(ng,1);0];
    Pconst.Gmax(i).value = [zeros(ng,np) zeros(ng,nd);-M(:,i)*ones(1,np) M(:,i)*ones(1,nd);zeros(1,np) zeros(1,nd)];
    aconst.Gmin(i).value = [-M(:,i);zeros(ng,1);0];
    Pconst.Gmin(i).value = [zeros(ng,np) zeros(ng,nd);M(:,i)*ones(1,np) -M(:,i)*ones(1,nd);zeros(1,np) zeros(1,nd)];
    bconst.Gmax(i).value = generator(i).Pmax;
    bconst.Gmin(i).value = -generator(i).Pmin;
end

%% ����D��q,�ɸ������ֲ������Խ��в��ֵ���
umin = [[renewable.dPmin]';[demand.dPmin]'];
umax = [[renewable.dPmax]';[demand.dPmax]'];
Dconst = [eye(np+nd); -eye(np+nd)];
Qconst = [-umin;umax];
S_DQconst_modify;
nq = length(Qconst);
%% ������߱�������Ҫ��Gexp��beta
Gexp = sdpvar(ng,1);
beta = sdpvar(ng,1);
% u����һ����Dֻ��һ�������ǲ�ͬ��Du+Q�������Ӧ���Ǹ���ǶMax���ⲻͬ�����Ի���Ҫ����
for i = 1:nl
    w.Lmax(i).varible = sdpvar(nq,1);
    w.Lmin(i).varible = sdpvar(nq,1);
end 
for i = 1:ng
    w.Gmax(i).varible = sdpvar(nq,1);
    w.Gmin(i).varible = sdpvar(nq,1);
end
anx = sdpvar(1,1); %�������Ǹ���ģ�
x = [Gexp;beta;anx];
anx2 = sdpvar(1,1); %�������Ǹ���ģ�
%% д��Լ��
Cons = [];
Cons = [Cons, anx == 1];
Cons = [Cons, anx2 == 0];
%ƽ��Լ��
Cons = [Cons, sum(Gexp) + sum([renewable.Pexp]) - sum([demand.Dexp]) >= 0]; 
Dual.price = length(Cons);
%����betaԼ��
Cons = [Cons, sum(beta) >= 1]; 
Dual.consbeta_more = length(Cons);
Cons = [Cons, sum(beta) <= 1];
Dual.consbeta_less = length(Cons);
% ��·���ʲ��ܳ������ߵ�³��Լ��
for i = 1:nl
    Cons = [Cons, aconst.Lmax(i).value' * x + Qconst' * w.Lmax(i).varible + anx2 <= bconst.Lmax(i).value];
    Dual.Lmax(i) = length(Cons);
    Cons = [Cons, aconst.Lmin(i).value' * x + Qconst' * w.Lmin(i).varible + anx2 <= bconst.Lmin(i).value];
    % ��ʵ���ﱾ��Ѱ�ҵ���һ�����н⣬ֻҪ��һ�����н�С�������У�������һ��Ҫ�ҵ����Ž⣡
    % �����������������
    Dual.Lmin(i) = length(Cons);
    Cons = [Cons, Dconst' * w.Lmax(i).varible + Pconst.Lmax(i).value' * x == 0];
    Cons = [Cons, Dconst' * w.Lmin(i).varible + Pconst.Lmin(i).value' * x == 0];
    Cons = [Cons, w.Lmax(i).varible >=0];
    Cons = [Cons, w.Lmin(i).varible >=0];
    if i>=182
        fprintf('����');
    end 
end 
% ���鹦�ʲ��ܳ��������޵�³��Լ��
for i = 1:ng
    Cons = [Cons, aconst.Gmax(i).value' * x + Qconst' * w.Gmax(i).varible <= bconst.Gmax(i).value];
        Dual.Gmax(i) = length(Cons);
    Cons = [Cons, aconst.Gmin(i).value' * x + Qconst' * w.Gmin(i).varible <= bconst.Gmin(i).value];   
        Dual.Gmin(i) = length(Cons);
    Cons = [Cons, Dconst' * w.Gmax(i).varible + Pconst.Gmax(i).value' * x == 0]; % ���ó�����ûд�����ﶼ�����
    Cons = [Cons, Dconst' * w.Gmin(i).varible + Pconst.Gmin(i).value' * x == 0];
    Cons = [Cons, w.Gmax(i).varible >=0];
    Cons = [Cons, w.Gmin(i).varible >=0];
end
%% Ŀ�꺯��
obj = [generator.cost] * Gexp;
solution = optimize(Cons,obj,ops);
