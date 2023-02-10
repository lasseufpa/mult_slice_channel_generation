function reshaped_positions = reshape_positions (positions, n_step, speed_per_ue, directions, ue_height, n_ues)

	reshaped_positions = reshape([reshape(positions(n_step-1,1,:), 1, 2)+speed_per_ue.*cos(directions); reshape(positions(n_step-1,2,:),1,2)+speed_per_ue.*sin(directions); repmat(ue_height, 1, n_ues)], 1, 3, n_ues);

end