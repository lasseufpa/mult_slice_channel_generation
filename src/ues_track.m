% close all
% clear all

rng(10)													% Constant seed

% s = qd_simulation_parameters;                           % Set up simulation parameters
% s.show_progress_bars = 1;                               % Show progress bars
% s.center_frequency = 2.53e9;                            % Set center frequency
% s.samples_per_meter = 1;                                % 1 sample per meter
% s.use_absolute_delays = 1;                              % Include delay of the LOS path

% l = qd_layout(s);                                       % Create new QuaDRiGa layout
% l.no_rx = 1;                                          % Set number of MTs
% l.randomize_rx_positions( 1000 , 1.5 , 1.5 , 500 );      % 200 m radius, 1.5 m Rx height
% l.visualize([], [], 0)
% print("Test")
create_tracks(1, 1.5, 1000, 200, 10, 1, 1)
print("Test")