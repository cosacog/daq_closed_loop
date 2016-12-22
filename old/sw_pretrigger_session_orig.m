function s = sw_pretrigger_session_orig(plotHandle)
%SW_PRETRIGGER_SESSION software trigger and pre-trigger capture
% This file demonstrates how to configure a software trigger (rising edge).
% It is editable for other trigger conditions. In addition, this file also
% demonstrates how to capture pre-trigger data.
%
% Written by Isaac Noh
% Copyright 2013 The MathWorks, Inc.


%% EDIT CONFIGURATION FOR YOUR HW==========================================
% Setup the hardware channels
s = daq.createSession('ni');
% s.addAnalogInputChannel('cDAQ1Mod2','ai6','Voltage'); 
s.addAnalogInputChannel('Dev2','ai0','Voltage'); 
s.addAnalogInputChannel('Dev2','ai1','Voltage'); 
% s.addDigitalChannel('cDAQ1Mod4','port0/line0','InputOnly'); 
%==========================================================================

%% EDIT THESE PARAMETERS FOR YOUR CUSTOM ACQUISITION========================
% Setup the acquisition parameters 
mySampleRate = 1000;
captureLength = 0.9; % capture example for 1 seconds after trigger, must be multiple of myBufferRefillPeriod
myBufferRefillPeriod = 0.1; % in seconds
myNumPretriggerBuffers = 2; % this code assumes at least 2 buffers
myNumChannels = 2;
%==========================================================================

%% DO NOT EDIT ============================================================
% Apply the settings to the hardware
s.Rate = mySampleRate;
s.IsContinuous = 1;

% The samples are stored in a circular buffer, which is a
% computationally efficient way of storing the samples
myBufferSize = ceil(myBufferRefillPeriod * mySampleRate);
myNumBuffers = myNumPretriggerBuffers + (captureLength/myBufferRefillPeriod) + 1; % plus 1 to account for mid refill trigger
myCurrentBuffer = 1;

% The set of buffers
myCircularBuffers = zeros(myBufferSize, myNumChannels, myNumBuffers);
myCircularTimeBuffer = zeros(myBufferSize, 1, myNumBuffers);

