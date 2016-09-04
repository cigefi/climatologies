# Climatologies
This script is capable of reading recursively a bunch of netcdf files and generate 4 types of climatologies: yearly, monthly, seasonal, and biweekly.
The unique requirement for the data is to be organized in the following structure:<br/>
[EXPERIMENT NAME]<br/>
------ [MONITORING DATA]<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;------ ####.nc<br />

To obtain this file structure, you can use [fileOrganize.sh](https://github.com/cigefi/fileManager/) script.

### Yearly (default mode)
##### Input
- (Required) dirName: Path of the directory that contains the files and path to save the output files (cell array)
- (Optional) type: yearly
- (Optional) extra: This param contains extra configuration options, such as, var2Read (variable to be read, use 'ncdump -h' command from bash to get the variable names) and range of years (use 'f' to specify the lowest year, 'l' to specify the top year, and 'vec' to specify a vector of year)s (cell array)

##### Output (3 files)
- log file: File that contains the list of property processed .nc files and the errors
- [Experiment-Name]-[var2Read].dat file: File that contains a 2-Dimensional structure with the values point by point
- [Experiment-Name].eps file: File that contains a plot of the data in high resolution

##### Function invocation
Reads all the .nc files from _SOURCE_PATH_ and generates yearly climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'});
```
Same as above
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'yearly'});
```
Reads all the .nc files wich contain the variable _pr_ from _SOURCE_PATH_ and generates daily climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'yearly'},{'var2Read',{'pr'}});
```
Same as above, but the lowest data to be read is from 1950
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'yearly'},{'var2Read',{'pr'},'f',1950});
```
Same as above, but the data to be read is from the range 1950 to 2000
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'yearly'},{'var2Read',{'pr'},'f',1950,'l',2000});
```
Same as above, but the data to be read is from the years _1956_,_1988_, and _2004_
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'yearly'},{'var2Read',{'pr'},'vec',[1988,2004,1956]});
```
###### Alternative forms - parameters
The optional parameter _var2Read_ can take one of the following forms:
```matlab
... {'var2Read',{'pr','tasmax'}, ...}
```
```matlab
... {'var2Read',{'pr','tasmax','tasmean'}, ...}
```
```matlab
... {'var2Read',{'pr','tasmax','tasmean','tasmin'}, ...}
```


### Monthly
##### Input
- (Required) dirName: Path of the directory that contains the files and path to save the output files (cell array)
- (Required) type: monthly
- (Optional) extra: This param contains extra configuration options, such as, var2Read (variable to be read, use 'ncdump -h' command from bash to get the variable names) and range of years (use 'f' to specify the lowest year, 'l' to specify the top year, and 'vec' to specify a vector of year)s (cell array)

##### Output (3 to 25 files)
- log file: File that contains the list of property processed .nc files and the errors
- [Experiment-Name]-[Month].dat file: File that contains a 2-Dimensional structure with the values point by point
- [Experiment-Name]-[Month].eps file: File that contains a plot of the data in high resolution

