function ToyotaTPMS(STATUS,ID,PRESSURE,TEMPERATURE,FILENAME)
    %% EJEMPLO DE VARIABLES DE ENTRADA
    % TRAMA NORMAL
    % ToyotaTPMS(128,"FB0A43E7", 36.750, 29,"Toyota_normal_frame.u8")
    % TRAMA MODIFICADA
    % ToyotaTPMS(128,"FB0A43E7", 3.750, 69,"Toyota_atack_frame.u8")

    %% CONSTANTES
    %CONSTANTE POR LA QUE DEBEMOS MULTIPLICAR LA PRESION DESPLAZADA 7 VECES
    PRESSURECONST = 4;
    %DESPLAZAMIENTO DE LA PRESION
    PRESSUREOFFSET= 7;
    %DESPLAZAMIENTO DE LA TEMPERATURA
    TEMPOFFSET = 40;
    %% PREAMBULO
    %PARTE INCIAL DE TRAMA, INDICANDO INCIO DE LA COMUNICACION
    preambulo = [0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0x00,0xff,0xff,0xff,0xff]
    %% Trama que se debe codificar
     %CONVERSION DE DATOS A FORMATO BINARIO
    systemStatus = dec2bin(STATUS,8)=='1';
    systemID = dec2bin(hex2dec(ID),32)=='1';
    systemPressure = dec2bin(PRESSURECONST*(PRESSURE+PRESSUREOFFSET),8)=='1';
    systemTemperature = dec2bin(TEMPERATURE + TEMPOFFSET,8)=='1';

    onesFilled = ones(1,length(systemPressure));
    %NOS QUEDAMOS CON EL PRIMER BIT DE ESTADO
    firstStatusBit = systemStatus(1);
    %NOS QUEDAMOS LOS 7 BITS RESTANTES
    lastSevenStatusBits = systemStatus(2:length(systemStatus));
    
    %CALCULAMOS LA PRESION INVERTIDA CON LA OPERACION XOR
    invertedPressure = xor(systemPressure,onesFilled);
    %CONSTRUMOS LA TRAMA CON LA QUE DEBEMOS CALCULAR EL CRC DE 8 BITS
    frame=[systemID,firstStatusBit,systemPressure,systemTemperature,lastSevenStatusBits,invertedPressure];
    %PARSEAMOS TODOS LOS VALORES A FORMATO FLOAT
    frame= double(frame);
    
    %CALCULO DE CHECKSUM MEDIANTE LA OPERACION CRC-8 CON 0X07 DE FACTOR
    %POLINOMICO
    checkSum = crc8(frame,8,"07","80");

    %AÑADIMOS EL CRC A LA TRAMA A CODIFICAR
    trama =[frame checkSum]
    %% CODIFICACION DE LA SEÑAL
    % CODIFICACION DE LA SEÑAL EN MANCHESTER DIFERENCIAL
    [frameToModulate,lastBit] = Differential_ManchesterEncoder(trama) %returns difManch and lastBit
    %NEGAMOS CON LA FUNCION XOR EL ULTIMO BIT DE LA CODIFICACION
    finalBit= xor(lastBit,0xff)
    if finalBit==1
        finalBit=0xff
    end
    %REPETIMOS EL ULTIMO BIT NEGADO TRES VECES
    finaltrail=[finalBit,finalBit,finalBit]
    % CONSTRUCCION DE LA TRAMA CODIFICADA, EL PREAMBULO Y EL FIN DE LA
    % COMUNICACION NO DEBEN CODIFICARSE
    finalCodifiedFrame = [preambulo,frameToModulate,finaltrail]
    %PARSEO DE LA TRAMA A FORMATO UINT8
    for i=1: length(finalCodifiedFrame)
        if(finalCodifiedFrame(i)==1)
            finalCodifiedFrame(i)=255
        end
    end
    %% ESCRITURA DEL ARCHIVO BINARIO
    %APERTURA DEL ARCHIVO
    fd = fopen(FILENAME,"w+");
    %ESCRITURA DE LA SEÑAL PARA ALIMENTAR A GNURADIO
    if fd > 0
     for k=1:length(finalCodifiedFrame)
       fwrite(fd,finalCodifiedFrame(k),'uint8');
     end
    end
end

