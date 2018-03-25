#!/bin/bash
# file: preproc_rest
# usage: preproc_rest Sess WORKDIR Parc Parcname

# note: for only after minimal preprocessing with fmriprep has been performed..

subj=$1
WORKDIR=$2

Parc=$3
Parcname=$4

cd ${WORKDIR}/${subj}/func

#Lets go
#First, add detrend to confounds file

printf "Detrend\n" >> DetrendLinear.txt

for ((i=1;i<=518;i+=1))
        do
        printf "${i}\n" >> DetrendLinear.txt
done

#Now merge with original from fmriprep

paste DetrendLinear.txt confounds > sub-01_${Sess}_task-rest_run-001_bold_confounds_withdetrend.tsv

rm DetrendLinear.txt

#Remove 1st line just to be sure

sed '1d' sub-01_${Sess}_task-rest_run-001_bold_confounds_withdetrend.tsv > sub-01_${Sess}_task-rest_run-001_bold_confounds_withdetrend_nohead.tsv


#Standard confound regression
#Fields to include: 1,2,14,15,16,17,18,28,29,30,31,32,33

fsl_regfilt -i sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc.nii.gz -o sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc_regressed.nii.gz -d sub-01_${Sess}_task-rest_run-001_bold_confounds_withdetrend_nohead.tsv -m sub-01_${Sess}_task-rest_run-001_bold_space-T1w_brainmask.nii.gz -f "1,2,14,15,16,17,18,28,29,30,31,32,33"

#Pull out framewise displacement for Mac in order to further regression
#Field 6 from original confounds file

awk -F "/" '{print $6}' sub-01_${Sess}_task-rest_run-001_bold_confounds.tsv > sub-01_${Sess}_task-rest_run-001_bold_confounds_framewisedisplacement.txt

#Smoothing
#Calculate median for brightness threshold settings

mrstats sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc_regressed.nii.gz -mask sub-01_${Sess}_task-rest_run-001_bold_space-T1w_brainmask.nii.gz -allvolumes -output median > sub-01_${Sess}_task-rest_run-001_bold_mediansignal.txt

#Brightness threshold calculation
medboldval=`echo sub-01_${Sess}_task-rest_run-001_bold_mediansignal.txt`
brightthr=`echo "$medboldval*0.75" | bc -l`

#Susie
fslmaths sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc_regressed.nii.gz -mas sub-01_${Sess}_task-rest_run-001_bold_space-T1w_brainmask.nii.gz sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc_regressed_masked.nii.gz 
susan sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc_regressed_masked.nii.gz $brightthr 8 3 1 sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc_regressed_smoothed.nii.gz

#Bandpass filtering
#Set only high band-pass filter
#Sigma = 43.10 - calculated by 1/(2 * TR [1.16] * 0.10)

fslmaths sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc_regressed_smoothed.nii.gz -bptf 43.10 sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc_regressed_smoothed_filtered.nii.gz

#Extacted timeseries from parcellation region means

fslmeants -i sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preproc_regressed_smoothed_filtered.nii.gz --label=${Parc} > sub-01_${Sess}_task-rest_run-001_bold_space-T1w_preprocfull_${Parcname}_timeseries.txt
