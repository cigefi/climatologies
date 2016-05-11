% Function climatology
%
% Prototype: climatology(dirName,type, var2Read,yearZero,yearN)
%            climatology(dirName,type, var2Read)
%            climatology(dirName,type)
%            climatology(dirName)
%
% dirName = Path of the directory that contents the files and path for the
% processed files (cell array)
% type (Recommended) = Variable to specify the type of climatology: yearly,
% monthly, seasonal. Default value {'yearly'}. (cell array)
% var2Read (Recommended)= Variable to be read (use 'ncdump' to check the
% variable names) (string)
% yearZero (Optional) = Lower year of the data to be read (integer)
% yearN (Optional) = Higher year of the data to be read (integer)
function [] = climatology(dirName,type,var2Read,yearZero,yearN)
    if nargin < 1
        error('climatology: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end 
    switch nargin
        case 1 % Validates if the type param is received
            type = {'yearly'};
            temp = java.lang.String(dirName(1)).split('/');
            temp = temp(end).split('_');
            var2Read = char(temp(1)); % Default value is taken from the path
            yearZero = 0; % Default value
            yearN = 0; % Default value
        case 2 % Validates if the var2Read param is received
            temp = java.lang.String(dirName(1)).split('/');
            temp = temp(end).split('_');
            var2Read = char(temp(1)); % Default value is taken from the path
            yearZero = 0; % Default value
            yearN = 0; % Default value
        case 3 % Validates if the yearZero param is received
            yearZero = 0; % Default value
            yearN = 0; % Default value
        case 4 % Validates if the yearN param is received
            yearN = 0;
    end
    ttype = char(lower(type(1)));
    switch ttype
        case 'jan'
            ttype = 'monthly';
        case 'feb'
            ttype = 'monthly';
        case 'mar'
            ttype = 'monthly';
        case 'apr'
            ttype = 'monthly';
        case 'may'
            ttype = 'monthly';
        case 'jun'
            ttype = 'monthly';
        case 'jul'
            ttype = 'monthly';
        case 'aug'
            ttype = 'monthly';
        case 'sep'
            ttype = 'monthly';
        case 'oct'
            ttype = 'monthly';
        case 'nov'
            ttype = 'monthly';
        case 'dec'
            ttype = 'monthly';
        case 'sum'
            ttype = 'seasonal';
        case 'win'
            ttype = 'seasonal';
        case 'spr'
            ttype = 'seasonal';
        case 'fal'
            ttype = 'seasonal';
    end
    
    if(yearZero > yearN) % Validates if the yearZero is higher than yearN
        yearTemp = yearZero;
        yearZero = yearN;
        yearN = yearTemp;
    end
    dirData = dir(char(dirName(1)));  % Get the data for the current directory
    months = [31,28,31,30,31,30,31,31,30,31,30,31]; % Reference to the number of days per month
    %monthsName = {'January','February','March','April','May','June','July','August','September','October','November','December'};
    %seasonsName = {'Winter','Spring','Summer','Fall'};
    seasonsName = {};
    monthsName = {};
    for t=1:1:length(type)
        if strcmp(ttype,'seasonal')
            seasonsName = checkSeasons(seasonsName,type(t));
        end
        if strcmp(ttype,'monthly')
            monthsName = checkMonths(monthsName,type(t));
        end
    end
    if length(seasonsName) < 1 && strcmp(ttype,'seasonal')
        seasonsName = {'Winter','Spring','Summer','Fall'};
    end
    if length(monthsName) < 1 && strcmp(ttype,'monthly')
        monthsName = {'January','February','March','April','May','June','July','August','September','October','November','December'};
    end
    
    path = java.lang.String(dirName(1));
    if(path.charAt(path.length-1) ~= '/')
        path = path.concat('/');
    end
    try
		experimentParent = path.substring(0,path.lastIndexOf(strcat('/',var2Read)));
		experimentName = experimentParent.substring(experimentParent.lastIndexOf('/')+1);
    catch
        experimentName = '[CIGEFI]'; % Dafault value
    end
    out = [];
    lastDecember = []; % Temp var to save the data of the previous December
    if(length(dirName)>1)
        savePath = java.lang.String(dirName(2));
        if(length(dirName)>2)
            logPath = java.lang.String(dirName(3));
        else
            logPath = java.lang.String(dirName(2));
        end
    else
        savePath = java.lang.String(dirName(1));
        logPath = java.lang.String(dirName(1));
    end
    
	if(savePath.charAt(savePath.length-1) ~= '/')
		savePath = savePath.concat('/');
	end
    if(logPath.charAt(logPath.length-1) ~= '/')
        logPath = logPath.concat('/');
    end
    %fprintf('Processing: %s\n',char(experimentName));
    processing = 0;
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        if(fileT.substring(fileT.lastIndexOf('.')+1).equalsIgnoreCase('nc'))
            try
                yearC = str2double(fileT.substring(fileT.length-7,fileT.lastIndexOf('.')));
                if(yearZero>0)
                    if(yearC<yearZero) 
                        continue;
                     end
                end
                if(yearN>0)
                    if(yearC>yearN)
                        continue;
                    end
                end
                if all(yearC > 0 && ~strcmp(experimentName,'[CIGEFI]'))
                    if(~processing)
                        fprintf('Processing: %s\n',char(experimentName));
                        processing = 1;
                        if ~exist(char(logPath),'dir')
                            mkdir(char(logPath));
                        end
                        if(exist(strcat(char(logPath),'log.txt'),'file'))
                            delete(strcat(char(logPath),'log.txt'));
                        end
                    end
                    % Subrutine to writte the data in new Netcdf file
                    switch ttype
                        case 'yearly'
                            switch var2Read
                                case 'pr'
                                    newYear = readFile(fileT,var2Read,yearC,logPath,84600);
                                case 'tasmin'
                                    newYear = readFile(fileT,var2Read,yearC,logPath,273.15);
                                case 'tasmax'
                                    newYear = readFile(fileT,var2Read,yearC,logPath,273.15);
                                case 'tasmean'
                                    newYear = readFileTemp(fileT,'tasmin',yearC,logPath);
                            end
                            if isempty(out)
                                out = newYear;
                            else
                                out = nanmean(cat(1,out,newYear),1);
                            end
                        case 'monthly'
                            switch var2Read
                                case 'pr'
                                    newYear = readFileMonthly(fileT,var2Read,yearC,logPath,months,monthsName,84600);
                                case 'tasmin'
                                    newYear = readFileMonthly(fileT,var2Read,yearC,logPath,months,monthsName,273.15);
                                case 'tasmax'
                                    newYear = readFileMonthly(fileT,var2Read,yearC,logPath,months,monthsName,273.15);
                                case 'tasmean'
                                    newYear = readFileMonthlyTemp(fileT,'tasmin',yearC,logPath,months,monthsName);
                            end
                            if ~isempty(newYear)
                                if ~isempty(out)
                                    out = (out + newYear)/2;
                                else
                                    out = newYear;
                                end
                            end
                        case 'seasonal'
                            switch var2Read
                                case 'pr'
                                    [newYear,lastDecember] = readFileSeasonal(fileT,var2Read,yearC,logPath,months,seasonsName,lastDecember);
                                case 'tasmin'
                                    [newYear,lastDecember] = readFileSeasonalTempMin(fileT,var2Read,yearC,logPath,months,seasonsName,lastDecember);
                                case 'tasmax'
                                    [newYear,lastDecember] = readFileSeasonalTempMax(fileT,var2Read,yearC,logPath,months,seasonsName,lastDecember);
                                case 'tasmean'
                                    [newYear,lastDecember] = readFileSeasonalTemp(fileT,var2Read,yearC,logPath,months,seasonsName,lastDecember);
                            end
                            if ~isempty(newYear)
                                if ~isempty(out)
                                    out = (out + newYear)/2;
                                else
                                    out = newYear;
                                end
                            end
                    end
                end
            catch exception
                if(exist(char(logPath),'dir'))
                    fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                    fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
                    fclose(fid);
                end
                %mailError(type,var2Read,char(experimentName),char(exception.message));
                continue;
            end
        else
            if isequal(dirData(f).isdir,1)
                newPath = char(path.concat(dirData(f).name));
                switch nargin
                    case 1 
                        %climatology({newPath,char(savePath.concat(dirData(f).name)),char(logPath)});
                        climatology({newPath,char(savePath.concat(dirData(f).name))});
                    case 2 % Validates if the type param is received
                        %climatology({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},type);
                        climatology({newPath,char(savePath.concat(dirData(f).name))},type);
                    case 3 % Validates if the var2Read param is received
                        %climatology({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},type,var2Read);
                        climatology({newPath,char(savePath.concat(dirData(f).name))},type,var2Read);
                    case 4 % Validates if the yearZero param is received
                        %climatology({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},type,var2Read,yearZero);
                        climatology({newPath,char(savePath.concat(dirData(f).name))},type,var2Read,yearZero);
                    otherwise
                        %climatology({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},type,var2Read,yearZero,yearN); 
                        climatology({newPath,char(savePath.concat(dirData(f).name))},type,var2Read,yearZero,yearN);      
                end
            end
        end
    end
    if ~isempty(out)
        if ~exist(char(savePath),'dir')
            mkdir(char(savePath));
        end
        switch ttype
            case 'yearly'
                out = squeeze(out(1,:,:));
                fileT = savePath.concat(strcat(char(experimentName),'-',var2Read,'.dat'));
                dlmwrite(char(fileT),out);
                switch(var2Read)
                    case 'pr'
                        units = 'mm';
                        frequency = 'day';
                        PlotData(out,strcat('Precipitation (',units,'/',frequency,')'),char(savePath),char(experimentName));
                    case 'tasmin'
                        units = '°C';
                        frequency = 'day';
                        PlotData(out,strcat('Temperature (',units,'/',frequency,')'),char(savePath),char(experimentName));
                    otherwise
                        PlotData(out,'',char(savePath));
                end
            case 'monthly'
                for m=1:1:length(monthsName)
                    disp(strcat('Processing',{' '},monthsName(m)));
                    currentMonth = squeeze(out(m,:,:));
                    %currentMonth = squeeze(out(:,:,m));
                    fileT = savePath.concat(strcat(char(experimentName),'-',monthsName(m),'.dat'));
                    dlmwrite(char(fileT),currentMonth);
                    switch(var2Read)
                        case 'pr'
                            units = 'mm';
                            frequency = 'day';
                            PlotData(currentMonth,strcat('Precipitation (',units,'/',frequency,')'),char(savePath),strcat(char(experimentName),'-',monthsName(m)));
                        case 'tasmin'
                            units = '°C';
                            frequency = 'day';
                            PlotData(currentMonth,strcat('Temperature (',units,'/',frequency,')'),char(savePath),strcat(char(experimentName),'-',monthsName(m)));
                        otherwise
                            PlotData(currentMonth,'',char(savePath),strcat(char(experimentName),'-',monthsName(m)));
                    end
                end
            case 'seasonal'
                keySet =   {'Winter','Spring','Summer','Fall'};
                valueSet = [1,2,3,4];
                smap = containers.Map(keySet,valueSet);
                tmp = [NaN,NaN,NaN,NaN];
                for i=1:1:length(seasonsName)
                    tmp(smap(char(seasonsName(i)))) = 1;
                end
                seasonsName = [];
                for i=1:1:length(tmp)
                    if ~isnan(tmp(i))
                        seasonsName = cat(1,seasonsName,keySet(i));
                    end
                end
                for s=1:1:length(seasonsName)
                    disp(strcat('Processing',{' '},seasonsName(s)));
                    if(s==1)
                        currentSeason = squeeze(out(s,:,:));
                        %currentSeason = squeeze(out(:,:,s));
                        if ~isempty(lastDecember)
                            lastDecember = squeeze(lastDecember(1,:,:));
                            %lastDecember = squeeze(lastDecember(:,:,1));
                            currentSeason = (currentSeason+lastDecember)/2;
                        end
                    else
                        currentSeason = squeeze(out(s,:,:));
                        %currentSeason = squeeze(out(:,:,s));
                    end
                    fileT = savePath.concat(strcat(char(experimentName),'-',seasonsName(s),'.dat'));
                    dlmwrite(char(fileT),currentSeason);
                    switch(var2Read)
                        case 'pr'
                            units = 'mm';
                            frequency = 'day';
                            PlotData(currentSeason,strcat('Precipitation (',units,'/',frequency,')'),char(savePath),strcat(char(experimentName),'-',seasonsName(s)));
                        case 'tasmin'
                            units = '°C';
                            frequency = 'day';
                            PlotData(currentSeason,strcat('Temperature (',units,'/',frequency,')'),char(savePath),strcat(char(experimentName),'-',seasonsName(s)));
                        otherwise
                            PlotData(currentSeason,'',char(savePath),strcat(char(experimentName),'-',seasonsName(s)));
                    end
                end
        end
    end
end

function [out] = readFile(fileT,var2Read,yearC,logPath,scale)
    try
        [data,err] = readNC(fileT,var2Read);
        if ~isnan(err)
            out = [];
            fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
            fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(err));
            fclose(fid);
            %mailError('yearly',var2Read,'',char(err));
            return;
        end
        switch var2Read
            case 'pr'
                out = nanmean(scale.*data,1);
            case 'tasmin'
                out = nanmean(data-scale,1);
            case 'tasmax'
                out = nanmean(data-scale,1);
        end
        try
            clear data;
        catch
            disp('Error, cannot delete var data');
        end
        disp(char(strcat('Data saved: ',num2str(yearC))));
        fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
        fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
        fclose(fid);
    catch exception
        out = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
        fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        fclose(fid);
        mailError('yearly',var2Read,'',char(exception.message));
        disp(exception.message);
    end