% Set the NotifyWhenDataAvailableExceeds property to set the frequency for
% refilling the buffer.
s.NotifyWhenDataAvailableExceeds = myBufferSize; % runs every 200 samples (= myBufferSize)
lh = s.addlistener('DataAvailable',@refillBuffers); % function to call
idx_data = 0;
myDataBeingLogged = false;
trigInd = 0;
s.startBackground();
time_stamp = 0; % time stamp to check the interval
% t_interval = captureLength + myBufferRefillPeriod*(myNumPretriggerBuffers+1); % 
t_interval = 3.0; % time interval for next epoch
pow_alpha = [];len_pow = 0;
cycle_pow = 10; % cycle
ch_monitor = 1; % channel for monitor and fft
% =========================================================================
    %% Listener function
    function refillBuffers(src,event) %#ok
        
        % Get the current data
        ai0data = event.Data(:,1);
        ai1data = event.Data(:,2);
        ai0time = event.TimeStamps;
        % disp(size(event.Data));
        % Refill the buffer and throw out data beyond pretrigger time (FIFO)
        newData = [ai0data ai1data];
        myCircularBuffers = cat(3, myCircularBuffers(:,:,2:end), newData);
        myCircularTimeBuffer = cat(3, myCircularTimeBuffer(:,:,2:end), ai0time);
            
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
        % raw data
        subplot(4,2,[1 2])
        t_buffer = reshape(myCircularTimeBuffer,[myNumBuffers*myBufferSize,1]);
        w_buffer = reshape(myCircularBuffers(:,ch_monitor,:),[myNumBuffers*myBufferSize,1]);
        plot(t_buffer, w_buffer);
        xlim([t_buffer(1) t_buffer(end)]);ylim([-20 20])
        title('online data');

        % power
        pow_buffer = abs(fft(w_buffer));
        pow_alpha = [pow_alpha, pow_buffer(cycle_pow)];len_pow = len_pow + 1;
        subplot(4,2,7);
        if len_pow > cycle_pow
            idx_len_pow = len_pow - cycle_pow;
        else
            idx_len_pow = 1;
        end

        plot(pow_alpha(idx_len_pow:end),'-*');
        xlim([0.5,10.5]);ylim([0,50])
        title('power');

        %% THIS CAN BE REPLACED WITH ANOTHER TRIGGER MECHANISM=============
        % Check if the trigger condition is met
        % trig = event.Data(:,2) > 10; % triggers when ai0 signal is high
        trig = pow_buffer(cycle_pow) > 40; 
        %==================================================================
                
        %% Find the first data point that fits the trigger condition

        % if any(trig) && (myDataBeingLogged == false) && (ai0time(1) - time_stamp >= t_interval)
        is_exceeds_enough_interval = (ai0time(1) - time_stamp) > t_interval;
        % disp(is_exceeds_enough_interval);
        % disp(ai0time(1) - time_stamp);
        if is_exceeds_enough_interval && any(trig) && (myDataBeingLogged == false)
            trigInd = find(trig, 1, 'first');
            myDataBeingLogged = true;
            % disp((ai0time(1) - time_stamp) >= t_interval)
            disp('myDataBeingLogged');
        end

        % Actions for when the trigger condition is met
        if myDataBeingLogged == true
            if myCurrentBuffer == (captureLength/myBufferRefillPeriod) + 1 % +1 to account for the padded buffer (line 27)
                % Reorganize data once trigger condition met
                myCircularBuffer2Save = permute(myCircularBuffers, [1 3 2]); % rearrange 3D matrix for proper reshape
                myCircularBuffer2Save = reshape(myCircularBuffer2Save, myNumBuffers*myBufferSize, myNumChannels);
                myCircularTimeBuffer2Save = reshape(myCircularTimeBuffer, myNumBuffers*myBufferSize, 1);

                % Extract the pretrigger length and the capture length from
                % the buffer.
                numBufferSamples = myNumPretriggerBuffers*myBufferSize; 
                fullCapTrigInd = numBufferSamples + trigInd;
                trigTime = myCircularTimeBuffer(fullCapTrigInd);
                numCapSamples = captureLength * mySampleRate;
                reqCapture = myCircularBuffer2Save((fullCapTrigInd-numBufferSamples):(fullCapTrigInd+numCapSamples),:);
                reqCaptureTime = myCircularTimeBuffer2Save((fullCapTrigInd-numBufferSamples):(fullCapTrigInd+numCapSamples),:) - trigTime;
                
                %% EDIT FOR CUSTOM ACTION==================================
                % Add to or replace this section to save data
                figure(plotHandle)
                subplot(4,2,[3 4]);
                plot(reqCaptureTime, reqCapture(:,1));
                title([num2str(idx_data+1),'epoch'])
                
                % data store in plotHandle.UserData (=usrdata)
                usrdata = get(plotHandle,'UserData');
                idx_data = length(usrdata) + 1;
                usrdata(idx_data).time = reqCaptureTime;
                usrdata(idx_data).data = reqCapture;
                set(plotHandle, 'UserData', usrdata);
                
                % reset time stamp, myCurrentBuffer
                time_stamp = ai0time(end);
                myCurrentBuffer = 0;
                % myDataBeingLogged = false;

                % stop after get enough data
                if idx_data > 10
                    % Clean up HW resources
                    s.stop();
                    s.release();
                    delete(lh);
                    disp(ai0time)
                end
    %                 return reqCapture;
                %==========================================================
            end
            myCurrentBuffer = myCurrentBuffer + 1;
            % additional
            myDataBeingLogged = false;
            trigInd = 0;
        end % if myDataBeingLogged == true
    end % refillBuffers

end % my_sw_pretrigger_session