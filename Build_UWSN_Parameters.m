function P = Build_UWSN_Parameters()
% =========================================================================
% Baseline parameter configuration for paper experiments.
%
% PARAMETER LOGIC
% 1) Scenario parameters:
%    Lx,Ly,Lz,N,Rs,Rc
%
% 2) Environmental working-condition parameters:
%    ocean current, shipping factor, wind
%
% 3) Acoustic communication parameters:
%    f, bandwidth, source level, SNR threshold
%
% 4) Optimization/model parameters:
%    objective weights, penalty coefficient
%
% IMPORTANT:
% U0, wind variation, N, Rs, Rc are baseline simulation/work-condition
% settings, not claimed as measured values from a specific sea area.
% Sensitivity studies should vary N, Rc, U0 and objective weights.
% =========================================================================

%% -------------------------- Monitoring region ----------------------------
P.Lx = 100;                  % m
P.Ly = 100;                  % m
P.Lz = 50;                   % m

P.N  = 30;                   % sensor nodes
P.Rs = 20;                   % effective sensing radius, m
P.Rc = 40;                   % maximum allowed communication distance, m

%% ---------------------------- Time model ---------------------------------
P.dt = 10;                 % time step (s)
P.K = 26;                  % 0,10,...,250
P.totalTime = (P.K-1)*P.dt; % 250 s
P.time = (0:P.K-1)*P.dt;
%% -------------------------- Ocean current model --------------------------
% Low-current baseline condition for the 100 x 100 x 50 m simulation region.
P.current.U0 = 0.03;         % m/s
P.current.period = 250;      % model variation period, s
P.current.crossRatio = 0.35;
P.current.verticalRatio = 0.06;
P.current.reflectBoundary = true;

%% --------------------- Acoustic communication model ----------------------
% Literature-supported experimental communication baseline:
% center frequency = 12 kHz
% bandwidth        = 8 kHz
% source level     = 175 dB re 1 uPa @ 1 m
%
% A 10 dB SNR threshold is used as the minimum communication requirement.
P.acoustic.f_kHz = 12;               % kHz
P.acoustic.bandwidth_Hz = 8000;       % Hz
P.acoustic.SL_dB = 175;               % dB re 1 uPa @ 1 m
P.acoustic.SNRth_dB = 10;             % dB
P.acoustic.spreading_k = 1.5;         % practical spreading

%% ---------------------- Marine ambient noise -----------------------------
% s = 0.5 represents moderate shipping activity in the adopted noise model.
P.noise.shipping = 0.5;

% Baseline wind working condition.
P.noise.windMean = 5;                 % m/s
P.noise.windAmp = 2;                  % m/s

% This is a simulation disturbance timescale, not a measured weather period.
P.noise.windPeriod = 600;              % s

P.noiseLevel_dB = zeros(1,P.K);
P.windSeries = zeros(1,P.K);

for k = 1:P.K

    t = P.time(k);

    windSpeed = max(0, ...
        P.noise.windMean + ...
        P.noise.windAmp*sin(2*pi*t/P.noise.windPeriod));

    P.windSeries(k) = windSpeed;

    P.noiseLevel_dB(k) = MarineAmbientNoise( ...
        P.acoustic.f_kHz, ...
        P.acoustic.bandwidth_Hz, ...
        P.noise.shipping, ...
        windSpeed);
end

%% ------------------------- Objective weights -----------------------------
% Coverage is the primary objective.
P.w1 = 0.7;       % time-averaged 3D coverage
P.w2 = 0.1;       % time-averaged LCC connectivity
P.w3 = 0.1;       % normalized acoustic communication cost
P.w4 = 0.1;       % deployment nonuniformity

if abs(P.w1+P.w2+P.w3+P.w4-1) > 1e-12
    error('w1+w2+w3+w4 must equal 1.');
end

%% ---------------------- 3D monitoring sample grid ------------------------
P.nx = 21;
P.ny = 21;
P.nz = 11;

xg = linspace(0,P.Lx,P.nx);
yg = linspace(0,P.Ly,P.ny);
zg = linspace(0,P.Lz,P.nz);

[Xg,Yg,Zg] = ndgrid(xg,yg,zg);

P.samplePoints = [Xg(:),Yg(:),Zg(:)];
P.numSamplePoints = size(P.samplePoints,1);
end
