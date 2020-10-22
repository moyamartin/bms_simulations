%% Kalman Filter Matlab Algorithm applied to a battery model %%
%% Load measurements, matrices and define the kalman filter structure %%

% Load A, B, C, D matrices
load('Juego_de_Matrices_A_B_C_D_ver_0.1.mat')
load('Juego_de_parametros_R_C_corregidos')
load('OCV_VS_SOC_01C.mat')
SOC_01C = SOC_01C - min(SOC_01C);
SOC_01C = SOC_01C/max(SOC_01C);
C = zeros(1, 3);

% Discretize the matrices
Ts = 0.1;
A = eye(3) + A*Ts;
% this value must be fixed and constant across all the SOC
B(3, 1, :) = 1/(2.9*3600);
B = B*Ts;
% Load a drive cycle to test the kalman filter %%
load('../dataset_18650pf/0degC/Drive Cycles/06-01-17_22.03 0degC_Cycle_4_Pan18650PF.mat')

%% Define the Kalman Filter and run the simulation %%
% define the battery Kalman Filter
% here all the known matrices are defined:
% x_act: first known measurement or estimation
% F: Transition matrix
% G: Control matrix
% P_act: Actual covariance matrix
% R: Measurement noise
% Q: Process Noise
% H: Observatio matrix
% u: input variable
% NOTE: the structure should be defined as is, if any field has a different
% name the functions won't work (yeah, I should let the kalman_filter_init
% function do this for us and pass every matrix by parameter)
% NOTE 2: Pay attention to matrix sizes and order!!
current_soc = 1;
SOC_index = find_closest_value(current_soc, SOC_lutable);
idx = find_closest_value(current_soc, SOC_01C);
% Here we fix the offset from OCV_01C
OCV_01C = OCV_01C - 0.059;
C(:, :) = [-1, -1, OCV_01C(idx)/SOC_01C(idx)];
soc_kalman_filter = struct( 'x_act', [0.0; 0.0; 1], 'F', A(:, :, SOC_index), ...
                            'G', B(:, :, SOC_index), ...
                            'P_act', [1.0, 0.0, 0.0;
                                      0.0, 1.0, 0.0; 
                                      0.0, 0.0, 1.0], ...
                            'D', D(:, SOC_index), 'R', 0.2, ...
                            'H', C(:, :), 'Q', zeros(3, 3), 'u', [0.0]);%[0.035, 0, 0;
                                               % 0, 0.035, 0;
                                               % 0, 0, 0], ...
                            
%% Resample step %%                        
% Guarda el voltage entre rangos 
measured_voltage = meas.Voltage;
% save measured current
measured_current = meas.Current;
% save measured Ah
measured_soc = (meas.Ah/2.9) + 1;
% save drive cycle time
time_buffer = meas.Time;
fs = 1/Ts;    % Frecuencia de sampleo
% Resamplea las muestras a una frecuencia
[current_resampled, timeline] = resample(measured_current, time_buffer, fs, ...
                                         5, 20);
[voltage_resampled, ~] = resample(measured_voltage, time_buffer, fs, 5, 20);
[ah_resample, ~] = resample(measured_soc, time_buffer, fs, 5, 20);
%% Apply the kalman filter to the battery model %%
% The init function only initializes unknown matrices to their
% correspondent sizes, here we are passing the number of states of the
% system because it's the only variable we need, in  the C library you
% should pass the number of states, inputs and outputs
soc_kalman_filter = kalman_filter_init(soc_kalman_filter, 3, 1);

% store timeline of soc
soc_array = zeros(length(timeline), 1);

%v_ocv_0 = 3.2;

soc_error = zeros(length(timeline), 1);

% For the extended version update the matrix F and G respectively
for i = 1:length(timeline)
    %current_state(i, :) = soc_kalman_filter.x_act;

    soc_array(i, 1) = soc_kalman_filter.x_act(3);
    soc_kalman_filter.u = current_resampled(i);
    soc_kalman_filter = kalman_filter_step(soc_kalman_filter, ...
                                           voltage_resampled(i));   
    SOC_index = find_closest_value(soc_kalman_filter.x_act(3), SOC_lutable);
    soc_kalman_filter.F = A(:, :, SOC_index);
    soc_kalman_filter.G = B(:, :, SOC_index);
    idx = find_closest_value(soc_kalman_filter.x_act(3), SOC_01C);
    soc_kalman_filter.H(:, 3) = OCV_01C(idx)/SOC_01C(idx);
    soc_kalman_filter.D = D(:, SOC_index);
    soc_error(i) = (soc_kalman_filter.x_act(3) - ah_resample(i))*100;
end

%% PLOT RESULTS %%
% plot the results of the kalman filter, the noisy input and the true value
figure()
subplot(311)
plot(timeline, soc_array, meas.Time, (meas.Ah/2.9) + 1);
title("SoC estimation using a Kalman Filter")
legend('Estimación del Filtro', 'Medicion del dataset')
xlabel('t[s]')
ylabel('%')

subplot(312)
plot(timeline, current_resampled);
title("Dataset's Current")
xlabel('t[s]')
ylabel('I[A]')

subplot(313)
plot(timeline, soc_error);
title("Soc error")
xlabel('t[s]')
%% SHOW FIT METRICS %%
% calculate rms

%fprintf("RMSE x axis: %f.2\n", RMSE_x)
%fprintf("RMSE y axis: %f.2\n", RMSE_y)