function set_daq_device(plotHandle, dev)
% set daq device (e.g. 'Dev2')
% Usage: set_daq_device(plotHandle, dev)
% params:
%   plotHandle
%   dev: daq device. e.g.'Dev1'. refer to daq.getDevices()
    plotHandle.UserData.daq_dev = dev;
    disp(plotHandle.UserData)
end