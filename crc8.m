
%   Based on crc8 function from rtl_433 util
%   https://github.com/merbanan/rtl_433/blob/master/src/util.c

function [checkSum]= crc8(frame,nBytes,polynomial,init)
    polynomial = double(dec2bin(hex2dec(polynomial),8)=='1');
    init = double(dec2bin(hex2dec(init),8)=='1');
    checkSum = double(init);
    i=1
    j=8
    for z=1:nBytes
      checkSum = double(xor(checkSum,frame(i:j)));
      for bit=1:8
         if checkSum(1)==1
             aux = [checkSum 0];
             aux= aux(2:length(aux))
             checkSum = double(xor(aux,polynomial));  
         else
             checkSum = [checkSum 0]
             checkSum= checkSum(2:length(checkSum))
         end

      end
      i=j+1;
      j=j+8;
    end
end

