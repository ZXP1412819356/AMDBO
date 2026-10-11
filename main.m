%AMDBO Xinpeng Zheng

close all
clear all
clc
N=30;  
Max_iter=1000;  
Function_name='F1'; % Name of the test function that can be from F1 to F30
% Since CEC2017 needs to read input_data folder data, the CEC2005 test set is used here for demonstration
% [lb,ub,dim,fobj]=Get_F(Function_name); % CEC2005 
[lb,ub,dim,fobj]=CEC2017(Function_name); % CEC2017
[score,pos,curve]=AMDBO(N,Max_iter,lb,ub,dim,fobj);
figure('Position',[454   445   694   297]);
subplot(1,2,1);
% func_plot(Function_name);  % CEC2005
func_plot2017(Function_name);  % CEC2017
title('Function Topology')
xlabel('x_1');
ylabel('x_2');
zlabel([Function_name,'( x_1 , x_2 )'])
subplot(1,2,2);
semilogy(curve,'b-','LineWidth',1);
hold on
semilogy(curve,'r-','LineWidth',1.5);
xlabel('Iteration#');
ylabel('Best fitness obtained so far');
legend('AMDBO');
title('Convergence curve')
axis tight
display(['The best fitness of SAO is: ', num2str(score)]);
