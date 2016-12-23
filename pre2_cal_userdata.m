function pre2_cal_userdata(plotHandle, time_seg)
% set calibration
% Usege: pre2_cal_userdata(plotHandle, time_seg)
% params:
%   plotHandle
%   time_seg (sec): time of segment to use calibration (from end)
% out:
%   ch_info(idx).baseline
%   ch_info(idx).ratio_cal
%   ch_info(idx).done_cal
% real measurement can be calculate as follows:
%   e.g. amplitudes_real(microV) = 
%       (recorded(V) - baseline)*ratio_cal
% ======== settings =============
prctiles = [0.01, 99.9];% use in calc percentile(i.e. min, max)
try
    n_ch = plotHandle.UserData.n_ch;
    ch_info = plotHandle.UserData.ch_info;
    rawdataCal = plotHandle.UserData.rawdataCal;
    times = plotHandle.UserData.rawdataTimeCal;
    % calc indices
    idxs = find(times > (times(end)-time_seg));
    times_seg = times(idxs);
    rawdata_seg = rawdataCal(idxs,:);
    for ii = 1:n_ch
        if ~ch_info(ii).done_cal && ch_info(ii).done_rec_cal
            rawdata_seg_ch = rawdata_seg(:,ii);
            min_data = prctile(rawdata_seg_ch, prctiles(1));
            max_data = prctile(rawdata_seg_ch, prctiles(2));
            bl_data = (min_data + max_data)/2;
            cal_range = ch_info(ii).cal_range;
            diff_range_out = diff(cal_range);
            diff_range_in = max_data - min_data;
            ratio_in_out = diff_range_out/diff_range_in;
            ch_info(ii).baseline = bl_data;
            ch_info(ii).ratio_cal = ratio_in_out;
            ch_info(ii).done_cal = true;
        end
    end
    plotHandle.UserData.ch_info = ch_info;
catch
    disp(plotHandle.UserData.ch_info)
    error('Parameters in plotHandle.UserData are not set correctly')
end
disp(plotHandle.UserData.ch_info)
end
