CurrentPeakValue=[1.45 2.9 5.8 11.6 17.4];
VoltajeVariation=[0.0370 0.1080 0.21 0.3970 0.6160];


%voltaje Variation at almost %100 SOC
%1= 4.175-4.138
%2= 4.172-4.064
%3= 4.165-3.955
%4= 4.155-3.758
%5= 4.137-3.521

R0=VoltajeVariation./CurrentPeakValue;

R0=mean(R0);
R0=R0-0.00712; %ajuste para evitar tension positiva erronea en rta scalon
R0=0.0266; %valor obtenido tras el ajuste de Voltaje-I*R0

Time=meas.Time;
Current=meas.Current;
Voltage=meas.Voltage;
Voltage=Voltage-ones(length(Voltage),1)*Voltage(1); %Esto es para restar
% el OCV que no aporta a la dinamica del sistema
Ts=0.1;
desde=1; %muestra donde comienzo el ploteo
hasta=195; %muestra donde recorto ploteo
Voltage=Voltage-R0*Current; %quito R0 para calculos de dinamica de C1 y C2
%Voltage(101:106)=zeros(6,1) totalmente manualmente le quito el pico
%positivo generado por algun errror en medicion tension corriente

subplot(2,1,1)
plot(Time(desde:hasta),Current(desde:hasta))
subplot(2,1,2)
plot(Time(desde:hasta),Voltage(desde:hasta))

CellModel=iddata(Voltage(desde:hasta),Current(desde:hasta),Ts)
np = 2;
nz = 1;
sys = tfest(CellModel,np,nz);
sys=zpk(sys)

Tz=-1/cell2mat(sys.z(1));

Tp=-1./cell2mat(sys.p);

Kp=sys.k;
Kp=0.0255; %valor obtenido por ajuste a ojo prueba y error
R2=Kp*(Tz-Tp(2))/(Tp(1)-Tp(2));
R1=Kp-R2;
C1=Tp(1)/R1;
C2=Tp(2)/R2;

CurrentSim=timeseries(-Current(desde:hasta),Time(desde:hasta));


subplot(3,1,1)
plot(Vout)
subplot(3,1,2)
plot(Time(desde:hasta),Voltage(desde:hasta))
subplot(3,1,3)
plot(CurrentSim)


figure(2)
plot(Vout)
hold
Voltage=meas.Voltage;
plot(Time(desde:hasta),Voltage(desde:hasta))


