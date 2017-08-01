function ImgUint8 = ContrastAdjustCT_Uint8(Img, WW, WL)

ImgOut = ContAdjUint8(Img,WW, WL);
ImgUint8 = uint8(ImgOut);
