folder_path = '/home/mmoya/Projects/bms/simulations/dataset_18650pf/';

file_paths = [
    "25degC/Drive Cycles/03-20-17_05.56 25degC_HWFTa_Pan18650PF.mat"
    "25degC/Drive Cycles/03-20-17_19.27 25degC_HWFTb_Pan18650PF.mat"
    "25degC/Drive Cycles/03-20-17_01.43 25degC_US06_Pan18650PF.mat"
    "25degC/C20 OCV and 1C discharge tests_start_of_tests/05-08-17_13.26 C20 OCV Test_C20_25dC.mat"
    %"10degC/Drive Cycles/03-27-17_09.06 10degC_US06_Pan18650PF.mat" 
    %"10degC/Drive Cycles/03-27-17_09.06 10degC_HWFET_Pan18650PF.mat"
    %"0degC/Drive Cycles/06-02-17_04.58 0degC_US06_Pan18650PF.mat"
    %"0degC/Drive Cycles/06-02-17_10.43 0degC_HWFET_Pan18650PF.mat"
    %"-10degC/Drive Cycles/06-07-17_08.39 n10degC_HWFET_Pan18650PF.mat"
    %"-10degC/Drive Cycles/06-07-17_08.39 n10degC_US06_Pan18650PF.mat"
    %"-20degC/Drive Cycles/06-23-17_23.35 n20degC_HWFET_Pan18650PF.mat"
    %"-20degC/Drive Cycles/06-25-17_10.31 n20degC_US06_Pan18650PF.mat"
];
voltage = [];
current = [];
avg_voltage = [];
avg_current = [];
temp = [];
soc = [];

for i = 1:length(file_paths)
    buffer = load(folder_path + file_paths(i));
    voltage = buffer.meas.Voltage;
    avg_voltage = movmean(voltage, 400);
    current = buffer.meas.Current;
    avg_current = movmean(current, 400);
    temp = buffer.meas.Battery_Temp_degC;
    max_aH = -1*min(buffer.meas.Ah);
    soc = [soc; (buffer.meas.Ah + max_aH)/max_aH];
end

save('validation_data_25', 'voltage', 'avg_voltage', 'current', 'avg_current', 'temp', 'soc')
