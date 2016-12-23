function s = pre3_record_resting_eeg161220(plotHandle, ch_eeg)
% record resting eegs to set the threshold to put out TMS pulse
% Usage: pre3_record_resting_eeg161220(plotHandle, ch_eeg)
% params:
%   plotHandle
%   ch_eeg: channel index to record (eeg channel)

% ========= Setup the hardware channels =================
s = daq.createSession('ni');
usrdata = get(plotHandle,'UserData');
dev = usrdata.daq_dev; % e.g.'Dev1'

% s.addAnalogInputChannel('cDAQ1Mod2','ai6','Voltage'); 
s.addAnalogInputChannel(dev,'ai0','Voltage'); % eeg
s.addAnalogInputChannel(dev,'ai1','Voltage'); % mep
s.addAnalogInputChannel(dev,'ai2','Voltage'); % TMS pulse
% s.addDigitalChannel('cDAQ1Mod4','port0/line0','InputOnly'); 
% s.Channels.TerminalConfig = 'SingleEnded'

% ===================== settings ========================
t_plot = 5; % sec
t_force_quit = 120;% sec
range_freqs = [4,20]; % Hz to plot power spectrum
freq_oi = usrdata.freq_oi; % Hz to plot power time sequence
n_ch = length(s.Channels); % only eeg = length(s.Channels)
tBufferRing = 1.0; % sec
% ======== retrieve settings for recordings ============================
usrdata.tBufferRing = tBufferRing;
ch_info = usrdata.ch_info;
for ii = 1: n_ch
    s.Channels(ii).Range = ch_info(ii).volt_range_daq;
end
% n_ch = usrdata.n_ch;
% ==================== setup ==============================================
s_rate = usrdata.s_rate; % 1000 (Hz)
tSegBuffer = usrdata.tSegBuffer; % 0.1(sec)
p_plot = t_plot*s_rate; % points of times (plot)

% The set of buffers
bufferDataStore = zeros(1, n_ch);
bufferTimeStore = zeros(1, 1);

% The set of ring buffers
pSizeBuffer = ceil(tSegBuffer * s_rate);
nSegBuffers = tBufferRing/tSegBuffer; % plus 1 to account for mid refill trigger
pSizeBufferRing = pSizeBuffer * nSegBuffers;
buffersRing = zeros(pSizeBufferRing, n_ch);
bufferRingTime = zeros(pSizeBufferRing, 1);

% plot settings
titles = {'online data'};
chnames = ch_info(ch_eeg).chname;
ylim_raw = ch_info(ch_eeg).range_view;
% % setting: power plot
coef_pow_correct = 2/pSizeBufferRing; % to correct power by point length
freqs_ring_buf = [0:(1/tBufferRing):s_rate-1/tBufferRing]; % frequencies of power by ring buffer
idx_freqs_ring_buf = find(freqs_ring_buf >= range_freqs(1) & freqs_ring_buf <= range_freqs(2)); % idx for power range to plot
freqs_ring_buf_range = freqs_ring_buf(idx_freqs_ring_buf); % frequencies for power range to plot
idx_freq_oi = find(freqs_ring_buf>=freq_oi, 1); % idx of power to be saved
xlim_freqs = [freqs_ring_buf_range(1), freqs_ring_buf_range(end)]; % xlim
pows_eeg = []; len_pows = 0; % power data of time sequence
len_pow_view = 10; % points to view
title_pow_ts = sprintf('Power of %d Hz',freq_oi);
% ==================== coefficences to convert into real data ============================
ratios_io = zeros(1,n_ch);
ratios_io_buf = zeros(pSizeBuffer, n_ch);
bls = zeros(1,n_ch);
bls_buf = zeros(pSizeBuffer, n_ch);
for ii = 1:n_ch
    try
        ratios_io(ii) = ch_info(ii).ratio_cal;
        bls(ii) = ch_info(ii).baseline * ratios_io(ii);
    catch
        ratios_io(ii) = 1;
        bls(ii) = 0;
    end
    ratios_io_buf(:,ii) = zeros(pSizeBuffer,1) + ratios_io(ii);
    bls_buf(:,ii) = zeros(pSizeBuffer, 1) + bls(ii);
