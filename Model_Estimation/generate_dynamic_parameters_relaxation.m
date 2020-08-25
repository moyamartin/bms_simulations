%% Obtaining Tz, Tp1 and Tp2
current_dir = pwd;

load([current_dir '/25degC/5 pulse disch/03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat'])
load([current_dir '/ocv_soc.mat'])
load([current_dir '/indexes_current_pulses.mat'])

Current = meas.Current;
Voltage = meas.Voltage;

% Rescato los valores donde hay flancos en el verctor de corriente
I_flancos = flanks(Current, 50);

i=1;
indexes = struct('inicio',0,'fin',0);

for( n = 1 : length(I_flancos) )

    if(I_flancos(n) == 1)
        indexes(i).inicio = n;
    end
    
    if (I_flancos(n) == - 1)
        indexes(i).fin = n;
        i = i+1;
    end
    
end
subplot(2,1,1)

%Plotear el escalon de tensión i. 
i = 60;
plot(meas.Time(indexes(i).inicio:indexes(i).fin),Voltage(indexes(i).inicio:indexes(i).fin))


% Inicializa arreglos z, p, k
z = zeros(length(indexes) - 1, 1);
p = zeros(length(z), 2);
k = zeros(length(p), 1);

%        V'(t)   -v(t) + Vocv(SOC) - R0*i(t)
%   Gs = ---- = ----------------------------
%        I(t)               i(t)

% Cálculo de R0
R0 = Average_R0(Current, Voltage);



for i = 1:length(indexes) - 11
    
    n_muestras = indexes(i).fin-indexes(i).inicio+1;
    
    % Guardar Tiempos entre rangos 
    time_buffer = meas.Time(indexes(i).inicio:indexes(i).fin);
    % Guarda el OCV entre rangos
    OCV_buffer =  ocv(i)*ones(n_muestras,1);
    % Guarda el voltage entre rangos
    voltage_buffer = meas.Voltage(indexes(i).inicio:indexes(i).fin);
    %Guardo la corriente entre rangos
    current_buffer = meas.Current(indexes(i).inicio:indexes(i).fin);
    % Guarda el Ro*I entre rangos
    R0xI_buffer = R0*current_buffer;
    
    Vprima =  -voltage_buffer + OCV_buffer  - R0xI;
    
    
    %plotear 
  %  plot(meas.Time(indexes(i).inicio:indexes(i).fin),-Vprima)
    

    fs = 1/.01;    % Frecuencia de sampleo
    % Resamplea las muestras a una frecuencia
    [current_resampled, ~] = resample(current_buffer, time_buffer, fs, 5, 20);
    [voltage_resampled, ~] = resample(Vprima, time_buffer, fs, 5, 20);
    % Genera el iddata del voltage y la corriente
    data_buffer = iddata(voltage_resampled, current_resampled, 1/fs);
    % Estima de la funcion transferencia
    battery_model = tfest(data_buffer, 2, 1)
    %Extrae los ceros, polos y ganancia
    zpk_buffer = zpk(battery_model)
    z(i) = cell2mat(zpk_buffer.Z);
    p(i, :) = cell2mat(zpk_buffer.P);
    k(i) = zpk_buffer.K;
end

%% Evaluate model

