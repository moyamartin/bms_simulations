%% Create and populate Non-Linear-Battery-Model Matrices

%           1/-t1     0        0               1/t1
% 
%     A = [   0      1/-t2     0 ]      B = [  1/t2 ]
% 
%             0       0        0              -1/Sca 
% 
% 
%     C =  [ -1      -1       ke ]      D =  [ -R0 ]

% Load R, C & SOC lutables
load( 'Juego_de_parametros_R_C_corregidos_ver_0.1.mat');

%Create time constants based on R & C parametes,
t1 = (-1./(R1_lutable.*C1_lutable))';
t2 = (-1./(R2_lutable.*C2_lutable))';

% Matrices quantity
N_matrices = length(t1);

% Create Matrices full of zeros! 
A = zeros(3,3,N_matrices);
B = zeros(3,1,N_matrices);
C = zeros(1,3,N_matrices);
D = zeros(1,N_matrices);

% Battery Capacity
C = 2.9; % [Ah]

%                    s
% 1 Ah = 1 Ah * 3600 - = 3600 As
%                    h

Sca = C*3600; % [As]

clear C;

% Ke is the linear regression coefficient;
Ke = 0.8907;

for (i = 1: N_matrices)
    
    A(1,1,i) = t1(i);
    A(2,2,i) = t2(i);
    
    B(1,1,i) = 1/C1_lutable(i);
    B(2,1,i) = 1/C2_lutable(i);
    B(3,1,i) = -1/Sca;
    
    C(:,:,i) = [-1,-1,Ke];
    
    D(i) = -R0_lutable(i);

end

clear N_matrices t1 t2 Sca Ke i;

%% Load and resample Drive Cicle data

disp('loading ... 25degC_Cycle_2_Pan18650PF.mat');
load('03-19-17_03.25 25degC_Cycle_2_Pan18650PF.mat');

Ts=0.1;

 %genero corriente de simulacion en base a la corriente de dataset

CurrentSim=timeseries(-meas.Current,meas.Time);

%Ensayo a corriente constante
%  CurrentSim = timeseries(ones(100001,1)*0.9,[0:0.1:10000]);

%adapto tension como entrada al bloque de kalman

VoltageSim=timeseries(meas.Voltage,meas.Time);
SOCSim=timeseries(meas.Ah,meas.Time);

% Resample Vterm Current & SOC to t = Ts
sim('ResampleoV_I_SOC_16.slx');

%% Simulate my Non-Linear-Battery-Model

% Set initial conditions
V1_0 = 0;
V2_0 = 0;
SOC_0 = 1;
x_0=[V1_0;V2_0;SOC_0];

x = x_0;

% Simulate! 
for i=1 : length(Iout.Data)

[ d, ix ] = min( abs( SOC_lutable-x(3)) );

[x,y] = StateExtrapolation(A(:,:,ix),B(:,1,ix),C(:,:,ix),D(ix),x, Iout.Data(i), Ts);

x_sim(:,:,i) = x;
y_sim(i) = y;

end

V1_Sim=reshape(x_sim(1,1,:),1,100001);
V2_Sim=reshape(x_sim(2,1,:),1,100001);
SOC_Sim=reshape(x_sim(3,1,:),1,100001);
Vterm_Sim=reshape(y_sim(:),1,100001);
 
Tiempo_Simulado=[0:0.1:10000];

% Load OCV data
load('OCV_VS_SOC_01C.mat','SOC_01C','OCV_01C');

% Normalizo SOC_01C entre 0 y 1
min_SOC_01C = -1*min(SOC_01C);
SOC_01C_norm = (SOC_01C + min_SOC_01C)/min_SOC_01C;

% Ad OCV V term to simulated output data
 for i = 1 : length(x_sim(3,1,:))
    
    [ d, ix ] = min( abs( SOC_01C_norm-x_sim(3,1,i) ) );
    
    Vterm_Sim(i) = y_sim(i) + OCV_01C(ix);
     
 end
 
 Vterm_Sim=reshape(Vterm_Sim(:),1,100001);

 %% Plot and analize data
 
figure()
subplot(3,1,1)
plot(Tiempo_Simulado,Vterm_Sim,Vout.Time,Vout.Data)
title('My non linear battery - Vterm');
legend('Sim','Dataset');

subplot(3,1,2)
plot(Iout.time,Iout.Data)
title('Current');

subplot(3,1,3)
plot(SOCout.time,SOCout.Data/2.9)
title('SOC');


