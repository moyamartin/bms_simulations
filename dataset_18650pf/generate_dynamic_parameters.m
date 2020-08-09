%% Obtaining Tz, Tp1 and Tp2
current_dir = pwd;
load([current_dir '/25degC/5 pulse disch/03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat'])
load([current_dir '/ocv_soc.mat'])
load([current_dir '/indexes_current_pulses.mat'])

z = zeros(length(indexes) - 1, 1);
p = zeros(length(z), 2);
k = zeros(length(p), 1);
for i = 1:length(indexes) - 1
    voltage_buffer = meas.Voltage(indexes(i):indexes(i+1)) - meas.Voltage(indexes(i));
    current_buffer = meas.Current(indexes(i):indexes(i+1));
    current_step = min(current_buffer);
    time_buffer = meas.Time(indexes(i):indexes(i+1)) - meas.Time(indexes(i));
    fs = 1/.001;
    [current_resampled, ~] = resample(current_buffer, time_buffer, fs, 5, 20);
    [voltage_resampled, ~] = resample(voltage_buffer, time_buffer, fs, 5, 20); 
    data_buffer = iddata(voltage_resampled, current_resampled, 1/fs);
    battery_model = tfest(data_buffer, 2, 1)
    zpk_buffer = zpk(battery_model)
    z(i) = cell2mat(zpk_buffer.Z);
    p(i, :) = cell2mat(zpk_buffer.P);
    k(i) = zpk_buffer.K;
end
%data = iddata();