end

function [out] = readFileMonthly(fileT,var2Read,yearC,logPath,months,monthsName,scale)
    try
        [data,err] = readNC(fileT,var2Read);
        if ~isnan(err)
            out = [];
            fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
            fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(err));
            fclose(fid);
            %mailError('monthly',var2Read,'',char(err));
            return;
        end
        switch var2Read
            case 'pr'
                data = scale.*data;
            case 'tasmin'
                data = data - scale;
            case 'tasmax'
                data = data - scale;
        end
        lPos = 0;
        out = [];
        keySet = {'January','February','March','April','May','June','July','August','September','October','November','December'};
        valueSet = [1,2,3,4,5,6,7,8,9,10,11,12];
        mmap = containers.Map(keySet,valueSet);
        dPlot = nan(1,12);
        for i=1:1:length(monthsName)
            dPlot(mmap(char(monthsName(i)))) = 1;
        end
        days = length(data(:,1,1));
        for m=1:1:length(dPlot)
            fPos = lPos + 1;
            if(leapyear(yearC)&& m==2 && days==366)
                lPos = months(m) + fPos; % Leap year
            else
                lPos = months(m) + fPos - 1;
            end
            if ~isnan(dPlot(m))
                out = cat(1,out,nanmean(data(fPos:lPos,:,:),1));
            end
            %out = cat(1,out,nanmean(data(fPos:lPos,:,:),1));
            %disp(strcat('Data saved: ',monthsName(m),{' - '},num2str(yearC)));
        end
        disp(strcat('Data saved: ',{' '},num2str(yearC)));
        try
            clear data;
        catch
            disp('Error, can not delete var data');
        end
        fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
        fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
        fclose(fid);
    catch exception
        out = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
        fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        fclose(fid);
        mailError('monthly',var2Read,'',char(exception.message));
    end
