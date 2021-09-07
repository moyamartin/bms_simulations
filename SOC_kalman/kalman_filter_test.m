%% Kalman Filter Matlab Algorithm Test %%

% This example simulates the trayectory of a cannon ball and predicts the
% trayectory of it using a kalman filter

addpath('./lib')
load('datasets/trayectory_measurements.mat')
load('datasets/measurements_no_noise.mat')

% I was lazy and I didn't want to modify the script from python to export
% the data as it should be, so I transpose it manually here
measurements_no_noise = measurements_no_noise';

% define our example's Kalman Filter
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
example_kalman_filter = struct( ...
	'x_act', [0.0; 70.71067812; 500.0; 70.71067812], ...
	'F', [1.0, 0.1, 0.0, 0.0;
		0.0, 1.0, 0.0, 0.0;
		0.0, 0.0, 1.0, 0.1;
		0.0, 0.0, 0.0, 1.0], ...
    'G', [0.0, 0.0, 0.0, 0.0; 
          0.0, 0.0, 0.0, 0.0; 
		  0.0, 0.0, 1.0, 0.0; 
		  0.0, 0.0, 0.0, 1.0], ...
	'P_act', [1.0, 0.0, 0.0, 0.0; 
			  0.0, 1.0, 0.0, 0.0; 
			  0.0, 0.0, 1.0, 0.0;
			  0.0, 0.0, 0.0, 1.0], ...
	'R', 0.2*eye(4), ...
	'H', eye(4), 'Q', zeros(4, 4), 'u', [0.0; 0.0; -0.0495; -0.981], ...
    'D', zeros(4, 4) ...
);

example_kalman_filter = kalman_filter_init(example_kalman_filter, 4, 4);

% here we are storing the result from the current state of the system
% calculated by the kalman filter
current_state = zeros(size(measurements));

% For the extended version update the matrix F and G respectively
for i = 1:length(measurements)
    current_state(i, :) = example_kalman_filter.x_act;
    example_kalman_filter = kalman_filter_step(example_kalman_filter, ...
        measurements(i, :)');
end

%% PLOT RESULTS %%
% plot the results of the kalman filter, the noisy input and the true value
figure()
plot(current_state(:, 1), current_state(:, 3), measurements(:, 1), ...
    measurements(:, 3), measurements_no_noise(:, 1), ...
    measurements_no_noise(:, 2));
title("Trayectoria de una bala de cañon usando un Filtro de Kalman")
legend('Estimación del Filtro', 'Mediciones ruidosas', 'Valor Real')
xlabel('x [m]')
ylabel('y [m]')

%% SHOW FIT METRICS %%
% calculate rms
RMSE_x = sqrt(mean((measurements_no_noise(:, 1) - current_state(:, 1)).^2));
RMSE_y = sqrt(mean((measurements_no_noise(:, 2) - current_state(:, 3)).^2));

fprintf("RMSE x axis: %f.2\n", RMSE_x)
fprintf("RMSE y axis: %f.2\n", RMSE_y)