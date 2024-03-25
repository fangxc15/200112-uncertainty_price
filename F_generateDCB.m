function [Y0,Y] = F_generateDCB(n)
%������������-1/x���ɵľ���
fh = str2func(['case' num2str(n)]); %���캯�����
mpc = fh();
[Num.B temp] = size(mpc.branch); %ȷ���м���֧·
Y = zeros(n,n);
Y0 = zeros(n+1,n+1);
    for b = 1:Num.B 
        fbus = mpc.branch(b,1);     %��ʼ�ڵ�
        tbus = mpc.branch(b,2);     %��ֹ�ڵ� 
        %�迹        mpc.branch(b,3) + i * mpc.branch(b,4)
        tempb = 1/(i * mpc.branch(b,4));  %����
        tempM = zeros(n,1);
        tempN = zeros(n,1);
        %�����ѹ���ı��
        if mpc.branch(b,9) ~=0
            tap = mpc.branch(b,9);
%             tap = mpc.branch(b,9) * exp(1j*pi/180 * mpc.branch(b,10)); %��ѹ���ı��
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
        %����Y0����
        %����֧·
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