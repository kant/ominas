

pro ominas_bug_info,outfile
compile_opt idl2,logical_predicate
outfile=n_elements(outfile) ? outfile : ''

if outfile then openw,lun,outfile,/get_lun else lun=-1

;environment
spawn,'env | grep OMINAS_',ominas_vars
spawn,'env | grep NV_',nv_vars
ominas_setup=pp_readtxt(getenv('HOME')+path_sep()+'.ominas'+path_sep()+'ominas_setup.sh')
sep='--------------------------------------------------------------------------------'

printf,lun,'OMINAS variables:'
printf,lun,ominas_vars,format='(A)'
printf,lun,sep
printf,lun,'NV variables:'
printf,lun,nv_vars,format='(A)'
printf,lun,sep
printf,lun,'ominas_setup.sh:'
printf,lun,ominas_setup,format='(A)'
printf,lun,sep


;IDL
help,!version,output=version

printf,lun,''
printf,lun,'IDL:'
printf,lun,version,format='(A)'
printf,lun,sep
printf,lun,'environment IDL_PATH'
printf,lun,getenv('IDL_PATH')
printf,lun,sep
printf,lun,'environment IDL_DLM_PATH'
printf,lun,getenv('IDL_DLM_PATH')
printf,lun,sep
printf,lun,'preferences IDL_PATH'
printf,lun,pref_get('IDL_PATH')
printf,lun,sep
printf,lun,'preferences IDL_DLM_PATH'
printf,lun,pref_get('IDL_DLM_PATH')
printf,lun,sep


;Icy
printf,lun,''
printf,lun,'Icy:'
catch,err
if err then begin
  catch,/cancel
  printf,lun,'Not found'
endif else begin
  help,'icy',/dlm,output=icydlm
  printf,lun,sep
  printf,lun,icydlm,format='(A)'
  printf,lun,sep
  printf,lun,cspice_tkvrsn('TOOLKIT'),format='(A)'
  printf,lun,sep
  cspice_ktotal,'ALL',count
  printf,lun,strtrim(count,2),' loaded kernels:'
  for i=0,count-1 do begin
    cspice_kdata,i,'ALL',file,type,source,handle,found
    printf,lun,i,file,format='(I,": ",A)'
  endfor
  printf,lun,sep
endelse

if outfile then free_lun,lun

end