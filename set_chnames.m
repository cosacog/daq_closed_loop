function set_chnames(plotHandle, ch_names)
% set channel names to plot handle (ie.plotHandle.UserData.ch_info.chname)
% Usage: set_chnames(plotHandle, ch_names)
% params:
%   plotHandle
%   ch_names: cell of channel names
for ii = 1:length(ch_names)
    plotHandle.UserData.ch_info(ii).chname = ch_names{ii};
end
end
