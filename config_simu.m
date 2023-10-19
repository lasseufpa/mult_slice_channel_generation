function [config] = config_simu()

%% Simulation Parameters
config.scenario_name = "mult_slice";
config.root_path_velocities = ["../intent_radio_sched_multi_bs/associations/data/", config.scenario_name,"/"];
config.num_episodes = 1;

%% Debug Parameters 
config.plot_track = false; % Plot UEs positions
config.plot_beam_footprint = false; % Plot beam footprint
config.show_progress_bars = true;

%% Frequency Parameters
config.center_frequency        = 2.6e9;                                         % Carrier Frequency [Hz]
config.bandwidth          = 100e6;                                        % Channel Bandwidth [Hz]
config.subcarrier_idx      = 0.5;                                          % Subcarrier used in Fourier Transform
config.num_rbs           = 135;                                            % Number of Used Resource Blocks
config.num_total_rbs      = 135;                                          % Total Number of Resource Blocks
config.num_subcarrier_per_rb   = 12;                                           % Number of Subcarriers per Resource Block
config.subcarrier_width    = 60e3;                                         % Subcarrier Spacing [Hz]
config.width_rb = config.subcarrier_width * config.num_subcarrier_per_rb;    % RB Bandwidth

%% Time Parameters
config.sampling_frequency = 1000;                                         
config.turn_time = 1;
config.total_simu_time = 10;
config.prob_turn = 0.5;

%% Power Parameters
%config.txPowerBS      = 36;                                               % BS transmit power
%config.txPowerPerRB = dbm2lin(config.txPowerBS)/config.numTotalOfRBs; % Power per Resource Block
%config.noiseDensity   = -174;                                             % Noise Density [dB]
%config.noiseFigure    = 9;                                                % Noise Figure [dB] Value according to LTE
%config.noisePower     = dbm2lin(config.noiseDensity + config.noiseFigure)  * config.widthRB;   % Noise Power


%% Cell Parameters
config.max_bs_radius = 500;
config.min_dist_ue_bs = 100;
config.inter_site_distance = 1000;

%% Scenario Parameters
config.scenario = '3GPP_38.901_UMa';

%% Channel Model
config.sample_density = 2.5;
config.use_absolute_delays = true;

%% BS Parameters
config.num_sectors = 1;
config.num_cells = 1;
config.tx_antenna_type = 'omni';

%% UE Parameters
config.n_ues = 25;
config.ue_height   = 1.5;                                                 % UE Height
end

