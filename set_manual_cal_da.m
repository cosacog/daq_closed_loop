function set_manual_cal_da(plotHandle, ch, ratio_da, dig_baseline)
% set calibration DA ratio and digital baseline
% Usage: set_manual_cal_da(plotHandle, ratio_da, dig_baseline)
% params:
%   plotHandle
%   ch: channel
%   ratio_da: ratio of DA convert
%   dig_baseline: baseline correction of digital values
    plotHandle.UserData.ch_info(ch).ratio_cal = ratio_da;
    plotHandle.UserData.ch_info(ch).baseline = dig_baseline;
    disp(plotHandle.UserData.ch_info(ch))
end
