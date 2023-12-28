function [reshaped_positions, directions] = move_ues (positions, initial_positions, n_step, speed_per_ue, directions, ue_height, n_ues, max_bs_radius, min_dist_ue_bs)

	[x_positions, y_positions] = polar_to_cartesian(positions, n_step, n_ues, speed_per_ue, directions);

	% Move UEs respecting the cell bounds
	for ue_idx=1:n_ues
		ue_norm = calc_ue_norm(x_positions(ue_idx), y_positions(ue_idx), initial_positions(1:2,ue_idx));
		while or(ue_norm > max_bs_radius, ue_norm < min_dist_ue_bs)
			directions(ue_idx) = directions(ue_idx) + pi/4;
			[x_positions, y_positions] = polar_to_cartesian(positions, n_step, n_ues, speed_per_ue, directions);
			ue_norm = calc_ue_norm(x_positions(ue_idx), y_positions(ue_idx), initial_positions(1:2,ue_idx));
		end
	end

	reshaped_positions = reshape([x_positions; y_positions; repmat(0, 1, n_ues)], 1, 3, n_ues);

end

function ue_norm = calc_ue_norm(x_position, y_position, initial_positions)
	ue_norm = norm([x_position+initial_positions(1), y_position+initial_positions(2)]);
end

function [x_positions, y_positions] = polar_to_cartesian(positions, n_step, n_ues, speed_per_ue, directions)
	x_positions = reshape(positions(n_step-1,1,:), 1, n_ues)+speed_per_ue.*cos(directions);
	y_positions = reshape(positions(n_step-1,2,:),1,n_ues)+speed_per_ue.*sin(directions);
end