##### Function invocation
Reads all the .nc files from _SOURCE_PATH_ and generates monthly climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'monthly'});
```
Reads all the .nc files wich contain the variable _pr_ from _SOURCE_PATH_ and generates monthly climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'monthly'},{'var2Read',{'pr'}});
```
Same as above, but the lowest data to be read is from 1950
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'monthly'},{'var2Read',{'pr'},'f',1950});
```
Same as above, but the data to be read is from the range 1950 to 2000
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'monthly'},{'var2Read',{'pr'},'f',1950,'l',2000});
```
Same as above, but the data to be read is from the years _1956_,_1988_, and _2004_
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'monthly'},{'var2Read',{'pr'},'vec',[1988,2004,1956]});
```
###### Alternative forms - parameters
Since the latest version of the script, is possible to generate the climatologies for specific months. Using the following convention:
```matlab
| Month   | Param | Month     | Param |
| -----   | ----- | ---       | ---   |
| January | jan   | July      | jul   |
| February| feb   | August    | aug   |
| March   | mar   | September | sep   |
| April   | apr   | October   | oct   |
| May     | may   | November  | nov   |
| June    | jun   | December  | dec   |
```
Then, the parameter _{'monthly'}_ can be replace by:
```matlab
...{'jan'}...
```
```matlab
...{'jan','feb'}...
```
```matlab
...{'jan','dec','mar','apr'}...
```
```matlab
...{'oct','jun'}...
```

### Seasonal
##### Input
- (Required) dirName: Path of the directory that contains the files and path to save the output files (cell array)
- (Required) type: seasonal
- (Optional) extra: This param contains extra configuration options, such as, var2Read (variable to be read, use 'ncdump -h' command from bash to get the variable names) and range of years (use 'f' to specify the lowest year, 'l' to specify the top year, and 'vec' to specify a vector of year)s (cell array)

##### Output (3-9 files)
- log file: File that contains the list of property processed .nc files and the errors
- [Experiment-Name]-[Season].dat file: File that contains a 2-Dimensional structure with the values point by point
- [Experiment-Name]-[Season].eps file: File that contains a plot of the data in high resolution

##### Function invocation
Reads all the .nc files from _SOURCE_PATH_ and generates seasonal climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'seasonal'});
```
Reads all the .nc files wich contain the variable _pr_ from _SOURCE_PATH_ and generates monthly climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'seasonal'},{'var2Read',{'pr'}});
```
Same as above, but the lowest data to be read is from 1950
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'seasonal'},{'var2Read',{'pr'},'f',1950});
```
Same as above, but the data to be read is from the range 1950 to 2000
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'seasonal'},{'var2Read',{'pr'},'f',1950,'l',2000});
```
Same as above, but the data to be read is from the years _1956_,_1988_, and _2004_
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'seasonal'},{'var2Read',{'pr'},'vec',[1988,2004,1956]});
```
###### Alternative forms - parameters
Since the latest version of the script, is possible to generate the climatologies for specific months. Using the following convention:
```matlab
| Season  | Param | 
| -----   | ----- |
| Summer  | sum   |
| Winter  | win   | 
| Fall    | fal   | 
| Spring  | spr   |
```
Then, the parameter _{'seasonal'}_ can be replace by:
```matlab
...{'sum'}...
```
```matlab
...{'win','sum'}...
```
```matlab
...{'sum','win','spr'}...
```
```matlab
...{'spr','sum'}...
```

### Biweekly
##### Input
- (Required) dirName: Path of the directory that contains the files and path to save the output files (cell array)
- (Required) type: biweekly
- (Optional) extra: This param contains extra configuration options, such as, var2Read (variable to be read, use 'ncdump -h' command from bash to get the variable names) and range of years (use 'f' to specify the lowest year, 'l' to specify the top year, and 'vec' to specify a vector of year)s (cell array)

##### Output (5 to 49 files)
- log file: File that contains the list of property processed .nc files and the errors
- [Experiment-Name]-[Month]-[Month Segment].dat file: File that contains a 2-Dimensional structure with the values point by point
- [Experiment-Name]-[Month]-[Month Segment].eps file: File that contains a plot of the data in high resolution

##### Function invocation
Reads all the .nc files from _SOURCE_PATH_ and generates biweekly climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'biweekly'});
```
Reads all the .nc files wich contain the variable _pr_ from _SOURCE_PATH_ and generates biweekly climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'biweekly'},{'var2Read',{'pr'}});
```
Same as above, but the lowest data to be read is from 1950
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'biweekly'},{'var2Read',{'pr'},'f',1950});
```
Same as above, but the data to be read is from the range 1950 to 2000
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'biweekly'},{'var2Read',{'pr'},'f',1950,'l',2000});
```
Same as above, but the data to be read is from the years _1956_,_1988_, and _2004_
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},{'biweekly'},{'var2Read',{'pr'},'vec',[1988,2004,1956]});
```
###### Alternative forms - parameters
Since the latest version of the script, is possible to generate the climatologies for specific months. Using the following convention:
```matlab
| Month   | Param  | Month     | Param  |
| ------- | ------ | --------- | ------ |
| January | jan2   | July      | jul2   |
| February| feb2   | August    | aug2   |
| March   | mar2   | September | sep2   |
| April   | apr2   | October   | oct2   |
| May     | may2   | November  | nov2   |
| June    | jun2   | December  | dec2   |
```
Then, the parameter _{'biweekly'}_ can be replace by:
```matlab
...{'jan2'}...
```
```matlab
...{'jan2','feb2'}...
```
```matlab
...{'jan2','dec2','mar2','apr2'}...
```
```matlab
...{'oct2','jun2'}...
```
###### * The number 2 must be added in order to distinguish between monthly and biweekly climatologies

#### Read saved data
To read the data from .dat files, you can use the command:
```matlab
data = dlmread('MyData.dat');
```
### License
CIGEFI Centre for Geophysical Research<br/>
Universidad de Costa Rica &copy;2016

[Roberto Villegas-Díaz](mailto:roberto.villegas@ucr.ac.cr)
