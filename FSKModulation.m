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
    %  Escribimos parte real con precision de 4 bytes, punto flotante
        fwrite(fid2,real(signalIQ(k)),'uint8');
end

fclose(fid2);

%% Get the real component and plot it on the x axis
x = real(signalIQ);
y = imag(signalIQ);

plot(x, y, 'bo-', 'LineWidth', 2);
grid on;
title('Plot of cos(t) + j*sin (t)', 'Fontsize', 10);
xlabel('Real Component', 'Fontsize', 10);
ylabel('Imaginary Component', 'Fontsize', 10);
axis square;
%% Enlarge figure to full screen.
rxSig = awgn(signalIQ,20);
scatterplot(rxSig)

end