end

function [out] = readFileMonthlyTemp(fileT,var2Read,yearC,logPath,months,monthsName)
    try
        scale = 273.15;
        fileT2 = fileT.substring(0,fileT.lastIndexOf(strcat('/',var2Read)));
        fileT2 = fileT2.concat('/tasmax_day/');
        fileT2 = fileT2.concat(fileT.substring(fileT.lastIndexOf('day/')+4));
        if(exist(char(fileT2),'file'))           
            [mind,err] = readNC(fileT,var2Read);
            if ~isnan(err)
                out = [];
                fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(err));
                fclose(fid);
                %mailError('monthly',var2Read,'',char(err));
                return;
            end            
            [maxd,err] = readNC(fileT2,'tasmax');
            if ~isnan(err)
                out = [];
                fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(err));
                fclose(fid);
                return;
            end
            lPos = 0;
            out = [];
            daysMin = length(mind(:,1,1));
            daysMax = length(maxd(:,1,1));
            keySet = {'January','February','March','April','May','June','July','August','September','October','November','December'};
            valueSet = [1,2,3,4,5,6,7,8,9,10,11,12];
            mmap = containers.Map(keySet,valueSet);
            dPlot = nan(1,12);
            for i=1:1:length(monthsName)
                dPlot(mmap(char(monthsName(i)))) = 1;
            end
            for m=1:1:length(monthsName)
                fPos = lPos + 1;
                if(leapyear(yearC)&& m==2 && daysMin==366 && daysMax==366)
                    lPos = months(m) + fPos; % Leap year
                else
                    lPos = months(m) + fPos -1;
                end
                if ~isnan(dPlot(m))
                    tMin = mind(fPos:lPos,:,:);
                    tMax = maxd(fPos:lPos,:,:);
                    data = (tMin+tMax)/2;
                    out = cat(1,out,nanmean(data-scale,1));
                end
                %disp(strcat('Data saved: ',monthsName(m),{' - '},num2str(yearC)));
            end
            disp(strcat('Data saved: ',{' '},num2str(yearC)));
            varlist = {'mind','maxd','data'};
            clear(varlist{:});
            fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
            fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
            fclose(fid);
        else
            out = [];
            fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
            fprintf(fid, '[ERROR][%s] %s does not exist\n\n',char(datetime('now')),char(fileT2));
            fclose(fid);
        end
    catch exception
        out = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
        switch(exception.identifier)
            case 'MATLAB:Java:GenericException'
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),'The param var2Read does not exist into the .nc file');
            otherwise
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        end
        fclose(fid);
        mailError('monthly',var2Read,'',char(exception.message));
    end
