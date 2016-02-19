function ret = muse_read_buffer (match_string,desired_size)
%the argument should be a string to filter de data
match_string='acc';
desired_size=100;

v = evalin('base', 'server_muse_io');
ret=[];
while size(ret,1)<desired_size
      m = osc_recv(server_muse_io);
      % check to see if anything is there...
      if length(m) > 0
        % the address of the first message..
     %   m{1}.path
        % and its data part
     %   m{1}.data
        % the last message... etc.
     %   m{length(m)}
        %%%filter data
        a={};
        k=1;
        for i = 1:length(m)
           if (findstr(m{i}.path,match_string))
               a{k}=m{i};
               k=k+1;
           end
           %m{i}
        end
      else
          display "nothing was read in function muse_read_acc_buffer"
          return
      end

    %prepare data in more suitable format

    if match_string=='acc';
        %%ACC will have a matrix o 3xN.
        for i=1:length(a)
            ret=[ret;cell2mat(a{i}.data)];
        end
    end

end

