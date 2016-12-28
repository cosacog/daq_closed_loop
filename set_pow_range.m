function set_pow_range(plotHandle, pow_range)
% set power range for pre3**
% Usage: set_pow_range(plotHandle, pow_range)
% params:
%   plotHandle
%   pow_range: power range. e.g.[0, 2.5]
plotHandle.UserData.pow_range = pow_range;
disp(plotHandle.UserData)
end