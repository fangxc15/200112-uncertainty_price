
%% 这里的输出就是result_input和result_origin_point;
        for pno = 0:Setting.NumP
%             spread = spread_array(j); 
            for g = 1:ng 
                generator(g).cost = Para.gen_Point(g,pno+1) + spread;
            end
            S_marketclearing_bilateral;
            result.Gexp = value(Gexp); result.Gexp = result.Gexp(:)';

            if exist('Dexp_curt') == 1
                result.Dexp_curt = value(Dexp_curt);
                result.Dexp_curt = result.Dexp_curt(:)';
                result.D_use = [demand.Dexp] - result.Dexp_curt;
            else
                result.D_use = [demand.Dexp];
            end
            
            result_input(pno+1) = result;
%             result_collect(kIC_no, pno+1) = result;
            
            if pno == 0
                S_output;
                S_calculateLMP;
                result.LMP = LMP;
                result.LMP_E = LMP_E;
                result.LMP_GIup = LMP_GIup;
                result.LMP_GIdown = LMP_GIdown;
                result.ref_cost = [generator.cost];
                % 计算收益
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
                result.GstrategicP = sum(result.GtotalR(Setting.falseagent)) - sum(result.Gcost(Setting.falseagent));
                result.GstrategicR = sum(result.GtotalR(Setting.falseagent));
                result.GstrategicPbid = result.GstrategicP;
                result.obj = -value(obj);
                result.welfare = [demand.Duti] * result.D_use' - [generator.cost] * result.Gexp';
                result.false_volume = false_volume;
                result.kIC = kIC;
                result.spread = spread;
                result_origin_point = result;
%                 result_origin(false_no,kIC_no) = result;
            end
            clear result
        end
        for g = 1:ng
            generator(g).cost = real_cost(g);
        end
        
        
        agentno = Setting.falseagent;
        for pno = 1:Setting.NumP
            mid_all(:,pno) = -(result_input(pno).Gexp + result_input(pno+1).Gexp)/2;
        end
        
        % 
        if isfield(Setting,'new_version') && Setting.new_version == 11
            % 这里的version11就代表了考虑max(0,a)还有productsum的relaxIC计算方式
            temp_P = sum(max(0,sum(Para.gen_Interval_len(agentno,:) .* mid_all(agentno,:),1) ...
                                - kIC * Setting.Qmaxq(agentno) * abs(Para.gen_Interval_len(agentno,:))));
        else
            % 否则就是只考虑了max(0,a)但没有考虑productsum的方式
            temp_len = sum(Para.gen_Interval_len(agentno,:) .^2,1).^0.5;
            temp_P = sum(max(0,sum(Para.gen_Interval_len(agentno,:) .* mid_all(agentno,:),1) ...
                    - kIC * temp_len   * Setting.Qmax));
            %temp_P = sum(max(0,sum(Para.gen_Interval_len(agentno,:) .* mid_all(agentno,:),1) ...
             %                   - kIC * Setting.Qmaxq(agentno) * abs(Para.gen_Interval_len(agentno,:)))); 
        end
        
        temp_R = sum(Para.gen_Point(Setting.falseagent,1) .* result_input(1).Gexp(Setting.falseagent)') + temp_P;
        
        result_origin_point.GstrategicPbid = temp_P;
        result_origin_point.GstrategicR = temp_R;
        result_origin_point.GstrategicP = temp_R - sum(real_cost(Setting.falseagent) .* result_input(1).Gexp(Setting.falseagent));


%         result_origin(false_no,kIC_no).GstrategicPbid = temp_P;
%         result_origin(false_no,kIC_no).GstrategicR = temp_R;
%         result_origin(false_no,kIC_no).GstrategicP = temp_R - sum(real_cost(Setting.falseagent) .* result_input(1).Gexp(Setting.falseagent));
