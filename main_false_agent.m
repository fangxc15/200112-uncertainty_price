%% ����ʵ�ַ����ѱ�����/ѡ����ʵ�չ�ֵ�

% �����������������Щɶ������ɶ��û��
% ��ǰ���Ǹ���BB-IC��Ȩ�⡣�൱��VCG/LMP���ơ��ڻѱ���ʱ�򣬴�ʱspreadû�б䡣
% һ��ά���ǻѱ���һ��ά����IC�Ĵ�С�����ﲻ������spread���ǹ̶�Ϊ0�ġ����Ժ�����ͬIC֮�»���λѱ�. 
% �ѱ���Ӱ��Ԥ���SW,Ԥ���BB

% �����ڲ�ͬ��IC֮�£�����ͻ��Ӧ��ͬ��SW(Ҳ����spread).�������һ��IC(�����ж�Ӧ��spread)��
% ȥ�������ѱ������ĸ�����ʱ�򣬾�Ҫ�����spread/IC�����ȥ���㡣����Ҳ�ڸ�spread�¼��㸣����


% realcost�����
% Para.genpoint���鱨���ֵ
% ��spread�����ֵ��generator.cost
clear

load('result_Pareto_V11//IEEE118_V1.mat')
clear result result_collect

Setting.new_version = 11;
version_suffix = '_V11';
mpc = case118;
nnode = 118;
Filename = 'IEEE118_V1';


%% ��������Ҫ����һ������

%% ���濪ʼִ�г������
% �����ǵ����г����壬��������������...

real_cost = [generator.cost];
Setting.otheragent = setdiff(1:ng,falseagent);
Setting.Qmax = sum([generator(falseagent).Pmax]);
Setting.Qmaxq = [generator.Pmax];
% clear newPara_gen
ops = sdpsettings('solver','gurobi','verbose',1,'saveyalmipmodel',1);

% outall.RelaxIC
chooseIC_array = 1:2;
false_volume_array = 0:0.05:0.5;

for false_no = 1:length(false_volume_array)
    for g = 1:ng
        generator(g).cost = real_cost(g);
    end
    false_volume = false_volume_array(false_no);
    Setting.false_volume = false_volume * real_cost;%ones(1,ng);
    for pno = 0:Setting.NumP
        temp_para = F_generator_temppara(generator,pno,falseagent,Setting);
        Para.gen_Point(:,pno+1) = [temp_para.cost]';  
    end

	Para.gen_Interval_len = Para.gen_Point(:,1:Setting.NumP) - Para.gen_Point(:,2:Setting.NumP+1);
%%
    Para_collect(false_no) = Para;
%     outIC = zeros(1,length(spread_array));
%     outSW = zeros(1,length(spread_array));
%     checkbalance = zeros(1,length(spread_array));
    for kIC_no = chooseIC_array%1:length(target_all.RelaxIC)
        kIC = outall.RelaxIC(kIC_no);
        spread = outall.spread(kIC_no);
        
        S_piecewise_clearing;
        
        result_origin(false_no,kIC_no) = result_origin_point;
        result_collect(false_no).result(kIC_no, :) = result_input;
        result_collect(kIC_no, :) = result_input;
    end
end

for false_no = 1:length(false_volume_array)
    for kIC_no = chooseIC_array
        false_volume = false_volume_array(false_no);
        kIC = outall.RelaxIC(kIC_no);
        matrix_GstrategicPbid(false_no,kIC_no) =  result_origin(false_no,kIC_no).GstrategicPbid;
        matrix_GstrategicR(false_no,kIC_no)    =  result_origin(false_no,kIC_no).GstrategicR;
        matrix_GstrategicP(false_no,kIC_no)   =  result_origin(false_no,kIC_no).GstrategicP;
    end
end

save('result_Pareto_V11//IEEE118_V1_falsestrategy.mat')
%% ���ﱾ��Ϳ��Կ�����ʵ�걨�µ�ĳ���г����
load('result_Pareto_V11//IEEE118_V1_falsestrategy.mat')

outall.RelaxIC
outall.RelaxSW

choose_kIC_no = 5;
Setting.NumP = 25;
% choose_kIC_no = find(outall.RelaxIC == choose_IC);
hasstruct = 1;
try
    result_choose = result_origin(1,choose_kIC_no);
catch
    hasstruct = 0;
end
if hasstruct == 0 || isempty(result_choose.Gexp)
    fprintf('��Ҫ�ٴμ���');
    false_no = 1;
    false_volume = 0;

    kIC_no = choose_kIC_no;
    kIC = outall.RelaxIC(choose_kIC_no);
    spread = outall.spread(choose_kIC_no);
    
    
    for g = 1:ng
        generator(g).cost = real_cost(g);
    end
    Setting.false_volume = false_volume * ones(1,ng);
    for pno = 0:Setting.NumP
        temp_para = F_generator_temppara(generator,pno,falseagent,Setting);
        Para.gen_Point(:,pno+1) = [temp_para.cost]';  
    end
	Para.gen_Interval_len = Para.gen_Point(:,1:Setting.NumP) - Para.gen_Point(:,2:Setting.NumP+1);
    
    S_piecewise_clearing;
    if isfield(result_origin_point,'spread')
         result_origin_point = rmfield(result_origin_point, 'spread');
    end

    % result_origin_point ����������
    result_origin(false_no,kIC_no) = result_origin_point;
    result_choose = result_origin(false_no,kIC_no);
    result_choose.spread = spread;
end 
%% Ҫչ��result_choose����Щ����?
% ��ḣ���仯/kIC�仯

save('result_Pareto_V11//IEEE118_V1_choose_result_2.mat')
%%
load('result_Pareto_V11//IEEE118_V1_choose_result_2.mat')
%%
false_no = 3;
false_volume = 0.1;
kIC_no = choose_kIC_no;
kIC = outall.RelaxIC(choose_kIC_no);
spread = outall.spread(choose_kIC_no);


hasstruct = 1;
try
    result_choose_false = result_origin(false_no,choose_kIC_no);
catch
    hasstruct = 0;
end
if hasstruct == 0 || isempty(result_choose_false.Gexp)
    fprintf('��Ҫ�ٴμ���');
    % for false_no = 1:length(false_volume_array)
    for g = 1:ng
        generator(g).cost = real_cost(g);
    end
    %     false_volume = false_volume_array(false_no);
    Setting.false_volume = false_volume * real_cost;
    for pno = 0:Setting.NumP
        temp_para = F_generator_temppara(generator,pno,falseagent,Setting);
        Para.gen_Point(:,pno+1) = [temp_para.cost]';  
    end


    Para.gen_Interval_len = Para.gen_Point(:,1:Setting.NumP) - Para.gen_Point(:,2:Setting.NumP+1);


    S_piecewise_clearing;
    if isfield(result_origin_point,'spread')
         result_origin_point = rmfield(result_origin_point, 'spread');
    end
    result_origin(false_no,kIC_no) = result_origin_point;
%     result_collect(false_no).result(kIC_no, :) = result_input;
%     result_collect(kIC_no, :) = result_input;
    result_choose_false = result_origin(false_no,kIC_no);
end
%%
save('result_Pareto_V11//IEEE118_V1_choose_false_2.mat')
