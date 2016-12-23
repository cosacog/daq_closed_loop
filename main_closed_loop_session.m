function s = main_closed_loop_session(plotHandle)
% record eeg data and put out TMS pulse, then record meps
% Usage: s = main_closed_loop_session(plogHandle)
% params: plotHandle. needs to run pre* before this script

%======== EDIT CONFIGURATION FOR YOUR HW===================================
% Setup the hardware channels
s = daq.createSession('ni');
usrdata = get(plotHandle,'UserData');
dev = usrdata.daq_dev; % e.g. 'Dev1'
% s.addAnalogInputChannel('cDAQ1Mod2','ai6','Voltage'); 
s.addAnalogInputChannel(dev,'ai0','Voltage'); % eeg
s.addAnalogInputChannel(dev,'ai1','Voltage'); % mep
s.addAnalogInputChannel(dev,'ai2','Voltage'); % TMS pulse
% s.addDigitalChannel('cDAQ1Mod4','port0/line0','InputOnly'); 
%======= Prepare for TMS pulse ============================
% addpath('c:\toolbox\io32'); % include io32.dll
% ioObj = io32;
% status = io32(ioObj);
% data_out = 255;
% data_out0 = 0;
% address = hex2dec('CFF8');

% sample to put out TMS pulse
%io32(ioObj, address, data_out);% trigger on
%pause(0.01); % 10 ms
%io32(ioObj, address, data_out0); % trigger off

% ================= settings ==========================
% tBufferRing = 1.0 % 
t_interval = 5.0; % time interval for next epoch
t_range_mep = [18, 45]; % ms, time range to detect MEP peaks
n_epochs_to_save = 20; % epochs number to save
% ========================================================
usrdata.savedata = [];

%% EDIT THESE PARAMETERS FOR YOUR CUSTOM ACQUISITION========================
% Setup the acquisition parameters 
if ~isfield(usrdata,'s_rate')
    error('Run pre1_record_calibration before recording')
end
%==================== setup ==============================================
s_rate = usrdata.s_rate; % 1000 (hz)
freq_oi = usrdata.freq_oi; % 10 (hz)
tBufferRing = usrdata.tBufferRing; % 1.0(sec)
tSegBuffer = usrdata.tSegBuffer; % 0.1 (sec)
n_ch = usrdata.n_ch; % = length(s.Channels) = 3
ch_info = plotHandle.UserData.ch_info;
ch_monitor = 1; % channel for monitor and fft
ch_mep = 2; % channel for mep recording
ch_trig = 3; % trigger channel
for ii = 1: n_ch
    s.Channels(ii).Range = ch_info(ii).volt_range_daq;
end
hilo = {'hi','lo'}; % store in savedata
% =================== power threshold ====================================
try
    thr_pow = usrdata.thr_pow;
catch
    errow('Power threshold(thr_pow) is not set. Refer to set_pow_threshold.')
end

% initialize
idx_epochs = 0; % 取り込んだepochの数
time_stamp = 0; % time stamp to check the interval
pow_ts = [];len_pow = 0;
% thr_pow = 4;
ylim_pow = [0, ceil(thr_pow(2)*2*5)/5];

% initalize the set of buffers
pSizeBuffer = ceil(tSegBuffer * s_rate);
nSegBuffers = tBufferRing/tSegBuffer; % plus 1 to account for mid refill trigger
pSizeBufferRing = pSizeBuffer*nSegBuffers;
coef_pow_correct = 2/pSizeBufferRing;

buffersRing = zeros(pSizeBufferRing, n_ch);
bufferRingTime = zeros(pSizeBufferRing, 1);

% set power frequencies and its index
freqs_pow = [0:pSizeBufferRing/s_rate:s_rate/2]; % cycle
idx_pow_oi = find(freqs_pow >= freq_oi,1); % 11 

% retrieve plot parameters
ylim_monitor = ch_info(ch_monitor).range_view;
ylim_mep = ch_info(ch_mep).range_view;
timesMep = 1:1000/s_rate:tSegBuffer*1000;
idx_range_mep = find(timesMep >= t_range_mep(1) & timesMep <= t_range_mep(2));
clrs_title_eeg_power = {'r','k'};
% ==================== coefficences to convert into real data ============================
try
    ratios_io = [];bls = [];
    ratios_io_buf = zeros(pSizeBuffer, n_ch);
    bls_buf = zeros(pSizeBuffer, n_ch);
    for ii = [ch_monitor, ch_mep, ch_trig]
        ratios_io(ii) = ch_info(ii).ratio_cal;
        ratios_io_buf(:,ii) = zeros(pSizeBuffer,1) + ratios_io(ii);
        bls(ii) = ch_info(ii).baseline * ratios_io(ii);
        bls_buf(:, ii) = zeros(pSizeBuffer, 1) + bls(ii);
    end
