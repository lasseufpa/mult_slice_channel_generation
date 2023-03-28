function [tx, rx] = create_antennas(center_frequency, tx_antenna_type)

    switch tx_antenna_type
        case '3gpp-macro'
            tx_antenna_3gpp_macro.phi_3dB = 70;
            tx_antenna_3gpp_macro.theta_3dB = 10;
            tx_antenna_3gpp_macro.rear_gain = 25;
            tx_antenna_3gpp_macro.electric_tilt = 15;

            tx = qd_arrayant('3gpp-macro', tx_antenna_3gpp_macro.phi_3dB, tx_antenna_3gpp_macro.theta_3dB, tx_antenna_3gpp_macro.rear_gain, tx_antenna_3gpp_macro.electric_tilt);
            tx.element_position(1, :) = 0; % Distance from pole
            tx.name = '3gpp-macro';
            tx.center_frequency = center_frequency;
        case 'omni'
            tx = qd_arrayant('omni');
            tx.center_frequency = center_frequency;
        otherwise
        	error("Invalid antenna type for Tx");
    end
	

	rx = qd_arrayant('omni');
	rx.center_frequency = center_frequency;
end