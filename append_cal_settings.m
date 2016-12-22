function cal_settings_out = append_cal_settings(cal_settings, cel_setting)
% append cal settings
% Usage: cal_settings_out = append_cal_settings(cal_settings, cel_setting)
% params:
%   cal_settings: struct including (1) idx:channel index
%                                  (2) cal: range of min max. e.g.[-100 100]
%                                  (3) unit: e.g. 'microV', 'V'
%   cel_setting: cel including (1) idx (2) cal (3) unit
% out:
%   cal_settings_out: struct

% check cel_settings
isNumericCel1 = isnumeric(cel_setting{1});
isRangeCel2 = length(cel_setting{2})==2;
isStringCel3 = isstr(cel_setting{3});
hasError = ~(isNumericCel1*isRangeCel2*isStringCel3);
if hasError
    error('One of the cel of settings(cel_setting) has a wrong item.')
end
%
cal_settings_out = cal_settings;
idx = length(cal_settings)+1;
cal_settings_out(idx).idx = cel_setting{1};
cal_settings_out(idx).cal = cel_setting{2};
cal_settings_out(idx).unit = cel_setting{3};
end