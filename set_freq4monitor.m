function set_freq4monitor(plotHandle, freq)
% set frequency for monitor of eeg power
% Usage: set_freq4monitor(plotHandle, freq)
% params:
%   plotHandle
%   freq: frequency (Hz) for monitor of eeg power (e.g.10)
plotHandle.UserData.freq_oi = freq;
disp(plotHandle.UserData)
end
