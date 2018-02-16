;=============================================================================
; dh_read_png.pro
;
;=============================================================================
function dh_read_png, dd, label, dim, type, min, max, abscissa=abscissa, $
                          nodata=nodata, gff=gff, $
                          sample=sample, returned_samples=returned_samples

 if(keyword_set(sample)) then return, 0
 filename = dat_filename(dd)

min=0
max=0
;read the image
da=read_png(filename)
;read the metadata
filename_ja=(stregex(filename,'(.*)-raw\.png',/subexpr,/extract))[-1]+'-metadata.json'
label=json_parse(filename_ja)
label[0]='' ;dummy key to make detectors that assume label is a string array happy
type=size(da,/type)
nax=size(da,/n_dimensions)
dim=size(da,/dimensions)
return,da
end
;=============================================================================
