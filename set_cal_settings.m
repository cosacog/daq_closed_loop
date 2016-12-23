function set_cal_settings(plotHandle, cal_settings)
% set cal_settings
% Usage: set_cal_settings(plotHandle, cal_settings)
usrdata = plotHandle.UserData;
for ii = 1:length(cal_settings)
    idx_ch = cal_settings(ii).idx;
    usrdata.ch_info(idx_ch).cal_range = cal_settings(ii).cal;
    usrdata.ch_info(idx_ch).unit = cal_settings(ii).unit;
    usrdata.ch_info(idx_ch).done_cal = false;
    disp(usrdata.ch_info(idx_ch));
end
set(plotHandle, 'UserData', usrdata)
end