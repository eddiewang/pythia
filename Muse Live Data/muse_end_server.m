function muse_end_server()

server_muse_io = evalin('base', 'server_muse_io');
    try
    osc_free_server(server_muse_io);
    catch
        error('server not closed')
    end
    display 'server closed'
    assignin('base', 'server_muse_io', 0);
end
