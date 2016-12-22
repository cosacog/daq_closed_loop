function s = sw_pretrigger_session_orig(plotHandle)
%SW_PRETRIGGER_SESSION software trigger and pre-trigger capture
% This file demonstrates how to configure a software trigger (rising edge).
% It is editable for other trigger conditions. In addition, this file also
% demonstrates how to capture pre-trigger data.
%
% Written by Isaac Noh
% Copyright 2013 The MathWorks, Inc.


%======== EDIT CONFIGURATION FOR YOUR HW===================================
% Setup the hardware channels
s = daq.createSession('ni');
% s.addAnalogInputChannel('cDAQ1Mod2','ai6','Voltage'); 
s.addAnalogInputChannel('Dev2','ai0','Voltage'); % eeg
s.addAnalogInputChannel('Dev2','ai1','Voltage'); % mep
s.addAnalogInputChannel('Dev2','ai2','Voltage'); % TMS pulse
% s.addDigitalChannel('cDAQ1Mod4','port0/line0','InputOnly'); 
%==========================================================================
usrdata = get(plotHandle,'UserData');
usrdata.savedata = [];

%% EDIT THESE PARAMETERS FOR YOUR CUSTOM ACQUISITION========================
% Setup the acquisition parameters 
if ~isfield(usrdata,'mySampleRate')
    usrdata.mySampleRate = 1000;
    usrdata.captureLength = 0.9; % capture example for 1 seconds after trigger, must be multiple of myBufferRefillPeriod
    usrdata.myBufferRefillPeriod = 0.1; % in seconds
    usrdata.myNumPretriggerBuffers = 2; % this code assumes at least 2 buffers
    usrdata.myNumChannels = 2;
end
%==================== setup ==============================================
mySampleRate = usrdata.mySampleRate;
captureLength = usrdata.captureLength;
myBufferRefillPeriod = usrdata.myBufferRefillPeriod;
myNumPretriggerBuffers = usrdata.myNumPretriggerBuffers;
myNumChannels = usrdata.myNumChannels;

%==========================================================================

%% DO NOT EDIT ============================================================
% Apply the settings to the hardware
s.Rate = mySampleRate;
s.IsContinuous = 1;

% The samples are stored in a circular buffer, which is a
% computationally efficient way of storing the samples
myBufferSize = ceil(myBufferRefillPeriod * mySampleRate);
myNumBuffers = myNumPretriggerBuffers + (captureLength/myBufferRefillPeriod) + 1; % plus 1 to account for mid refill trigger

% The set of buffers
myCircularBuffers = zeros(myBufferSize, myNumChannels, myNumBuffers);
myCircularTimeBuffer = zeros(myBufferSize, 1, myNumBuffers);

