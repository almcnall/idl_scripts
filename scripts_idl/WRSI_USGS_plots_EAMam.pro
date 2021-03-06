WRSI_USGS_plots_EAMam

;this script makes plots of the LIS-WRSI (CHIRPS) similar to what is found on the USGS website
;WRSI and WRSI anomalies

;make the wrsi color table available
wkdir = '/home/source/mcnally/scripts_idl/'
cd, wkdir
.compile make_wrsi_cmap.pro

indir = '/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/'
ifile = file_search(indir+'EA_MAY2NOV_WRSI_inst_CHIRPS_8114.nc')

fileID = ncdf_open(ifile, /nowrite) &$
wrsiID = ncdf_varid(fileID,'WRSI_inst') &$
ncdf_varget,fileID, wrsiID, EOSwrsi

;nx = 294, ny = 348, nz = 33
dims = size(EOSwrsi, /dimensions)
NX = dims[0]
NY = dims[1]
NZ = dims[2]

;East africa domain
map_ulx = 22.05 & map_lrx = 51.35
map_uly = 22.95 & map_lry = -11.75
;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.-1
;NX = lrx - ulx + 2 ;not sure why i have to add 2...
;NY = lry - uly + 2
year = indgen(33)+1981
for i = 0,n_elements(EOSwrsi[0,0,*])-1 do begin &$
  p1 = image(byte(EOSwrsi[*,*,i]), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry], $
            RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title =string(year[i]))  &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24) &$
 
  tmpclr = p1.rgb_table &$
  tmpclr[*,0] = [211,211,211] &$
  p1.rgb_table = tmpclr &$
 
 ;p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
 
  p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 18 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) &$
 endfor
 
 ;how to calculate the anomaly when the value is a flag?
 ;
 ;;make a CHIRPS-WRSIclim for the whole EA domain...the others are formated to the RFE domain (751x801)
EOSwrsi2 = EOSwrsi
EOSwrsi2(where(EOSwrsi2 eq -9999.0))= !values.f_nan
EOSwrsi2(where(EOSwrsi2 ge 253))= 25

clim = mean(EOSwrsi2, dimension=3) & help, clim

;ofile = '/home/mcnally/ee_ek_7033eo.bil'
;openw,1,ofile
;writeu,1,clim
;close,1

;this is closer but still not there...but closer
;but we can probably set >253 to 0 and say that it was a fail
;EOSwrsi2(where(EOSwrsi2 gt 253))= 0
clim(where(clim lt 0))=!values.f_nan
clim(where(clim gt 253))=25
EOSa = fltarr(294,348,33)

for y = 0, n_elements(EOSwrsi[0,0,*])-1 do begin &$
  EOSa[*,*,y] = EOSwrsi[*,*,y]/clim &$
endfor
    
;indir = '/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/'
;ifile = file_search(indir+'EA_OCT2FEB_WRSIa_inst_CHIRPS_8114.nc')
;
;fileID = ncdf_open(ifile, /nowrite) &$
;wrsiaID = ncdf_varid(fileID,'WRSIa_inst') &$
;ncdf_varget,fileID, wrsiaID, EOSwrsia

ncolors = 10
 for i = 0,n_elements(EOSa[0,0,*])-1 do begin &$
  p1 = image(byte(EOSa[*,*,i]*100), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry], $
            RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), title =string(year[i]), min_value=50, max_value=150)  &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24) &$
 
  tmpclr = p1.rgb_table &$
  tmpclr[*,0] = [211,211,211] &$
  p1.rgb_table = tmpclr &$
 
 ;p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
 
  p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 18 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) &$
 endfor
 
 