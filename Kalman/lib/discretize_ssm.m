load('ocv_vs_soc')
load('Juego_de_Matrices_A_B_C_D_ver_0.1.mat')
C = zeros(length(OCV_lutable), 3);
for i=1:length(OCV_lutable)
    C(i, :) = [-1, -1, OCV_lutable(i)/SOC_lutable(i)];
end
Ts = 0.1;
A = eye(3) + A*Ts;
B(3, 1, :) = 1/(2.9*3600);
B = B*Ts;
save(['battery_state_space_model_' num2str(Ts) '.mat'], 'A', 'B', 'C', 'D')