end

function [out,lastDecember] = readFileSeasonal(fileT,var2Read,yearC,logPath,months,seasonsName,lastDecember)
    try
        keySet =   {'Winter','Spring','Summer','Fall'};
        valueSet = [1,2,3,4];
        smap = containers.Map(keySet,valueSet);
        scale = 84600;
        %data = nc_varget(char(fileT),var2Read);
        [data,err] = readNC(fileT,var2Read);
        if ~isnan(err)
            out = [];
            fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
            fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(err));
            fclose(fid);
            %mailError('seasonal',var2Read,'',char(err));
            return;
        end
        data = scale.*data;
        lPos = 0;      
        out = [];
        season_map = [2 5 8 11];
        days = length(data(:,1,1));
        dPlot = [NaN,NaN,NaN,NaN];
        for i=1:1:length(seasonsName)
            dPlot(smap(char(seasonsName(i)))) = 1;
        end
        for s=1:1:length(dPlot)
            fPos = lPos + 1;
            if s > 1
                init = season_map(s-1)+1;
            else
                init = 1;
            end
            for m=init:1:season_map(s)
                if(leapyear(yearC)&& s==1 && days==366)
                    lPos = lPos + months(m) + 1; % Leap year
                else
                    lPos = lPos + months(m);
                end
            end
            if ~isnan(dPlot(s))
                if s==1
                    nSeason = cat(1,lastDecember,data(fPos:lPos,:,:));
                else
                    nSeason = data(fPos:lPos,:,:);
                end
                out = cat(1,out,nanmean(nSeason,1));
            end
            %disp(strcat('Data saved: ',seasonsName(s),{' - '},num2str(yearC)));
        end
        fPos = lPos + 1;
        lastDecember = nanmean(data(fPos:days,:,:),1);
        disp(strcat('Data saved: ',{' '},num2str(yearC)));
        clear data;
        fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
        fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
        fclose(fid);
    catch exception
        out = [];
        lastDecember = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
        fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        fclose(fid);
        %mailError('seasonal',var2Read,'',char(exception.message));
    end
