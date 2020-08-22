%cargar el dataset a probar

load('03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat')

Ts=0.1;
%Cargo valores del modelo extraido de bateria Lucio Santos mediante scripts
%KF25degC_5Pulse_HPPC_Pan18650PF (C1 C2 R0 R1 R2)
load('parametros_2.mat')

%genero corriente de simulacion en base a la corriente de dataset

CurrentSim=timeseries(-meas.Current,meas.Time);

%capacidad nominal de las baterias del dataset
Capacidad_nom=2.9;%Ah

%coeficiente de aproximacion lineal de SOC vs OCV calculado por Martin Moya

load('ocv_soc.mat')
coef=polyfit(soc,ocv,1);
SOC=meas.Ah/(-meas.Ah(102800))+1;

OCV_0=coef(2);
K_e= coef(1);

%Defino matrices del modelo 

A=[-1/(R1*C1),0,0;0,-1/(R2*C2),0;0,0,0];
B=[1/C1,1/C2,-1/(Capacidad_nom*3600)]'; %3600 para que sea A*s y no Ah
C=[-1,-1,K_e];
D=-R0;
Q=0.01;
R=1000;

%genero OCV para simulacion

OCV= OCV_0 + K_e*SOC;
OCVSim=timeseries(OCV,meas.Time);

%abrir simulacion y correr


%Condiciones iniciales   Vc1 / Vc2 / SOC;
X0=[0 0 1];



aux=num2str((length(meas.Time)));
set_param('circuito2branch_working','StartTime','0','StopTime',aux)
sim('circuito2branch_working')



%ploteos comparacion resultados simulacion

figure(1)
plot(Xhat.time,Xhat.Data(:,3))
title('SOC (de 0 a 1)')

%tension de capacitor Vc2
%plot(Xhat.time,Xhat.Data(:,2))
%tension de capacitor Vc1
%plot(Xhat.time,Xhat.Data(:,1))

figure(2)
%comparacion Tension estimada de Kalman y Tension Medida

plot(Yhat.time,Yhat.Data,meas.Time,meas.Voltage)
title('Comparacion Tension en Bornes KF vs Measurement')


figure(3)
plot(Xhat.time,Xhat.Data(:,3)*Capacidad_nom-(Xhat.Data(1,3)*Capacidad_nom),meas.Time,meas.Ah)
title('SOC*Ah nominal vs Ah dataset  (de 0 a 1)')


figure(4)
AhKF=timeseries(Xhat.Data(:,3)*Capacidad_nom-Xhat.Data(1,3)*Capacidad_nom,Xhat.time)
measAh=timeseries(meas.Ah,meas.Time);
[measAh AhKF]=synchronize(measAh,AhKF,'intersection')
plot(measAh.time,measAh.Data,AhKF.time,AhKF.Data)


std(AhKF-measAh)
median(abs(AhKF.data-measAh.data))

figure(5)
plot(AhKF.time,AhKF.data-measAh.data)
title('error Ah Dataset vs Ah KF [Ah]')



