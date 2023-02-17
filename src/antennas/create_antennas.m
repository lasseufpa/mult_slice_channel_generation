function [tx_array_3gpp_macro, rx_omni] = create_antennas(center_frequency)

	tx_antenna_3gpp_macro.phi_3dB = 70;
	tx_antenna_3gpp_macro.theta_3dB = 10;
	tx_antenna_3gpp_macro.rear_gain = 25;
	tx_antenna_3gpp_macro.electric_tilt = 15;

	tx_array_3gpp_macro = qd_arrayant('3gpp-macro', tx_antenna_3gpp_macro.phi_3dB, tx_antenna_3gpp_macro.theta_3dB, tx_antenna_3gpp_macro.rear_gain, tx_antenna_3gpp_macro.electric_tilt);
	tx_array_3gpp_macro.element_position(1, :) = 0; % Distance from pole
	tx_array_3gpp_macro.name = '3gpp-macro';
	tx_array_3gpp_macro.center_frequency = center_frequency;

	rx_omni = qd_arrayant('omni');
	rx_omni.center_frequency = center_frequency;
end