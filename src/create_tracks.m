function tracks = create_tracks(n_ues, ue_height, max_bs_radius, min_dist_ue_bs, sampling_frequency, turn_time, total_simu_time)
	# n_ue: int
	# ue_height: meters
	# max_bs_radius: meters
	# min_dist_ue_bs: meters
	# sampling_frequency: Hz
	# turn_time: seconds
	# total_simu_time: seconds

	tracks(n_ues) = qd_track;

	# Set initial positions
	mag = randi([min_dist_ue_bs, max_bs_radius], 1, n_ues);
	angle_dir = rand(1,n_ues)*2*pi;
	initial_positions = [mag.*cos(angle_dir); mag.*sin(angle_dir); repmat(ue_height, 1, n_ues)];

	# Considering a constant speed per UE
	# TODO read velocities from external file
	speed_per_ue = [100, 100]; # m/s
	if size(speed_per_ue)(2)~=n_ues
		error("Number of UEs differ from the number of velocities provided.");
	end

	# Calculating new position on every 1/sampling_rate seconds but turning directions in each turn_time seconds
	total_steps = sampling_frequency * total_simu_time;
	directions = angle_dir;
	positions = zeros(total_steps, 3, n_ues);
	positions(1, :, :) = initial_positions; # First position is the initial position
	for n_step=2:total_steps
		fprintf("Step %d \n", n_step)
		positions(n_step, :, :) = reshape_positions(positions, n_step, speed_per_ue, directions, ue_height, n_ues);
	end

	for ue_idx=1:n_ues
		tracks(ue_idx).initial_position = initial_positions(:,ue_idx);
		tracks(ue_idx).positions = (positions(:, :, ue_idx))';
	end

	l = qd_layout;
	l.no_rx = n_ues; 
	l.rx_position = [tracks(:).initial_position];
	for n_ue=1:n_ues
		l.rx_track(n_ue).positions = tracks(n_ue).positions
		l.rx_track(n_ue).calc_orientation;
	end
	l.visualize([],[],0); 

	disp("test")
end