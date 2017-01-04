% setup
ch_eeg=1; ch_mep=2; ch_trig=3;
ph1=figure(1)
set_daq_device(ph1, 'Dev2')
set_chnames(ph1,{'eeg','mep','trig'})
cal_settings = append_cal_settings([], {ch_eeg,[-100 100],'microV'});
cal_settings = append_cal_settings(cal_settings, {ch_mep,[-1000 1000],'microV'});
cal_settings = append_cal_settings(cal_settings, {ch_trig,[0 5000],'microV'});
set_cal_settings(ph1, cal_settings)

% set view range
set_ch_view_range(ph1,ch_eeg,[-200 200])
set_ch_view_range(ph1,ch_mep,[-2000 2000])
set_ch_view_range(ph1,ch_trig,[0 5])

% cal signal record
s=pre1_record_calibration(ph1, ch_eeg)
pause(10)
s.stop();s.release();
% cal signal record: change cal signal range
s=pre1_record_calibration(ph1, ch_mep)
pause(10)
s.stop();s.release();

% cal set
t_cal_set = 10; % sec. time for setting calibration
pre2_cal_userdata(ph1, t_cal_set)
set_manual_cal_da(ph1,ch_trig,1,0)

% check cal waveform
s=pre3_view_cal_signal(ph1)
s.stop();s.release();

% monitor subject eeg
set_freq4monitor(ph1, 10) % 10 hz for monitor
set_pow_range(ph1, [0, 1.25])
s =pre4_record_resting_eeg(ph1, ch_eeg)
s.stop();s.release()

% plot power time series
subplot(2,3,[1:3]);plot(ph1.UserData.pows_eeg_rest);title('power time series')

% check power value percentile
prctile(ph1.UserData.pows_eeg,10)
prctile(ph1.UserData.pows_eeg,90)
% set_pow_threshold(ph1, [0.55, 2.98])
set_pow_threshold(ph1, [2.8, 3.3])

% main
s=main_closed_loop_session(ph1)
s.stop();s.release()

%save
dt_str = datestr(datetime,'yymmddHHMM');
fig_name_out = sprintf('fig_%s.fig', dt_str);
mat_name_out = sprintf('dat_%s.mat', dt_str);
savefig(ph1, fig_name_out);
usrdata = ph1.UserData;
save(mat_name_out, 'usrdata');

