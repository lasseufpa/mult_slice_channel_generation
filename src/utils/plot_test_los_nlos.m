tx_number = 1;
rx_number = 1;
scenario = "3GPP-38.901-UMa";
number_snapshots = 1000;
path_channels = "../../results/channel/";

power_time = [];
los_or_nlos = cell(1, number_snapshots);

# Get the last segment
max_segment_number = get_last_segment(path_channels, scenario, tx_number, rx_number);
cumulative = 0;
for idx_segment=1:max_segment_number
	channel_file = dir([path_channels, scenario,"-*_Tx", num2str(tx_number, '%04.f'), "_Rx", num2str(rx_number, '%04.f'), "_seg", num2str(idx_segment, '%04.f'), ".mat"]);
	los_or_nlos{idx_segment} = erase(lower(channel_file.name(1, size(scenario)(2)+2:size(scenario)(2)+5)), "_");
	channel_step = qd_channel.mat_load([path_channels, channel_file.name]);
	cumulative = cumulative+size(channel_step.coeff)(4);
	power_time = [power_time, 10*log10(squeeze(sum(sum(sum(abs(channel_step.coeff(:,:,:,:)).^2, 1), 2), 3))')];
	fprintf("Segment %d \n", idx_segment)
end

set(0,'DefaultFigurePaperSize',[14.5 4.7])              % Change Plot Size 

# Plot LOS area
idx_los = find(ismember(los_or_nlos, "los"));
diff_idx = diff([0,diff(idx_los)==1,0]);
first_idx = idx_los(diff_idx>0);
last_idx = idx_los(diff_idx<0);

for area_idx=1:size(first_idx)(2)
	area([first_idx(area_idx), last_idx(area_idx)], repmat(-160, 1, 2),'FaceColor',"cyan",'LineStyle','none');
	hold on
end

# Plot received power
plot(power_time);
hold off
grid on
ylim([-140, -80])
xlabel("Simulation steps (n)");
ylabel("RX power (dBm)");
saveas(gcf, "../../results/layout/los_nlos_power.png");
disp("Test")