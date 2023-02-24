% function fig_plot =  plot_test_los_nlos()

tx_number = 1;
rx_number = 1;
scenario = "3GPP-38.901-UMa";
number_segments = 100;
path_channels = "../../results/channel/";

power_time = zeros(number_segments);
los_or_nlos = cell(number_segments);
for idx_segment=1:number_segments
	channel_file = dir([path_channels, scenario,"-*_Tx", num2str(tx_number, '%04.f'), "_Rx", num2str(rx_number, '%04.f'), "_seg", num2str(idx_segment, '%04.f'), ".mat"]);
	los_or_nlos{idx_segment} = erase(lower(channel_file.name(1, size(scenario)(2)+2:size(scenario)(2)+5)), "_");
	channel_step = qd_channel.mat_load([path_channels, channel_file.name]);
	power_time(idx_segment) = 10*log10(sum(sum(abs(channel_step.coeff(:,:,:)).^2)));
	fprintf("Segment %d \n", idx_segment)
end

set(0,'DefaultFigurePaperSize',[14.5 4.7])              % Change Plot Size 
plot(spower_time);

disp("Test")