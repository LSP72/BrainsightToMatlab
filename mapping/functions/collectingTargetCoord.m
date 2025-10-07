function [X, Y, Z] = collectingTargetCoord(data)
    %{
        This function collects the coordinates of grid followed during the
        mapping as long as the peak-to-peak MEP value of the concerned
        target.
        Plots a 2D map.
    %}

    X = [];
    Y = [];
    Z = [];
    grid = struct();

    for i = 1:length(data.targets)
        if ~isempty(data.targets{1, i}.Target_Name)
            splittedTargetName = strsplit(data.targets{1, i}.Target_Name);
            if length(splittedTargetName) > 2 & ~ismember('Sample', splittedTargetName)
                targetName = matlab.lang.makeValidName(data.targets{1, i}.Target_Name);
                x = data.targets{1, i}.Loc__X;
                y = data.targets{1, i}.Loc__Y;
                z = data.targets{1, i}.Loc__Z;
                grid.X.(targetName) = x;
                grid.Y.(targetName) = y;
                grid.Z.(targetName) = z;
                X = [X; x];
                Y = [Y; y];
                Z = [Z; z];
            end
        end

    end
    assignin('base', 'gridCoord', grid);
end