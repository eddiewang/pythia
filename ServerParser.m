function ServerParser (server)

addpath('osc-mexmaci64');
%The server will listen to all incoming osc 
%filters it and stores in a mat file, withing the variable data
disp ('Staring Server')
muse_port = 8000;
PC_SDK = 1;

file_name='muse_values.mat';

if (~exist('server','var'))
    try
    server = osc_new_server(muse_port) ;   
    save('server.mat','server');
    catch
        try
        load('server.mat','server');
        osc_free_server(server)
        server = osc_new_server(muse_port) ;   
        save('server.mat','server');
        catch
             disp ('Restart Matlab is required')
        end
    end
end
disp(server);

try

if PC_SDK
string_eeg='/muse/eeg';
string_alpha_absolute='/muse/elements/alpha_absolute';
string_beta_absolute='/muse/elements/beta_absolute';
string_delta_absolute='/muse/elements/delta_absolute';
string_gamma_absolute='/muse/elements/gamma_absolute';
string_theta_absolute='/muse/elements/theta_absolute';
string_horseshoe='/muse/elements/horseshoe';
string_concentration='/muse/elements/experimental/concentration';
else
string_eeg = '/EEG';
string_alpha_absolute='/ALPHA_ABSOLUTE';
string_beta_absolute='/BETA_ABSOLUTE';
string_delta_absolute='/DELTA_ABSOLUTE';
string_gamma_absolute='/GAMMA_ABSOLUTE';
string_theta_absolute='/THETA_ABSOLUTE';
string_horseshoe='/HORSESHOE';
string_concentration='/muse/elements/horseshoe'; %NEEDS TO BE CORRECTED
end
    
data={};
arranged_data={}; 
arranged_data.eeg=[];
total_scanned_records=0;
counter=[0,0,0,0,0,0,0];
data_balanced=0;
i=1;
tic
while true
    tic
    %read data
    try
        %osc_recv
        new_data = osc_recv(server,1);
        %disp (new_data{aux}.path)
        catch exception
        %stop(T);
        disp '*****  ERROR *****'       
        getReport(exception)
        disp '***********************************************'        
    end 
        %eliminate the unwanted data.            
        for (aux=1:length(new_data))
            switch new_data{aux}.path
                case string_eeg
                    new_data{aux}.path='/EEG' ;
                    sapo=1;
                    counter(sapo)=counter(sapo)+1;
                    %arragement of the data in vectors
                       values = [new_data{aux}.data{1}; ...
                       new_data{aux}.data{2}; ...
                       new_data{aux}.data{3}; ...
                       new_data{aux}.data{4}];                              
                    arranged_data.eeg=[arranged_data.eeg values];

                case string_alpha_absolute
                    new_data{aux}.path='/ALPHA_ABSOLUTE' ;
                    sapo=2;
                    counter(sapo)=counter(sapo)+1;                                            
                case string_beta_absolute
                    new_data{aux}.path='/BETA_ABSOLUTE';
                    sapo=3;
                    counter(sapo)=counter(sapo)+1;                                       

                case string_gamma_absolute
                    new_data{aux}.path='/GAMMA_ABSOLUTE';
                    sapo=4;
                    counter(sapo)=counter(sapo)+1;

                case string_delta_absolute
                        new_data{aux}.path='/DELTA_ABSOLUTE';
                    sapo=5;
                    counter(sapo)=counter(sapo)+1;

                case string_theta_absolute
                        new_data{aux}.path='/THETA_ABSOLUTE';
                    sapo=6;
                    counter(sapo)=counter(sapo)+1;                    
                case string_horseshoe
                    new_data{aux}.path='/HORSESHOE'    ;
                    sapo=7;
                    counter(sapo)=counter(sapo)+1; 
                case '/ACCELEROMETER'
                    new_data{aux}=[];

                otherwise
                new_data{aux}.path;
                new_data{aux}=[];
            end
            total_scanned_records=total_scanned_records+1;

        end
        new_data=new_data(~cellfun('isempty',new_data));
        data=[data,new_data];
        for k=1:length(new_data)
            if (length(new_data{k}.data)) < 4
                a=1;
            end
        end
        %check if the number of entries for the ower are unbalanced
        if (counter(2)==counter(3)&...
                counter(3)==counter(4)&...
                counter(4)==counter(5)&...
                counter(5)==counter(6))
            data_balanced=1;
            size_of_unbalanced_window=0;
            %disp balanced
        else
            data_balanced=0;
            if (length(data)>300)
                disp 'Size of data exceeded and not balanced. Data reset' 
                data={}; 
                arranged_data={}; arranged_data.eeg=[];
                total_scanned_records=0;
                counter=[0,0,0,0,0,0,0];                    
            end
        end

        %trunk if there is too much data
        %if (length(data)>10000)
        %    toc
        %    disp 'Data trunked!'
        %    data=data(length(data)-10000:end);
        %end
        %only writes balanced data
        %if file does not exists, means it wasn t read yet. write and
        %delte the data. Otherwise keep going
        if and(data_balanced,(~exist(file_name,'file')))
            %file=fopen(file_name,'w');
            save(file_name,'data','arranged_data');                
            %fclose(file);  
            fprintf('File saved! with %i/%i records. Collection and recorded %4.2f sec \n',length(data),total_scanned_records,toc);
            data={}; 
            arranged_data={}; arranged_data.eeg=[];
            total_scanned_records=0;
            counter=[0,0,0,0,0,0,0];
        else
            %disp('File not read yet!');
        end
    %break
    i=i+1;
    if (i==1)
        disp 'working...'
        break
    end   
end
 
catch
 osc_free_server(server)
 delete('server.mat')
 clear server
end

% parse_data(hfigure,data)
 