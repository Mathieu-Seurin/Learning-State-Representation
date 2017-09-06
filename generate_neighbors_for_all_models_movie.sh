#!/bin/bash

# NOTE This script assumes the model folders have already the output files after running the following two scripts for each model
#qlua script.lua  -use_cuda  -mcd $max_cos_dis -sigma $s -data_folder complexData # mobileRobot #complexData #colorful  #stati$
#th imagesAndReprToTxt.lua  -use_cuda -data_folder complexData #mobileRobot # complexData #colorful  #staticButtonSimplest
# where: 
# CONFIG OPTIONS:
# -use_cuda
# -use_continuous
# -params.sigma  is CONTINUOUS_ACTION_SIGMA
# -params.mcd is MAX_COS_DIST_AMONG_ACTIONS_THRESHOLD
# -data_folder options: DATA_FOLDER (Dataset to use):
#          staticButtonSimplest, mobileRobot, simpleData3D, pushingButton3DAugmented, babbling')
#data= staticButtonSimplest, mobileRobot, complexData colorful  #staticButtonSimplest https://stackoverflow.com/questions/2459286/unable-to-set-variables-in-bash-script  #"$data"='staticButtonSimplest'

function has_command_finished_correctly {
    if [ "$?" -ne "0" ]
    then
        exit
    else
        return 0
    fi
}

# other best models TODO
# /home/natalia/dream/baxter_representation_learning_3D/Log/3D_0.03_supervised
# /home/natalia/dream/baxter_representation_learning_3D/Log/3D_0.053_fix_butt_15ep
# /home/natalia/dream/baxter_representation_learning_3D/Log/3D_0.097_AE
# /home/natalia/dream/baxter_representation_learning_3D/Log/colorful75_0.013_ground_truth
# /home/natalia/dream/baxter_representation_learning_3D/Log/colorful75_0.196_button_ref
# /home/natalia/dream/baxter_representation_learning_3D/Log/complex_0.13_fix_rand_round0.06
# /home/natalia/dream/baxter_representation_learning_3D/Log/complex_0.035_groundTruth
# /home/natalia/dream/baxter_representation_learning_3D/Log/complex_0.071_supervised_bit_bad
# /home/natalia/dream/baxter_representation_learning_3D/Log/complex_0.078_fix_above_more_tol
# /home/natalia/dream/baxter_representation_learning_3D/Log/complex_0.145_AE_res
# /home/natalia/dream/baxter_representation_learning_3D/Log/complex bst078
# /home/natalia/dream/baxter_representation_learning_3D/Log/modelY2017_D26_M08_H20M07S28_colorful75_resnet_cont_MCD0_4_S0_3_ProTemCauRepFix

data_folder='staticButtonSimplest' #'colorful75'  #IMPORTANT: = the assignment operator (no space before and after)
# COLORFUL75 datasets  not done yet #'./Log/colorful75_0.196_button_ref' 
#for path_to_model in # './Log/colorful75_0.196_button_ref' './Log/Supervised_colorful75' './Log/colorful75_0.013_ground_truth'    
# 3D (STATIC_BUTTON_SIMPLEST) dataset
for path_to_model in './Log/3D_0.03_supervised_staticButtonSimplest' './Log/3D_0.053_fix_butt_15ep_staticButtonSimplest' './Log/3D_0.097_AE_staticButtonSimplest'
do
    echo " **** Running neighbour generation for all models. Model: $path_to_model DATA_FOLDER: $data_folder****"
    python generateNNImages.py -1 $path_to_model $data_folder
    #   ----- Note: includes the call to:
    #                th create_all_reward.lua
    #                th create_plotStates_file_for_all_seq.lua
    has_command_finished_correctly

    #python plotStates.py  -1
    #has_command_finished_correctly
done
