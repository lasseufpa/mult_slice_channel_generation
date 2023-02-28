tx_number = 1;
rx_number = 1;
scenario = '3GPP-38.901-UMa';
number_snapshots = 1000;
path_channels = 'results/channel/';
path_result = 'results/layout/';

channel_step = qd_channel.mat_load([path_channels, 'Tx', num2str(tx_number, '%04.f'), '_Rx', num2str(rx_number, '%04.f'), '.mat']);
power_time = 10*log10(squeeze(sum(sum(sum(abs(channel_step.coeff(:,:,:,:)).^2, 1), 2), 3))');

set(0,'DefaultFigurePaperSize',[14.5 4.7])              % Change Plot Size 

% Plot received power
plot(power_time);
hold off
grid on
ylim([-140, -80])
xlabel("Simulation steps (n)");
ylabel("RX power (dBm)");
saveas(gcf, [path_result, 'received_power_tx', num2str(tx_number), '_rx', num2str(rx_number), '.png']);