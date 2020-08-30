function [difManchesterEnc,lastBit]= Differential_ManchesterEncoder(bitFrame)
lastBit =1;
difManchesterEnc= []
for i = 1:length(bitFrame)
      if bitFrame(i)==1
         if lastBit == 0
             difManchesterEnc=[difManchesterEnc 0xff];
             difManchesterEnc=[difManchesterEnc 0xff];
             lastBit=1;
         else
             difManchesterEnc=[difManchesterEnc 0x00];
             difManchesterEnc=[difManchesterEnc 0x00];
             lastBit = 0;
         end
      elseif bitFrame(i)==0
          if lastBit == 0
             difManchesterEnc=[difManchesterEnc 0xff];
             difManchesterEnc=[difManchesterEnc 0x00]; 
             lastBit == 0
          else lastBit == 0
             difManchesterEnc=[difManchesterEnc 0x00];
             difManchesterEnc=[difManchesterEnc 0xff];
             lastBit == 1
          end
          
              
      end
end
