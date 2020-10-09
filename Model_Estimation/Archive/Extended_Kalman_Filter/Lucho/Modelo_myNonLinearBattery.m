
%load('03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat')
load('C:\Users\Martin\Desktop\prueba\bms_simulations\dataset_18650pf\25degC\Drive Cycles\03-19-17_03.25 25degC_Cycle_2_Pan18650PF.mat')
Ts=0.1;


 %genero corriente de simulacion en base a la corriente de dataset

CurrentSim=timeseries(-meas.Current,meas.Time);

%adapto tension como entrada al bloque de kalman

VoltageSim=timeseries(meas.Voltage,meas.Time);
SOCSim=timeseries(meas.Ah,meas.Time);


 %Inicializo
 load('OCV_VS_SOC_01C.mat','SOC_01C','OCV_01C')
x_0=[0;0;1];  
Estados_Simulados=zeros(1,3,length(Vout.Data));
Salida_Simulada=zeros(1,length(Vout.Data));
for i=1 : length(Vout.Data)
   if i==1
    [x,y]=myNonLinearBattery(x_0,Iout.Data(1),Ts);
    Estados_Simulados(:,:,1)=x;
    Salida_Simulada(:,1)=y;
   else
    [x,y]=myNonLinearBattery(x,Iout.Data(i),Ts);
    Estados_Simulados(:,:,i)=x;
    Salida_Simulada(:,i)=y;
   end
end

V1_Simulada=reshape(Estados_Simulados(1,1,:),1,100001);
V2_Simulada=reshape(Estados_Simulados(1,2,:),1,100001);
SOC_Simulado=reshape(Estados_Simulados(1,3,:),1,100001);
V_Simulada=reshape(Salida_Simulada(1,:),1,100001);
Tiempo_Simulado=[0:0.1:10000];


figure(1)

subplot(3,1,1)
plot(Tiempo_Simulado,V_Simulada,Vout.Time,Vout.Data)
legend('Sim','Dataset')

subplot(3,1,2)
plot(Iout.time,Iout.Data)

subplot(3,1,3)
plot(SOCout.time,SOCout.Data/2.9)

figure(2)
plot(SOC_table,OCV_table)

%plot(SOC_table(:,2),Vocv_table(:,2))