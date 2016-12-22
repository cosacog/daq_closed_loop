function s = sw_pretrigger_session
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
captureLength = 1; % capture example for 1 seconds after trigger, must be multiple of myBufferRefillPeriod
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
lh = s.addlistener('DataAvailable',@(src, event)refillBuffers(src,event)); % function to call

myDataBeingLogged = false;
trigInd = 0;
s.startBackground();
% =========================================================================


%% Listener function
   end % my_sw_pretrigger_session
