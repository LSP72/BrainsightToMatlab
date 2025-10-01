function [X, Y, PP] = collectingTargetCoord(data)
    %{
        This function collects the coordinates of grid followed during the
        mapping as long as the peak-to-peak MEP value of the concerned
        target.
        Plots a 2D map.
    %}

    X = [];
    Y = [];
    PP = [];
    
    % Collecting 
    n = length(data.samples);

    for i = 1:n
        % Looking for the 'mapping' coordinates
        numStr = regexp(data.samples{1,i}.Assoc__Target, '\((.*?)\)', 'tokens');
        numbers = str2double(strsplit(numStr{1}{1}, ','));

        % Collecting the info
        X = [X; numbers(1)];
        Y = [Y; numbers(2)];
        PP = [PP; data.samples{1,i}.EMG_Peak_to_peak_1];

    end

end