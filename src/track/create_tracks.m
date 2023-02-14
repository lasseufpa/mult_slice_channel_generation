function tracks = create_tracks(n_ues, ue_height, max_bs_radius, min_dist_ue_bs, sampling_frequency, turn_time, total_simu_time, prob_turn, speed_change_steps, speeds)
	# n_ue: int
	# ue_height: meters
	# max_bs_radius: meters
	# min_dist_ue_bs: meters
	# sampling_frequency: Hz
	# turn_time: seconds
	# total_simu_time: seconds
	# prob_turn: rate [0,1]
	# speed_change_steps: Array containing step numbers that the speed should change to MT
	# speeds: Matrix containing speed values for each MT in each speed_change_step (dimension = speed_change_steps x n_ue)

	tracks(n_ues) = qd_track;

	# Set initial positions
	mag = randi([min_dist_ue_bs, max_bs_radius], 1, n_ues);
	angle_dir = rand(1,n_ues)*2*pi;
	initial_positions = [mag.*cos(angle_dir); mag.*sin(angle_dir); repmat(ue_height, 1, n_ues)];

	# Considering a constant speed per UE
	# TODO read velocities from external file
	speed_per_ue = speeds(1,:); # m/s
	if size(speed_per_ue)(2)~=n_ues
		error("Number of UEs differ from the number of velocities provided.");
	end

	# Calculating new position on every 1/sampling_rate seconds but turning directions in each turn_time seconds
	total_steps = round(sampling_frequency * total_simu_time);
	steps_to_turn = round(turn_time * sampling_frequency);
	directions = angle_dir;
	positions = zeros(total_steps, 3, n_ues);
	positions(1, :, :) = zeros(size(initial_positions)); # First position is the initial position
	for n_step=2:total_steps
		fprintf("Track Step %d \n", n_step)

		# Change directions in each steps_to_turn
		if mod(n_step,steps_to_turn)==0 & rand()<prob_turn
			directions = rand(1,n_ues)*2*pi;
		end

		# Change speed in the steps defined in speed_change_steps
		if ismember(n_step, speed_change_steps)
			speed_per_ue = speeds(find(speed_change_steps==n_step)(1)+1, :);
		end

		[positions(n_step, :, :), directions] = move_ues(positions, initial_positions, n_step, speed_per_ue, directions, ue_height, n_ues, max_bs_radius, min_dist_ue_bs);
	end

	for ue_idx=1:n_ues
		tracks(ue_idx).initial_position = initial_positions(:,ue_idx);
		tracks(ue_idx).positions = (positions(:, :, ue_idx))';
	end
end