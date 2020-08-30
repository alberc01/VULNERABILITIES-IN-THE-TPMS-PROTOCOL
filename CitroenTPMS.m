function CitroenTPMS(STATUS,ID,FLAGS,REPEAT,PRESSURE,TEMPERATURE,BATTERY,FILENAME)
    %% EJEMPLO DE VARIABLES DE ENTRADA
    % TRAMA NORMAL
    % "D2","5DCCD5CC", 0, 1, 289, 23, 14,"Citroen_codif_frame.u8"
    % TRAMA MODIFICADA
    % "D2","5DCCD5CC", 0, 1, 47, 63, 14,"Citroen_codif_Modif_frame.u8"
    %% CONSTRUCCION DE LA TRAMA
    % citroen tpms
    % /**
    % Citroen FSK 10 byte Manchester encoded checksummed TPMS data
    % also Peugeot and likely Fiat, Mitsubishi, VDO-types.
    % Packet nibbles:
    %     UU  IIIIIIII FR  PP TT BB  CC
    % - U = state, decoding unknown, not included in checksum
    % - I = id
    % - F = flags, (seen: 0: 69.4% 1: 0.8% 6: 0.4% 8: 1.1% b: 1.9% c: 25.8% e: 0.8%)
    % - R = repeat counter (seen: 0,1,2,3)
    % - P = Pressure (kPa in 1.364 steps, about fifth PSI?)
    % - T = Temperature (deg C offset by 50)
    % - B = Battery?
    % - C = Checksum, XOR bytes 1 to 9 = 0
    % */
    % 
    % FRAME EXAMPLE
    % status = d2 = 1101 0010
    % ------------------------------------
    % 
    % id =(5dccd5cc) 0101 1101 1100 1100 1101 0101 1100 1100
    % flags = 0000
    % repeat = 0001
    % press =(289/1.364= 211,877=>211) = 1101 0011
    % temp = (23+50= 73)= 0100 1001
    % battery = 14 = 0000 1110
    % -------------------------------------
    % 
    % checksum = 
    % 
    % 0000 0000 ^ 0101 1101 = 0101 1101
    % 0101 1101 ^ 1100 1100 = 1001 0001
    % 1001 0001 ^ 1101 0101 = 0100 0100
    % 0100 0100 ^ 1100 1100 = 1000 1000
    % 1000 1000 ^ 0000 0001 = 1000 1001
    % 1000 1001 ^ 1101 0011 = 0101 1010
    % 0101 1010 ^ 0100 1001 = 0001 0011
    % 0001 0011 ^ 0000 1110 = 0001 1101
    % CHECKSUM = 0001 1101

    %% CONSTANTES
    %CONSTANTE POR LA QUE DEBEMOS DIVIDIR LA PRESION
    PRESSURECONST = 1.364
    %DESPLAZAMIENTO DE LA TEMPERATURA
    TEMPOFFSET = 50
    %% PREAMBULO Y FINAL DE COMUNICACION

    %PARTE INCIAL DE TRAMA, INDICANDO INCIO DE LA COMUNICACION
    preambulo = [0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0xff,0x00]
    %PARTE FINAL DE TRAMA, INDICANDO FINAL DE LA COMUNICACION
    finaltrail = [0x00,0xff,0xff,0xff,0xff,0xff,0xff,0x00]

    %% Trama que se debe codificar
     %CONVERSION DE DATOS A FORMATO BINARIO
    systemStatus = dec2bin(hex2dec(STATUS),8);
    systemID = dec2bin(hex2dec(ID),32);
    systemFlags = dec2bin(FLAGS,4);
    systemRepeat = dec2bin(REPEAT,4);
    systemPressure = dec2bin(PRESSURE/PRESSURECONST,8);
    systemTemperature = dec2bin(TEMPERATURE + TEMPOFFSET,8);
    systemBattery = dec2bin(BATTERY,8);
    frame=[systemStatus,systemID,systemFlags,systemRepeat,systemPressure,systemTemperature,systemBattery]

    %PARSEO DE LA TRAMA DE CARACTER A DIGITO
    parsedFrame = []
    for i=1:length(frame)
        if frame(i)== '1'
            parsedFrame = [parsedFrame 1]
        else
            parsedFrame = [parsedFrame 0]
        end
    end

    %CALCULO DE CHECKSUM MEDIANTE LA OPERACION XOR ENTRE ELEMENTOS DE LA TRAMA
    %SEPARADOS EN GRUPOS DE 8 BITS
    checksum=zeros(1,8)
    j=9;
    for i=9:length(parsedFrame)
        if mod(i,8)==0
            checksum = xor(checksum,parsedFrame(j:i))
            j=i+1;
        end
    end

    %CONSTRUCCION DE LA TRAMA FINAL QUE DEBEREMOS MODULAR
    trama =[parsedFrame checksum]

    %% CODIFICACION DE LA SEÑAL
    % CODIFICACION DE LA SEÑAL EN MANCHESTER
    frameToModulate= ManchesterEncoder(trama) %returns manchesterEnc
    % CONSTRUCCION DE LA TRAMA CODIFICADA, EL PREAMBULO Y EL FIN DE LA
    % COMUNICACION NO DEBEN CODIFICARSE
    finalCodifiedFrame = [preambulo,frameToModulate,finaltrail]
    fd = fopen(FILENAME,"w+");

    %ESCRITURA DE LA SEÑAL PARA ALIMENTAR A GNURADIO
    if fd > 0
     for k=1:length(finalCodifiedFrame)
       fwrite(fd,finalCodifiedFrame(k),'uint8');
     end
    end
end

