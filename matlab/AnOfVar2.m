function [H,F,ABE]=AnOfVar2(X,alpha)
% 等重复实验双因素方差分析(Two-way analysis of variance)，检验两个因素对实验结果是否有显著影响
% 方差分析中，每个水平作的实验次数可以不一样，此时称为非平衡方差分析，否则称为平衡方差分析(等重复实验)
% 至于非平衡和多因素方差分析相对复杂，请直接使用MATLAB自带的anovan()函数
%
% 参数说明
% X：三维数组，行代表因素A的水平，列代表因素B的水平，页代表实验次数
% alpha∈[0 1]：置信度
% H=[Ha;Hb;Hab]：假设检验结果，H=0，接受原均值相等的假设，不同的实验水平对实验结果没有影响，H=1，有显著影响
% F=[Fa,Fa_alpha;Fb,Fb_alpha;Fab,Fab_alpha;]：假设检验的F分布值，Fi>Fi_alpha时，H=1
% ABE=[Qa Da Qa_ba;Qb Db Qb_ba;Qab Dab Qab_ba;Qe De Qe_ba;Qt Dt Qt_ba]：5×3矩阵，方差分析中的一些参数
%     Qa,Da,Qa_ba：因素A离差(平方和/自由度/平均平方和)
%     Qb,Db,Qa_ba：因素B离差(平方和/自由度/平均平方和)
%     Qab,Dab,Qab_ba：AB交叉离差(平方和/自由度/平均平方和)
%     Qe De Qe_ba：误差离差(平方和/自由度/平均平方和)
%     Qt Dt Qt_ba：总离差(平方和/自由度/平均平方和)
% 
% 实例说明
% X(:,:,1)=[71 72 75 77;73 76 78 74;76 79 74 74;75 73 70 69];
% X(:,:,2)=[73 73 73 75;75 74 77 74;73 77 75 73;73 72 71 69];
% [H,F,ABE]=AnOfVar2(X,0.95);
%
% by dynamic of Matlab技术论坛
% see also http://www.matlabsky.com
% contact me matlabsky@gmail.com
% 2010-02-06 13:34:35
%
[r,s,t]=size(X);
Xij_ba=mean(X,3);
X_ba=mean(X(:));
Xi_ba=mean(Xij_ba,2);
Xj_ba=mean(Xij_ba,1);
% 计算离差平方和用到的5个中间参数
P=r*s*t*X_ba^2;
R=t*sum(sum(Xij_ba.^2));
U=s*t*sum(Xi_ba.^2);
V=r*t*sum(Xj_ba.^2);
W=sum(X(:).^2);
% 离差平方和
Qa=U-P; % 因素A离差
Qb=V-P; % 因素B离差
Qab=R-U-V+P; % 因素AB交互作用离差
Qe=W-R; % 误差平方和
Qt=W-P; % 总离差平平方和，Qt=Qa+Qb+Qab+Qe
% 离差自由度
Da=r-1; % Qa自由度=水平数-1
Db=s-1; % Qb自由度=水平数-1
Dab=Da*Db; % Qab自由度=(A水平数-1)*(B水平数-1)
De=r*s*(t-1); % Qe自由度=Qt水平数-Qa水平数-Qb水平数-Qab水平数
Dt=r*s*t-1; % Qt水平数=总实验次数-1
% 平均离差平方和=离差平方和/自由度
Qa_ba=Qa/Da;
Qb_ba=Qb/Db;
Qab_ba=Qab/Dab;
Qe_ba=Qe/De;
Qt_ba=Qt/Dt;
% F分布假设检验
Fa=Qa_ba/Qe_ba;
Fa_alpha=finv(alpha,Da,De);
Ha=Fa>Fa_alpha;
Fb=Qb_ba/Qe_ba;
Fb_alpha=finv(alpha,Db,De);
Hb=Fb>Fb_alpha;
Fab=Qab_ba/Qe_ba;
Fab_alpha=finv(alpha,Dab,De);
Hab=Fab>Fab_alpha;
H=[Ha,Hb,Hab]';
F=[Fa Fa_alpha;Fb Fb_alpha;Fab Fab_alpha];
ABE=[Qa Da Qa_ba;Qb Db Qb_ba;Qab Dab Qab_ba;Qe De Qe_ba;Qt Dt Qt_ba];
% 结果显示
disp('============================================================')
str={'A','B','AB'};
for i=1:3
    if H(i)==1
        disp(['拒绝因素',str{i},'均值相等的假设，即因素',str{i},'对实验结果有显著影响！'])
    else
        disp(['接受因素',str{i},'均值相等的假设，即因素',str{i},'对实验结果影响不明显！'])
    end
end
disp(' ')
disp('误差来源    离差平方和   自由度      平均离差     F值        Fα')
fprintf('%5s%13.3f%8d%15.3f%10.3f%10.3f\n','行(A)',Qa,Da,Qa_ba,Fa,Fa_alpha)
fprintf('%5s%13.3f%8d%15.3f%10.3f%10.3f\n','列(B)',Qb,Db,Qb_ba,Fb,Fb_alpha)
fprintf('%3s%14.3f%8d%15.3f%10.3f%10.3f\n','交叉',Qab,Dab,Qab_ba,Fab,Fab_alpha)
fprintf('%3s%14.3f%8d%15.3f\n','误差',Qe,De,Qe_ba)
fprintf('%3s%14.3f%8d%15.3f\n','总和',Qt,Dt,Qt_ba)
disp('============================================================')