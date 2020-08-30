function FSKModulation(frame,filename)
%% Fsk modulation
M = 2; %Modulation order= 2 (1 y 0)
Fs = 250000; %Sample rate
nsamp = 32; %Number of samples per symbol
freqsep = 60700;%Frecuencia de separacion
msg = frame;
disp(length(frame));
signalIQ = fskmod(msg,M,freqsep,nsamp,Fs);

fid2 = fopen(filename,'w');
for k=1:length(signalIQ)
    %  Escribimos parte real con precision unsigned int 8
        fwrite(fid2,real(signalIQ(k)),'uint8');
end

fclose(fid2);
end
