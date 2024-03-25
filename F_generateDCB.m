function [Y0,Y] = F_generateDCB(n)
%本函数生成用-1/x生成的矩阵
fh = str2func(['case' num2str(n)]); %构造函数句柄
mpc = fh();
[Num.B temp] = size(mpc.branch); %确定有几条支路
Y = zeros(n,n);
Y0 = zeros(n+1,n+1);
    for b = 1:Num.B 
        fbus = mpc.branch(b,1);     %起始节点
        tbus = mpc.branch(b,2);     %终止节点 
        %阻抗        mpc.branch(b,3) + i * mpc.branch(b,4)
        tempb = 1/(i * mpc.branch(b,4));  %导纳
        tempM = zeros(n,1);
        tempN = zeros(n,1);
        %求出变压器的变比
        if mpc.branch(b,9) ~=0
            tap = mpc.branch(b,9);
%             tap = mpc.branch(b,9) * exp(1j*pi/180 * mpc.branch(b,10)); %变压器的变比
        else
            tap = 1;
%             tap = 1 * exp(1j*pi/180 * mpc.branch(b,10));
        end 
        
        
        tempb = tempb/tap;
%         tempM(fbus) = 1/conj(tap);
%         tempM(tbus) = -1;
%         tempN(fbus) =  1/tap;
%         tempN(tbus) = -1;
        tempM(fbus) = 1;
        tempM(tbus) = -1;
        tempN(fbus) =  1;
        tempN(tbus) = -1;

        addY = tempM * tempb *tempN';
        Y = Y + addY * mpc.branch(b,11);
% 
        %生成Y0矩阵
        %空中支路
%         tempM0 = zeros(n+1,1);
%         tempM0(fbus) = 1/conj(tap);
%         tempM0(tbus) = -1;
%         tempN0 = zeros(n+1,1);
%         tempN0(fbus) =  1/tap;
%         tempN0(tbus) = -1;
        tempM0 = zeros(n+1,1);
        tempM0(fbus) = 1;
        tempM0(tbus) = -1;
        tempN0 = zeros(n+1,1);
        tempN0(fbus) =  1;
        tempN0(tbus) = -1;

        addY0 =  tempM0 * tempb *tempN0';
        Y0 = Y0+addY0 * mpc.branch(b,11);
        
    end
    
    
end 