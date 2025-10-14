%% Clearing the environment
clc
clear all
addpath(genpath(userpath))

%% Initiating which MEP is not considered
% UL mapping:
% sample_indexes = {[], [10 16], [3 21]};
% LL mapping:
sample_indexes = {[9 10 13], [], []};

%% Initiating if looking to EMG_1 or EMG_2
% EMG_1
% option = [];
% % EMG_2
option = 2;

%% Script to plot the maps
[files, path] = uigetfile('*.txt', 'Sélectionnez les fichiers', 'MultiSelect', 'on');
str_file_dir = convertCharsToStrings(path);
outputDir = fullfile('/Users/mathildetardif/Documents/MATLAB/BrainsightToMatlab/mapping/results');

% collecting if several files have been selected:
if isa(files, 'cell')
    n = length(files);
else
    n = 1;
end

% Collecting the name of the muscle
reponse = inputdlg('Targeted muscle:', 'Info request', [1 40]);
muscle = reponse{1};  % Collecting the typed text
disp(['The targeted muscle is the ' muscle '.']);

coord = struct();
Sessions = [];

if n > 1
    for i = 1:length(files)
        sess = "Session" + num2str(i);
        Sessions = [Sessions, sess];
        str_file = convertCharsToStrings(files(i));
        str_file_path = str_file_dir + str_file;
        allData = parseTxtFileMapping(str_file_path);
        data = selectSamples(allData, sample_indexes{i}); % for now, the list is defined earlier by hand
        selectedData = selectingMEPBSForMapping(data, option);
        [X, Y, Z, PP] = collectingCoord(selectedData, muscle, otion);
        [XAbsTarget, YAbsTarget] = collectingAbsTargetCoord(selectedData);
        [XTarget, YTarget, ZTarget] = collectingTargetCoord(data);
        coord.X.(sess) = X;
        coord.Y.(sess) = Y;
        coord.Z.(sess) = Z;
        coord.PP.(sess) = PP;
        coord.X_Abs.(sess) = XAbsTarget;
        coord.Y_Abs.(sess) = YAbsTarget;
        coord.X_target.(sess) = XTarget;
        coord.Y_target.(sess) = YTarget;
        coord.Z_target.(sess) = ZTarget;
        % saveData(X', Y', Z', PP, outputDir, muscle, sess, option);
        figure
        plotting2DMap(XAbsTarget, YAbsTarget, PP, muscle, i)
        % figure
        % plottingTheMap(X, Y, Z, PP, muscle, i)
        % % figure
        gridDisplay(XAbsTarget, YAbsTarget, MEPGrid(XAbsTarget, YAbsTarget, PP), muscle, i)
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

    % saveData(XX', YY', ZZ', PPP, outputDir, muscle, 'average'); % option
    % 
    figure
    plotting2DMap(XAbsTarget, YAbsTarget, PPP, muscle)
    % figure
    % plottingTheMap(XX, YY, ZZ, PPP, muscle)
    % % figure
    gridDisplay(XAbsTarget, YAbsTarget, MEPGrid(XAbsTarget, YAbsTarget, PPP), muscle)

else
    sess = "Session";
    str_file = convertCharsToStrings(files);
    str_file_path = str_file_dir + str_file;
    allData = parseTxtFileMapping(str_file_path);
    data = selectSamples(allData, sample_indexes{1});
    selectedData = selectingMEPBSForMapping(data);
    [X, Y, Z, PP] = collectingCoord(selectedData, muscle); % option
    [XAbsTarget, YAbsTarget] = collectingAbsTargetCoord(selectedData);
    [XTarget, YTarget, ZTarget] = collectingTargetCoord(data);
    coord.X.(sess) = X;
    coord.Y.(sess) = Y;
    coord.Z.(sess) = Z;
    coord.PP.(sess) = PP;
    coord.X_Abs.(sess) = XAbsTarget;
    coord.Y_Abs.(sess) = YAbsTarget;
    coord.X_target.(sess) = XTarget;
    coord.Y_target.(sess) = YTarget;
    coord.Z_target.(sess) = ZTarget;
    saveData(X', Y', Z', PP', outputDir, muscle, '', option); 
    
    figure
    plotting2DMap(XAbsTarget, YAbsTarget, PP, muscle)
    % figure
    % plottingTheMap(X, Y, Z, PP, muscle, 1)
    % figure
    gridDisplay(XAbsTarget, YAbsTarget, MEPGrid(XAbsTarget, YAbsTarget, PP), muscle)

end