end
disp(ratios_io_buf(1:3,:))
disp(bls_buf(1:3,:))
% ================ Apply the settings to the hardware ===================
s.Rate = s_rate;
s.IsContinuous = 1;
s.NotifyWhenDataAvailableExceeds = pSizeBuffer; % runs every 100 samples (= pSizeBuffer)
lh = s.addlistener('DataAvailable',@refillBuffers); % function to call
clf(plotHandle)
s.startBackground();
%================= Listener function ================================
    function refillBuffers(src,event) %#ok
        % Get the current data
        newData = event.Data;
%         disp(newData(1:3,:));
        newData_io = newData.*ratios_io_buf - bls_buf;
%         disp(newData_io(1:3,:));
        ai0time = event.TimeStamps;

        % reset buffer when started
        if ai0time(1) == 0
            bufferDataStore = newData_io;
            bufferTimeStore = ai0time;
        else
            bufferDataStore = cat(1, bufferDataStore, newData_io);
            bufferTimeStore = cat(1, bufferTimeStore, ai0time);
            buffersRing = cat(1, buffersRing(pSizeBuffer+1:end,:), newData_io);
            bufferRingTime = cat(1, bufferRingTime(pSizeBuffer+1:end,:), ai0time);
        end

        % Refill the buffer and throw out data beyond pretrigger time (FIFO)
        usrdata.rawdata_eeg = bufferDataStore;
        usrdata.rawdataTime = bufferTimeStore;
        set(plotHandle, 'UserData',usrdata);

        % quit after recording enough time
        if ai0time(end) > t_force_quit
            s.stop();
            s.release();
            delete(lh);
            disp('quit')
            usrdata.pows_eeg_cal = pows_eeg;
            set(plotHandle,'UserData',usrdata);
            figure;plot(pows_eeg);title('power time series')
        end
                
        % plot online eeg data
        idx_t_init = max([length(bufferTimeStore)-p_plot ,1]);
        t_buffer = bufferTimeStore(idx_t_init:end);
        w_buffer = bufferDataStore(idx_t_init:end,:);
        xlim_raw = [t_buffer(end)-t_plot, t_buffer(end)];
        figure(plotHandle)
%         for ii = 1:(n_ch)
            subplot(2,3,[1:3])
            plot(t_buffer, w_buffer(:,ch_eeg));
            xlim(xlim_raw);ylim(ylim_raw)
            title('online data')
            ylabel(chnames);
%         end

        % plot power spectrum (alpha ~ beta range)
        % % calc power
        rawdata_ring_detrend = buffersRing(:,ch_eeg)-...
            linspace(mean(buffersRing(1:10,ch_eeg)),mean(buffersRing(end-10:end,ch_eeg)), pSizeBufferRing)';
        pow_eeg = abs(fft(rawdata_ring_detrend))*coef_pow_correct;
        pow_eeg_range = pow_eeg(idx_freqs_ring_buf);
        % % plot
        subplot(2,3,4)
        plot(freqs_ring_buf_range, pow_eeg_range);
        xlim(xlim_freqs);ylim([0, 2.5])
        title('FFT (theta-beta)')
        xlabel('Hz')

        % plot time sequence of power of interest
        pow_eeg_freq_oi = pow_eeg(idx_freq_oi);

        pows_eeg = [pows_eeg, pow_eeg_freq_oi];
        len_pows = len_pows+1;
        xlim_pow_ts = [len_pows - len_pow_view, len_pows];
        subplot(2,3,5)
        plot(pows_eeg);xlim(xlim_pow_ts);ylim([0, 2.5])
        title(title_pow_ts);

        % plot histogram of power of interest
        subplot(2,3,6)
        if rem(len_pows,50) == 40
            histogram(pows_eeg(30:end), 10);
            title('histogram of power')
            usrdata.pows_eeg = pows_eeg;
            set(plotHandle,'UserData', usrdata);
        end
    end % refillBuffers
end % my_sw_pretrigger_session
