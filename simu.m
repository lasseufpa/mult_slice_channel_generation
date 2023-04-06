addpath(genpath(pwd));
rng(10);										% Constant seed

scenario_name = "scenario_1";
root_path_velocities = ["../intent_radio_sched_multi_bs/associations/data/", scenario_name,"/"];
num_episodes = 10;
n_ues = 100;
ue_height = 1.5;
max_bs_radius = 500;
min_dist_ue_bs = 10;
sampling_frequency = 1000;
bandwidth = 100e6; % Hz
number_subcarriers = 135;
thermal_noise_power = 10e-14;
transmission_power = 0.1;  % 0.1 Watts = 20 dBm
turn_time = 1;
total_simu_time = 10;
num_sectors = 1;
num_cells = 7;
tx_antenna_type = 'omni';
inter_site_distance = 1000;
prob_turn = 0.5;
scenario = '3GPP_38.901_UMa';
plot_track = false;
plot_beam_footprint = false;

s = qd_simulation_parameters;                           % New simulation parameters
s.sample_density = 1.2;                                 % 2.5 samples per half-wavelength
s.center_frequency = 2.6e9;								% Center frequency at 2.6 GHz
s.use_absolute_delays = 1;                              % Include delay of the LOS path
s.show_progress_bars = 1;                               % progress bars

% Removing previous simulation folders
try
    warning('off', 'MATLAB:RMDIR:RemovedFromPath');
    rmdir("results/layout/ep_*", 's');
    rmdir("results/channel/ep_*", 's');
    rmdir("results/freq_channel/ep_*", 's');
catch ERROR
    % Do nothing
end

for episode=1:num_episodes % For each episode
    % Read UEs information from sixg_radio_mgmt simulator
    file = load(strjoin([root_path_velocities, "ep_", num2str(episode),".mat"], ''));
    speed_change_steps = file.speed_change_steps;
    ues_velocities = file.ues_velocities;

    fprintf(['\n\n\n############# Episode ', num2str(episode), '#############\n'])
    
    % Create folders
    mkdir(['results/layout/ep_', num2str(episode)]);
    mkdir(['results/channel/ep_', num2str(episode)]);
    mkdir(['results/freq_channel/ep_', num2str(episode)]);
    
    % Tracks
    tracks = create_tracks(n_ues, ue_height, max_bs_radius, min_dist_ue_bs, sampling_frequency, turn_time, total_simu_time, prob_turn, speed_change_steps, ues_velocities);

    % Antennas
    [tx_antenna, rx_antenna] = create_antennas(s.center_frequency, tx_antenna_type);

    % Layout
    layout = qd_layout.generate('hexagonal', num_cells, inter_site_distance, tx_antenna, num_sectors);
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

    % Scenario
    layout.set_scenario(scenario);

    % Plot track
    if plot_track
        fig_tracks = layout.visualize([],[],0,1);
        saveas(fig_tracks, ['results/layout/ep_', episode,'/tracks.png']);
    end

    % Calculate the beam footprint
    if plot_beam_footprint
        set(0,'DefaultFigurePaperSize',[14.5 7.8])              % Adjust paper size for plot
        [map,x_coords,y_coords]=layout.power_map(strcat(scenario,'_LOS'),'quick',10,-1e3,1e3,-1e3,1e3);
        cell_value = map(1,1);
        size_map = size(cell_value{:}(:,:,1,1), 1);
        P = zeros(num_cells, num_sectors, size_map, size_map, 1);

        for cell_idx=1:num_cells
            for sector=1:num_sectors
                cell_value = map(1,cell_idx);
                P(cell_idx, sector, :, :) = cell_value{:}(:,:,1,sector);
            end
        end

        P_sum = 10*log10( squeeze(sum(sum(P, 1), 2)) ) + 50;
        fig_power_map = layout.visualize([1:num_cells],[],0,1);                                   % Plot layout
        hold on
        imagesc( x_coords, y_coords, P_sum );                       % Plot the received power
        hold off
        colorbar('South')                                       % Show a colorbar
        colmap = colormap;
        colormap( colmap*0.5 + 0.5 );                           % Adjust colors to be "lighter"
        axis equal
        set(gca,'layer','top')                                  % Show grid on top of the map
        title('Beam footprint in dBm');                         % Set plot title
        saveas(fig_power_map, ['results/layout/ep_', num2str(episode),'/power_map.png']);
    end

    % Layout channel generation
    channels = layout.get_channels();

    target_cell_power = zeros(n_ues, 1, num_sectors, number_subcarriers, sampling_frequency*total_simu_time);
    intercell_interference = zeros(n_ues, 1, num_sectors, number_subcarriers, sampling_frequency*total_simu_time);
    for ch_idx = 1:size(channels, 2)
        channels(ch_idx).mat_save(['results/channel/ep_', num2str(episode),'/', channels(ch_idx).name, '.mat'])
        freq_channel = channels(ch_idx).fr(bandwidth, number_subcarriers);
        ue_id = str2num(channels(ch_idx).name(10:13));
        if contains(channels(ch_idx).name, "Tx0001")
           target_cell_power(ue_id,:,:,:,:) = reshape(freq_channel, [1, size(freq_channel)]);
        else
            intercell_interference(ue_id,:,:,:,:) = intercell_interference(ue_id,:,:,:,:) + reshape(freq_channel, [1, size(freq_channel)]);
        end
    end
    
    if num_sectors == 1
        spectral_efficiencies_per_rb = log2(1 + (transmission_power/number_subcarriers)*(abs(target_cell_power).^2)./(abs(intercell_interference).^2 + thermal_noise_power));
        save(['results/freq_channel/ep_', num2str(episode),'/spectral_efficiencies_per_rb.mat'], 'spectral_efficiencies_per_rb');
    else
        save(['results/freq_channel/ep_', num2str(episode),'/intercell_interference.mat'], 'intercell_interference');
    end
end