% Function climatology
%
% Prototype: climatology(dirName,type, var2Read,yearZero,yearN)
%            climatology(dirName,type, var2Read)
%            climatology(dirName,type)
%            climatology(dirName)
%
% dirName = Path of the directory that contents the files and path for the
% processing files (cell array)
% type (Recommended) = Variable to specify the type of climatology: daily,
% monthly, seasonal. Default value 'daily'. (string)
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
            type = 'daily';
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
    
    if(yearZero > yearN) % Validates if the yearZero is higher than yearN
        yearTemp = yearZero;
        yearZero = yearN;
        yearN = yearTemp;
    end
    dirData = dir(char(dirName(1)));  % Get the data for the current directory
    months = [31,28,31,30,31,30,31,31,30,31,30,31]; % Reference to the number of days per month
    monthsName = {'January','February','March','April','May','June','July','August','September','October','November','December'};
    seasonsName = {'Winter','Spring','Summer','Fall'};
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
                if(yearC > 0 && strcmp(var2Read,'tasmax')==0)
                    if(~processing)
                        fprintf('Processing: %s\n',char(experimentName));
                        processing = 1;
                    end
                    % Subrutine to writte the data in new Netcdf file
                    switch type
                        case 'daily'
                            switch var2Read
                                case 'pr'
                                    out = mean(cat(1,out,readFile(fileT,var2Read,yearC,logPath)),1);
                                otherwise
                                    out = mean(cat(1,out,readFileTemp(fileT,var2Read,yearC,logPath)),1);
                            end
                        case 'monthly'
                            switch var2Read
                                case 'pr'
                                    newYear = readFileMonthly(fileT,var2Read,yearC,logPath,months,monthsName);
                                otherwise
                                    newYear = readFileMonthlyTemp(fileT,var2Read,yearC,logPath,months,monthsName);
                            end
                            if(~isempty(newYear))
                                if(~isempty(out))
                                    out = (out + newYear)/2;
                                else
                                    out = newYear;
                                end
                            end
                        case 'seasonal'
                            switch var2Read
                                case 'pr'
                                    [newYear,lastDecember] = readFileSeasonal(fileT,var2Read,yearC,logPath,months,seasonsName,lastDecember);
                                otherwise
                                    [newYear,lastDecember] = readFileSeasonalTemp(fileT,var2Read,yearC,logPath,months,seasonsName,lastDecember);
                            end
                            if(~isempty(newYear))
                                if(~isempty(out))
                                    out = (out + newYear)/2;
                                else
                                    out = newYear;
                                end
                            end
                    end
                end
            catch exception
                fid = fopen(strcat(char(logPath),'log.txt'), 'at');
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
                fclose(fid);
                continue;
            end
        else
            if isequal(dirData(f).isdir,1)
                newPath = char(path.concat(dirData(f).name));
                switch nargin
                    case 1 
                        climatology({newPath,char(savePath.concat(dirData(f).name)),char(logPath)});
                    case 2 % Validates if the type param is received
                        climatology({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},type);
                    case 3 % Validates if the var2Read param is received
                        climatology({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},type,var2Read);
                    case 4 % Validates if the yearZero param is received
                        climatology({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},type,var2Read,yearZero);
                    otherwise
                        climatology({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},type,var2Read,yearZero,yearN);      
                end
            end
        end
    end
    if(~isempty(out))
        if ~exist(char(savePath),'dir')
            mkdir(char(savePath));
        end
        switch type
            case 'daily'
                out = squeeze(out(1,:,:));
                switch(var2Read)
                    case 'pr'
                        units = 'mm';
                        frequency = 'day';
                        PlotData(out,strcat('Precipitation (',units,{' '},frequency,')'),char(savePath),char(experimentName));
                    case 'tasmin'
                        units = '°C';
                        frequency = 'day';
                        PlotData(out,strcat('Temperature (',units,{' '},frequency,')'),char(savePath),char(experimentName));
                    otherwise
                        PlotData(out,'',char(savePath));
                end
                fileT = savePath.concat(strcat(char(experimentName),'-',var2Read,'.mat'));
                save(char(fileT),'out'); 
            case 'monthly'
                for m=1:1:12
                    disp(strcat('Processing',{' '},monthsName(m)));
                    currentMonth = squeeze(out(m,:,:));
                    switch(var2Read)
                        case 'pr'
                            units = 'mm';
                            frequency = 'day';
                            PlotData(currentMonth,strcat('Precipitation (',units,{' '},frequency,')'),char(savePath),strcat(char(experimentName),'-',monthsName(m)));
                        case 'tasmin'
                            units = '°C';
                            frequency = 'day';
                            PlotData(currentMonth,strcat('Temperature (',units,{' '},frequency,')'),char(savePath),strcat(char(experimentName),'-',monthsName(m)));
                        otherwise
                            PlotData(currentMonth,'',char(savePath),strcat(char(experimentName),'-',monthsName(m)));
                    end
                    fileT = savePath.concat(strcat(char(experimentName),'-',monthsName(m),'.mat'));
                    save(char(fileT),'currentMonth'); 
                end
            case 'seasonal'
                for s=1:1:4
                    disp(strcat('Processing',{' '},seasonsName(s)));
                    if(s==1)
                        currentSeason = squeeze(out(s,:,:));
                        if ~isempty(lastDecember)
                            lastDecember = squeeze(lastDecember(1,:,:));
                            currentSeason = (currentSeason+lastDecember)/2;
                        end
                    else
                        currentSeason = squeeze(out(s,:,:));
                    end
                    switch(var2Read)
                        case 'pr'
                            units = 'mm';
                            frequency = 'day';
                            PlotData(currentSeason,strcat('Precipitation (',units,{' '},frequency,')'),char(savePath),strcat(char(experimentName),'-',seasonsName(s)));
                        case 'tasmin'
                            units = '°C';
                            frequency = 'day';
                            PlotData(currentSeason,strcat('Temperature (',units,{' '},frequency,')'),char(savePath),strcat(char(experimentName),'-',seasonsName(s)));
                        otherwise
                            PlotData(currentSeason,'',char(savePath),strcat(char(experimentName),'-',seasonsName(s)));
                    end
                    fileT = savePath.concat(strcat(char(experimentName),'-',seasonsName(s),'.mat'));
                    save(char(fileT),'currentSeason'); 
                end
        end
    end
