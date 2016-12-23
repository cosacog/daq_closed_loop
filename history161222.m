%-- 2016/11/18 16:00 --%
daq
daqdevice
daq.getDevices
daq.getVendors
daqhwinfo
daqhwinfo('parallel')
%-- 2016/11/18 16:17 --%
daqhwinfo('parallel')
dio = digitalio('parallel',1)
info = daqhwinfo
info.InstalledAdaptors
daqhwinfo('parallel')
daqhwinfo('winsound')
daqregister('parallel')
daqhwinfo('winsound')
daqhwinfo('parallel')
cd c:/
cd toolbox
DownloadPsychtoolbox('c:/toolbox')
DownloadPsychtoolbox('c:\toolbox')
%-- 2016/11/18 16:40 --%
obj = io32
addpath('c:
addpath('c:\toolbox\io32')
obj = io32
io32(obj)
clear obj
ioObj = io32;
status = io32(ioObj);
status
address = hex2dec('CFF8');
data_out = 255;
data_out0 = 0;
io32(ioObj, address, data_out0)
io32(ioObj, address, data_out)
io32(ioObj, address, data_out0)
io32(ioObj, address, data_out)
io32(ioObj, address, data_out0)
io32(ioObj, address, data_out)
io32(ioObj, address, data_out0)
commandhistory
%-- 2016/11/28 13:48 --%
daq
daq.getDevices
daq.getVencors
daq.getVendors
%-- 2016/11/28 16:28 --%
daq.getVendors
%-- 2016/11/29 16:25 --%
daq.getDevices
%-- 2016/11/30 19:38 --%
edit
daq.getDevice
daq.getDevices
cd C:\daq_ogata\data_acquisition
ph = figure(1)
s=sw_pretrigger_session_orig(ph)
%-- 2016/11/30 19:44 --%
ph = figure(1)
cd C:\daq_ogata\data_acquisition
s = sw_pretrigger_session_orig(ph)
clear ph
ph = figure(1)
s = sw_pretrigger_session_orig(ph)
clear(ph)
clear ph
ph = figure(1)
s = sw_pretrigger_session_orig(ph)
%-- 2016/12/19 19:45 --%
edit
addpath('C:\daq_ogata')
parallel_port_out_sample161118
ph1=figure(1)
addpath('C:\daq_ogata\data_acquisition')
s=sw_pretrigger_session161214(ph1)
daq.getDevices()
s=sw_pretrigger_session161214(ph1)
s.stop()
ph1.UserData
savedata = ph1.UserData.savedata(6);
savedata
figure;plot(savedata.time,savedata.data(:,1))
pow= abs(fft(savedata.data(:,1)));
figure;plot(pow(1:15))
figure;plot(pow(11:15))
figure;plot(pow(10:15))
savedata.time(end)-savedata.time(1)
1/1.2*11
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
s.stop()
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
s.stop()
s.startBackground()
s.stop()
s.startBackground()
s.stop()
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
s.stop()
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
parallel_port_out_sample161118
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
s.stop()
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
clear;close all
ph1=figure(1)
s=sw_pretrigger_session161214(ph1)
ph1
ph1.UserData
pwd
cd K:
pwd
ls
cd data_acquisition\
save('daq.mat',ph1)
save('daq.mat','ph1')
savefig('daq.fig','ph1')
savefig(ph1, 'daq.fig')
save('daq.mat','ph1.UsrData')
save('daq.mat','ph1.UserData')
usrdata=ph1.UserData;
save('daq.mat','usrdata')
usrdata
%-- 2016/12/22 19:00 --%
edit
addpath('K:\data_acquisition')
ph1=figure(1)
s=pre1_record_calibration(ph1)
set_
help set_chnames
set_chnames(ph1, {'eeg','mep','trig'})
help pre1_record_calibration
help append_cal_settings
cal_settings = append_cal_settings(cal_settings, {1,[-100 100],'microV')
cal_settings = append_cal_settings(cal_settings, {1,[-100 100],'microV'})
cal_settings = append_cal_settings([], {1,[-100 100],'microV'})
cal_settings = append_cal_settings(cal, {2,[-1000 1000],'microV'})
cal_settings = append_cal_settings(cal_settings, {2,[-1000 1000],'microV'})
cal_settings = append_cal_settings(cal_settings, {3,[0 5000],'microV'})
s=pre1_record_calibration(ph1)
s=pre1_record_calibration(ph1, cal_settings)
cal_settins
cal_settings
cal_settings(1)
s
s.Channels(1)
s.Channels(1).Range
help s
help daq.ni.Session
s=pre1_record_calibration(ph1, [])
s.stop()
s=pre1_record_calibration(ph1, cal_settings(1))
s=pre1_record_calibration(ph1, cal_settings{1})
cal_settings(1)
cal_settings{1:2
}
cal_settings{1:2}
cal_settings(1:2)
s=pre1_record_calibration(ph1, cal_settings(1))
s.release()
s=pre1_record_calibration(ph1, cal_settings(1))
s.stop()
s.Range
s.Channels(1).Range
s.Channels(1).Range = [-10 10]
s.release()
s=pre1_record_calibration(ph1, cal_settings(1))
s.stop()
s.release()
s=pre1_record_calibration(ph1, cal_settings(1))
s.stop(
s.stop()
pre2_cal_userdata(ph1)
ch_info = ph1.UserData.ch_info
ch_info(1)
ch_info(2)
ch_info(3)
ph1.UserData
pre2_cal_userdata(ph1)
pre2_cal_userdata(ph1,5)
clear
ph1=figure(1)
ph1.UserData
close
ph1=figure(1)
set_chnames(ph1,{'eeg','meg','trig'})
cal_settings = append_cal_settings([],{1, [-100 100],'microV'})
cal_settings = append_cal_settings([],{2, [-1000 1000],'microV'})
cal_settings = append_cal_settings([],{3, [0 5000],'microV'})
set_cal_settings(ph1,cal_settings)
ph1.UserData
ph1.UserData.ch_info
set_cal_settings(ph1,cal_settings)
ph1.UserData.ch_info
ph1.UserData.ch_info(1)
cal_settings
cal_settings = append_cal_settings([],{1, [-100 100],'microV'})
cal_settings = append_cal_settings(cal_settings,{2, [-1000 1000],'microV'})
cal_settings = append_cal_settings(cal_settings,{3, [0 5000],'microV'})
set_cal_settings(ph1,cal_settings)
ph1.UserData.ch_info(1)
pre1_record_calibration(ph1,1)
s.stop()
s=pre1_record_calibration(ph1,1)
cear
clearclear
clear
clc
ph1=figure(1)
set_chnames(ph1,{'eeg','mep','trig'})
cal_settings = append_cal_settings([],{1,[-100 100],'microV'})
cal_settings = append_cal_settings(cal_settings,{2,[-1000 1000],'microV'})
cal_settings = append_cal_settings(cal_settings,{3,[0 5000],'microV'})
s=pre1_record_calibration(ph1,1)
s.stop()
ph1.UserData.ch_info(1)
set_cal_settings(ph1, cal_settings)
ph1.UserData.ch_info
s=pre1_record_calibration(ph1,1)
s.release()
s=pre1_record_calibration(ph1,1)
s.stop()
ph1.UserData.ch_info
ph1.UserData.ch_info.done_cal
ph1.UserData.ch_info.done_rec_cal
~ch_info(2).done_rec_cal
~ph1.UserData.ch_info(2).done_rec_cal
help any
any([2,3] == 2)
any([2,3] == 1)
any([2,3] == 3)
s=pre1_record_calibration(ph1,1)
s.release()
s=pre1_record_calibration(ph1,1)
s.stop()
pre2_cal_userdata(ph1)
pre2_cal_userdata(ph1, 5)
ph1.UserData.ch_info
ph1.UserData.ch_info(1)
help pre3_record_resting_eeg
pre3_record_resting_eeg(ph1, 1)
help set_ch_view_range
set_ch_view_range(ph1,1,[-200 100])
pre3_record_resting_eeg(ph1, 1)
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
set_ch_view_range(ph1,1,[-200 200])
s=pre3_record_resting_eeg(ph1, 1)
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
help pre1_record_calibration
% hoge
help pre1_record_calibration
pre1_record_calibration(ph1,2)
s.release()
s= pre1_record_calibration(ph1,2)
s.stop()
s.Channels(1).Range
r=s.Channels(1).Range
r + 2
r(1)
r{1}
r(1){1}
s.release()
s= pre1_record_calibration(ph1,2)
s.stop()
pre2_cal_userdata(ph1,2)
pre2_cal_userdata(ph1,5)
ph1,UserData.ch_info(2)
ph1,UserData
s= pre1_record_calibration(ph1,2)
s.release()
s= pre1_record_calibration(ph1,2)
s.stop()
pre2_cal_userdata(ph1,5)
ph1.UserData.ch_info(2)
ph1.UserData.ch_info(1)
pre3_record_resting_eeg(ph1,2)
s.release()
s = pre3_record_resting_eeg(ph1,2)
s.stop()
s.release()
s=pre1_record_calibration(ph1,2)
s.stop()
s.release()
pre2_cal_userdata(ph1, 5)
ph1.UserData.ch_info(1)
s=pre3_record_resting_eeg(ph1, 2)
ph1.UserData.ch_info
ph1.UserData.ch_info(2)
s.release()
s=pre1_record_calibration(ph1, 2)
s.stop()
s.release()
ph1.UserData.ch_info(2)
ph1.UserData.ch_info(2).range_view = [-2000 2000]
s=pre3_record_resting_eeg(ph1, 2)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 2)
s.release()
s=pre3_record_resting_eeg(ph1, 2)
ph1.UserData(2).ratio_cal
pre2_cal_userdata(ph1,5)
ph1.UserData(2).ratio_cal
ph1.UserData.ch_info(2).ratio_cal
ph1.UserData.ch_info
s.release()
s=pre3_record_resting_eeg(ph1, 2)
s.release()
s=pre3_record_resting_eeg(ph1, 2)
s.release()
s=pre3_record_resting_eeg(ph1, 2)
s.release()
s=pre3_record_resting_eeg(ph1, 2)
s.release()
s=pre3_record_resting_eeg(ph1, 2)
s.stop()
s.release()
clear;close all
ph1=figure(1)
set_chnames(ph1,{'eeg','mep','trig'})
cal_settings = append_cal_settings([],{1,[-100 100], 'microV'})
cal_settings = append_cal_settings(cal_settings,{2,[-1000 1000], 'microV'})
cal_settings = append_cal_settings(cal_settings,{3,[0 5000], 'microV'})
set_cal_settings(ph1,cal_settings)
s=pre1_record_calibration(ph1, 1)
s.stop()
s.release()
s=pre1_record_calibration(ph1, 2)
s.stop()
s.release()
pre2_cal_userdata(ph1,5)
s=pre1_record_calibration(ph1, 1)
s.stop()
s.release()
pre2_cal_userdata(ph1, 5)
help set_ch_view_range
set_ch_view_range(ph1, 1, [-200 200])
set_ch_view_range(ph1, 2, [-2000 2000])
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.release()
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
ph1.UserData
rawdata_eeg = ph1.UserData.rawdata_eeg;
figure;plot(rawdata_eeg(:,1)
figure; plot(rawdata_eeg(:,1))
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 2)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
s.stop()
s.release()
s=pre3_record_resting_eeg(ph1, 1)
ph1.UserData
prctile(ph1.UserData.pows_eeg,10)
prctile(ph1.UserData.pows_eeg,90)
help main_closed_loop_session
edit
s.release()
help set_pow_threshold
set_pow_threshold(ph1, [0.3, 1.2])
s=main_closed_loop_session(ph1)
ph1.UserData.ch_info(3)
ph1.UserData.ch_info(3).baseline=0
ph1.UserData.ch_info(3).ratio_cal=1
ph1.UserData.ch_info(3).range_view=[-1 6]
s=main_closed_loop_session(ph1)
s.stop()
get_pow_threshold(ph1)
set_pow_threshold(ph1, [0.2, 1.5])
s.release()
s=main_closed_loop_session(ph1)
s.stop()
s.release()
s=main_closed_loop_session(ph1)
s.stop()
addpath('c:\toolbox\io32'); % include io32.dll
ioObj = io32;
status = io32(ioObj);
data_out = 255;
data_out0 = 0;
address = hex2dec('CFF8');
status
s.release()
s=main_closed_loop_session(ph1)
s.stop()
s.release()
s=main_closed_loop_session(ph1)
ph1.UserData
pwe
pwd
cd K:
cd data_acquisition\
ls
savefig(ph1,'161222.fig')
s.release()
s=main_closed_loop_session(ph1)
s.stop()
s.release()
s=main_closed_loop_session(ph1)
history