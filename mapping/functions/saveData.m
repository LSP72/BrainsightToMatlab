function T = saveData(X, Y, Z, PP, outputDir, muscle, session, option)
    %{
        For this fucnton X, Y, Z & PP need to be column vectors please.
    %}

    if nargin < 8 || isempty(option)
        columns = {'X', 'Y', 'Z', 'P2P_1'};
        dataName = ['ID_mapping_data_EMG1_' muscle '_' char(session)];
    else
        columns = {'X', 'Y', 'Z', 'P2P_2'};
        dataName = ['ID_mapping_data_EMG2_' muscle '_' char(session)];
    end

    T = table(X, Y, Z, PP, 'VariableNames', columns);
    writetable(T, fullfile(outputDir, [dataName '.xlsx']));

end