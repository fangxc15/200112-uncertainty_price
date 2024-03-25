function generator = F_generator_temppara(generator,pno,falseagent,Setting)
    % 对ESS Para进行分段
    for i = 1:length(falseagent)
        agentno = falseagent(i);
        generator(agentno).cost = (generator(agentno).cost + Setting.false_volume(agentno)) * (Setting.NumP-pno)/Setting.NumP ...
                                        + Setting.costmax(agentno) * pno/Setting.NumP;
    end 
end 