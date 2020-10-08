%% Define metavariables
clear all
close all
duration = 5;   % Duration of movement
dt = 0.1;       % Sampling rate

%% Define Update Equations (Coefficient matrices)

% State transition matrix
% State prediction
A = [1 dt; 0 1];

% Input control matrix
% Expected effect of the input acceleration on the state
B = [dt^2/2; dt];

% Measurement matrix
% The expected measurement given the predicted state
C = [1 0];

%% Define Main Variables
% Acceleration magnitute
u_t = 10;  

% Initial Sate
% Two components: [position; velocity]
x_t = [0; 0];

% State Estimante
% Estimate of initial location
% We will be updating this variable
xHat_t = x_t;

% Process Noise
% Standard deviation of process (acceleration in this case)
u_t_noiseMag = 0.05;

% Measurement Noise
% Standard deviation of measurement (position in this case)
z_t_noiseMag = 10;

% Covariance matrices for noise
% Convert stdv into covariance noise by squaring it
% Process covariance
E_x = u_t_noiseMag^2 * [dt^4/4, dt^3/2; dt^3/2, dt^2];

% Measurement covariance
E_z = z_t_noiseMag^2;

% Estimate of initial position variance
EHat_t = E_x;
%% Initialize result variables
% Actual path
p_actual = [];

% Actual velocity
v_actual = [];

% Measured path
z_t = [];
%% Simulate measurements over time

figure (1);
clf

for t = 0:dt:duration

    % Generate the Path
    % Acceleration Noise
    Ex = u_t_noiseMag*randn*B;
    % State Prediction
    x_t = A*x_t + B*u_t + Ex;

    % Generate Measurement
    % Measurement Noise
    Ez = z_t_noiseMag*randn;
    % Measurement Prediction
    zHat_t = C*x_t + Ez;

    % Store for Plot
    p_actual = [p_actual; x_t(1)];
    z_t = [z_t; zHat_t];
    v_actual = [v_actual; x_t(2)];
    
    % Iteratively plot the measurement
    subplot(2,1,1),plot(0:dt:t, p_actual, '-r.')
    subplot(2,1,1),plot(0:dt:t, z_t, '-k.')

    % Plot theoretical estimate without Kalman
    subplot(2,1,1),plot(0:dt:t, smooth(z_t),'-g.')
    axis([0 duration -30 max(p_actual)])

    hold on
    pause % Uncomment to see the discrete progress
end


% Add Labels to Plot
xlabel({'Time(s)'});
ylabel({'Position(m)'});
title({'Path Tracking without Kalman Filter'});
legend('Estimation','Actual','Measured')
hold on

%% Apply Kalman Filter
% Initialize Estimation Variables
% Estimate of the first component of the state (position)
xHat_t1 = [];
% Estimate of the second component of the state (velocity)
xHat_t2 = [];

% State
x_t = [0; 0];

% Prior covariance
E_tminus1 = E_x;
EHat_t_mag = [];

% Predicted state
x_predic =[];

% Predicted covariance
E_predic = [];

for t = 1:length(p_actual)

    % Predict the next state
    xHat_t = A * xHat_t + B * u_t;

    % Predict the next covariance
    EHat_t = A * EHat_t * A' + E_x;

    % Kalman gain
    K_t    = EHat_t * C' * inv(C * EHat_t * C' + E_z);

    % Update state estimate
    x_t = xHat_t + K_t *(z_t(t) - C*xHat_t);

    % Update covariance estimate
    E_t = (eye(2) - K_t * C)*EHat_t;

    % Store for plotting
    xHat_t1 = [xHat_t1; xHat_t(1)];
    xHat_t2 = [xHat_t2; xHat_t(2)];
    EHat_t_mag = [EHat_t_mag; EHat_t(1)];
end

%% Plot the results
tt = 0 : dt : duration;
subplot(2,1,2),plot(tt,p_actual,'-r.',tt,z_t,'-k.', tt,xHat_t1,'-g.');
axis([0 duration -30 max(p_actual)])
% Add labels to plot
legend('Actual','Measurement','Estimation')
xlabel({'Time(s)'});
ylabel({'Position(m)'});
title({'Path Tracking with Kalman Filter'});
