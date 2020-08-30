function [manchesterEnc] = ManchesterEncoder(bitFrame) 
manchesterEnc = []
for i = 1:1:length(bitFrame)
    if bitFrame(i) == 1
        manchesterEnc=[manchesterEnc 0xff]
        manchesterEnc=[manchesterEnc 0x00] 
    else
        manchesterEnc=[manchesterEnc 0x00]
        manchesterEnc=[manchesterEnc 0xff]
    end
end

