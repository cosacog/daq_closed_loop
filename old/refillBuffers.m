function refillBuffers(src,event) %#ok

    % Get the current data
    ai0data = event.Data(:,1);
    ai0time = event.TimeStamps;
    dio1data = event.Data(:,2);



    %% THIS CAN BE REPLACED WITH ANOTHER TRIGGER MECHANISM=============
    % Check if the trigger condition is met
%     trig = event.Data(:,2) > 0.5; % triggers when digital signal is high
    trig = event.Data(:,2) > 5.5; % triggers when digital signal is high
    %==================================================================
    
    %% Find the first data point that fits the trigger condition
    if any(trig) && (myDataBeingLogged == false)
        trigInd = find(trig, 1, 'first');
        myDataBeingLogged = true;
    end



    %% Refill the buffer and throw out data beyond pretrigger time (FIFO)
    newData = [ai0data dio1data];
    myCircularBuffers = cat(3, myCircularBuffers(:,:,2:end), newData);
    myCircularTimeBuffer = cat(3, myCircularTimeBuffer(:,:,2:end), ai0time);

    % Actions for when the trigger condition is met
    if myDataBeingLogged == true
        if myCurrentBuffer == (captureLength/myBufferRefillPeriod) + 1 % +1 to account for the padded buffer (line 27)
            % Reorganize data once trigger condition met
            myCircularBuffers = permute(myCircularBuffers, [1 3 2]); % rearrange 3D matrix for proper reshape
            myCircularBuffers = reshape(myCircularBuffers, myNumBuffers*myBufferSize, myNumChannels);
            myCircularTimeBuffer = reshape(myCircularTimeBuffer, myNumBuffers*myBufferSize, 1);

            % Clean up HW resources
            s.stop();
            s.release();
            delete(lh);

            % Extract the pretrigger length and the capture length from
            % the buffer.
            numBufferSamples = myNumPretriggerBuffers*myBufferSize;
            fullCapTrigInd = numBufferSamples + trigInd;
            trigTime = myCircularTimeBuffer(fullCapTrigInd);
            numCapSamples = captureLength * mySampleRate;
            reqCapture = myCircularBuffers((fullCapTrigInd-numBufferSamples):(fullCapTrigInd+numCapSamples),:);
            reqCaptureTime = myCircularTimeBuffer((fullCapTrigInd-numBufferSamples):(fullCapTrigInd+numCapSamples),:) - trigTime;

            %% EDIT FOR CUSTOM ACTION==================================
            % Add to or replace this section to save data
            subplot(2,1,1);
            plot(reqCaptureTime, reqCapture(:,1));
            subplot(2,1,2);
            plot(reqCaptureTime, reqCapture(:,2));
            %==========================================================
        end
        myCurrentBuffer = myCurrentBuffer + 1;
    end
end % refillBuffers

