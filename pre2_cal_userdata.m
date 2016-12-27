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
usrdata = plotHandle.UserData;
prctiles = [0.01, 99.9];% use in calc percentile(i.e. min, max)
n_ch = usrdata.n_ch;
ch_info = usrdata.ch_info;
% rawdataCal = usrdata.rawdataCal;
times = usrdata.rawdataTimeCal;
% calc indices
idxs = find(times > (times(end)-time_seg));
% times_seg = times(idxs);
% rawdata_seg = rawdataCal(idxs,:);
for ii = 1:n_ch
    if ~ch_info(ii).done_cal && ch_info(ii).done_rec_cal
        % _calc_cal_ratio_da_baseline
        rawdata_seg_ch = ch_info(ii).rawdataCal(idxs);
        % rawdata_seg_ch = rawdata_seg(:,ii);
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
usrdata.ch_info = ch_info;
set(plotHandle,'UserData', usrdata);
disp(usrdata.ch_info)
end
