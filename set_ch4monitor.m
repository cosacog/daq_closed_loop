function set_ch4monitor(plotHandle, ch)
% set frequency for monitor of eeg power
% Usage: set_ch4monitor(plotHandle, freq)
% params:
%   plotHandle
%   ch: channel for monitor of eeg power (e.g.1)
plotHandle.UserData.ch4monitor = ch;
disp(plotHandle.UserData)
end
