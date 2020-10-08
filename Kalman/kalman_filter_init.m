function [init_kalman_filter] = ...
    kalman_fiter_init(kalman_filter_struct, n_states, n_input)
% KALMAN_FILTER_INIT Generates the rest of the undefined matrices of the kalman
% filter structure
%
% usage:
% 	kalman_filter_init(kalman_filter_struct, n_states, n_input, n_outputs)
%
% args:
%	kalman_filter_struct: struct that holds all the matrices of the kalman
%	filter
%	n_states: number of states that the linearized system has
%	n_input: number of observable variables of the system
%	n_outputs: number of outputs of the system

init_kalman_filter = kalman_filter_struct;

% Initialize x_pred matrix with zeros
init_kalman_filter.x_pred = zeros(n_states, 1);

% Initialize p_pred matrix with zeros
init_kalman_filter.P_pred = zeros(n_states, n_states);

% Initialize Kalman gain matrix
init_kalman_filter.K = zeros(n_states, n_input);

% Initialize identity matrix
init_kalman_filter.I = eye(n_states);