catch
    error('ch_info(ii).ratio_cal, or baseline is not set correctly. Calibrate is necessary')
end
% ============ initial plot ================
clf(plotHandle)
% raw plot
subplot(4,2,[1 2])
axe_raw = gca;
ax_raw = line(nan,nan);
set(axe_raw, 'YLim', ylim_monitor, 'YLimMode', 'manual');
title('online data');

% epoch plot
subplot(4,2,[3 4]);
axe_epo = gca;
al_epo = line(nan, nan);

% mep raw plot
subplot(4,2,5)
axe_mep = gca;
ax_mep = plot(nan, nan, nan, nan,nan,nan,'r*');
al_trig = line([nan, nan],[-10000,10000],'color','g');
set(axe_mep, 'YLim',ylim_mep, 'YLimMode','manual')
title('MEP wave')

% mep amplitudes plot
subplot(4,2,6)
axe_amp = gca;
ax_amp = plot(nan, nan, 'r*',nan,nan,'b*')
set(axe_amp, 'Xlim',[0,1], 'XLimMode','manual')
title('MEP amplitudes, Hi:Red, Lo:Blue')
idx_amp_hi_x = []; mep_amp_hi_y = []; % high condition
idx_amp_lo_x = []; mep_amp_lo_y = []; % low condition

% power plot
subplot(4,2,7);
axe_pow = gca;
ax_pow = plot(nan,nan,'-*');
al_lo = line([0,12], [thr_pow(1),thr_pow(1)], 'col','red');
al_hi = line([0,12], [thr_pow(2),thr_pow(2)], 'col','red');
set(axe_pow, 'XLim',[0.5, 10.5], 'XLimMode','manual');
set(axe_pow, 'YLim',ylim_pow, 'YLimMode','manual')
len_pow_plot = 10; % points to plot
% ==========  Apply the settings to the hardware ================
s.Rate = s_rate;
s.IsContinuous = 1;

% Set the event property
s.NotifyWhenDataAvailableExceeds = pSizeBuffer; % runs every 100 samples (= pSizeBuffer)
lh = s.addlistener('DataAvailable',@refillBuffers); % function to call

isMyDataLogged = false; 
isDataMepLogged = false;
is_exceeds_enough_interval = false;
s.startBackground();

