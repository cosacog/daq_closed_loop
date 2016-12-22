function stopWhenExceedOne(src, event)
global data_store;
if any(event.Data > 6.0)
    disp('Event listner: Detected voltage exceeds 1, stopping acquisition')
    % continuous acquisitions need to be stopped explicitly.
    src.stop()
    plot(event.TimeStamps, event.Data)
else
%     counter = mod(src.ScansAcquired/50,10);
%     src.queueOutputData(data);
    % counter = data_store(2);
    data_store = [data_store; event.Data];
%     counter = 1;
%     fprintf('\b')
%     fprintf('%s%d','Event listner: Continue to acquire:', t_stamps(end))
    fprintf('%d', counter);
end
end
