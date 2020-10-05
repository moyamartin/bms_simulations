%% Kalman Filter Matlab Algorithm Test %%

% This example simulates the trayectory of a cannon ball and predicts the
% trayectory of it using a kalman filter

load('trayectory_measurements.mat')
load('measurements_no_noise.mat')

measurements_no_noise = measurements_no_noise';

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
	'H', eye(4), 'Q', zeros(4, 4), 'u', [0.0; 0.0; -0.0495; -0.981] ...
);

example_kalman_filter = kalman_filter_init(example_kalman_filter, 4);

current_state = zeros(size(measurements));

for i = 1:length(measurements)
    current_state(i, :) = example_kalman_filter.x_act;
    example_kalman_filter = kalman_filter_step(example_kalman_filter, ...
        measurements(i, :)');
end

figure()
plot(current_state(:, 1), current_state(:, 3), measurements(:, 1), ...
    measurements(:, 3), measurements_no_noise(:, 1), ...
    measurements_no_noise(:, 2));
title("Trayectoria de una bala de cañon usando un Filtro de Kalman")
legend('Estimación del Filtro', 'Mediciones ruidosas', 'Valor Real')
xlabel('x [m]')
ylabel('y [m]')
