function [outRelaxIC,checkbalance] = F_find_properIC(result_input, Setting, Para,  spread)
    % 这个是除了strategic_company之外的主体的BB
    BB = -sum(result_input(1).GtotalR(Setting.otheragent)) - sum(result_input(1).RtotalR) ...
                - sum(result_input(1).DtotalC) - sum(result_input(1).branch_all); %这个是收到的钱 

    % 还要把Congestion_revenue也算进来？
    
    agentno = Setting.falseagent;
    temp_len = sum(Para.gen_Interval_len(agentno,:) .^2,1).^0.5;
    for pno = 1:Setting.NumP
        mid_all(:,pno) = -(result_input(pno).Gexp + result_input(pno+1).Gexp)/2;
    end
    
    kIC_left = 0;
    kIC_right = 1;
    % 这个strict ic根本就不对！
    if isfield(Setting,'new_version') && Setting.new_version == 11 
        % 这里的version11就代表了考虑max(0,a)还有productsum的relaxIC计算方式
        temp_strictIC_R = sum(max(0,sum(Para.gen_Interval_len(agentno,:) .* mid_all(agentno,:),1) ...
                    - 0 * Setting.Qmaxq(agentno) *abs(Para.gen_Interval_len(agentno,:))));
    else    
        % 否则就是只考虑了max(0,a)但没有考虑productsum的方式
        temp_strictIC_R = sum(max(0,sum(Para.gen_Interval_len(agentno,:) .* mid_all(agentno,:),1) ...
                    - 0 * temp_len   * Setting.Qmax));
    end
    temp_strictIC_M = temp_strictIC_R + sum(Para.gen_Point(Setting.falseagent,1) .* result_input(1).Gexp(Setting.falseagent)');
    % 这里都在考察的是，如果谎报，那会怎样
    
%     sum(result_input(1).GRupR(Setting.falseagent))
%     sum(result_input(1).GRdownR(Setting.falseagent))
%     sum(result_input(1).GenergyR(Setting.falseagent))
%     sum(result_input(1).GtotalR(Setting.falseagent))
%     result_input(1).Gexp
%     result_input(1).LMP_E([generator.bus])
%     result_input(1).Gexp .* result_input(1).LMP_E([generator.bus])
    temp_LMP = sum(result_input(1).GtotalR(Setting.falseagent));
    checkbalance = BB-temp_LMP - sum(result_input(1).Gexp) * spread; %这个Balance的原因是因为
    % 并没有出现收支不平衡，这是为什么？是不是主体份额太小了？
    while kIC_right - kIC_left > 0.0001
        kIC_mid = (kIC_left + kIC_right)/2;
        temp_P = sum(max(0,sum(Para.gen_Interval_len(agentno,:) .* mid_all(agentno,:),1) ...
                            - kIC_mid * Setting.Qmaxq(agentno) * abs(Para.gen_Interval_len(agentno,:))));
        temp_R = sum(Para.gen_Point(Setting.falseagent,1) .* result_input(1).Gexp(Setting.falseagent)') + temp_P;
        if BB - temp_R > 0 %如果收支有盈余
            kIC_right = kIC_mid;
        else               %如果收支没有盈余
            kIC_left = kIC_mid;
        end     
    end
    
    outRelaxIC = kIC_mid;
end