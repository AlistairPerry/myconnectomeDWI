
add detrend to timeseries

covariates

F 1,2,14,15,16,17,18, 28, 29, 30, 31, 32, 33



pull out FD for Mac


field 6 from orig


calculate median

mrstats sub-01_ses-044_task-rest_run-001_bold_space-T1w_preproc.nii.gz -mas sub-01_ses-044_task-rest_run-001_bold_space-T1w_brainmask.nii.gz -allvolumes -output median

susan

brightnessthr median * 0.75


susan sub-01_ses-044_task-rest_run-001_bold_space-T1w_preproc.nii.gz [brthr] 8 3 1 susanout


band pass 

fslmaths susanout -bptf 43.10 susan_filtered


timeseries

  parc

fslmeants -i ${funcfile} --label=${Parc} > ${OutDir}/${Sess}/sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc_${parcname}_timeseries.txt

