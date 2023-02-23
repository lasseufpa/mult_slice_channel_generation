addpath(genpath(pwd));
rng(10);										% Constant seed

n_ues = 1;
ue_height = 1.5;
max_bs_radius = 500;
min_dist_ue_bs = 10;
sampling_frequency = 1000;
turn_time = 1;
total_simu_time = 1;
prob_turn = 0.5;
speed_change_steps = [5];
speeds = repmat(1000, size(speed_change_steps)(2)+1, n_ues); # Info from sixg_radio_mgmt 
% speeds(2, 3) = 0; # Stopping MT 3 at step 5
scenario = "3GPP_38.901_UMa";
plot_track = false
plot_beam_footprint = false

s = qd_simulation_parameters;                           % New simulation parameters
s.sample_density = 1.2;                                 % 2.5 samples per half-wavelength
s.center_frequency = 2.6e9;								# Center frequency at 2.6 GHz
s.use_absolute_delays = 1;                              % Include delay of the LOS path
s.show_progress_bars = 1;                               % progress bars

# Tracks
tracks = create_tracks(n_ues, ue_height, max_bs_radius, min_dist_ue_bs, sampling_frequency, turn_time, total_simu_time, prob_turn, speed_change_steps, speeds);

# Antennas
[tx_antenna, rx_antenna] = create_antennas(s.center_frequency);

# Layout
layout = qd_layout.generate("regular", 7, 1000, tx_antenna);
layout.simpar = s;
layout.no_rx = n_ues; 
layout.rx_position = [tracks(:).initial_position];
for ue_idx=1:n_ues
	layout.rx_track(ue_idx).positions = tracks(ue_idx).positions;
	layout.rx_track(ue_idx).no_segments = tracks(ue_idx).no_segments;
	layout.rx_track(ue_idx).segment_index = tracks(ue_idx).segment_index;
	layout.rx_track(ue_idx).calc_orientation;
end
layout.rx_array = rx_antenna;

# Scenario
layout.set_scenario(scenario);

# Plot track
if plot_track
	fig_tracks = layout.visualize([],[],0,1);
	saveas(fig_tracks, "results/layout/tracks.png");
end

% Calculate the beam footprint
if plot_beam_footprint
	set(0,'DefaultFigurePaperSize',[14.5 7.8])              % Adjust paper size for plot
	[map,x_coords,y_coords]=layout.power_map(strcat(scenario,"_LOS"),'quick',10,-1e3,1e3,-1e3,1e3);
	P = zeros(7, 3, size(map(1,1){:}(:,:,1,1))(1), size(map(1,1){:}(:,:,1,1))(1));

	for cell_idx=1:7
		for sector=1:3
			P(cell_idx, sector, :, :) = map(1,cell_idx){:}(:,:,1,sector);
		end
	end

	P_sum = 10*log10( squeeze(sum(sum(P, 1), 2)) ) + 50;
	fig_power_map = layout.visualize([1:7],[],0,1);                                   % Plot layout
	hold on
	imagesc( x_coords, y_coords, P_sum );                       % Plot the received power
	hold off
	colorbar('South')                                       % Show a colorbar
	colmap = colormap;
	colormap( colmap*0.5 + 0.5 );                           % Adjust colors to be "lighter"
	axis equal
	set(gca,'layer','top')                                  % Show grid on top of the map
	title('Beam footprint in dBm');                         % Set plot title
	saveas(fig_power_map, "results/layout/power_map.png");
end

# Builder
builder = layout.init_builder();
gen_parameters(builder);
channels = get_channels(builder);

for ch_idx = 1:size(channels)(2)
	channels(ch_idx).mat_save([channels(ch_idx).name, ".mat"])
end
disp("Break")