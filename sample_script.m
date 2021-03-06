% setup
ch_eeg=1; ch_mep=2; ch_trig=3;
ph1=figure(1)
set_daq_device(ph1, 'Dev2')
set_chnames(ph1,{'eeg','mep','trig'})
cal_settings = append_cal_settings([], {ch_eeg,[-100 100],'microV'}); % ch1:eeg
cal_settings = append_cal_settings(cal_settings, {ch_mep,[-1000 1000],'microV'}); % ch2:mep
cal_settings = append_cal_settings(cal_settings, {ch_trig,[0 5000],'microV'}); % ch3:trigger
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
pause(10)
s.stop();s.release();

% monitor subject eeg
set_freq4monitor(ph1, 10) % 10 hz for monitor
set_pow_range(ph1, [0, 3.0])
s =pre4_record_resting_eeg(ph1, ch_eeg)
pause(120)
s.stop();s.release()

% plot power time series
subplot(2,3,[1:3]);plot(ph1.UserData.pows_eeg_rest);title('power time series')

% check power value percentile
pow_thr_lo = prctile(ph1.UserData.pows_eeg_rest,5)
pow_thr_hi = prctile(ph1.UserData.pows_eeg_rest,95)
set_pow_threshold(ph1, [pow_thr_lo, pow_thr_hi])% 
% set_pow_threshold(ph1, [2.8, 3.3])

% main
s=main_closed_loop_session(ph1)
pause(120)
s.stop();s.release()

% confirm eeg power histogram
ph2=figure(2);
pow_thr_artfct = 20;
pow_ts_main = ph1.UserData.pow_ts_main;
histogram(pow_ts_main(pow_ts_main<pow_thr_artfct))
disp(prctile(pow_ts_main(pow_ts_main<pow_thr_artfct),5));
disp(prctile(pow_ts_main(pow_ts_main<pow_thr_artfct),95));

%save
dt_str = datestr(datetime,'yymmddHHMM');
fig_name_out = sprintf('fig_%s.fig', dt_str);
mat_name_out = sprintf('dat_%s.mat', dt_str);
savefig(ph1, fig_name_out);
usrdata = ph1.UserData;
save(mat_name_out, 'usrdata');

%%------- post analysis(mep amplitudes) ---------------------
fnames_data = {'dat_1601101410.mat','dat_1601101414.mat'}; % which is assumed to include a variable "usrdata".
cond_hi = 1;cond_lo = 0;
conds_hilo = [];
amps_mep = [];
for ii = 1:length(fnames_data)
    clear usrdata;
    fname = fnames_data{ii};
    load(fname);% "usrdata" is loaded
    savedata = usrdata.savedata;
    for jj = 1:length(savedata)
        saved_item = savedata(jj);
        if ~isempty(strmatch(saved_item.hilo,'hi'))
            cond_hilo = cond_hi;
        elseif ~isempty(strmatch(saved_item.hilo,'lo'))
            cond_hilo = cond_lo;
        else
            error('saved_iten.hilo does not contain "hi" or "lo"')
        end
        conds_hilo = [conds_hilo, cond_hilo];
        amps_mep = [amps_mep, saved_item.amp_mep];
    end
end

% mean+-se -> add plot
amps_mep = log10(amps_mep);% log transform

amps_lo = amps_mep(conds_hilo == cond_lo);
amps_hi = amps_mep(conds_hilo == cond_hi);

mean_lo = mean(amps_lo);
mean_hi = mean(amps_hi);

se_lo = std(amps_lo)/length(amps_lo)^0.5;
se_hi = std(amps_hi)/length(amps_hi)^0.5;

% plot
figure;
plot(conds_hilo, amps_mep,'*');
set(gca,'xlim',[-0.5, 1.5], 'Xtick',[cond_lo cond_hi],'XTickLabel',...
    {sprintf('Lo n=%d',length(amps_lo)),sprintf('Hi n=%d',length(amps_hi))})

hold on
errorbar([0.1 1.1],[mean_lo, mean_hi], [se_lo, se_hi],'r+')
hold off
