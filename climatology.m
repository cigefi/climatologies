% Function climatology
%
% Prototype: climatology(dirName,type, var2Read,yearZero,yearN)
%            climatology(dirName,type, var2Read)
%            climatology(dirName,type)
%
%
% dirName = Path of the directory that contents the files and path for the
% processing files
% var2Read (Recommended)= Variable to be read (use 'ncdump' to check variable names)
% yearZero (Optional) = Lower year of the data to be read
% yearN (Optional) = Higher year of the data to be read
function [] = climatology(dirName,type,var2Read,yearZero,yearN)
    if nargin < 1
        error('climatology: dirName is a required input')
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
    seasonsName = {'Spring','Summer','Fall','Winter'};
    path = java.lang.String(dirName(1));
    if(path.charAt(path.length-1) ~= '/')
        path = path.concat('/');
    end
    experimentParent = path.substring(0,path.lastIndexOf(strcat('/',var2Read)));
    experimentName = experimentParent.substring(experimentParent.lastIndexOf('/')+1);
    out = [];
    if(length(dirName)>1)
        save_path = java.lang.String(dirName(2));
        if(length(dirName)>2)
            path_log = java.lang.String(dirName(3));
        else
            path_log = java.lang.String(dirName(2));
        end
	else
		save_path = java.lang.String(dirName(1));
		path_log = java.lang.String(dirName(1));
	end
	if(save_path.charAt(save_path.length-1) ~= '/')
		save_path = save_path.concat('/');
	end
	if(path_log.charAt(path_log.length-1) ~= '/')
		path_log = path_log.concat('/');
    end
    fprintf('Processing: %s\n',char(experimentName));
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        if(fileT.substring(fileT.lastIndexOf('.')+1).equalsIgnoreCase('nc'))
            try
                yearC = str2num(fileT.substring(fileT.length-7,fileT.lastIndexOf('.')));
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
%                     frecuency = nc_attget(char(fileT),nc_global,'frequency');
%                     units = nc_attget(char(fileT),var2Read,'units');
                    % Subrutine to writte the data in new Netcdf file
                    switch type
                        case 'daily'
                            switch var2Read
                                case 'pr'
                                    out = mean(cat(1,out,readFile(fileT,var2Read,yearC,path_log)),1);
                                otherwise
                                    out = mean(cat(1,out,readFileTemp(fileT,var2Read,yearC,path_log)),1);
                            end
                        case 'monthly'
                            switch var2Read
                                case 'pr'
                                    n_year = readFileMonthly(fileT,var2Read,yearC,path_log,months,monthsName);
                                otherwise
                                    n_year = readFileMonthlyTemp(fileT,var2Read,yearC,path_log);
                            end
                            if(~isempty(n_year))
                                if(~isempty(out))
                                    out = (out + n_year)/2;
                                else
                                    out = n_year;
                                end
                            end
                        case 'seasonal'
                            disp('In progress...');
                    end
                    %out = cat(1,out,writeFile(fileT,var2Read,yearC,months,save_path,monthsName,path_log));
                end
            catch
                continue;
            end
        else
            if isequal(dirData(f).isdir,1)
                newPath = char(path.concat(dirData(f).name));
                switch nargin
                    case 1 
                        climatology({[newPath],[char(save_path.concat(dirData(f).name))],[char(path_log)]});
                    case 2 % Validates if the type param is received
                        climatology({[newPath],[char(save_path.concat(dirData(f).name))],[char(path_log)]},type);
                    case 3 % Validates if the var2Read param is received
                        climatology({[newPath],[char(save_path.concat(dirData(f).name))],[char(path_log)]},type,var2Read);
                    case 4 % Validates if the yearZero param is received
                        climatology({[newPath],[char(save_path.concat(dirData(f).name))],[char(path_log)]},type,var2Read,yearZero);
                    otherwise
                        climatology({[newPath],[char(save_path.concat(dirData(f).name))],[char(path_log)]},type,var2Read,yearZero,yearN);      
                end
            end
        end
    end
    if(~isempty(out))
        switch type
            case 'daily'
                out = squeeze(out(1,:,:));
                switch(var2Read)
                    case 'pr'
                        units = 'mm';
                        frequency = 'day';
                        PlotData(out,strcat('Precipitation (',units,{' '},frequency,')'),char(path),char(experimentName));
                    case 'tasmin'
                        units = '°C';
                        frequency = 'day';
                        PlotData(out,strcat('Temperature (',units,{' '},frequency,')'),char(path),char(experimentName));
                    otherwise
                        PlotData(out,'',char(path));
                end
                fileT = path.concat(strcat(var2Read,'.dat'));
                save(char(fileT),'out'); 
            case 'monthly'
                for m=1:1:12
                    disp(strcat('Processing',{' '},monthsName(m)));
                    c_month = squeeze(out(m,:,:));
                    switch(var2Read)
                        case 'pr'
                            units = 'mm';
                            frequency = 'day';
                            PlotData(c_month,strcat('Precipitation (',units,{' '},frequency,')'),char(path),strcat(char(experimentName),'-',monthsName(m)));
                        case 'tasmin'
                            units = '°C';
                            frequency = 'day';
                            PlotData(c_month,strcat('Temperature (',units,{' '},frequency,')'),char(path),strcat(char(experimentName),'-',monthsName(m)));
                        otherwise
                            PlotData(c_month,'',char(path),strcat(char(experimentName),'-',monthsName(m)));
                    end
                    fileT = path.concat(strcat(monthsName(m),'.dat'));
                    save(char(fileT),'c_month'); 
                end
            case 'seasonal'
                disp('In progress...');
        end
    end
