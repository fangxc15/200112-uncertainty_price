if DCcheck 
    demandvalue = [demand.Dexp];
    renewablevalue = [renewable.Pexp];
    for i = 1:nb
        demandno = find([demand.bus] == i);
        renewableno = find([renewable.bus] == i);
        mpc.bus(i,3) = - sum(renewablevalue(renewableno)) + sum(demandvalue(demandno));
    end 
%     mpc.bus(:,3) = [0;150;150;450;0];
    mpc.gen(:,2) = result.Gexp;
    output = F_calculate_DC(mpc);
    if sum(abs([output.branch.P] - result.Pl))<1e-5
        fprintf('********\n');
        fprintf('ͨ��ֱ������У��\n\n');
    else 
        fprintf('!!!!!!!!!!\n');
        fprintf('��ͨ��ֱ������У��\n\n');

    end 
end