% Set the NotifyWhenDataAvailableExceeds property to set the frequency for
% refilling the buffer.
s.NotifyWhenDataAvailableExceeds = myBufferSize; % runs every 200 samples (= myBufferSize)
lh = s.addlistener('DataAvailable',@refillBuffers); % function to call
idx_epochs = 0; % 取り込むデータの数
isMyDataLogged = false; 
isDataMepLogged = false;
trigInd = 0;
s.startBackground();
time_stamp = 0; % time stamp to check the interval
t_interval = 3.0; % time interval for next epoch
pow_alpha = [];len_pow = 0;
cycle_pow = 10; % cycle
ch_monitor = 1; % channel for monitor and fft
% =========================================================================
    %% Listener function
    function refillBuffers(src,event) %#ok
        % Get the current data
        newData = event.Data(:,1:2);
        dataMep = event.Data(:,3);
        ai0time = event.TimeStamps;

        % when resume recording, clear buffers, reset time_stamp
        % % if this is skipped, warning will appear
        if ai0time(1) == 0
            myCircularBuffers = zeros(myBufferSize, myNumChannels, myNumBuffers);
            myCircularTimeBuffer = zeros(myBufferSize, 1, myNumBuffers);
            time_stamp = ai0time(end);
        end

        % Refill the buffer and throw out data beyond pretrigger time (FIFO)
        myCircularBuffers = cat(3, myCircularBuffers(:,:,2:end), newData);
        myCircularTimeBuffer = cat(3, myCircularTimeBuffer(:,:,2:end), ai0time);
        usrdata.circularBuffer = myCircularBuffers;
        usrdata.circularTimeBuffer = myCircularTimeBuffer;
        set(plotHandle, 'UserData',usrdata);

        % force quit unknown error
        if (ai0time(1) - time_stamp > 200.0)
            s.stop();
            s.release();
            delete(lh);
            % disp(ai0time)
            disp('quit')
        end
                
        % plot online eeg data and fft power value        
        figure(plotHandle)
        % % raw data
        subplot(4,2,[1 2])
        t_buffer = reshape(myCircularTimeBuffer,[myNumBuffers*myBufferSize,1]);
        w_buffer = reshape(myCircularBuffers(:,ch_monitor,:),[myNumBuffers*myBufferSize,1]);
        plot(t_buffer, w_buffer);
        xlim([t_buffer(1) t_buffer(end)]);ylim([-20 20])
        title('online data');

        % % plot power
        thr_pow = 40;
        pow_buffer = abs(fft(w_buffer));
        pow_alpha = [pow_alpha, pow_buffer(cycle_pow)];len_pow = len_pow + 1;
        subplot(4,2,7);
        if len_pow > cycle_pow
            idx_len_pow = len_pow - cycle_pow;
        else
            idx_len_pow = 1;
        end

        plot(pow_alpha(idx_len_pow:end),'-*');
        line([0,12], [thr_pow,thr_pow], 'col','red');
        xlim([0.5,10.5]);ylim([0,50])
        title('eeg power');

        % plot MEP waveform and amplitudes
        if isDataMepLogged
            % plot raw MEP data
            subplot(4,2,5)
            plot((ai0time-ai0time(1))*1000, dataMep);title('MEP wave')

            % plot MEP amplitude data

            isDataMepLogged = false;
        end

        % Check if the trigger condition is met
        trig = pow_buffer(cycle_pow) > thr_pow; 
        is_exceeds_enough_interval = (ai0time(1) - time_stamp) > t_interval;
        if is_exceeds_enough_interval && any(trig) && (isMyDataLogged == false)
            trigInd = find(trig, 1, 'first');
            isMyDataLogged = true;
            disp('isMyDataLogged');
        end

        % Actions for when the trigger condition is met
        if isMyDataLogged
            % Reorganize data once trigger condition met
            myCircularBuffer2Save = permute(myCircularBuffers, [1 3 2]); % rearrange 3D matrix for proper reshape
            reqCapture = reshape(myCircularBuffer2Save, myNumBuffers*myBufferSize, myNumChannels);
            reqCaptureTime = reshape(myCircularTimeBuffer, myNumBuffers*myBufferSize, 1);

            % Extract the pretrigger length and the capture length from
            % the buffer.
            % ============== put out TMS pulse =======================

            % ============== end of TMS pulse ========================

            % plot epoch data
            figure(plotHandle)
            subplot(4,2,[3 4]);
            trigTime = reqCaptureTime(end);
            plot(reqCaptureTime-trigTime, reqCapture(:,1));
            title([num2str(idx_epochs+1),' epoch'])
            
            % data store in plotHandle.UserData (=usrdata)
            % usrdata = get(plotHandle,'UserData');
            idx_epochs = length(usrdata.savedata) + 1;
            usrdata.savedata(idx_epochs).time = reqCaptureTime;
            usrdata.savedata(idx_epochs).data = reqCapture;
            set(plotHandle, 'UserData', usrdata);

            % stop after get enough data
            if idx_epochs >= 10
                % Clean up HW resources
                s.stop();
                s.release();
                delete(lh);
                disp(ai0time)
            end

            % reset time stamp, myCurrentBuffer
            time_stamp = ai0time(end);
            isMyDataLogged = false;
            isDataMepLogged = true;
        end % if isMyDataLogged == true
    end % refillBuffers
end % my_sw_pretrigger_session