end

function [out,lastDecember] = readFileSeasonalTemp(fileT,var2Read,yearC,logPath,months,seasonsName,lastDecember)
    try
        scale = 273.15;
        keySet = {'Winter','Spring','Summer','Fall'};
        valueSet = [1,2,3,4];
        smap = containers.Map(keySet,valueSet);
        fileT2 = fileT.substring(0,fileT.lastIndexOf(strcat('/',var2Read)));
        fileT2 = fileT2.concat('/tasmax_day/');
        fileT2 = fileT2.concat(fileT.substring(fileT.lastIndexOf('day/')+4));
        if(exist(char(fileT2),'file'))
            %mind = nc_varget(char(fileT),var2Read);
            %maxd = nc_varget(char(fileT2),'tasmax');            
            [mind,err] = readNC(fileT,var2Read);
            if ~isnan(err)
                out = [];
                fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(err));
                fclose(fid);
                %mailError('seasonal',var2Read,'',char(err));
                return;
            end            
            [maxd,err] = readNC(fileT2,'tasmax');
            if ~isnan(err)
                out = [];
                fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(err));
                fclose(fid);
                return;
            end
            data = (mind+maxd)/2;
            data = data - scale;
            lPos = 0;      
            out = [];
            season_map = [2 5 8 11];
            days = length(data(:,1,1));
            dPlot = [NaN,NaN,NaN,NaN];
            for i=1:1:length(seasonsName)
                dPlot(smap(char(seasonsName(i)))) = 1;
            end
            for s=1:1:length(seasonsName)
                fPos = lPos + 1;
                if s > 1
                    init = season_map(s-1)+1;
                else
                    init = 1;
                end
                for m=init:1:season_map(s)
                    if(leapyear(yearC)&& s==1 && days==366 && m==2)
                        lPos = lPos + months(m) + 1; % Leap year
                    else
                        lPos = lPos + months(m);
                    end
                end
                
                if ~isnan(dPlot(s))
                    if s==1
                        nSeason = cat(1,lastDecember,data(fPos:lPos,:,:));
                    else
                        nSeason = data(fPos:lPos,:,:);
                    end
                    out = cat(1,out,nanmean(nSeason,1));
                end
                %disp(strcat('Data saved: ',seasonsName(s),{' - '},num2str(yearC)));
            end
            fPos = lPos + 1;
            lastDecember = nanmean(data(fPos:days,:,:),1);
            disp(strcat('Data saved: ',{' '},num2str(yearC)));
            varlist = {'mind','maxd','data'};
            clear(varlist{:});
            fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
            fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
            fclose(fid);
        else
            out = [];
            lastDecember = [];
            fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
            fprintf(fid, '[ERROR][%s] %s does not exist\n\n',char(datetime('now')),char(fileT2));
            fclose(fid);
        end
    catch exception
        out = [];
        lastDecember = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
        switch(exception.identifier)
            case 'MATLAB:Java:GenericException'
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),'The param var2Read does not exist into the .nc file');
            otherwise
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        end
        fclose(fid);
        %mailError('seasonal',var2Read,'',char(exception.message));
    end
