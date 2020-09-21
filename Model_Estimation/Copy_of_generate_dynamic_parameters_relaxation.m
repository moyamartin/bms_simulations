%% Obtaining parameters!

%Load parameters from dataset
disp('loading ... 25degC/5 pulse disch/03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat');
load('../dataset_18650pf/25degC/5 pulse disch/03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat');
disp('loading ... ocv_soc.mat');
load('../dataset_18650pf/ocv_soc.mat');
disp('loading model_params.mat');
load('../dataset_18650pf/model_params.mat');


Current = [meas.Time, meas.Current];
Voltage = [meas.Time,meas.Voltage];

%% Calculate SOC

min_ah = -1*min(meas.Ah);
SOC = (meas.Ah + min_ah)/min_ah;
SOC_table = [meas.Time,SOC];
% Clean Workspace
clear min_ah;

% Check SOC grapicaly
plot(meas.Time,SOC);

%% Rescue flanks positions on Current Vector

Current_flanks = flanks(meas.Current, 50);

% Check Flanks vs Current and Voltage
plot( meas.Time, Current_flanks, meas.Time, meas.Current, meas.Time, meas.Voltage);
legend( 'flanks','meas.Current','meas.Voltage');
title( 'Flanks vs meas.Current vs meas.Voltage');


%% Rescue OCV values

% Rescue OCV and indexes position from dataset 
n=1;
for i = 1 : length(meas.Voltage)
    if(Current_flanks(i) == -1)
        OCV(n,1) = meas.Voltage(i);
    end
    if(Current_flanks(i) == 1)
        OCV(n,2) = i;
        n = n+1;
    end
end

% 
n=1;
for( i = 1 : length(meas.Time) )
    Vocv(i,1) = OCV(n,1);
    if ( i == OCV(n,2))
        if(n<length(OCV(:,1)))
            n = n+1;
        end
    end
end

Vocv_table = [meas.Time,Vocv];

% Clean Workspace
clear i n OCV;


% Check graphically Voltage Vs Vocv 
plot(meas.Time, meas.Voltage,Vocv_table(:,1),Vocv_table(:,2));
legend( 'meas.Voltage','Vocv');
title( 'Voltage Vs Vocv');


%% Valid Data periods

indexes = struct('start',0,'end',0);

%Rescato el numero de muestras donde inician y terminan los periodos de
%relajación

i=1;

for( n = 1 : length(Current_flanks) )

    if(Current_flanks(n) == -1)
            indexes(i).start = n;
            if( i ~= 1)
                indexes(i-1).end = n;
            end
            i = i+1;
    end
end



% Check graphically Voltage valid data periods
for (i = 1 : 67)
    
delta = 100;
figure(i)
plot(meas.Time((indexes(i).start-delta):indexes(i).end),meas.Voltage((indexes(i).start-delta):indexes(i).end))
str = sprintf('meas.Voltage((indexes(%d).start-%d):indexes(%d).end)', i, delta, i)
title( str );

pause;

end

% Clean Workspace
clear i n delta str;

 %% Initial Paramiters
 
 %Average R0
 disp('Average R0 ... ')
% Valor de R0 Obtenido a partir de promediar todos los R0(i) de cada pulso
% de descarga en todos los SOC
% Da muy cercana al valor ajustado por lucho, R0 = 0.0256
R0 = Average_R0(meas.Current,meas.Voltage);

R1 = [0.0273228292774916];
C1 = [172.286830453445];
R2 = [0.120006294781068];
C2 = [485.470579532194];


%%

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



%% Inicializa arreglos z, p, k
z = zeros(length(indexes) - 1, 1);
p = zeros(length(z), 2);
k = zeros(length(p), 1);

%        V'(t)   v(t) - Vocv(SOC) - R0*i(t)
%   Gs = ---- = ----------------------------
%        I(t)               i(t)


for i = 1:length(indexes) - 12
    
    %Para una sola muestra, debe estar comentado
    i = 1;
    
    str = sprintf('procesando ensayo numero %d ...', i);
    disp(str);

    % Delta Start
    ds = 100;
    % Delta end
    de = 0;
    
    n_muestras = (indexes(i).end+de)-(indexes(i).start-ds) + 1;
    
    % Guardar Tiempos entre rangos 
    time_buffer = meas.Time((indexes(i).start-ds):(indexes(i).end+de));
    % Guarda el Vocv entre rangos
    Vocv_buffer =  Vocv((indexes(i).start-ds):(indexes(i).end+de));
    % Guarda el voltage entre rangos
    voltage_buffer = meas.Voltage((indexes(i).start-ds):(indexes(i).end+de));
    %Guardo la corriente entre rangos
    current_buffer = meas.Current((indexes(i).start-ds):(indexes(i).end+de));
    % Guarda el Ro*I entre rangos
    R0xI_buffer = R0*current_buffer;
    
    
    Vprima =  voltage_buffer - Vocv_buffer  - R0xI_buffer;
    
    %plotear 
    figure(1)
    subplot(2,1,1)
    plot(meas.Time((indexes(i).start-ds):(indexes(i).end+de)),current_buffer );
    subplot(2,1,2)
    plot(meas.Time((indexes(i).start-ds):(indexes(i).end+de)),voltage_buffer);
    grid on;
    
    figure(2)
    plot(meas.Time((indexes(i).start-ds):(indexes(i).end+de)),voltage_buffer,meas.Time((indexes(i).start-ds):(indexes(i).end+de)),Vprima);
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
    battery_model = tfest(data_buffer, 3, 1)
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

