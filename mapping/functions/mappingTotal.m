%% Clearing the environment
clc
clear all
%% Script to plot the maps
[files, path] = uigetfile('*.txt', 'Sélectionnez les fichiers', 'MultiSelect', 'on');
str_file_dir = convertCharsToStrings(path);

% collecting if several files have been selected:
if isa(files, 'cell')
    n = length(files);
else
    n = 1;
end

% Collecting the name of the muscle
reponse = inputdlg('Targeted muscle:', 'Info request', [1 40]);
muscle = reponse{1};  % On récupère le texte saisi
disp(['The targeted muscle is the ' muscle '.']);

% Collecting the data
% str_file = convertCharsToStrings(files);
% str_file_dir = convertCharsToStrings(path);
% str_file_path = str_file_dir + str_file;
% data = parseTxtFile(str_file_path);
% [X, Y, Z, PP] = collectingCoord(data, muscle);

%%

coord = struct();
Sessions = [];
sample_indexes = {[9, 10, 13], [], []};

if n > 1
    for i = 1:length(files)
        sess = "Session" + num2str(i);
        Sessions = [Sessions, sess];
        str_file = convertCharsToStrings(files(i));
        str_file_path = str_file_dir + str_file;
        allData = parseTxtFile(str_file_path);
        data = selectSamples(allData, sample_indexes{i}); % for now, the list is defined earlier by hand
        [X, Y, Z, PP] = collectingCoord(data, muscle);
        coord.X.(sess) = X;
        coord.Y.(sess) = Y;
        coord.Z.(sess) = Z;
        coord.PP.(sess) = PP;
        [X_t, Y_t, PP_t] = collectingTargetCoord(data);
        coord.X_t.(sess) = X_t;
        coord.Y_t.(sess) = Y_t;
        coord.PP_t.(sess) = PP_t;
        figure
        plotting2DMap(X_t, Y_t, PP_t, muscle, i)
        figure
        plottingTheMap(X, Y, Z, PP, muscle, i)
        figure
        gridDisplay(X_t, Y_t, MEPGrid(X_t, Y_t, PP_t), muscle, i)
    end

    %% Plotting the average map

    % When using real coordinate of each session
    XX = zeros(size(coord.X.(Sessions(1))));
    YY = zeros(size(coord.Y.(Sessions(1))));
    ZZ = zeros(size(coord.Z.(Sessions(1))));
    PPP = zeros(size(coord.PP.(Sessions(1))));

    for i = 1:n
        XX = XX + coord.X.(Sessions(i));
        YY = YY + coord.Y.(Sessions(i));
        ZZ = ZZ + coord.Z.(Sessions(i));
        PPP = PPP + coord.PP.(Sessions(i));
    end
    XX = XX/n ;
    YY = YY/n;
    ZZ = ZZ/n;
    PPP = PPP/n;

    % When plotting the average map from the target coordinates
    PPP_t = zeros(size(coord.PP_t.(Sessions(1))));
    for i = 1:n
        PPP_t = PPP_t + coord.PP_t.(Sessions(i));
    end
    PPP_t = PPP_t/n;

    figure
    plotting2DMap(X_t, Y_t, PPP_t, muscle)
    figure
    plottingTheMap(XX, YY, ZZ, PPP, muscle)
    % figure
    gridDisplay(X_t, Y_t, MEPGrid(X_t, Y_t, PPP_t), muscle)


else
    sess = "Session";
    str_file = convertCharsToStrings(files);
    str_file_path = str_file_dir + str_file;
    allData = parseTxtFile(str_file_path);
    data = selectSamples(allData, sample_indexes{i});
    [X, Y, Z, PP] = collectingCoord(data, muscle);
    coord.X.(sess) = X;
    coord.Y.(sess) = Y;
    coord.Z.(sess) = Z;
    coord.PP.(sess) = PP;
    [X_t, Y_t, PP_t] = collectingTargetCoord(data);
    coord.X_t.(sess) = X_t;
    coord.Y_t.(sess) = Y_t;
    coord.PP_t.(sess) = PP_t;
    figure
    plotting2DMap(X_t, Y_t, PP_t, muscle)
    figure
    plottingTheMap(X, Y, Z, PP, muscle, 1)
    figure
    gridDisplay(X_t, Y_t, MEPGrid(X_t, Y_t, PP_t), muscle)

end