function [selectedMEPs] = selectingMEPBS(data)

    %{
      data is the structure extracted from Brainsight;
        this function returns all the MEP the user selected
    %}
    
      % Create a figure
    f = uifigure('Name', 'MEP Selection', 'Position', [100 100 1000 600]);
    ax = uiaxes('Parent', f, 'Position', [100 120 600 400]);
                                        % position in [%]
    hold(ax, 'on');

    % Collecting the time to plot the MEPs & the number of samples
    t = timeDefinition(data);
    nMEP = length(data.samples);
    selectedMEPs = {};

    % Create a matrix with all the MEPs to plot
    allMEP = [] ;
    for i = 1:nMEP
        MEP = data.samples{1,i}.EMG_Data_1 ;
        allMEP = [allMEP, MEP'];
    end

    % Plot all the MEPs
    hLines = plot(ax, t', allMEP);
    xlabel(ax, 'Time (ms)');
    ylabel(ax, 'Amplitude (mV)');
    title(ax, 'Select MEPs using checkboxes');

    % Create checkbox panel (empty)
    panel = uipanel('Parent', f, 'Title', 'Select MEPs', ...
                    'Position', [750 120 200 400], ...
                    'Scrollable', 'on');

    % Add all the checkboxes and their state
    cb = gobjects(nMEP, 1);  % here to display graphics object
    for i = 1:nMEP           % creating a button for each MEP
        cb(i) = uicheckbox(panel, ...
                           'Text', sprintf('MEP %d', i), ...
                           'Value', true, ...   % all selected initially
                           'Position', [10, 650 - 25*i, 120, 20], ...
                           'ValueChangedFcn', @(src,~) toggleMEP(src, hLines(i)));
    end

    % Initialize variables for waiting
    f.UserData.completed = false;
    f.UserData.selectedMEPs = {};

    % Button for analysis
    uibutton(f, 'Text', 'Export Selected MEPs', ...
             'Position', [400 40 200 40], ...
             'ButtonPushedFcn', @(~,~) extractingSelectedMEPs(data, cb,f));

    % Wait for the user to complete selection
    while isvalid(f) && ~f.UserData.completed
        drawnow;  % Process GUI events
        pause(0.1);  % Small pause to prevent excessive CPU usage
    end

     % Retrieve results
    if isvalid(f)
        selectedMEPs = f.UserData.selectedMEPs;
        close(f);
    else
        selectedMEPs = {};
    end

end

%% Function that will display or not MEP
function toggleMEP(src, hLine)
    if src.Value
        hLine.Visible = 'on';
    else
        hLine.Visible = 'off';
    end
end

%% Function that returns only the selected MEPs
function extractingSelectedMEPs(data, cb, f)
   
    selected = logical(arrayfun(@(x) x.Value, cb));

    % if only want the MEP signals:
    % % Extract only selected MEPs
    % selectedMEPs = MEP(:, selected);   % rows = trials, cols = time points
    % 
    % % Transpose so that each column is one trial
    % resultMatrix = selectedMEPs';      % now: (time points × trials)
    % 
    % % Display size in command window
    % disp(size(resultMatrix));
    % % Export to workspace
    % assignin('base', 'SelectedMEPs', resultMatrix);

    % Collect all the samples of selected MEPs
    selectedMEPs = data.samples(1, selected);          % actual MEP signals
    
    f.UserData.selectedMEPs = selectedMEPs;
    f.UserData.completed = true;

    % Export to workspace
    assignin('base', 'SelectedMEPs', selectedMEPs);
    
    % Display confirmation in command window
    fprintf('✅ Exported %d selected MEPs to variable "SelectedMEPs" in workspace.\n', sum(selected));
    
end