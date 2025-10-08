function parsedData = parseTxtFileMapping(file_path)
    % Parse a TXT file containing multiple types of data sections.
    %
    % Args:
    %     file_path (string): Path to the TXT file
    %
    % Returns:
    %     struct containing fields: samples, targets, planned_landmarks, session_landmarks
    
    % Initialize result structure
    parsedData = struct();
    parsedData.samples = {};
    parsedData.targets = {};
    parsedData.planned_landmarks = {};
    parsedData.session_landmarks = {};
    parsedData.session_data = {};
    
    % Define expected headers for each data type (base headers without EMG variations)
    headers = struct();
    headers.target = {"Target Name", "Loc. X", "Loc. Y", "Loc. Z", "m0n0", "m0n1", "m0n2", "m1n0", "m1n1", "m1n2", "m2n0", "m2n1", "m2n2"};
    % Base sample headers - will be dynamically extended based on actual file headers
    headers.sample_base = {"Sample Name", "Session Name", "Index", "Assoc. Target", "Loc. X", "Loc. Y", "Loc. Z", "m0n0", "m0n1", "m0n2", "m1n0", "m1n1", "m1n2", "m2n0", "m2n1", "m2n2", "Dist. to Target", "Target Error", "Angular Error", "Twist Error", "Stim. Power A", "Stim. Pulse Interval", "Stim. Power B", "Date", "Time", "Creation Cause", "Crosshairs Driver", "Offset", "Comment"};
    headers.planned_landmark = {"Planned Landmark Name", "Loc. X", "Loc. Y", "Loc. Z"};
    headers.session_landmark = {"Session Landmark Name", "Session Name", "Used?", "Loc. X", "Loc. Y", "Loc. Z"};
    headers.session_data = {"Session Name", "Loc. X", "Loc. Y", "Loc. Z", "m0n0", "m0n1", "m0n2", "m1n0", "m1n1", "m1n2", "m2n0", "m2n1", "m2n2"};
    
    current_mode = '';
    current_headers = {};
    
    try
        fid = fopen(file_path, 'r', 'n', 'UTF-8');
        if fid == -1
            error('Could not open file: %s', file_path);
        end
        
        line_num = 0;
        while ~feof(fid)
            line = fgetl(fid);
            line_num = line_num + 1;
            
            % Skip empty lines
            if isempty(strtrim(line))
                continue;
            end
            
            line = strtrim(line);
            
            % Check if line is a header
            if startsWith(line, '#')
                if contains(line, 'Target Name')
                    current_mode = 'target';
                    current_headers = headers.target;
                elseif contains(line, 'Sample Name')
                    current_mode = 'sample';
                    % Parse the actual header line to detect all EMG fields dynamically
                    current_headers = parse_sample_headers(line);
                elseif contains(line, 'Planned Landmark Name')
                    current_mode = 'planned_landmark';
                    current_headers = headers.planned_landmark;
                elseif contains(line, 'Session Landmark Name')
                    current_mode = 'session_landmark';
                    current_headers = headers.session_landmark;
                elseif contains(line, 'Session Name') && ~contains(line, 'Session Landmark Name')
                    % This handles the "# Session Name	Loc. X	Loc. Y..." header
                    current_mode = 'session_data';
                    current_headers = headers.session_data;
                else
                    % Skip other comment lines
                    continue;
                end
                continue;
            end
            
            % Parse data lines
            if ~isempty(current_mode)
                try
                    fields = split(line, sprintf('\t'));
                    
                    % Parse the data
                    if ~isempty(current_headers) && length(fields) >= 1
                        data_record = struct();
                        
                        for i = 1:length(current_headers)
                            header = current_headers{i};
                            if i <= length(fields)
                                value = fields{i};
                                % Check if this is an EMG Data field (any number)
                                if strcmp(current_mode, 'sample') && contains(header, 'EMG Data') && ~isempty(value) && ~strcmp(value, '(null)')
                                    % Parse semicolon-separated EMG data
                                    data_record.(matlab_field_name(header)) = parse_emg_data(value);
                                else
                                    data_record.(matlab_field_name(header)) = parse_value(value);
                                end
                            else
                                data_record.(matlab_field_name(header)) = [];
                            end
                        end
                        
                        % Add to appropriate list
                        switch current_mode
                            case 'target'
                                parsedData.targets{end+1} = data_record;
                            case 'sample'
                                parsedData.samples{end+1} = data_record;
                            case 'planned_landmark'
                                parsedData.planned_landmarks{end+1} = data_record;
                            case 'session_landmark'
                                parsedData.session_landmarks{end+1} = data_record;
                            case 'session_data'
                                parsedData.session_data{end+1} = data_record;
                        end
                    else
                        fprintf('Warning: Line %d has insufficient data or no headers defined\n', line_num);
                    end
                    
                catch ME
                    fprintf('Error parsing line %d: %s\n', line_num, ME.message);
                    fprintf('Line content: %s\n', line);
                end
            end
        end
        
        fclose(fid);
        
    catch ME
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
        fprintf('Error reading file: %s\n', ME.message);
    end
end

function headers = parse_sample_headers(header_line)
    % Parse the sample header line to dynamically detect all columns including EMG fields
    % Remove the leading '#' and split by tabs
    header_line = strrep(header_line, '#', '');
    header_line = strtrim(header_line);
    headers = split(header_line, sprintf('\t'));
    
    % Convert to cell array of strings and trim each header
    for i = 1:length(headers)
        headers{i} = strtrim(headers{i});
    end
