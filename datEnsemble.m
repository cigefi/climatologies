function datEnsemble(dirName,var2Read)
   if nargin < 1
        error('dat2emsemble: dirName is a required input')
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
        subexperimentParent = experimentParent.substring(0,experimentParent.lastIndexOf('/'));
		%experimentName = experimentParent.substring(experimentParent.lastIndexOf('/')+1);
        experimentName1 = experimentParent.substring(experimentParent.lastIndexOf('/')+1);
        experimentName2 = subexperimentParent.substring(subexperimentParent.lastIndexOf('/')+1);
        experimentName = strcat(char(experimentName2),'/',char(experimentName1));
    catch
        experimentName = '[CIGEFI]'; % Dafault value
    end
    processing = 0;
    out = [];
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        ext = fileT.substring(fileT.lastIndexOf('.')+1);
        if(ext.equalsIgnoreCase('dat'))
            if ~strcmp(experimentName,'[CIGEFI]')
                if(~processing)
                    fprintf('Processing: %s/%s_day\n',char(experimentName),char(var2Read));
                    processing = 1;
                    if ~exist(char(logPath),'dir')
                        mkdir(char(logPath));
                    end
                    if(exist(strcat(char(logPath),'log.txt'),'file'))
                        delete(strcat(char(logPath),'log.txt'));
                    end
                end
                try
                    nd = dlmread(char(fileT));
                    out = cat(3,out,nd);
                    
                    if ~isempty(out)&&length(out(1,1,:))>(length(dirData)-3)
                        out = nanmean(out,3);
                        fileT = savePath.concat(strcat('[ENSEMBLE]',char(experimentName2),'-',char(experimentName1),'-',var2Read,'.dat'));
                        dlmwrite(char(fileT),out);
                    end
                catch e
                    %disp(char(fileT));
                    disp(e.message);
                end
            end      
        else
            if isequal(dirData(f).isdir,1)
                newPath = char(path.concat(dirData(f).name));
                if length(dirName) > 2
                    if nargin > 1
                        datEnsemble({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},var2Read);
                    else
                        datEnsemble({newPath,char(savePath.concat(dirData(f).name)),char(logPath)});
                    end
                else
                    if nargin > 1
                        datEnsemble({newPath,char(savePath.concat(dirData(f).name))},var2Read);
                    else
                        datEnsemble({newPath,char(savePath.concat(dirData(f).name))});
                    end
                end
            end
        end
    end
end