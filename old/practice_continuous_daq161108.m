% éQè∆: goo.gl/uJFHty
s = daq.createSession('ni');
addAnalogInputChannel(s, 'Dev2', 'ai0','Voltage');
% addAnalogInputChannel(s, 'Dev2', 'ai1','Voltage');
% s.DurationInSeconds = 5;
s.IsContinuous = true;
% data_store = zeros(2,1);
global data_store
data_store = linspace(-1,1,5000)';
counter = 1;
% lh = addlistener(s, 'DataAvailable', @(src, event) plot(event.TimeStamps, event.Data));
lh = addlistener(s, 'DataAvailable', @(src, event)stopWhenExceedOne(src, event));
% lh = addlistener(s, 'DataAvailable', @(src, event) src.queueOutputData(data_store));
% queueOutputData(s, data_store);
s.NotifyWhenDataAvailableExceeds = 50;
s.startBackground()

s.release();
