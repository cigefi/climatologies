# Climatologies
This script is capable of reading recursively a bunch of netcdf files and generate 3 types of climatologies: daily, monthly, and seasonal.
The unique requirement for the data is to be organized in the following structure:<br/>
[EXPERIMENT NAME]<br/>
------ [MONITORING DATA]<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;------ ####.nc<br />

To obtain this file structure, you can use [fileOrganize.sh](https://github.com/cigefi/fileManager/) script.

### Daily (default mode)
##### Input
- (Required) dirName: Path of the directory that contains the files and path to save the output files (cell array)
- (Optional) type: daily
- (Optional) var2Read: Variable to be read (use 'ncdump -h' command from bash to get the variable names
- (Optional) yearZero: Lower year of the data to be read (integer)
- (Optional) yearN: Higher year of the data to be readed (integer)

##### Output (3 files)
- log file: File that contains the list of property processed .nc files and the errors
- [Experiment-Name]-[var2Read].dat file: File that contains a 2-Dimensional structure with the values point by point
- [Experiment-Name].eps file: File that contains a plot of the data in high resolution

##### Function invocation
Reads all the .nc files from _SOURCE_PATH_ and generates daily climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'})
```
Same as above
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'daily')
```
Reads all the .nc files wich contain the variable _pr_ from _SOURCE_PATH_ and generates daily climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'daily','pr')
```
Same as above, plus the maximum data to be read is from the year 1950
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'daily','pr',1950)
```
Same as above, but the data to be read is from the range 1950 to 2000
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'daily','pr',1950,2000)
```

### Monthly
##### Input
- (Required) dirName: Path of the directory that contains the files and path to save the output files (cell array)
- (Optional) type: monthly
- (Optional) var2Read: Variable to be read (use 'ncdump -h' command from bash to get the variable names
- (Optional) yearZero: Lower year of the data to be read (integer)
- (Optional) yearN: Higher year of the data to be readed (integer)

##### Output (25 files)
- log file: File that contains the list of property processed .nc files and the errors
- [Experiment-Name]-[Month].dat file: File that contains a 2-Dimensional structure with the values point by point
- [Experiment-Name]-[Month].eps file: File that contains a plot of the data in high resolution

##### Function invocation
Reads all the .nc files from _SOURCE_PATH_ and generates monthly climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'monthly')
```
Reads all the .nc files wich contain the variable _pr_ from _SOURCE_PATH_ and generates monthly climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'monthly','pr')
```
Same as above, plus the maximum data to be read is from the year 1950
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'monthly','pr',1950)
```
Same as above, but the data to be read is from the range 1950 to 2000
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'monthly','pr',1950,2000)
```

### Seasonal
##### Input
- (Required) dirName: Path of the directory that contains the files and path to save the output files (cell array)
- (Optional) type: seasonal
- (Optional) var2Read: Variable to be read (use 'ncdump -h' command from bash to get the variable names
- (Optional) yearZero: Lower year of the data to be read (integer)
- (Optional) yearN: Higher year of the data to be readed (integer)

##### Output (10 files)
- log file: File that contains the list of property processed .nc files and the errors
- [Experiment-Name]-[Season].dat file: File that contains a 2-Dimensional structure with the values point by point
- [Experiment-Name]-[Season].eps file: File that contains a plot of the data in high resolution

##### Function invocation
Reads all the .nc files from _SOURCE_PATH_ and generates seasonal climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'seasonal')
```
Reads all the .nc files wich contain the variable _pr_ from _SOURCE_PATH_ and generates seasonal climatology
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'seasonal','pr')
```
Same as above, plus the maximum data to be read is from the year 1950
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'seasonal','pr',1950)
```
Same as above, but the data to be read is from the range 1950 to 2000
```matlab
climatology({'SOURCE_PATH','SAVE_PATH'},'seasonal','pr',1950,2000)
```

#### Read saved data
To read the data from .dat files, you can use the command:
```matlab
data = dlmread('MyData.dat');
```
### License
CIGEFI Centre for Geophysical Research<br/>
Universidad de Costa Rica &copy;2016
