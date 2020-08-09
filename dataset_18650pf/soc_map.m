%% Mapping SOC with OCV
% Note: Working with 25 degree dataset
% Load dataset
load('/home/mmoya/Projects/bms/simulations/dataset_18650pf/25degC/5 pulse disch/03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat');
min_ah = -1*min(meas.Ah)
soc = (meas.Ah + min_ah)/min_ah;
max_index = 102704;
step = 1830;