end

function [out] = readFileTemp(fileT,var2Read,yearC,logPath)
    try
        scale = 273.15;
        fileT2 = fileT.substring(0,fileT.lastIndexOf(strcat('/',var2Read)));
        fileT2 = fileT2.concat('/tasmax_day/');
        fileT2 = fileT2.concat(fileT.substring(fileT.lastIndexOf('day/')+4));
        if(exist(char(fileT2),'file'))            
            [mind,err] = readNC(fileT,var2Read);
            if ~isnan(err)
                out = [];
                fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(err));
                fclose(fid);
                mailError('yearly',var2Read,'',char(err));
                return;
            end            
            [maxd,err] = readNC(fileT2,'tasmax');
            if ~isnan(err)
                out = [];
                fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(err));
                fclose(fid);
                return;
            end
            data = (mind+maxd)/2;
            out = nanmean(data-scale,1);
            disp(strcat('Data saved: ',num2str(yearC)));
            varlist = {'mind','maxd','data'};
       	    try
                clear(varlist{:});
            catch
            	disp('Error, cannot delete temp vars');
            end
            fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
            fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
            fclose(fid);
        else
            out = [];
            fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
            fprintf(fid, '[ERROR][%s] %s does not exist\n\n',char(datetime('now')),char(fileT2));
            fclose(fid);
        end
    catch exception
        out = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
        switch(exception.identifier)
            case 'MATLAB:Java:GenericException'
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),'The param var2Read does not exist into the .nc file');
            otherwise
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        end
        fclose(fid);
        mailError('yearly',var2Read,'',char(exception.message));
    end
