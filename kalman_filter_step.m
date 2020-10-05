function [updated_kalman_filter_struct] = ...
    kalman_filter_step(kalman_filter_struct, measurement)
% KALMAN_FILTER_STEP Calculates a step of the kalman filter
%
%   This Matlab function of the Kalman filter is based on the following
%   blog https://www.kalmanfilter.net/multiSummary.html
% usage:
%	kalman_filter_step(kalman_filter_struct, measurement)
%
% args:
%	measurement: the measured state of the system.
%		i.e. if we are estimating the trayectory of a canon ball, in this case
%		would be the position x and y of the bullet
%	kalman_filter_struct: structure that holds all the matrices related to the
%	simulated kalman filter

%% Copy current kalman_filter_struct
% Idk how to do this in a better way, so I'll blame matlab for until
% further notice :sweat_smile

updated_kalman_filter_struct = kalman_filter_struct;

%% State extrapolation predict %%
%
%   x_{n+1, n} = F*x_{n, n} + G*u_{n, n}
%
updated_kalman_filter_struct.x_pred = updated_kalman_filter_struct.F* ...
	updated_kalman_filter_struct.x_act + updated_kalman_filter_struct.G* ...
	updated_kalman_filter_struct.u;

%% Covariance Extrapolation Predict %%
%
%   P_{n+1, n} = F*P_{n, n}*F' + Q
%

updated_kalman_filter_struct.P_pred = updated_kalman_filter_struct.F* ...
	updated_kalman_filter_struct.P_act*updated_kalman_filter_struct.F' + ...
	updated_kalman_filter_struct.Q;

%% Kalman Gain Update %%
%
%   K = P_{n, n-1}*H'(H*P_{n, n-1}*H' + R_n)^-1
%

updated_kalman_filter_struct.K = updated_kalman_filter_struct.P_pred*...
	updated_kalman_filter_struct.H'*inv(updated_kalman_filter_struct.H* ...
	updated_kalman_filter_struct.P_pred*updated_kalman_filter_struct.H' ...
    + updated_kalman_filter_struct.R);

%% Update Estimate with Measurement %%
%
%   x_{n, n} = X_{n, n-1} + K_n*(Z_n - H*H*x_{n, n-1})
%

updated_kalman_filter_struct.x_act = updated_kalman_filter_struct.x_pred + ...
	updated_kalman_filter_struct.K* ...
    (updated_kalman_filter_struct.H*measurement - ...
    updated_kalman_filter_struct.H*updated_kalman_filter_struct.x_pred);

%% Covariance Matrix Update %%
%
%   P_{n, n} = (I - K*H)P_{n, n-1}*(I - K*H)' + K*R*K'
%

i_minus_k_times_h = (updated_kalman_filter_struct.I - ...
	updated_kalman_filter_struct.K*updated_kalman_filter_struct.H);
updated_kalman_filter_struct.P_act = i_minus_k_times_h* ...
    updated_kalman_filter_struct.P_pred*i_minus_k_times_h' + ...
    updated_kalman_filter_struct.K*updated_kalman_filter_struct.R* ...
	kalman_filter_struct.K';
