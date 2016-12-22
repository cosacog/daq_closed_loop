function get_chinfo(plotHandle, idx_ch)
% get channel info
% Usage: get_chinfo(plotHandle, idx_ch)
% params:
%   plotHandle
%   idx_ch: index of channel to be displayed
    disp(plotHandle.UserData.ch_info(idx_ch))
end
