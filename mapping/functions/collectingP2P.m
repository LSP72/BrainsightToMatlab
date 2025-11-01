function [PP, Lat] = collectingP2P(data, option)

    PP = [];
    Lat = [];
    n = length(data.samples);
    
    if nargin < 2 || isempty(option)
        for i = 1:n
            PP = [PP, data.samples{1,i}.EMG_Peak_to_peak_1];
            Lat = [Lat, data.samples{1,i}.EMG_Latency_1];
        end
    else
        for i = 1:n
            PP = [PP, data.samples{1,i}.EMG_Peak_to_peak_2];
            Lat = [Lat, data.samples{1,i}.EMG_Latency_2];
        end
    end
end
