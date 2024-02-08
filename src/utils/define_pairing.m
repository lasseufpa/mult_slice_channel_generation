function [pairing] = define_pairing(basestation_ue_assoc)
idxs_non_zero = find(basestation_ue_assoc);
pairing = [ones(size(idxs_non_zero)); idxs_non_zero];
end

