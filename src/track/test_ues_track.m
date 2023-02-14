addpath(genpath(pwd));
rng(10);										% Constant seed

n_ues = 5;
ue_height = 1.5;
max_bs_radius = 1000;
min_dist_ue_bs = 20;
sampling_frequency = 10;
turn_time = 0.1;
total_simu_time = 1;
prob_turn = 0.5;
speed_change_steps = [5];
speeds = repmat(200, size(speed_change_steps)(2)+1, n_ues); # Info from sixg_radio_mgmt 
speeds(2, 3) = 0; # Stopping MT 3 at step 5

tracks = create_tracks(n_ues, ue_height, max_bs_radius, min_dist_ue_bs, sampling_frequency, turn_time, total_simu_time, prob_turn, speed_change_steps, speeds);

l = qd_layout;
l.no_rx = n_ues; 
l.rx_position = [tracks(:).initial_position];
for n_ue=1:n_ues
	l.rx_track(n_ue).positions = tracks(n_ue).positions;
	l.rx_track(n_ue).calc_orientation;
end
l.visualize([],[],0);

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