end

function valid_name = matlab_field_name(name)
    % Convert a string to a valid MATLAB field name
    valid_name = regexprep(name, '[^a-zA-Z0-9_]', '_');
    valid_name = regexprep(valid_name, '^([0-9])', 'f$1'); % Can't start with number
    if isempty(valid_name)
        valid_name = 'field';
    end
end

function parsed_value = parse_value(value)
    % Parse a string value to appropriate type (double or string)
    % Handles (null) values
    
    if isempty(value) || strcmp(strtrim(value), '(null)')
        parsed_value = [];
        return;
    end
    
    value = strtrim(value);
    
    % Try to parse as number
    num_value = str2double(value);
    if ~isnan(num_value)
        parsed_value = num_value;
    else
        parsed_value = value; % Return as string
    end
end

function emg_values = parse_emg_data(emg_string)
    % Parse semicolon-separated EMG data string into array of doubles
    
    if isempty(emg_string) || strcmp(strtrim(emg_string), '(null)')
        emg_values = [];
        return;
    end
    
    % Remove trailing "..." if present
    emg_string = regexprep(emg_string, '\.\.\.+$', '');
    
    % Split by semicolon
    parts = split(emg_string, ';');
    emg_values = [];
    
    for i = 1:length(parts)
        part = strtrim(parts{i});
        if ~isempty(part)
            num_val = str2double(part);
            if ~isnan(num_val)
                emg_values(end+1) = num_val;
            else
                fprintf('Warning: Could not parse EMG value: %s\n', part);
            end
        end
    end
end

function print_summary(data)
    % Print a summary of the parsed data
    
    fprintf('Parsed data summary:\n');
    fprintf('- Targets: %d records\n', length(data.targets));
    fprintf('- Samples: %d records\n', length(data.samples));
    fprintf('- Planned Landmarks: %d records\n', length(data.planned_landmarks));
    fprintf('- Session Landmarks: %d records\n', length(data.session_landmarks));
    fprintf('- Session Data: %d records\n', length(data.session_data));
    
    % Show structure of each data type
    data_types = {'targets', 'samples', 'planned_landmarks', 'session_landmarks', 'session_data'};
    
    for i = 1:length(data_types)
        data_type = data_types{i};
        records = data.(data_type);
        
        if ~isempty(records)
            fprintf('\n%s structure:\n', strrep(data_type, '_', ' '));
            field_names = fieldnames(records{1});
            fprintf('  Fields: %s\n', strjoin(field_names, ', '));
            
            % Show EMG data info for samples - handle multiple EMG channels
            if strcmp(data_type, 'samples')
                % Find all EMG Data fields
                emg_fields = field_names(contains(field_names, 'EMG_Data_'));
                for j = 1:length(emg_fields)
                    emg_field = emg_fields{j};
                    if isfield(records{1}, emg_field)
                        emg_data = records{1}.(emg_field);
                        if ~isempty(emg_data) && length(emg_data) >= 3
                            fprintf('  %s: %d values (first 3: [%.2f, %.2f, %.2f])\n', ...
                                emg_field, length(emg_data), emg_data(1), emg_data(2), emg_data(3));
                        elseif ~isempty(emg_data)
                            fprintf('  %s: %d values\n', emg_field, length(emg_data));
                        end
                    end
                end
            end
        end
    end
end

function save_to_mat_file(data, filename)
    % Save parsed data to .mat file
    if nargin < 2
        filename = 'parsed_data.mat';
    end
    
    save(filename, 'data');
    fprintf('Data saved to %s\n', filename);
end

% Example usage function
function example_usage()
    % Example of how to use the parser
    
    % Replace 'your_file.txt' with the actual path to your file
    file_path = 'your_file.txt';
    
    % Parse the file
    parsed_data = parseTxtFileMapping(file_path);
    
    % Print summary
    print_summary(parsed_data);
    
    % Access different types of data
    samples = parsed_data.samples;
    
    % Example: Access EMG fields dynamically
    if ~isempty(samples)
        sample1 = samples{1};
        fprintf('\nFirst sample: %s from %s\n', sample1.Sample_Name, sample1.Session_Name);
        
        % Get all field names
        field_names = fieldnames(sample1);
        
        % Find all EMG Peak-to-peak fields
        emg_peak_fields = field_names(contains(field_names, 'EMG_Peak_to_peak_'));
        fprintf('\nFound %d EMG Peak-to-peak channels\n', length(emg_peak_fields));
        for i = 1:length(emg_peak_fields)
            field_name = emg_peak_fields{i};
            fprintf('  %s: %.2f\n', field_name, sample1.(field_name));
        end
        
        % Find all EMG Latency fields
        emg_latency_fields = field_names(contains(field_names, 'EMG_Latency_'));
        fprintf('\nFound %d EMG Latency channels\n', length(emg_latency_fields));
        for i = 1:length(emg_latency_fields)
            field_name = emg_latency_fields{i};
            fprintf('  %s: %.2f\n', field_name, sample1.(field_name));
        end
        
        % Find all EMG Data fields
        emg_data_fields = field_names(contains(field_names, 'EMG_Data_'));
        fprintf('\nFound %d EMG Data channels\n', length(emg_data_fields));
        for i = 1:length(emg_data_fields)
            field_name = emg_data_fields{i};
            if ~isempty(sample1.(field_name))
                fprintf('  %s: %d data points\n', field_name, length(sample1.(field_name)));
            end
        end
    end
    
    % Save to .mat file
    save_to_mat_file(parsed_data);
end