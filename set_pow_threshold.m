function set_pow_threshold(plotHandle,range_pow_threshold)
% set power threshold to trigger
% Usage: set_pow_threshold(plotHandle, range_pow_threshold)
% params:
%   plotHandle: set after running pre3*
%   range_pow_threshold: range of power threshold (e.g.[0.1, 2.0])
plotHandle.UserData.thr_pow = range_pow_threshold;
disp(plotHandle.UserData)
end
