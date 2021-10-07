function n=genH2norm(sys)

Q=gram(sys,'c');
n=sqrt(max(eig(sys.c*Q*sys.c')));

% SISO: the same as H2-norm=sqrt(trace(covar(sys,1)))=norm(sys,2);
% but due to numerical reasons there are quite big differences!