% =========================================================================
    %% Listener function
    function refillBuffers(src,event) %#ok
        % Get the current data
        % newData = event.Data(:,1:2);% time, channel
        newData = event.Data;
        newData_io = newData.*ratios_io_buf - bls_buf;
        ai0time = event.TimeStamps;

        % when resume recording, clear buffers, reset time_stamp
        % % if this is skipped, warning will appear
        if ai0time(1) == 0
            buffersRing = zeros(pSizeBufferRing, n_ch);
            bufferRingTime = zeros(pSizeBufferRing, 1);
            time_stamp = ai0time(end);
        end

        % Refill the buffer and throw out data beyond pretrigger time (FIFO)
        buffersRing = cat(1, buffersRing(pSizeBuffer+1:end,:), newData_io);
        bufferRingTime = cat(1, bufferRingTime(pSizeBuffer+1:end,:), ai0time);

        % quit when long time
        if (ai0time(1) - time_stamp > 200.0)
            s.stop();
            s.release();
            delete(lh);
            disp('quit')
        end
                
        % plot online eeg data and fft power value        
        figure(plotHandle)
        % % plot raw data
        bufferRingMonitor = buffersRing(:, ch_monitor);
        subplot(4,2,[1 2])
        set(ax_raw, 'XData', bufferRingTime, 'YData', bufferRingMonitor);
        xlim(bufferRingTime([1,end]));

        % % plot power
        % %% calc power
        bufferRingMonitorDetrend = bufferRingMonitor -...
            linspace(mean(bufferRingMonitor(1:10)), mean(bufferRingMonitor(end-10:end)), pSizeBufferRing)';
        pow_bufRingMon = abs(fft(bufferRingMonitorDetrend))*coef_pow_correct;
        pow_ts = [pow_ts, pow_bufRingMon(idx_pow_oi)];len_pow = len_pow + 1;
        usrdata.pow_ts_main = pow_ts;
        set(plotHandle, 'UserData',usrdata);
        % %% plot
        % len_pow_plot = 10; 
        idx_pow_ini_y = max([1, len_pow - len_pow_plot + 1]);
        idx_pow_ini_x = min([10, len_pow]);
        subplot(4,2,7);
        set(ax_pow, 'XData',[1:idx_pow_ini_x],'YData',pow_ts(idx_pow_ini_y:end));
        title('eeg power','color',clrs_title_eeg_power{is_exceeds_enough_interval+1});

        % plot MEP waveform and amplitudes
        if isDataMepLogged
            bufferMep = newData_io(:,ch_mep);
            bufferTrig = newData_io(:,ch_trig);

            % detect trigger and calc amplitudes
            bufferTrigBin = bufferTrig > (max(bufferTrig) + median(bufferTrig))/2;
            idx_thr = find(bufferTrigBin,1);
            idx_range_mep_plus_thr = idx_thr + idx_range_mep;
            bufferSegMep = bufferMep(idx_range_mep_plus_thr);
            idx_min_max_mep = [find(bufferSegMep==min(bufferSegMep),1),...
                               find(bufferSegMep==max(bufferSegMep),1)]+idx_range_mep_plus_thr(1)-1;
            bufferMep_bcr = bufferMep - mean(bufferMep(1:idx_thr));
            amp_min_max_mep = bufferMep_bcr(idx_min_max_mep);
            amp_mep = range(amp_min_max_mep);
            t_min_max_mep = timesMep(idx_min_max_mep);

            % data store to usrdata            
            usrdata.bufferTrig = bufferTrig;
            usrdata.savedata(idx_epochs).amp_mep = amp_mep;
            set(plotHandle,'UserData',usrdata);
            if strcmp(usrdata.savedata(idx_epochs).hilo,'hi')
                idx_amp_hi_x = [idx_amp_hi_x, idx_epochs];
                mep_amp_hi_y = [mep_amp_hi_y, amp_mep];
            else
                idx_amp_lo_x = [idx_amp_lo_x, idx_epochs];
                mep_amp_lo_y = [mep_amp_lo_y, amp_mep];
            end
            

            % plot raw MEP data
            subplot(4,2,5)
            set(ax_mep(1), 'XData', timesMep, 'YData', bufferMep_bcr)
            set(ax_mep(2), 'XData', timesMep, 'YData', bufferTrig*100)
            set(ax_mep(3), 'XData', t_min_max_mep, 'YData', amp_min_max_mep)
            set(al_trig, 'XData', [timesMep(idx_thr), timesMep(idx_thr)])
            xlim(timesMep([1,end]))

            % plot MEP amplitudes data
            subplot(4,2,6)
            set(ax_amp(1), 'XData',idx_amp_hi_x,'YData',mep_amp_hi_y); % high
            set(ax_amp(2), 'XData',idx_amp_lo_x,'YData',mep_amp_lo_y); % low
            set(axe_amp, 'XLim',[0, idx_epochs+1])

            isDataMepLogged = false;
            % stop after get enough data
            if idx_epochs >= n_epochs_to_save
                % Clean up HW resources
                s.stop();
                s.release();
                delete(lh);
                disp('done')
            end
        end

        % Check if the trigger condition is met
        is_exceeds_hi_thr = pow_bufRingMon(idx_pow_oi) > thr_pow(2);
        is_exceeds_lo_thr = pow_bufRingMon(idx_pow_oi) < thr_pow(1);
        trig = is_exceeds_hi_thr || is_exceeds_lo_thr; 
        is_exceeds_enough_interval = (ai0time(1) - time_stamp) > t_interval;
        if is_exceeds_enough_interval && trig && ~isMyDataLogged
            % trigInd = find(trig, 1, 'first');
            isMyDataLogged = true;
            idx_epochs = length(usrdata.savedata) + 1;
            % cond = hilo(is_exceeds_lo_thr + 1);
            usrdata.savedata(idx_epochs).hilo = hilo(is_exceeds_lo_thr + 1);
            usrdata.savedata(idx_epochs).pow_oi = pow_bufRingMon(idx_pow_oi);
            % disp(pow_bufRingMon(idx_pow_oi));
            % disp('isMyDataLogged');
        end

        % Actions for when the trigger condition is met
        if isMyDataLogged
            % ============== put out TMS pulse =======================
            % io32(ioObj, address, data_out)% trigger on
            % pause(0.01)
            % io32(ioObj, address, data_out0) % trigger off
            % ============== end of TMS pulse ========================

            % plot epoch data
            figure(plotHandle)
            subplot(4,2,[3 4]);
            set(al_epo,'XData', bufferRingTime, 'YData', bufferRingMonitorDetrend);
            % plot(bufferRingTime, bufferRingMonitorDetrend);
            
            title([num2str(idx_epochs),' epoch'])
            
            % data store in plotHandle.UserData (=usrdata)
            usrdata.savedata(idx_epochs).time = ai0time;
            usrdata.savedata(idx_epochs).data = bufferRingMonitorDetrend;
            set(plotHandle, 'UserData', usrdata);

            % reset time stamp, myCurrentBuffer
            time_stamp = ai0time(end);
            isMyDataLogged = false;
            isDataMepLogged = true;
        end % if isMyDataLogged == true
    end % refillBuffers
end % my_sw_pretrigger_session