end

function [out] = readFile(fileT,var2Read,yearC,logPath)
    try
        scale = 84600;
        data = nc_varget(char(fileT),var2Read);
        out = mean(scale.*data,1);
        disp(strcat('Data saved: ',num2str(yearC)));
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
        fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
        fclose(fid);
    catch exception
        out = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
        fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        fclose(fid);
    end
end

function [out] = readFileMonthly(fileT,var2Read,yearC,logPath,months,monthsName)
    try
        scale = 84600;
        data = nc_varget(char(fileT),var2Read);
        data = scale.*data;
        lPos = 0;
        out = [];
        days = length(data(:,1,1));
        for m=1:1:length(months)
            fPos = lPos + 1;
            if(leapyear(yearC)&& m==2 && days==366)
                lPos = months(m) + fPos; % Leap year
            else
                lPos = months(m) + fPos -1;
            end
            out = cat(1,out,mean(data(fPos:lPos,:,:),1));
            disp(strcat('Data saved: ',monthsName(m),{' - '},num2str(yearC)));
        end
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
        fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
        fclose(fid);
    catch exception
        out = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
        fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        fclose(fid);
    end
end

function [out] = readFileMonthlyTemp(fileT,var2Read,yearC,logPath,months,monthsName)
    try
%         if(exist(strcat(char(logPath),'log.txt'),'file'))
%             delete(strcat(char(logPath),'log.txt'));
%         end
        scale = 273.15;
        fileT2 = fileT.substring(0,fileT.lastIndexOf(strcat('/',var2Read)));
        fileT2 = fileT2.concat('/tasmax_day/');
        fileT2 = fileT2.concat(fileT.substring(fileT.lastIndexOf('day/')+4));
        if(exist(char(fileT2),'file'))
            min = nc_varget(char(fileT),var2Read);
            max = nc_varget(char(fileT2),'tasmax');
            lPos = 0;
            out = [];
            daysMin = length(min(:,1,1));
            daysMax = length(max(:,1,1));
            for m=1:1:length(months)
                fPos = lPos + 1;
                if(leapyear(yearC)&& m==2 && daysMin==366 && daysMax==366)
                    lPos = months(m) + fPos; % Leap year
                else
                    lPos = months(m) + fPos -1;
                end
                tMin = min(fPos:lPos,:,:);
                tMax = max(fPos:lPos,:,:);
                data = (tMin+tMax)/2;
                out = cat(1,out,mean(data-scale,1));
                disp(strcat('Data saved: ',monthsName(m),{' - '},num2str(yearC)));
            end
            fid = fopen(strcat(char(logPath),'log.txt'), 'at');
            fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
            fclose(fid);
        else
            out = [];
            fid = fopen(strcat(char(logPath),'log.txt'), 'at');
            fprintf(fid, '[ERROR][%s] %s does not exist\n\n',char(datetime('now')),char(fileT2));
            fclose(fid);
        end
    catch exception
        out = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
        switch(exception.identifier)
            case 'MATLAB:Java:GenericException'
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),'The param var2Read does not exist into the .nc file');
            otherwise
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        end
        fclose(fid);
    end
