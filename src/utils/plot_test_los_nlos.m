% function fig_plot =  plot_test_los_nlos()

tx_number = 1;
rx_number = 1;
scenario = "3GPP-38.901-UMa";
los_nlos = "NLOS";
number_segments = 1000;
path_channels = "../../results/channel/";

power_time = zeros(1, number_segments);
for idx_segment=1:number_segments
	channel_file = dir([path_channels, scenario,"-*_Tx", num2str(tx_number, '%04.f'), "_Rx", num2str(rx_number, '%04.f'), "_seg", num2str(idx_segment, '%04.f'), ".mat"]);
	channel_step = qd_channel.mat_load([path_channels, channel_file.name]);
	power_time(idx_segment) = sum(abs(channel_step.coeff(:,:,:)).^2, 3);
	disp("test");
end
fig_plot = 0;

% end