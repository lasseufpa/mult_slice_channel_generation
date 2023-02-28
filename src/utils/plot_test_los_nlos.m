tx_number = 1;
rx_number = 1;
scenario = '3GPP-38.901-UMa';
number_snapshots = 1000;
path_channels = 'results/channel/';

channel_step = qd_channel.mat_load([path_channels, 'Tx', num2str(tx_number, '%04.f'), '_Rx', num2str(rx_number, '%04.f'), '.mat']);
power_time = 10*log10(squeeze(sum(sum(sum(abs(channel_step.coeff(:,:,:,:)).^2, 1), 2), 3))');

set(0,'DefaultFigurePaperSize',[14.5 4.7])              % Change Plot Size 

% % Plot LOS area
% idx_los = find(ismember(los_or_nlos, "los"));
% diff_idx = diff([0,diff(idx_los)==1,0]);
% first_idx = idx_los(diff_idx>0);
% last_idx = idx_los(diff_idx<0);

% for area_idx=1:size(first_idx, 2)
% 	area([first_idx(area_idx), last_idx(area_idx)], repmat(-160, 1, 2),'FaceColor',"cyan",'LineStyle','none');
% 	hold on
% end

% Plot received power
plot(power_time);
hold off
grid on
ylim([-140, -80])
xlabel("Simulation steps (n)");
ylabel("RX power (dBm)");
saveas(gcf, "../../results/layout/los_nlos_power.png");
disp("Test")