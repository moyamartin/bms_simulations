% Load A, B, C, D matrices
load('Juego_de_Matrices_A_B_C_D_ver_0.1.mat')
load('Juego_de_parametros_R_C_corregidos')
load('OCV_VS_SOC_01C.mat')
SOC_01C = SOC_01C - min(SOC_01C);
SOC_01C = SOC_01C/max(SOC_01C);
OCV_lutable = zeros(length(SOC_lutable), 1);
for i = 1:length(SOC_lutable)
    index = find_closest_value(SOC_lutable(i), SOC_01C);
    OCV_lutable(i) = OCV_01C(index);
end