folder_path = '/home/mmoya/Projects/bms/simulations/dataset_18650pf/';
file_paths = [
    "training_data_25.mat"
    "training_data_25_awgn.mat" 
    "training_data_25_awg_gain_A.mat" 
    "training_data_25_awg_gainneg_A.mat" 
    "training_data_25_awg_off_V.mat" 
    "training_data_25_awg_offneg_V.mat"
    "training_data_25_awg_off_T.mat" 
    "training_data_25_awg_offneg_T.mat"
    "training_data_25_awg_off_A.mat" 
    "training_data_25_awg_offneg_A.mat"
    "training_data_25_gain_A.mat"
    "training_data_25_gainneg_A.mat"
    "training_data_25_off_A.mat"
    "training_data_25_off_T.mat" 
    "training_data_25_off_V.mat" 
    "training_data_25_offneg_A.mat"
    "training_data_25_offneg_T.mat" 
    "training_data_25_offneg_V.mat"
];

buffer_voltage = [];
buffer_avg_voltage = [];
buffer_current = [];
buffer_avg_current = [];
buffer_temp = [];
buffer_soc = [];

for i = 1:length( file_paths)    
    buffer = load(folder_path + file_paths(i));
    buffer_voltage = [buffer_voltage; voltage];
    buffer_avg_voltage = [buffer_avg_voltage; avg_voltage];
    buffer_current = [buffer_current; current];
    buffer_avg_current = [buffer_avg_current; avg_current];
    buffer_temp = [buffer_temp; temp];
    buffer_soc = [buffer_soc; soc];
end
 
voltage = buffer_voltage;
current = buffer_current;
avg_voltage = buffer_avg_voltage;
avg_current = buffer_avg_current;
temp = buffer_temp;
soc = buffer_soc;

save('training_data_nn_25', 'voltage', 'avg_voltage', 'current', 'avg_current', 'temp', 'soc');
