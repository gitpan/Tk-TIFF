/*
  Copyright (c) 1998 Slaven Rezic. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include <tkGlue.def>

#include "pTk/tkPort.h"
#include "pTk/tkInt.h"
#include "pTk/tkImgPhoto.h"
#include "pTk/imgInt.h"
#include "pTk/tkVMacro.h"
#include "tkGlue.h"
#include "tkGlue.m"

extern Tk_PhotoImageFormat      imgFmtTIFF;

DECLARE_VTABLES;

MODULE = Tk::TIFF	PACKAGE = Tk::TIFF

PROTOTYPES: DISABLE

BOOT:
 {
  IMPORT_VTABLES;
  install_vtab("TkimgphotoVtab",TkimgphotoVGet(),sizeof(TkimgphotoVtab));
  install_vtab("ImgintVtab",ImgintVGet(),sizeof(ImgintVtab));
  Tk_CreatePhotoImageFormat(&imgFmtTIFF);
 }
