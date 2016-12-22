function s = sw_record_calibration161220(plotHandle, cal_settings)
% set calibration for the channels
% params:
%   plotHandle
%   cal_settings: struct including (1) idx:channel index
%                                  (2) cal: range of min max. e.g.[-100 100]
%                                  (3) unit: e.g. 'microV', 'V'
%                refer to append_cal_settings

% ======= EDIT CONFIGURATION FOR YOUR HW===================================
% Setup the hardware channels
s = daq.createSession('ni');
% s.addAnalogInputChannel('cDAQ1Mod2','ai6','Voltage'); 
s.addAnalogInputChannel('Dev2','ai0','Voltage'); % eeg
s.addAnalogInputChannel('Dev2','ai1','Voltage'); % mep
s.addAnalogInputChannel('Dev2','ai2','Voltage'); % TMS pulse
% s.addDigitalChannel('cDAQ1Mod4','port0/line0','InputOnly'); 
% s.Channels.TerminalConfig = 'SingleEnded'
% ===================== settings ========================
ylim_raw = [-20 20];
t_plot = 5; % sec
t_force_quit = 60;% sec

% ======== retrieve settings for recordings ============================
usrdata = get(plotHandle,'UserData');
usrdata.n_ch = length(s.Channels);
n_ch = usrdata.n_ch;
% recordings
if ~isfield(usrdata,'s_rate')
    usrdata.s_rate = 1000;
    usrdata.tCaptureData = 1.0; % capture example for 1 seconds after trigger, must be multiple of tSegBuffer
    usrdata.tSegBuffer = 0.1; % in seconds
end
% plot channels
if ~isfield(usrdata,'ch_info')
    warning('plotHandle does not have element "ch_info". Create channel names')
    for ii = 1:n_ch
        usrdata.ch_info(ii).chname = s.Channels(ii).ID;
    end
end
% ==================== setup ==============================================
s_rate = usrdata.s_rate;
tCaptureData = usrdata.tCaptureData;
tSegBuffer = usrdata.tSegBuffer;
time_stamp = 0; % time stamp to check the interval
p_plot = t_plot*s_rate; % points of times (plot)

% The set of buffers
pSizeBuffer = ceil(tSegBuffer * s_rate);
nSegBuffers = tCaptureData/tSegBuffer; % plus 1 to account for mid refill trigger
bufferDataStore = zeros(1, n_ch);
bufferTimeStore = zeros(1, 1);

% plot settings
pos_subplot = calc_compact_subplot_position(n_ch); % position of subplot

titles = {'online data'};
clrs_x = 'black';
if n_ch>1
    clrs_x = [repmat({'none'},1,n_ch-1), clrs_x];
    titles = [titles, repmat({''},1,n_ch-1)];
end

chnames = {};
for ii = 1:n_ch;chnames{ii} = usrdata.ch_info(ii).chname;end
% ==================== check channel indices ============================
clrs_ylab = repmat({'black'},1, n_ch);
for ii = 1:length(cal_settings)
    idx_ch = cal_settings(ii).idx;
    clrs_ylab{idx_ch}='red';
    usrdata.ch_info(idx_ch).cal_range = cal_settings(ii).cal;
    usrdata.ch_info(idx_ch).unit = cal_settings(ii).unit;
    usrdata.ch_info(idx_ch).done_cal = false;
end
% ================ Apply the settings to the hardware ===================
s.Rate = s_rate;
s.IsContinuous = 1;
s.NotifyWhenDataAvailableExceeds = pSizeBuffer; % runs every 100 samples (= pSizeBuffer)
lh = s.addlistener('DataAvailable',@refillBuffers); % function to call
s.startBackground();
%================= Listener function ================================
    function refillBuffers(src,event) %#ok
        % Get the current data
        newData = event.Data;
        ai0time = event.TimeStamps;

        % when resume recording, clear buffers, reset time_stamp
        % % if this is skipped, warning will appear
        if ai0time(1) == 0
            bufferDataStore = zeros(1,n_ch);
            bufferTimeStore = zeros(1, 1);
            time_stamp = ai0time(end);
        end

        % Refill the buffer and throw out data beyond pretrigger time (FIFO)
        bufferDataStore = cat(1, bufferDataStore, newData);
        bufferTimeStore = cat(1, bufferTimeStore, ai0time);
        usrdata.rawdataCal = bufferDataStore;
        usrdata.rawdataTimeCal = bufferTimeStore;
        set(plotHandle, 'UserData',usrdata);

        % force quit unknown error
        if (ai0time(1) - time_stamp > t_force_quit)
            s.stop();
            s.release();
            delete(lh);
            % disp(ai0time)
            disp('quit')
        end
                
        % plot online eeg data
        idx_t_init = max([length(bufferTimeStore)-p_plot ,1]);
        t_buffer = bufferTimeStore(idx_t_init:end);
        w_buffer = bufferDataStore(idx_t_init:end,:);
        xlim_raw = [t_buffer(end)-t_plot, t_buffer(end)];
        figure(plotHandle)
        for ii = 1:(n_ch)
            subplot('Position', pos_subplot(ii).pos)
            plot(t_buffer, w_buffer(:,ii));
            xlim(xlim_raw);ylim(ylim_raw)
            set(gca,'xcol',clrs_x{ii});
            title(titles{ii})
            ylabel(chnames{ii}, 'color',clrs_ylab{ii})
        end
    end % refillBuffers
end % my_sw_pretrigger_session
