%% SIMULATION OF V2G PARKING
% Simulation of V2G parking exploiting the exchange of energy to the grid
% this script provide all the parameters of three cars and the data for the
% MSD quantity and cost exchanged from Terna database

% Rodolfo Saraceni 09/2021
close all;
clear all;
clc;

%% MSD QUANTITY LOAD DATA
% Ciclo per acquisire quantità e costi del MSD dai dati Terna
%Utilizza una cartella dedicata con file in formato .xls

folder = './data_MSD/aprile_2019/';
% Carico tutti i file della cartella
files = dir(strcat(folder, '*.xls'));

Qacc_TOT = zeros(0,24);
Costo_TOT = zeros(0,24);
for jj = 1:length(files)
    path = strcat(folder, files(jj).name);
    % Seleziono zona SUD
    temp1 = readmatrix(path, 'Sheet', 'Qacc_TOT', 'Range', 'D12:AA12');
    temp2 = readmatrix(path, 'Sheet', 'Costo_TOT', 'Range', 'D12:AA12');
    Qacc_TOT = vertcat(Qacc_TOT, temp1); % [MWh]
    Costo_TOT = vertcat(Costo_TOT, temp2); % [€]
end

% Calcolo media
Qacc_MEAN = mean(Qacc_TOT, 1); % [MWh]
Costo_MEAN = mean(Costo_TOT, 1); % [€]

% Costo €/MWh medio
Costo_MWh = Costo_MEAN ./ Qacc_MEAN; % [€/MWh]

%% PLOT SECTION
figure('Name', 'Profilo di potenza');
title('Profilo potenza media scambiata ad Aprile 2019');
hold on;
yyaxis left;
plot(1:24, Qacc_MEAN, 'b', 'DisplayName', 'Energia scambiata');
ylabel('MWh');
yyaxis right;
plot(1:24, Costo_MWh, 'r', 'DisplayName', 'Costo unità di energia');
ylabel('€/MWh');
hold off;
xlabel('Hours');
xlim([1 24]);
legend;
grid on;

%% SIMULINK SIMULATION PARAMETERS
grid_voltage = 230*sqrt(3); % [V] voltage grid
pun = 40; % [€/MWh] prezzo unico nazionale

tmax = 86400; % [s] tempo massimo di simulazione
sample_time = 0.0005; % [s] sample time of simulation
time_var = linspace(1, tmax, 24); % array temporale

dimn = 10;
% timestamp = sort(randi(tmax, dimn-1, 1)); % Timestamp uguale per tutte le
% auto

% CAR 1 - FIAT 500e 42kWh
timestamp_C1 = sort(randi(tmax, dimn, 1));
car1_activaction = [timestamp_C1, randi([0,1], dimn, 1)];
% car1_activaction = [timestamp, ones(1,dimn)'];
num_car1 = randi([1,50]);

% Parametri batteria
Vbn_car1 = 350; % [V] tensione nominale batteria
Ahn_car1 = 120; % [Ah] ampere-ora nominali batteria
Soc0_car1 =randi([1,100]); % [%] SOC iniziale batteria

% CAR 2 - Volkswagen ID.3 77kWh
timestamp_C2 = sort(randi(tmax, dimn, 1));
car2_activaction = [timestamp_C2, randi([0,1], dimn, 1)];
% car2_activaction = [timestamp, ones(1,dimn)'];
num_car2 = randi([1,50]);

% Parametri batteria
Vbn_car2 = 408; % [V] tensione nominale batteria
Ahn_car2 = 185; % [Ah] ampere-ora nominali batteria
Soc0_car2 = randi([1,100]); % [%] SOC iniziale batteria

% CAR 3
timestamp_C3 = sort(randi(tmax, dimn, 1));
car3_activaction = [timestamp_C3, randi([0,1], dimn, 1)];
% car3_activaction = [timestamp, ones(1,dimn)'];
num_car3 = randi([1,50]);

% Parametri batteria
Vbn_car3 = 364; % [V] tensione nominale batteria
Ahn_car3 = 66; % [Ah] ampere-ora nominali batteria
Soc0_car3 = randi([1,100]); % [%] SOC iniziale batteria

% Parametri supercap
Cap_car3_SC = 165; % [F] capacità nominale supercap
V_car3_SC = 48; % [V] tensione nominale supercap
ESR_car3_SC = 5e-3; % [ohm] Equivalent DC series resistance
Soc0_car3_SC = randi([1,100]); % [V] tensione iniziale supercap
Nseries_car3_SC = 5; % Numero di SC in serie
Nparallel_car3_SC = 1; % Numero di SC in parallelo

%% SPLIT SIMULATION LOOP
% Loop che divide la simulazione in intervalli da un'ora ciascuno salvando
% e caricando i risultati in quella successiva

T_simul = 3600; % [s] durata di ogni simulazione
T_start = 0; % Instante iniziale prima simulazione
T_end = T_simul; % Instante finale simulazione

% Disabilita il load-file per la prima simulazione
set_param('V2G_GAFER_sim', ...
    'LoadInitialState','off');

for ii = 1:(tmax/T_simul)

% Imposto i parametri per salvare i risultati della simulazione
fprintf(sprintf("Avvio simulazione numero %d ...\n",ii));
set_param('V2G_GAFER_sim', ...
    'SaveFinalState','on', ...
    'FinalStateName', 'OperationPoint', ...
    'SaveOperatingPoint','on');%, ...

% Avvia la simulazione
res = sim('V2G_GAFER_sim', 'StopTime','T_end');
OperationPoint = res.OperationPoint;

fprintf(sprintf("Completata simulazione numero %d\n",ii));
fprintf("Wait one minute...\n");
pause(60); % Stop esecuzione per un minuto
fprintf("------------------------------------------------------------\n");

% Imposto i parametri per caricare i risultati precedenti
set_param('V2G_GAFER_sim', ...
    'LoadInitialState','on', ...
    'InitialState', 'OperationPoint');

% Aggiorno gli instanti di inizio e fine della simulazione
T_start = T_end + T_simul;
T_end = T_end + T_simul;

end