end

function [] = PlotData(data2D,label,path,name)
    disp('Generating map');
    % Extend the map to the longitude (360) and latitude (0) field
    A=data2D(:,1);
    data2Dh=[data2D,A];
    
    % New map
    longitud = linspace(0,360,length(data2D(1,:))+1);
    latitud = linspace(-90,90,length(data2D(:,1)));
    
    [longrat,latgrat]=meshgrat(longitud,latitud);
    testi=data2Dh;

    p=10;%p=round(latitud(2)-latitud(1));%[25:15:30];
    f = figure('visible', 'off');
    hold on;
    worldmap([-90 90],[-180 180])
    mlabel('off')
    plabel('off')
    framem('on')
    set(gcf,'Color',[1,1,1]);
    %colormap(parula);
    colormap(jet);
    try
        %[c,h]=contourfm(latgrat,longrat,testi',p,'LineStyle','none');
        contourfm(latgrat,longrat,testi',p,'LineStyle','none');
        worldmap
        for i=1:length(hi)
            plotm(hi(i).lat,hi(i).long,'k')
        end
        cb = colorbar('southoutside');
        cb.Label.String = label;
        print(strcat(path,char(name)),'-depsc','-tiff')
        close(f);
        disp('Map saved');
    catch exception
        disp(exception.message);
        close(f);
        disp('Map not saved');
        %mailError('','','',char(exception.message));
    end
end

function [data,error] = readNC(path,var2Read)
    var2Readid = 99999;
	error = NaN;
    missingValue = 1.e+20;
    try
        % Catching data from original file
        ncid = netcdf.open(char(path));%,'NC_NOWRITE');
        [~,nvar,~,~] = netcdf.inq(ncid);
        for i=0:1:nvar-1
            [varname,~,~,~] = netcdf.inqVar(ncid,i);
            switch(varname)
                case var2Read
                    var2Readid = i;
            end
        end
        data = permute(netcdf.getVar(ncid,var2Readid,'double'),[3 2 1]);%ncread(char(fileT),var2Read);
        data(abs(data)>=missingValue) = NaN;
        if isempty(data)
            error = 'Empty dataset';
        end
        netcdf.close(ncid)
    catch exception
        data = [];
        try
            netcdf.close(ncid)
        catch
            error = 'I/O ERROR';
            return;
        end
        error = exception.message;
    end
end
function [months] = checkMonths(monthsName,month)
    tmp = {};
    switch char(lower(month))
        case 'jan'
            tmp = {'January'};
        case 'feb'
            tmp = {'February'};
        case 'mar'
            tmp = {'March'};
        case 'apr'
            tmp = {'April'};
        case 'may'
            tmp = {'May'};
        case 'jun'
            tmp = {'June'};
        case 'jul'
            tmp = {'July'};
        case 'aug'
            tmp = {'August'};
        case 'sep'
            tmp = {'September'};
        case 'oct'
            tmp = {'October'};
        case 'nov'
            tmp = {'November'};
        case 'dec'
            tmp = {'December'};
    end
    months = union(monthsName,tmp);
end

function [seasons] = checkSeasons(seasonsName,season)
    tmp = {};
    switch char(lower(season))
        case 'sum'
            tmp = {'Summer'};%{'Winter','Spring','Fall'};
        case 'win'
            tmp  = {'Winter'};%{'Spring','Summer','Fall'};
        case 'spr'
            tmp = {'Spring'};%{'Winter','Summer','Fall'};
        case 'fal'
            tmp = {'Fall'};%{'Winter','Spring','Summer'};
    end
    seasons = union(seasonsName,tmp);
end

function [] = mailError(type,var2Read,experimentName,msg)
    %RECIPIENTS = {'villegas.roberto@hotmail.com','rodrigo.castillorodriguez@ucr.ac.cr'};
    RECIPIENTS = {'villegas.roberto@hotmail.com'};
    subject = strcat({'[MATLAB][ERROR] '},type,{' - '},var2Read,{' - '},experimentName);
    msj = strcat({'An exception has been thrown: '},msg);
    mailsender(RECIPIENTS,subject,msj);
end