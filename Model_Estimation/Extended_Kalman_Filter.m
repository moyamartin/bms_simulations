
A = zeros(3,3,66);
B = zeros(3,1,66);
C = zeros(1,3,66);
D = zeros(1,66);

t1 = (-1./(R1_lutable.*C1_lutable))';
t2 = (-1./(R2_lutable.*C2_lutable))';

%                    s
% 1 Ah = 1 Ah * 3600 - = 3600 As
%                    h

Sca = 2.9*3600; % [As]

Ke = 0.8517;

for (i = 1: length(t1))
    
    A(1,1,i) = t1(i);
    A(2,2,i) = t2(i);
    
    B(1,1,i) = 1/C1_lutable(i);
    B(2,1,i) = 1/C2_lutable(i);
    B(3,1,i) = -1/Sca;
    
    C(:,:,i) = [-1,-1,Ke];
    
    D(i) = -R0_lutable(i);

end

%% 
Ts=0.1;


 %genero corriente de simulacion en base a la corriente de dataset

CurrentSim=timeseries(-meas.Current,meas.Time);

%Ensayo a corriente constante
CurrentSim = timeseries(ones(100001,1)*0.9,[0:0.1:10000]);

%adapto tension como entrada al bloque de kalman

VoltageSim=timeseries(meas.Voltage,meas.Time);
SOCSim=timeseries(meas.Ah,meas.Time);


sim('ResampleoV_i_SOC_16');

%% State Extrapolation equation

% F	is a state transition matrix
% G	is a control matrix or input transition matrix (mapping control to state variables)

V1_0 = 0;
V2_0 = 0;
SOC_0 = 1;
x_0=[V1_0;V2_0;SOC_0];

x = x_0;


for i=1 : length(Iout.Data)

% Ts = (meas.Time(i+1) - meas.Time(i));

[ d, ix ] = min( abs( SOC_lutable-SOC(i) ) );

[x,y] = StateExtrapolation(A(:,:,ix),B(:,1,ix),C(:,:,ix),D(ix),x, Iout.Data(i), Ts);

x_sim(:,:,i) = x;
y_sim(i) = y;

end

V1_Sim=reshape(x_sim(1,1,:),1,100001);
V2_Sim=reshape(x_sim(2,1,:),1,100001);
SOC_Sim=reshape(x_sim(3,1,:),1,100001);
Vterm_Sim=reshape(y_sim(:),1,100001);
Tiempo_Simulado=[0:0.1:10000];

 load('OCV_VS_SOC_01C.mat','SOC_01C','OCV_01C');

% Normalizo SOC_01C entre 0 y 1
min_SOC_01C = -1*min(SOC_01C);
SOC_01C_norm = (SOC_01C + min_SOC_01C)/min_SOC_01C;


 for i = 1 : length(x_sim(3,1,:))
    
    [ d, ix ] = min( abs( SOC_01C_norm-( 1-x_sim(3,1,i) ) ) );
    
    y_sim_vterm(i) = y_sim(i) + OCV_01C(ix);
     
 end
 
 figure
 plot(Tiempo_Simulado,x_sim(3,1,:))
 
 Vterm_Sim=reshape(y_sim_vterm(:),1,100001);
 
figure(1)

subplot(3,1,1)
plot(Tiempo_Simulado,Vterm_Sim,Vout.Time,Vout.Data)
legend('Sim','Dataset')

subplot(3,1,2)
plot(Iout.time,Iout.Data)

subplot(3,1,3)
plot(SOCout.time,SOCout.Data/2.9)

figure(2)
plot(Tiempo_Simulado,Vterm_Sim);
title('Ensayo descarga a corriente constante');

figure(2)
plot(SOC_table,OCV_table)

plot (meas.Time)
hold
plot(Ts_sim)

y_sim(102800) = 0; 

plot (x(1,1,:));
figure()
plot(meas.Time,meas.Voltage,meas.Time,y_sim);
    
index = interp1(SOC_lutable,1:length(SOC_lutable),SOC,'nearest');

plot(meas.Time,meas.Current)


F = A(:,:,index);
G = B(:,:,index);

x = F*x+G*u;
y = 


SOC =[0.873496105020197]
            % Perform the table lookup
            A = tablelookup(SOC_lutable,A_table,SOC, interpolation=linear,extrapolation=nearest)
            
ind = interp1(SOC_lutable,1:length(SOC_lutable),SOC,'nearest');

ind = interp1(SOC_lutable,1:length(SOC_lutable),SOC,'nearest');

figure
plot(Tiempo_Simulado,V_Simulada_POST(:,:,1))
hold
plot(Tiempo_Simulado,V_Simulada_POST(:,:,19))
