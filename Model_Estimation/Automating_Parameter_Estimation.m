%% Load data

% Load data set experimental data

at25degC_5Pulse_HPPC_Pan18650PF = ['..\dataset_18650pf\25degC\5 pulse disch\03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat'];
load(at25degC_5Pulse_HPPC_Pan18650PF);

Current = meas.Current;
Voltage = meas.Voltage;
Time = meas.Time;

%% Rescue flanks positions

% Rescato las posiciones del vector Current donde hay flancos.
flancos = flanks(Current, 50);

i = 1;
for( n = 1 : length(flancos) )

    if(flancos(n) == 1)
        index(i).s = n; %index(i).Start
    end
    
    if (flancos(n) == - 1)
        index(i).e = n; %index(i).End
        i = i+1;
    end
    
end


%% Selecting the Number of R-C Branches

% Tomo el n semiperiodo de relajación para ajustar una curva
% polinomial y decidir que orden utilizar.
n = 10;
sample_v = Voltage(index(n).s : index(n).e);
sample_time = Time (index(n).s : index(n).e);
plot(sample_time,sample_v)

% Fit: 'Eq_RC_Circuit'.
[xData, yData] = prepareCurveData( sample_time, sample_v );

% Set up fittype and options.
ft = fittype( 'exp2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Normalize = 'on';
opts.StartPoint = [4.0866 -1.1738e-05 -0.00080023 -3.5629];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit vs data and conclude.
figure( 'Name', 'exp orden 2' );
title('Curve fit to determine number of R-C branches')
h = plot( fitresult, xData, yData );
legend( h, 'experimental data', 'exp2 aproximation', 'Location', 'NorthEast' );
xlabel time
ylabel Voltage
grid on

%%

