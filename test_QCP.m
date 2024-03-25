
% clear
% x = [1 2 3 4 5 6]';
% t = (0:0.02:2*pi)';
% A = [sin(t) sin(2*t) sin(3*t) sin(4*t) sin(5*t) sin(6*t)];
% e = (-4+8*rand(length(A),1));
% y = A*x+e;
% 
% xhat = sdpvar(6,1);
% sdpvar u v
% 
% F = [norm(y-A*xhat,2) <= u, norm(xhat,2) <= v];
% optimize(F,u + v);

clear
a = sdpvar(2,1);
Cons = [];
A = [2 1;1 2];
Ahalf = A ^ (1/2);
Cons = [Cons,norm(Ahalf*a) <=1];
Cons = [Cons, a>=0];
obj = -sum(a);
solution = optimize(Cons,obj);
