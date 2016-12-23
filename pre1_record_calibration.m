function s = pre1_record_calibration161220(plotHandle, ch_cal_rec)
% set calibration for the channels
% Usage: s = pre1_record_calibration161220(plogHandle, ch_cal_rec)
% params:
%   plotHandle
%   ch_cal_rec: channel to record calibration wave
% % =============== sample code ====================
% % ph1=figure(1)
% % set_chnames(ph1, {'eeg','mep','trig'})
% % cal_settings = [];
% % cal_settings = append_cal_settings([],{1,[-1000 1000],'microV'})
% % s=pre1_record_calibration161220(ph1, 1);
% % 
% % c.f. after this, go to cal_userdata

% ======= EDIT CONFIGURATION FOR YOUR HW===================================
% Setup the hardware channels
s = daq.createSession('ni');
dev = 'Dev1';
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
t_plot = 5; % sec
t_force_quit = 60;% sec

% ======== retrieve settings for recordings ============================
usrdata = get(plotHandle,'UserData');
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
% ==================== check channel indices ============================
clrs_ylab = repmat({'black'},1, n_ch);
for jj = 1:n_ch
    if any(ch_cal_rec == jj)
        usrdata.ch_info(jj).done_rec_cal = true;
        usrdata.ch_info(jj).done_cal = false;
        clrs_ylab{jj} = 'red';
    else
        usrdata.ch_info(jj).done_rec_cal = false;
    end
    usrdata.ch_info(jj).volt_range_daq = ylims_raw(jj,:);
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
            xlim(xlim_raw);ylim(ylims_raw(ii,:))
            set(gca,'xcol',clrs_x{ii});
            title(titles{ii})
            ylabel(chnames{ii}, 'color',clrs_ylab{ii})
        end
    end % refillBuffers
end % my_sw_pretrigger_session
