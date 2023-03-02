tx_number = 1;
rx_number = 1;
path_channels = 'results/freq_channel/';
path_result = 'results/layout/';

file = load([path_channels, 'Tx', num2str(tx_number, '%04.f'), '_Rx', num2str(rx_number, '%04.f'), '.mat'], 'freq_channel');
power_subcarrier_time = 10*log10(squeeze(sum(sum(abs(file.freq_channel).^2, 1), 2)));
imagesc(power_subcarrier_time);
colorbar;
xlabel("Simulation steps (n)");
ylabel("Subcarriers");
saveas(gcf, [path_result, 'power_freq_channel', num2str(tx_number), '_rx', num2str(rx_number), '.png']);