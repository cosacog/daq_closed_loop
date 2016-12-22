function set_ch_view_range(plotHandle, idx_ch, ranges)
% set channel view ranges
% Usage set_ch_view_range(plotHandle, idx_ch, ranges)
% params:
%   plotHandle
%   idx_ch: index of channel to set ranges
%   ranges: range of viewing (e.g.[-1000 1000])

plotHandle.UserData.ch_info(idx_ch).range_view = ranges;
disp(plotHandle.UserData.ch_info(idx_ch))
end