%% Obtaining parameters!


disp('loading ... 25degC/5 pulse disch/03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat');
load('../dataset_18650pf/25degC/5 pulse disch/03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat');
disp('loading ... ocv_soc.mat');
load('../dataset_18650pf/ocv_soc.mat');
disp('loading model_params.mat');
load('../dataset_18650pf/model_params.mat');


Current = [meas.Time, meas.Current];
Voltage = [meas.Time,meas.Voltage];

min_ah = -1*min(meas.Ah);
soc_t = (meas.Ah + min_ah)/min_ah;
soc_t = [meas.Time,soc_t];

SOC_table = soc;

%Estirar ocv al largo de meas.Time
Vocv = repelem(ocv,round(102800/55));
%completar los valores restantes con 0s
Vocv(numel(meas.Time)) = 0;
%hacer el vector Vocv para simulación
Vocv = [meas.Time,Vocv];

disp('Construyendo tablas de parámetros Rn y Cm...')
%Tz, Tp1 and Tp2

 Tz = -1*z;
 Tp = -1*p;
    
   
R2_table = k.*(Tz-Tp(:,2))./(Tp(:,1)-Tp(:,2));
R1_table = k-R2_table;
C1_table = Tp(:,1)./R1_table;
C2_table = Tp(:,2)./R2_table;

% Solo utilizo los parámetros en la zona lineal
% de 100 - 10 %
R2_table = R2_table(1:55,1);
R1_table = R1_table(1:55,1);
C1_table = C1_table(1:55,1);
C2_table = C2_table(1:55,1);

disp('Average R0 ... ')
% Valor de R0 Obtenido a partir de promediar todos los R0(i) de cada pulso
% de descarga en todos los SOC
% Da muy cercana al valor ajustado por lucho, R0 = 0.0256
R0 = Average_R0(meas.Current,meas.Voltage);


%%



min_ah = -1*min(meas.Ah);
soc = (meas.Ah + min_ah)/min_ah;
soc_t = [meas.Time,soc];


Vocv = repelem(ocv,round(102800/55));

Vocv = [meas.Time,Vocv];




%%
%Rescato los valores donde hay flancos en el verctor de corriente
I_flancos = flanks(meas.Current, 50);

i=1;
indexes = struct('inicio',0,'fin',0);

%Rescato el numero de muestras donde inician y terminan los periodos de
%relajación
for( n = 1 : length(I_flancos) )

    if(I_flancos(n) == 1)
        indexes(i).inicio = n;
    end
    
    if (I_flancos(n) == - 1)
        indexes(i).fin = n;
        i = i+1;
    end
    
end


%Plotear el escalon de tensión i. 
i = 60;
plot(meas.Time(indexes(i).inicio:indexes(i).fin),meas.Voltage(indexes(i).inicio:indexes(i).fin))


% Inicializa arreglos z, p, k
z = zeros(length(indexes) - 1, 1);
p = zeros(length(z), 2);
k = zeros(length(p), 1);

%        V'(t)   v(t) - Vocv(SOC) - R0*i(t)
%   Gs = ---- = ----------------------------
%        I(t)               i(t)

% Cálculo de R0
R0 = Average_R0(meas.Current, meas.Voltage);
R0_table = R0*ones(length(meas.Current),1);


for i = 1:length(indexes) - 12
    
    %Para una sola muestra, debe estar comentado
    i = 13;
    
    disp('procesando ensayo numero...');
    disp (int2str(i));
   
    n_muestras = indexes(i).fin-indexes(i).inicio + 1;
    
    % Guardar Tiempos entre rangos 
    time_buffer = meas.Time(indexes(i).inicio:indexes(i).fin);
    % Guarda el OCV entre rangos
    Vocv_buffer =  Vocv(indexes(i).inicio:indexes(i).fin);
    % Guarda el voltage entre rangos
    voltage_buffer = meas.Voltage(indexes(i).inicio:indexes(i).fin);
    %Guardo la corriente entre rangos
    current_buffer = meas.Current(indexes(i).inicio:indexes(i).fin);
    % Guarda el Ro*I entre rangos
    R0xI_buffer = R0*current_buffer;
    
    Vprima =  voltage_buffer - Vocv_buffer  - R0xI_buffer;
    
    %plotear 
    figure(1)
    subplot(2,1,1)
    plot(meas.Time(indexes(i).inicio:indexes(i).fin),current_buffer );
    subplot(2,1,2)
    plot(meas.Time(indexes(i).inicio:indexes(i).fin),Vprima);
    grid on;
    
    figure(2)
    plot(meas.Time(indexes(i).inicio:indexes(i).fin),voltage_buffer,meas.Time(indexes(i).inicio:indexes(i).fin),Vprima);
    grid on;
    
   %    plot(meas.Time(indexes(i).inicio:indexes(i).fin),Vprima,meas.Time(indexes(i).inicio:indexes(i).fin),meas.Voltage(indexes(i).inicio:indexes(i).fin));
     
%     pause;

    fs = 1/.1;    % Frecuencia de sampleo
    % Resamplea las muestras a una frecuencia
    [current_resampled, ~] = resample(current_buffer, time_buffer, fs, 5, 20);
    [voltage_resampled, ~] = resample(Vprima, time_buffer, fs, 5, 20);
    % Genera el iddata del voltage y la corriente
    data_buffer = iddata(voltage_resampled, current_resampled, 1/fs);
    % Estima de la funcion transferencia
    battery_model = tfest(data_buffer, 2, 1)
    %Extrae los ceros, polos y ganancia
    zpk_buffer = zpk(battery_model);
    z(i) = cell2mat(zpk_buffer.Z);
    p(i, :) = cell2mat(zpk_buffer.P);
    k(i) = zpk_buffer.K;
    
end

%% 

Tz=-1./z;

Tp=-1./p;

    R2_table = k.*(Tz-Tp(:,2))./(Tp(:,1)-Tp(:,2));
    R1_table = k-R2_table;
    C1_table = Tp(:,1)./R1_table;
    C2_table = Tp(:,2)./R2_table;
    
    

%% Evaluate model

% for single SOC model
indice = 10;
R1 =  R1_table(indice)
R2 = R2_table(indice)
C1 = C1_table(indice)
C2 = C2_table(indice)


subfigure(2,1,1)

plot(meas.Time,meas.Voltage,Vocv_sim.time,Vocv_sim.data);
title('meas.Voltage Vs Vterm simulation')
legend('meas.Voltage','sim data')

