function [attr] = open_annotations(filename)
    delimiter = '\t';
    formatSpec = '%f%C%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', ...
                         'string', 'EmptyValue', NaN,  'ReturnOnError', false);
    fclose(fileID);
    attr = table(dataArray{1:end-1}, 'VariableNames', {'VarName1','N'});
    clearvars filename delimiter formatSpec fileID dataArray ans;
end

