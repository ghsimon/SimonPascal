function [] = AutomationScraperextraction()
%AutomationScraperextraction This Program lets the User choose a folder to
%extract data from scraped data:
%   First a folder has to be selected, where the scraped data is stored in
%   a format which is as followed
%               datetime
%               Filename    #       Seedernr    #       NameSeeder
%               Filename    #       Seedernr    #       NameSeederc
% ....
%               Filename    #       Seedernr    #       NameSeeder
%               datetime
%               Filename    #       Seedernr    #       NameSeeder
% ....
% and so on.
%% Masterpart
dirName = uigetdir; %select directory for data extraction
[filesnr,fileList] = MP01(dirName); % gets number and name of files in dir
for ii=1:filesnr % run for all files
    %% catch name and data
    datafile = strcat(dirName, '\', fileList(ii,:));
    datafile = char(datafile);
    % exclude headerlines, if there are none, the programm will return a
    %  data.data error.
    [FileName,SeederNr,Seedernameall] = importfilecust(datafile);
    NameSeeder = Seedernameall{2}; % extract name of the seeder %first one is timestamp
    NameSeeder = strsplit(NameSeeder);
    Dataextraction(FileName,SeederNr,NameSeeder{2}); % calls the extraction programm
end

end
%% MP 01 scan data
function [filesnr,fileList] = MP01(dirName)
% opens the directory and creates a list out of all stored files in the
% directory
dirName = char(dirName); % change format of dirName
dirData = dir(dirName);      % Get the data for the current directory
dirIndex = [dirData.isdir];  % Find the index for directories
fileList = {dirData(~dirIndex).name}';  % Get a list of the files
filesnr= numel(fileList); % returns numer of elements in the fileList. will be used later for condition in loops
end
%%
function [FileName,SeederNr,Seedernameall] = importfilecust(filename)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [FILENAME,SEEDERNR,SEEDERNAMEALL] = IMPORTFILE(FILENAME) Reads data
%   from text file FILENAME for the default selection.
%
%   [FILENAME,SEEDERNR,SEEDERNAMEALL] = IMPORTFILE(FILENAME, STARTROW,
%   ENDROW) Reads data from rows STARTROW through ENDROW of text file
%   FILENAME.
%
% Example:
%   [FileName,SeederNr,Seedernameall] = importfile('eozlem.txt',1, 1072);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2016/12/09 10:42:37

%% Initialize variables.
delimiter = '#';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

% Converts strings in the input cell array to numbers. Replaced non-numeric
% strings with NaN.
rawData = dataArray{2};
for row=1:size(rawData, 1);
    % Create a regular expression to detect and remove non-numeric prefixes and
    % suffixes.
    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
    try
        result = regexp(rawData{row}, regexstr, 'names');
        numbers = result.numbers;
        
        % Detected commas in non-thousand locations.
        invalidThousandsSeparator = false;
        if any(numbers==',');
            thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
            if isempty(regexp(numbers, thousandsRegExp, 'once'));
                numbers = NaN;
                invalidThousandsSeparator = true;
            end
        end
        % Convert numeric strings to numbers.
        if ~invalidThousandsSeparator;
            numbers = textscan(strrep(numbers, ',', ''), '%f');
            numericData(row, 2) = numbers{1};
            raw{row, 2} = numbers{1};
        end
    catch me
    end
end


%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, 2);
rawCellColumns = raw(:, [1,3]);


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
FileName = rawCellColumns(:, 1);
SeederNr = cell2mat(rawNumericColumns(:, 1));
Seedernameall = rawCellColumns(:, 2);
end
