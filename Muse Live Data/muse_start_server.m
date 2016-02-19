function s = muse_start_server(address)
     
    try
    server_muse_io =evalin('base', 'server_muse_io');
    catch 
        %doesnt exist
        server_muse_io=0;
    end
    if ~(server_muse_io==0)
        display 'Server already open'
        return 
    end
    try
    s = osc_new_server(address);
    display 'Server open'
    catch
        display error;
        error('nao foi possivel');
    end
    assignin('base', 'server_muse_io', s);
end
