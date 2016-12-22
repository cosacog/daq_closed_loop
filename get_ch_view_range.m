function get_ch_view_range(plotHandle)
% get channel view range for plot
% Usage: get_ch_view_range(plotHandle)
% params:
%   plotHandle
ch_info = plotHandle.UserData.ch_info;
for ii = 1:length(ch_info)
    disp(sprintf('%dch %s view range unit(%s)',ii, ch_info(ii).chname, ch_info(ii).unit))
    disp(ch_info(ii).range_view)
end
end