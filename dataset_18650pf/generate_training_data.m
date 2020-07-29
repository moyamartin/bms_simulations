clear;
folder_path = '/home/mmoya/Projects/bms/simulations/dataset_18650pf/';

file_paths = [
    "25degC/Drive Cycles/03-18-17_02.17 25degC_Cycle_1_Pan18650PF.mat"
    "25degC/Drive Cycles/03-19-17_03.25 25degC_Cycle_2_Pan18650PF.mat"
    "25degC/Charges and Pauses/03-19-17_06.31 3406_Charge2.mat"
    "25degC/Charges and Pauses/03-19-17_08.08 3406_Pause3.mat"
    "25degC/Drive Cycles/03-19-17_09.07 25degC_Cycle_3_Pan18650PF.mat"
    "25degC/Charges and Pauses/03-19-17_11.59 3406_Charge3.mat"
    "25degC/Charges and Pauses/03-19-17_13.32 3406_Pause4.mat"
    "25degC/Drive Cycles/03-19-17_14.31 25degC_Cycle_4_Pan18650PF.mat"
    "25degC/Charges and Pauses/03-19-17_17.53 3406_Charge4.mat"
    "25degC/Charges and Pauses/03-20-17_00.44 3415_Pause1.mat"
    "25degC/Drive Cycles/03-21-17_00.29 25degC_UDDS_Pan18650PF.mat"
    "25degC/Charges and Pauses/03-21-17_06.44 3416_Charge3.mat"
    "25degC/Charges and Pauses/03-21-17_08.39 3416_Pause4.mat"
    "25degC/Drive Cycles/03-21-17_09.38 25degC_LA92_Pan18650PF.mat"
    "25degC/Charges and Pauses/03-21-17_13.34 3416_Charge4.mat"
    "25degC/Charges and Pauses/03-21-17_15.28 3416_Pause5.mat"
    "25degC/Drive Cycles/03-21-17_16.27 25degC_NN_Pan18650PF.mat"
    "25degC/Charges and Pauses/03-21-17_19.43 3416_Charge5.mat"
    %"10degC/Drive Cycles/03-28-17_12.51 10degC_Cycle_1_Pan18650PF.mat"
    %"10degC/Drive Cycles/03-28-17_18.18 10degC_Cycle_2_Pan18650PF.mat"
    %"10degC/Drive Cycles/04-05-17_17.04 10degC_Cycle_3_Pan18650PF.mat"
    %"10degC/Drive Cycles/04-05-17_22.50 10degC_Cycle_4_Pan18650PF.mat"
    %"10degC/Drive Cycles/03-27-17_09.06 10degC_UDDS_Pan18650PF.mat"
    %"10degC/Drive Cycles/03-27-17_09.06 10degC_LA92_Pan18650PF.mat"
    %"10degC/Drive Cycles/03-27-17_09.06 10degC_NN_Pan18650PF.mat"
    %"0degC/Drive Cycles/05-30-17_12.56 0degC_Cycle_1_Pan18650PF.mat"
    %"0degC/Drive Cycles/05-30-17_20.16 0degC_Cycle_2_Pan18650PF.mat"
    %"0degC/Drive Cycles/06-01-17_15.36 0degC_Cycle_3_Pan18650PF.mat"
    %"0degC/Drive Cycles/06-01-17_22.03 0degC_Cycle_4_Pan18650PF.mat"
    %"0degC/Drive Cycles/06-02-17_17.14 0degC_UDDS_Pan18650PF.mat"
    %"0degC/Drive Cycles/06-01-17_10.36 0degC_LA92_Pan18650PF.mat"
    %"0degC/Drive Cycles/06-01-17_10.36 0degC_NN_Pan18650PF.mat"
    %"-10degC/Drive Cycles/06-10-17_11.25 n10degC_Cycle_1_Pan18650PF.mat"
    %"-10degC/Drive Cycles/06-10-17_18.35 n10degC_Cycle_2_Pan18650PF.mat"
    %"-10degC/Drive Cycles/06-11-17_01.39 n10degC_Cycle_3_Pan18650PF.mat"
    %"-10degC/Drive Cycles/06-11-17_08.42 n10degC_Cycle_4_Pan18650PF.mat"
    %"-10degC/Drive Cycles/06-07-17_08.39 n10degC_UDDS_Pan18650PF.mat"
    %"-10degC/Drive Cycles/06-07-17_08.39 n10degC_LA92_Pan18650PF.mat"
    %"-10degC/Drive Cycles/06-14-17_13.12 n10degC_NN_Pan18650PF.mat"
    %"-20degC/Drive Cycles/06-24-17_04.29 n20degC_Cycle_1_Pan18650PF.mat"
    %"-20degC/Drive Cycles/06-24-17_11.58 n20degC_Cycle_2_Pan18650PF.mat"
    %"-20degC/Drive Cycles/06-24-17_19.29 n20degC_Cycle_3_Pan18650PF.mat"
    %"-20degC/Drive Cycles/06-25-17_03.01 n20degC_Cycle_4_Pan18650PF.mat"
    %"-20degC/Drive Cycles/06-23-17_23.35 n20degC_UDDS_Pan18650PF.mat"
    %"-20degC/Drive Cycles/06-23-17_23.35 n20degC_LA92_Pan18650PF.mat"
    %"-20degC/Drive Cycles/06-23-17_23.35 n20degC_NN_Pan18650PF.mat"
];

avg_sample = 400;
voltage = [];
current = [];
avg_voltage = [];
avg_current = [];
temp = [];
soc = [];

for i = 1:length(file_paths)
    buffer = load(folder_path + file_paths(i));
    voltage_augmented = awgn(buffer.meas.Voltage, 10);
    voltage = [voltage; voltage_augmented];
    avg_voltage = [avg_voltage; movmean(voltage_augmented, avg_sample)];
    current_augmented = awgn(buffer.meas.Current, 10)*.97; 
    current = [current; current_augmented];
    avg_current = [avg_current; movmean(current_augmented, avg_sample)];
    temp_augmented = awgn(buffer.meas.Battery_Temp_degC, 10);
    temp = [temp; temp_augmented];
    if contains(file_paths(i), 'Drive Cycles')
        max_ah = -1*min(buffer.meas.Ah);
        soc = [soc; (buffer.meas.Ah + max_ah)/max_ah];
    elseif contains(file_paths(i), '_Charge')
        max_ah = max(buffer.meas.Ah);
        soc = [soc; buffer.meas.Ah/max_ah];
    else
        soc = [soc; (buffer.meas.Ah + 1)];
    end
end

save('training_data_25_awg_gainneg_A', 'voltage', 'avg_voltage', 'current', 'avg_current', 'temp', 'soc')
