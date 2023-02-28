function max_segment_number = get_last_segment(path_channels, scenario, tx_number, rx_number)
	files = dir([path_channels, scenario,'-*_Tx', num2str(tx_number, '%04.f'), '_Rx', num2str(rx_number, '%04.f'), '_seg*.mat']);
	files = cell2mat({files.name});
	files = regexp(files,'(?<=seg)(.*?)(?=\.mat)','match');
	max_segment_number = max(cellfun(@str2num, files(1,:)));
end