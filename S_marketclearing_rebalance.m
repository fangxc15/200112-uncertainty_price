if ~exist('chooserelax')
    chooserelax = 'Demand';
end
G_adjust = sdpvar(ng,1);
Pl = sdpvar(nl,1);
Plrelax_add = sdpvar(nl,1);
Plrelax_minus = sdpvar(nl,1);
G_final = sdpvar(ng,1);
D_curt = sdpvar(nd,1);
Cons = [];
Cons = [Cons, G_adjust >=0];
Cons = [Cons, G_adjust <= result.GR];
Cons = [Cons, G_final == G_adjust + result.Gexp(:)];


Cons = [Cons, Plrelax_add>=0, Plrelax_minus>=0];
Cons = [Cons, D_curt >= 0];

Cons = [Cons, sum(G_final) + sum([renewable.Pexp] + [renewable.dPmin]) ...
    - sum([demand.Dexp] + [demand.dPmax]) + sum(D_curt)>= 0]; 
if strcmp(chooserelax,'Line')
    Cons = [Cons, D_curt == 0];
elseif strcmp(chooserelax,'Demand')
    Cons = [Cons, Plrelax_add==0, Plrelax_minus==0];
    Cons = [Cons, D_curt <= [demand.Dexp]'];
end
    

% for i = 1:nl
Cons = [Cons, Pl == GSDFG_lg  * G_final + GSDFP_lp * ([renewable.Pexp]' + [renewable.dPmin]') - ...
    GSDFD_ld * ([demand.Dexp]' + [demand.dPmax]' - D_curt)];
Cons = [Cons, Pl<= [branch.Pmax]' + Plrelax_add];
Cons = [Cons, Pl>= -[branch.Pmax]' - Plrelax_minus];
% end

obj = sum(Plrelax_add) +sum(Plrelax_minus) + sum(D_curt);
% obj = [generator.cost] * Gexp;
solution = optimize(Cons,obj,ops);
if strcmp(chooserelax,'Demand')
    result_rebalance.obj = value(obj);
    result_rebalance.G_adjust = value(G_adjust);
    result_rebalance.G_final = value(G_final);
    result_rebalance.Pl = value(Pl);
    result_rebalance.Plrelax_add = value(Plrelax_add);
    result_rebalance.Plrelax_minus = value(Plrelax_minus);
    result_rebalance.D_curt = value(D_curt);
    result_rebalance.curt_ratio = sum(result_rebalance.D_curt)/sum([demand.Dexp]'); % 切负荷比率是2.58%
    
elseif strcmp(chooserelax,'Line')
    result_relaxline.obj = value(obj);
    result_relaxline.G_adjust = value(G_adjust);
    result_relaxline.G_final = value(G_final);
    result_relaxline.Pl = value(Pl);
    result_relaxline.Plrelax_add = value(Plrelax_add);
    result_relaxline.Plrelax_minus = value(Plrelax_minus);
    result_relaxline.D_curt = value(D_curt);
%     result.rebalance.curt_ratio = sum(result_rebalance.D_curt)/sum([demand.Dexp]'); % 切负荷比率是2.58%
end

