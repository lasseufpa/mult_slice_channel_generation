addpath(genpath(pwd));
rng(10);										% Constant seed

config = config_simu();

s = qd_simulation_parameters;                           % New simulation parameters
s.sample_density = config.sample_density;                                 % 2.5 samples per half-wavelength
s.center_frequency = config.center_frequency;								% Center frequency at 2.6 GHz
s.use_absolute_delays = config.use_absolute_delays;                              % Include delay of the LOS path
s.show_progress_bars = config.show_progress_bars;                               % progress bars

% Removing previous simulation folders
try
    warning('off', 'MATLAB:RMDIR:RemovedFromPath');
    rmdir("results/layout/ep_*", 's');
    rmdir("results/channel/ep_*", 's');
    rmdir("results/freq_channel/ep_*", 's');
catch ERROR
    % Do nothing
end

for episode=0:(config.num_episodes-1) % For each episode
    % Read UEs information from sixg_radio_mgmt simulator
    file = load(strjoin([config.root_path_velocities, "ep_", num2str(episode),".mat"], ''));
    speed_change_steps = file.speed_change_steps;
    ues_velocities = file.ues_velocities;

    fprintf(['\n\n\n############# Episode ', num2str(episode), '#############\n'])
    
    % Create folders
    mkdir(['results/layout/ep_', num2str(episode)]);
    mkdir(['results/channel/ep_', num2str(episode)]);
    mkdir(['results/freq_channel/ep_', num2str(episode)]);
    
    % Tracks
    tracks = create_tracks(config.n_ues, config.ue_height, config.max_bs_radius, config.min_dist_ue_bs, config.sampling_frequency, config.turn_time, config.total_simu_time, config.prob_turn, speed_change_steps, ues_velocities);

    % Antennas
    [tx_antenna, rx_antenna] = create_antennas(s.center_frequency, config.tx_antenna_type);

    % Layout
    layout = qd_layout.generate('hexagonal', config.num_cells, config.inter_site_distance, tx_antenna, config.num_sectors);
    layout.simpar = s;
    layout.no_rx = config.n_ues; 
    layout.rx_position = [tracks(:).initial_position];
    for ue_idx=1:config.n_ues
        layout.rx_track(ue_idx).positions = tracks(ue_idx).positions;
        layout.rx_track(ue_idx).no_segments = tracks(ue_idx).no_segments;
        layout.rx_track(ue_idx).segment_index = tracks(ue_idx).segment_index;
        layout.rx_track(ue_idx).calc_orientation;
    end
    layout.rx_array = rx_antenna;

    % config.scenario
    layout.set_scenario(config.scenario);

    % Plot track
    if config.plot_track
        fig_tracks = layout.visualize([],[],0,1);
        saveas(fig_tracks, ['results/layout/ep_', episode,'/tracks.png']);
    end

    % Calculate the beam footprint
    if config.plot_beam_footprint
        set(0,'DefaultFigurePaperSize',[14.5 7.8])              % Adjust paper size for plot
        [map,x_coords,y_coords]=layout.power_map(strcat(config.scenario,'_LOS'),'quick',10,-1e3,1e3,-1e3,1e3);
        cell_value = map(1,1);
        size_map = size(cell_value{:}(:,:,1,1), 1);
        P = zeros(config.num_cells, config.num_sectors, size_map, size_map, 1);

        for cell_idx=1:config.num_cells
            for sector=1:config.num_sectors
                cell_value = map(1,cell_idx);
                P(cell_idx, sector, :, :) = cell_value{:}(:,:,1,sector);
            end
        end

        P_sum = 10*log10( squeeze(sum(sum(P, 1), 2)) ) + 50;
        fig_power_map = layout.visualize([1:config.num_cells],[],0,1);                                   % Plot layout
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
    [channels, builder] = layout.get_channels();

    target_cell_power = zeros(config.n_ues, 1, config.num_sectors, config.number_subcarriers, config.sampling_frequency*config.total_simu_time);
    intercell_interference = zeros(config.n_ues, 1, config.num_sectors, config.number_subcarriers, config.sampling_frequency*config.total_simu_time);
    for ch_idx = 1:(config.num_cells*config.n_ues)
        channels(ch_idx).mat_save(['results/channel/ep_', num2str(episode),'/', channels(ch_idx).name, '.mat'])
        freq_channel = channels(ch_idx).fr(config.bandwidth, config.number_subcarriers);
        ue_id = str2num(channels(ch_idx).name(10:13));
        if contains(channels(ch_idx).name, "Tx0001")
           target_cell_power(ue_id,:,:,:,:) = reshape(freq_channel, [1, size(freq_channel)]);
        else
            intercell_interference(ue_id,:,:,:,:) = intercell_interference(ue_id,:,:,:,:) + reshape(freq_channel, [1, size(freq_channel)]);
        end
    end
    
    target_cell_power = abs(target_cell_power).^2;
    intercell_interference = abs(intercell_interference).^2;
    
    if config.num_sectors == 1
        save(['results/freq_channel/ep_', num2str(episode),'/target_cell_power.mat'], 'target_cell_power', '-v7.3');
    else
        save(['results/freq_channel/ep_', num2str(episode),'/intercell_interference.mat'], 'intercell_interference', '-v7.3');
    end
end
