function datPlot(dirName,var2Read)
   if nargin < 1
        error('datPlot: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    switch nargin
        case 1 % Validates if the var2Read param is received
            temp = java.lang.String(dirName(1)).split('/');
            temp = temp(end).split('_');
            var2Read = char(temp(1)); % Default value is taken from the path
    end
    dirData = dir(char(dirName(1)));  % Get the data for the current directory
    path = java.lang.String(dirName(1));
    if(path.charAt(path.length-1) ~= '/')
        path = path.concat('/');
    end
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
    
    try
		experimentParent = path.substring(0,path.lastIndexOf(strcat('/',var2Read)));
		experimentName = experimentParent.substring(experimentParent.lastIndexOf('/')+1);
    catch
        experimentName = '[CIGEFI]'; % Dafault value
    end
    processing = 0;
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        ext = fileT.substring(fileT.lastIndexOf('.')+1);
        if(ext.equalsIgnoreCase('dat'))
            if ~strcmp(experimentName,'[CIGEFI]')
                if(~processing)
                    fprintf('Plotting: %s\n',char(experimentName));
                    processing = 1;
                    if ~exist(char(logPath),'dir')
                        mkdir(char(logPath));
                    end
                    if(exist(strcat(char(logPath),'log.txt'),'file'))
                        delete(strcat(char(logPath),'log.txt'));
                    end
                end
                plotFile(fileT,savePath,logPath);
            end
            
        else
            if isequal(dirData(f).isdir,1)
                newPath = char(path.concat(dirData(f).name));
                if length(dirName) > 2
                    if nargin > 1
                        datPlot({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},var2Read);
                    else
                        datPlot({newPath,char(savePath.concat(dirData(f).name)),char(logPath)});
                    end
                else
                    if nargin > 1
                        datPlot({newPath,char(savePath.concat(dirData(f).name))},var2Read);
                    else
                        datPlot({newPath,char(savePath.concat(dirData(f).name))});
                    end
                end
            end
        end
    end
end

function plotFile(fileT,savePath,logPath)
    % New file configuration
    if ~exist(char(savePath),'dir')
        mkdir(char(savePath));
    end
    ncid = NaN;
    newFile = NaN;
    try
        A = dlmread(char(fileT));
        tmp = fileT.split('/');
        tmp = char(tmp(end).split('.dat'));
        newFile = char(savePath.concat(tmp));

        % Creating new nc file
        if exist(newFile,'file')
            delete(newFile);
        end
        B=A(:,1);
        Ah=[A,B];
        Ah = smooth2a(Ah,3);
        longitud = linspace(0,360,length(A(1,:))+1);
        latitud = linspace(-90,90,length(A(:,1)));    
        [longrat,latgrat]=meshgrat(longitud,latitud);
        testi=Ah;
        p=10;
        f = figure('visible', 'off');
        hold on;
        worldmap([-90 90],[-180 180])
        mlabel('off')
        plabel('off')
        framem('on')
        set(gcf,'Color',[1,1,1]);
        hold on;
        colormapa=jet;
        colormapa(1,:)=[1 1 1];
        colormapa(2,:)=[6/7 6/7 1];
        colormapa(3,:)=[5/7 5/7 1];
        colormapa(4,:)=[4/7 4/7 1];
        colormapa(5,:)=[3/7 3/7 1];
        colormapa(6,:)=[2/7 2/7 1];
        colormapa(7,:)=[1/7 1/7 1];
        colormapa(8,:)=[0 0 1];
        colormap(colormapa);
        [c,h]=contourfm(latgrat,longrat,testi',p,'LineStyle','none');
        hi = worldhi([-90 90],[-180 180]);
        for i=1:length(hi)
            plotm(hi(i).lat,hi(i).long,'k')
        end
        label = 'Precipitation [mm/day]';
        cb = colorbar('southoutside');
        xlabel(cb,label);
        caxis([2 16])
        print(newFile,'-depsc','-tiff');
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
    	fprintf(fid, '[SAVED][%s] %s\n',char(datetime('now')),char(strcat(tmp,'.dat')));
    	fclose(fid);
    	disp(char(strcat({'Map saved:  '},{' '},char(strcat(tmp,'.dat')))));
    catch exception
        disp(exception.message);
        if ~isnan(ncid)
            netcdf.close(ncid);
        end
        if ~isnan(newFile)
            if exist(newFile,'file')
                delete(newFile);
            end
        end
        fid = fopen(strcat(char(logPath),'log.txt'), 'at');
        fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
        fclose(fid);
        return;
    end
end