end

function [out] = readFile(fileT,var2Read,yearC,path_log)
    try
        scale = 84600;
        data = nc_varget(char(fileT),var2Read);
        out = mean(scale.*data,1);
        disp(strcat('Data saved: ',num2str(yearC)));
        fid = fopen(strcat(char(path_log),'log.txt'), 'at');
        fprintf(fid, '[SAVED] %s\n',char(fileT));
        fclose(fid);
    catch
        out = [];
        fid = fopen(strcat(char(path_log),'log.txt'), 'at');
        fprintf(fid, '[ERROR] %s\n',char(fileT));
        fclose(fid);
    end
end

function [out] = readFileMonthly(fileT,var2Read,yearC,path_log,months,monthsName)
    try
        scale = 84600;
        data = nc_varget(char(fileT),var2Read);
        data = scale.*data;
        lPos = 0;
        out = [];
        for m=1:1:length(months)
            fPos = lPos + 1;
            if(leapyear(yearC)&& m==2 && length(data(:,1,1))==366)
                lPos = months(m) + fPos; % Leap year
            else
                lPos = months(m) + fPos -1;
            end
            out = cat(1,out,mean(data(fPos:lPos,:,:),1));
            disp(strcat('Data saved: ',monthsName(m),{' - '},num2str(yearC)));
        end
        fid = fopen(strcat(char(path_log),'log.txt'), 'at');
        fprintf(fid, '[SAVED] %s\n',char(fileT));
        fclose(fid);
    catch
        out = [];
        fid = fopen(strcat(char(path_log),'log.txt'), 'at');
        fprintf(fid, '[ERROR] %s\n',char(fileT));
        fclose(fid);
    end
end

function [out] = readFileMonthlyTemp(fileT,var2Read,yearC,path_log,months,monthsName)
    try
        scale = 273.15;
        fileT2 = fileT.substring(0,fileT.lastIndexOf(strcat('/',var2Read)));
        fileT2 = fileT2.concat('/tasmax_day/');
        fileT2 = fileT2.concat(fileT.substring(fileT.lastIndexOf('day/')+4));
        if(exist(char(fileT2),'file'))
            min = nc_varget(char(fileT),var2Read);
            max = nc_varget(char(fileT2),'tasmax');
            lPos = 0;
            out = [];
            for m=1:1:length(months)
                fPos = lPos + 1;
                if(leapyear(yearC)&& m==2 && length(min(:,1,1))==366 && length(max(:,1,1))==366)
                    lPos = months(m) + fPos; % Leap year
                else
                    lPos = months(m) + fPos -1;
                end
                data = (min(fPos:lPos,:,:)+max(fPos:lPos,:,:))/2;
                out = cat(1,out,mean(data-scale,1));
                disp(strcat('Data saved: ',monthsName(m),{' - '},num2str(yearC)));
            end
            fid = fopen(strcat(char(path_log),'log.txt'), 'at');
            fprintf(fid, '[SAVED] %s\n',char(fileT));
            fclose(fid);
        end
    catch
        out = [];
        fid = fopen(strcat(char(path_log),'log.txt'), 'at');
        fprintf(fid, '[ERROR] %s\n',char(fileT));
        fclose(fid);
    end
end

function [out] = readFileTemp(fileT,var2Read,yearC,path_log)
    try
        scale = 273.15;
        fileT2 = fileT.substring(0,fileT.lastIndexOf(strcat('/',var2Read)));
        fileT2 = fileT2.concat('/tasmax_day/');
        fileT2 = fileT2.concat(fileT.substring(fileT.lastIndexOf('day/')+4));
        if(exist(char(fileT2),'file'))
            min = nc_varget(char(fileT),var2Read);
            max = nc_varget(char(fileT2),'tasmax');
%             data = cat(1,min,max);
            data = (min+max)/2;
%             data2 = mean(cat(1,min,max),1);
            out = mean(data-scale,1);
            disp(strcat('Data saved: ',num2str(yearC)));
            fid = fopen(strcat(char(path_log),'log.txt'), 'at');
            fprintf(fid, '[SAVED] %s\n',char(fileT));
            fclose(fid);
        end
    catch
        out = [];
        fid = fopen(strcat(char(path_log),'log.txt'), 'at');
        fprintf(fid, '[ERROR] %s\n',char(fileT));
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
        [c,h]=contourfm(latgrat,longrat,testi',p,'LineStyle','none');
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