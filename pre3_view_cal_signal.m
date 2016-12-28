function s = pre3_view_cal_signal(plotHandle)
% view and confirm calibration signale for each channel
% Usage: s = pre3_view_cal_signal(plogHandle)
% params:
%   plotHandle

% ======= EDIT CONFIGURATION FOR YOUR HW=================================
% Setup the hardware channels
s = daq.createSession('ni');
usrdata = get(plotHandle,'UserData');
dev = usrdata.daq_dev; % e.g. 'Dev1' or 'Dev2'
% s.addAnalogInputChannel('cDAQ1Mod2','ai6','Voltage'); 
s.addAnalogInputChannel(dev,'ai0','Voltage'); % eeg
s.addAnalogInputChannel(dev,'ai1','Voltage'); % mep
s.addAnalogInputChannel(dev,'ai2','Voltage'); % TMS pulse
% s.addDigitalChannel('cDAQ1Mod4','port0/line0','InputOnly'); 
% s.Channels.TerminalConfig = 'SingleEnded'

% ===================== settings ========================
ylims_raw = [-10 10; -5 5; -10 10];
s.Channels(1).Range = ylims_raw(1,:);
s.Channels(2).Range = ylims_raw(2,:);
s.Channels(3).Range = ylims_raw(3,:);
t_plot = 10; % sec
t_force_quit = 60;% sec

% ======== retrieve settings for recordings ============================
usrdata.n_ch = length(s.Channels);
n_ch = usrdata.n_ch;
% recordings
if ~isfield(usrdata,'s_rate')
    usrdata.s_rate = 1000;
    usrdata.tSegBuffer = 0.1; % in seconds
end
% plot channels
if ~isfield(usrdata,'ch_info')
    error('plotHandle does not have element "ch_info". Refer to set_chnames, set_cal_settings.')
end

% ==================== setup ==============================================
s_rate = usrdata.s_rate;
tSegBuffer = usrdata.tSegBuffer;
time_stamp = 0; % time stamp to check the interval
p_plot = t_plot*s_rate; % points of times (plot)

% The set of buffers
pSizeBuffer = ceil(tSegBuffer * s_rate);
bufferDataStore = zeros(1, n_ch);
bufferTimeStore = zeros(1, 1);

% plot settings
pos_subplot = sub_calc_compact_subplot_position(n_ch); % position of subplot

titles = {'online data'};
clrs_x = 'black';
if n_ch>1
    clrs_x = [repmat({'none'},1,n_ch-1), clrs_x];
    titles = [titles, repmat({''},1,n_ch-1)];
end

chnames = {};
for jj = 1:n_ch;chnames{jj} = usrdata.ch_info(jj).chname;end

% ==================== coefficences to convert into real data ============================
ch_info = usrdata.ch_info;
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
        newData_da = newData.*ratios_io_buf - bls_buf;

        % when resume recording, clear buffers, reset time_stamp
        % % if this is skipped, warning will appear
        if ai0time(1) == 0
            bufferDataStore = zeros(1,n_ch);
            bufferTimeStore = zeros(1, 1);
            time_stamp = ai0time(end);
        end

        % Refill the buffer
        bufferDataStore = cat(1, bufferDataStore, newData_da);
        bufferTimeStore = cat(1, bufferTimeStore, ai0time);

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
        for ii = 1:n_ch
            subplot('Position', pos_subplot(ii).pos)
            plot(t_buffer, w_buffer(:,ii));
            xlim(xlim_raw);ylim(ch_info(ii).range_view)
            title(titles{ii})
            ylabel(chnames{ii})
        end
    end % refillBuffers
end % my_sw_pretrigger_session
