addpath(genpath(pwd));
rng(10);										% Constant seed

n_ues = 1;
ue_height = 1.5;
max_bs_radius = 1000;
min_dist_ue_bs = 20;
sampling_frequency = 10;
turn_time = 0.1;
total_simu_time = 1;
prob_turn = 0.5;
speed_change_steps = [5];
speeds = repmat(3, size(speed_change_steps)(2)+1, n_ues); # Info from sixg_radio_mgmt 
% speeds(2, 3) = 0; # Stopping MT 3 at step 5
scenario = "3GPP_38.901_UMa";

tracks = create_tracks(n_ues, ue_height, max_bs_radius, min_dist_ue_bs, sampling_frequency, turn_time, total_simu_time, prob_turn, speed_change_steps, speeds);

s = qd_simulation_parameters;                           % New simulation parameters
s.center_frequency = 2.53e9;                            % 2.53 GHz carrier frequency
s.sample_density = 1.2;                                 % 2.5 samples per half-wavelength
s.use_absolute_delays = 1;                              % Include delay of the LOS path
s.show_progress_bars = 1;                               % progress bars

l = qd_layout(s);
l.no_rx = n_ues; 
l.rx_position = [tracks(:).initial_position];
for n_ue=1:n_ues
	l.rx_track(n_ue).positions = tracks(n_ue).positions;
	l.rx_track(n_ue).calc_orientation;
end
l.visualize;

# Basestation cell area (min and max distance)
hold on
th = 0:pi/50:2*pi;
x=0;
y=0;
xunit = max_bs_radius * cos(th) + x;
yunit = max_bs_radius * sin(th) + y;
h = plot(xunit, yunit);
xunit = min_dist_ue_bs * cos(th) + x;
yunit = min_dist_ue_bs * sin(th) + y;
h = plot(xunit, yunit);  
hold off

# Scenario
l.set_scenario(scenario);

# Antennas
l.simpar.center_frequency = 2.4e9; # GHz 
tx_antenna_3gpp_macro.phi_3dB = 70;
tx_antenna_3gpp_macro.theta_3dB = 10;
tx_antenna_3gpp_macro.rear_gain = 25;
tx_antenna_3gpp_macro.electric_tilt = 15;
tx_array_3gpp_macro = qd_arrayant('3gpp-macro', tx_antenna_3gpp_macro.phi_3dB, tx_antenna_3gpp_macro.theta_3dB, tx_antenna_3gpp_macro.rear_gain, tx_antenna_3gpp_macro.electric_tilt);
tx_array_3gpp_macro.element_position(1, :) = 0; % Distance from pole
tx_array_3gpp_macro.name = '3gpp-macro';
l.tx_array = tx_array_3gpp_macro;
for ue_idx=1:n_ues
	l.rx_array(ue_idx).center_frequency = l.simpar.center_frequency;
end
l.rx_array = qd_arrayant('omni');

% Calculate the beam footprint
set(0,'DefaultFigurePaperSize',[14.5 7.8])              % Adjust paper size for plot
[map,x_coords,y_coords]=l.power_map(strcat(scenario,"_LOS"),'quick',10,-1e3,1e3,-1e3,1e3);
P = 10*log10( map{:}(:,:,1) ) + 50;                     % RX copolar power @ 50 dBm TX power
l.visualize([],[],0);                                   % Plot layout
axis([-1e3, 1e3,-1e3,1e3]);                              % Axis
hold on
imagesc( x_coords, y_coords, P );                       % Plot the received power
hold off

colorbar('South')                                       % Show a colorbar
colmap = colormap;
colormap( colmap*0.5 + 0.5 );                           % Adjust colors to be "lighter"
axis equal
% set(gca,'XTick',(-5:5)*1e3);
% set(gca,'YTick',(-5:5)*1e3);
% caxis([-150,-90])
set(gca,'layer','top')                                  % Show grid on top of the map
title('Beam footprint in dBm');                         % Set plot title

# Channels
% l.update_rate = 1/sampling_frequency;
channels = l.get_channels;
disp("Break")