load('03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat')

%CurrentPeakValue=[1.45 2.9 5.8 11.6 17.4];
%VoltajeVariation=[0.0370 0.1080 0.21 0.3970 0.6160];


%voltaje Variation at almost %100 SOC
%1= 4.175-4.138
%2= 4.172-4.064
%3= 4.165-3.955
%4= 4.155-3.758
%5= 4.137-3.521

%R0=VoltajeVariation./CurrentPeakValue;

%R0=mean(R0);
%R0=R0-0.00712; %ajuste para evitar tension positiva erronea en rta scalon
%R0=0.0266; %valor obtenido tras el ajuste de Voltaje-I*R0
R0=0.0266-0.00115729;
%desde=1;
%hasta=195;
desde=1; %muestra donde comienzo el ploteo
hasta=102800; %muestra donde recorto ploteo
Time=meas.Time;
Current=meas.Current;
Voltage=meas.Voltage;
Voltage=Voltage-ones(length(Voltage),1)*Voltage(desde); %Esto es para restar
% el OCV que no aporta a la dinamica del sistema
Ts=0.1;

Voltage=Voltage-R0*Current; %quito R0 para calculos de dinamica de C1 y C2
%Voltage(101:106)=zeros(6,1) totalmente manualmente le quito el pico
%positivo generado por algun errror en medicion tension corriente


%plot del escalon de corrientes vs tension del dataset
figure(1)
subplot(2,1,1)
plot(Time(desde:hasta),Current(desde:hasta))
subplot(2,1,2)
plot(Time(desde:hasta),Voltage(desde:hasta))



%calculo del modelo segun datos del datasset
CellModel=iddata(Voltage(desde:hasta),Current(desde:hasta),Ts)
np = 2;
nz = 1;
sys = tfest(CellModel,np,nz);
sys=zpk(sys)

Tz=-1/cell2mat(sys.z(1));

Tp=-1./cell2mat(sys.p);

%Kp=sys.k;  
Kp=0.0263; %valor obtenido por ajuste a ojo prueba y error ya que el de la funcion de matlab no era bueno
R2=Kp*(Tz-Tp(2))/(Tp(1)-Tp(2));
R1=Kp-R2;
C1=Tp(1)/R1;
C2=Tp(2)/R2;

CurrentSim=timeseries(-Current(desde:hasta),Time(1:hasta-desde+1));
OCV=meas.Voltage(desde);
aux=num2str((hasta-desde+1)*Ts);
set_param('circuito2branch_working','StartTime','0','StopTime',aux)
sim('circuito2branch_working')

%subplot(3,1,1)
%plot(Vout)
%subplot(3,1,2)
%plot(Time(desde:hasta),Voltage(desde:hasta))
%subplot(3,1,3)
%plot(CurrentSim)

%plot para comparar graficamente modelo y dataset
figure(2)
plot(Vout)
hold
Voltage=meas.Voltage;
plot(Time(1:hasta-desde+1),Voltage(desde:hasta))

filename='Lucio_prueba.mat';
save(filename,'C1','C2','R1','R2','R0');



%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
% ERROR GRAPHIC---------------------------------------------------------
CurrentSim=timeseries(-meas.Current,meas.Time);

Capacidad_nom=2.9;%Ah

AH_r = cumtrapz(meas.Time,meas.Current)./(3600*2.9); %en unidades

%SOC=1+AH_r; % en %

%SOC con el calculo que paso Martin Moya
load('ocv_soc.mat')
coef=polyfit(soc,ocv,1);
SOC=meas.Ah/(-meas.Ah(102800))+1;

OCV_0=coef(2);
K_e= coef(1);

%auxiliares graficar para corroborar estimacion correcta
%aux=[0:1/54:1]'
%Y = polyval(coef,aux)

%plot(aux,Y,soc,ocv)



%K_e=0.0185*100;
%OCV_0=2.324;
OCV= OCV_0 + K_e*SOC;
OCVSim=timeseries(OCV,meas.Time);


plot(SOC)



aux=num2str((length(meas.Time)).*Ts);
set_param('circuito2branch_working','StartTime','0','StopTime',aux)
sim('circuito2branch_working')

figure(3)
plot(meas.Time,meas.Voltage,Vout.time,Vout.Data)

%generacion matriz A
A=[-1/(R1*C1),0,0;0,-1/(R2*C2),0;0,0,0];
B=[1/C1,1/C2,-1/(Capacidad_nom*3600)]'; %3600 para que sea A*s y no Ah
C=[-1,-1,K_e];
D=-R0;

Battery_sys= ss(A,B,C,D)

%Q=10;
%R=0.005;
Q=0.01;
R=100;
[kalmf,L,P,M] =kalman(Battery_sys,Q,R)
Current_Resampled = resample(meas.Current,meas.Time,1000)
kalmanoutput=lsim(kalmf,meas.Current,meas.Time)

VoltageSinOffset=meas.Voltage-OCV_0;
VoltageSim=timeseries(VoltageSinOffset,meas.Time);

length(meas.Time)
length(Vout.time)

measVoltage=timeseries(meas.Voltage,meas.Time);
[measVoltage Vouttime]=synchronize(measVoltage,Vout,'intersection')
figure(4)
plot(measVoltage)
hold
plot(Vouttime)
std(Vouttime-measVoltage)
median(abs(Vouttime.data-measVoltage.data))

figure(5)
plot(Vouttime.time,Vouttime.data-measVoltage.data)



plot(Xhat.time,Xhat.Data(:,3))
plot(Xhat.time,Xhat.Data(:,2))
plot(Xhat.time,Xhat.Data(:,1))
plot(Yhat.time,Yhat.Data,meas.Time,meas.Voltage)


%prueba pq kalman anda mal
OCVSim=timeseries(ones(length(meas.Time),1)*meas.Voltage(1),meas.Time);
CurrentSim=timeseries(zeros(length(meas.Time),1)*meas.Voltage(1),meas.Time);
VoltageSim=OCVSim-OCV_0;% el modelo no tiene en cuenta el offset del OCv cuando linealiza SOC vs OCV

figure(2)
plot((meas.Ah/2.9)+1)
hold
plot(Xhat.time,Xhat.Data(:,3))



plot(Vout.time,Vout.Data,Yhat.time,Yhat.Data+OCV_0);

%graficas para R=0.1 Q=10;
Yhat1=Yhat+OCV_0;
Xhat1=Xhat;



[yresult,tresult,xresult]=lsim(Battery_sys,Currente.Data,Currente.time,[0 0 1])




