%% NNMF Test Script based on Kat Steele meeting some time Nov 2014
% Notes:
% Motor modules of human locomotion: influence of EMG averaging, concatenation, and number of step cycles.
% Oliveira, Anderson S. Gizzi, Leonardo. Farina, Dario. Kersting, Uwe G.
% Frontiers in Human Neuroscience 2014

load('12chEMG_bicepRaw.mat');
samprate=2000;
r=2; % number of synergies to look for(?)



%% Preprocessing - remove NaNs, bandpass 10-500, fullwave rectify, (low-pass under 10Hz??) a la O

% Remove NaNs by interpolation with Inpaint function
EMG2=EMG;

% Bandpass 10-500 Hz
band = [10 500]; % if you want to band pass a particular LFP range
[z,p,k]=butter(6,band/(samprate/2),'bandpass');
[sos,g] = zp2sos(z,p,k);

for m=1:12; %channels to filter
    EMG2(m,:)=filtfilt(sos,g,EMG2(m,:));
end

% Full wave rectify
EMG2=abs(EMG2);

% Feature filtering

% Lowpass under 10 Hz
low = 10; 
[z,p,k]=butter(6,low/(samprate/2),'low');
[sos,g] = zp2sos(z,p,k);

for m=1:12; %channels to filter
    EMG2(m,:)=filtfilt(sos,g,EMG2(m,:));
end

% Full wave rectify (again)
EMG2=abs(EMG2);
t=[0:1/2000:(length(EMG)-1)/2000];

%% NNMF
opts = statset('MaxIter',1000,'TolFun',1e-6,'TolX',1e-4, 'Display','off');
[W,H,err] = nnmf(EMG2,r,'alg','mult','rep',50,'options',opts);


%% Plot outputs
figure(3); plot(t,H); %synergies
figure(2); plot(t,EMG(3,:),t,EMG2) %Emg data