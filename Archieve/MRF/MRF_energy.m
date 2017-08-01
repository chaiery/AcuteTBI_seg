function [energy_0, energy_1] = MRF_energy(label_sub,prob,intensity_sub)
    % calculate energy when label is 0
    energy_0 = -1*log(1-prob+0.00001);
    intensity_sub = double(intensity_sub);
    intensity_diff = -0.0005*((intensity_sub - intensity_sub(2,2))^2);
    V_matrix = exp(intensity_diff);
    label_diff = (label_sub~=0);
    V = sum(sum(V_matrix.*label_diff));
    energy_0 = energy_0 + 1*V;

    energy_1 = -1*log(prob+0.00001);
    intensity_sub = double(intensity_sub);
    intensity_diff = -0.0005*((intensity_sub - intensity_sub(2,2))^2);
    V_matrix = exp(intensity_diff);
    label_diff = (label_sub~=1);
    V = sum(sum(V_matrix.*label_diff));
    energy_1 = energy_1 + 1*V;
end