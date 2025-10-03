function selectedSamples = selectSamples(data, sample_indexes)
    % data: from .txt from BS
    % sample_indexes: list of the indexes of the samples to be removed
    
    selectedSamples = data;
    indexesToRemove = [];
    n = length(data.samples);
    
    for i = 1:n
        endSampleName = data.samples{1, i}.Sample_Name(8:end);
        numEndSampleName = str2num(endSampleName);
        if ismember(numEndSampleName, sample_indexes)
            indexesToRemove = [indexesToRemove, i];
        end
    end
    selectedSamples.samples(:, indexesToRemove) = [];
end