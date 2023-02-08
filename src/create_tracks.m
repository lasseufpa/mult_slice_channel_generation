function track = create_tracks(n_ues, ue_height, max_bs_radius, min_dist_ue_bs, sampling_frequency, turn_time, total_simu_time)
	# n_ue: int
	# ue_height: meters
	# max_bs_radius: meters
	# min_dist_ue_bs: meters
	# sampling_frequency: Hz
	# turn_time: seconds
	# total_simu_time: seconds

	tracks(n_ues) = qd_track;

	# Set initial positions
	mag = randi([min_dist_ue_bs, max_bs_radius], n_ues, 1);
	angle_dir = rand(n_ues,1)*2*pi;
	initial_positions = [(mag.*cos(angle_dir))'; (mag.*sin(angle_dir))'; repmat(ue_height, 1, n_ues)]
	for ue_idx=1:n_ues
		tracks(ue_idx).initial_position(:) = initial_positions(:,ue_idx);
	end

	# Considering a constant speed per UE
	speed_per_ue = [1, 1] # m/s

	# Calculating new position on every 1 milisecond but turning directions in each 1 second
	total_steps = sampling_frequency * total_simu_time 

	l = qd_layout;
	l.no_rx = n_ues; 
	l.rx_position = [tracks(:).initial_position]
	l.visualize([],[],0); 

	disp("test")
end