end

function [out,lastDecember] = readFileSeasonal(fileT,var2Read,yearC,logPath,months,seasonsName,lastDecember)
    try
        scale = 84600;
        data = nc_varget(char(fileT),var2Read);
        data = scale.*data;
        lPos = 0;      
        out = [];
        season_map = [2 5 8 11];
        days = length(data(:,1,1));
        for s=1:1:length(seasonsName)
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
            if(s==1)
                nSeason = cat(1,lastDecember,data(fPos:lPos,:,:));
            else
                nSeason = data(fPos:lPos,:,:);
            end
            out = cat(1,out,mean(nSeason,1));
            disp(strcat('Data saved: ',seasonsName(s),{' - '},num2str(yearC)));
        end
        fPos = lPos + 1;
        lastDecember = mean(data(fPos:days,:,:),1);
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
        fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
        fclose(fid);
    catch exception
        out = [];
        lastDecember = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
        fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        fclose(fid);
    end
end

function [out,lastDecember] = readFileSeasonalTemp(fileT,var2Read,yearC,logPath,months,seasonsName,lastDecember)
    try
        scale = 273.15;
        fileT2 = fileT.substring(0,fileT.lastIndexOf(strcat('/',var2Read)));
        fileT2 = fileT2.concat('/tasmax_day/');
        fileT2 = fileT2.concat(fileT.substring(fileT.lastIndexOf('day/')+4));
        if(exist(char(fileT2),'file'))
            min = nc_varget(char(fileT),var2Read);
            max = nc_varget(char(fileT2),'tasmax');
            data = (min+max)/2;
            data = data - scale;
            lPos = 0;      
            out = [];
            season_map = [2 5 8 11];
            days = length(data(:,1,1));
            for s=1:1:length(seasonsName)
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
                if(s==1)
                    nSeason = cat(1,lastDecember,data(fPos:lPos,:,:));
                else
                    nSeason = data(fPos:lPos,:,:);
                end
                out = cat(1,out,mean(nSeason,1));
                disp(strcat('Data saved: ',seasonsName(s),{' - '},num2str(yearC)));
            end
            fPos = lPos + 1;
            lastDecember = mean(data(fPos:days,:,:),1);
            fid = fopen(strcat(char(logPath),'log.txt'), 'at');
            fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
            fclose(fid);
        else
            out = [];
            lastDecember = [];
            fid = fopen(strcat(char(logPath),'log.txt'), 'at');
            fprintf(fid, '[ERROR][%s] %s does not exist\n\n',char(datetime('now')),char(fileT2));
            fclose(fid);
        end
    catch exception
        out = [];
        lastDecember = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
        switch(exception.identifier)
            case 'MATLAB:Java:GenericException'
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),'The param var2Read does not exist into the .nc file');
            otherwise
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        end
        fclose(fid);
    end
end

function [out] = readFileTemp(fileT,var2Read,yearC,logPath)
    try
        scale = 273.15;
        fileT2 = fileT.substring(0,fileT.lastIndexOf(strcat('/',var2Read)));
        fileT2 = fileT2.concat('/tasmax_day/');
        fileT2 = fileT2.concat(fileT.substring(fileT.lastIndexOf('day/')+4));
        if(exist(char(fileT2),'file'))
            min = nc_varget(char(fileT),var2Read);
            max = nc_varget(char(fileT2),'tasmax');
            data = (min+max)/2;
            out = mean(data-scale,1);
            disp(strcat('Data saved: ',num2str(yearC)));
            fid = fopen(strcat(char(logPath),'log.txt'), 'at');
            fprintf(fid, '[SAVED][%s] %s\n\n',char(datetime('now')),char(fileT));
            fclose(fid);
        else
            out = [];
            fid = fopen(strcat(char(logPath),'log.txt'), 'at');
            fprintf(fid, '[ERROR][%s] %s does not exist\n\n',char(datetime('now')),char(fileT2));
            fclose(fid);
        end
    catch exception
        out = [];
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
        switch(exception.identifier)
            case 'MATLAB:Java:GenericException'
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),'The param var2Read does not exist into the .nc file');
            otherwise
                fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        end
        fclose(fid);
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
        hi = worldhi([-90 90],[-180 180]);
        for i=1:length(hi)
            plotm(hi(i).lat,hi(i).long,'k')
        end
        cb = colorbar('southoutside');
        cb.Label.String = label;
        print(strcat(path,char(name)),'-depsc','-tiff')
        close(f);
        disp('Map saved');
    catch
        close(f);
        disp('Map not saved');
    end
end