--=============================================================
-- Constants file

-- All constants should be located here for now, in CAPS_LOCK
-- Ex : NB_EPOCHS = 10
-- Disclamer there still plenty of constants everywhere
-- Because it wasn't done like this before, so if you still
-- find global variable, that's normal. You can change it
-- and put it here.

-- Hyperparameters are located in a different file (hyperparameters.lua)
--=============================================================
require 'lfs'
require 'hyperparams'
json = require 'json'   --  json = require("json")

---NOTE: THESE ARE DEFAULTS (IF NOT COMMAND LINE ARGS ARE PASSED), AND ARE OVERRIDEN BY DATA_FOLDER SPECIFIC CASES BELOW :
----------------------------------------------------------------------------------------------------------------------------
USE_CUDA = true
USE_SECOND_GPU = true

USE_CONTINUOUS = false

MAX_COS_DIST_AMONG_ACTIONS_THRESHOLD = 0.4  -- best so far for colorful75 with 4priors + fixed point
CONTINUOUS_ACTION_SIGMA = 0.4
DATA_FOLDER = MOBILE_ROBOT --works best!  # NONSTATIC_BUTTON
CONFIG_DICT = {}
CONFIG_JSON_FILE = 'Config.json'

--===============================================
--ALL POSSIBLE PRIORS: (set them in hyperparams)
--===============================================
REP = "Rep"
CAUS = "Caus"
PROP = "Prop"
TEMP = "Temp"
BRING_CLOSER_REWARD = "Reward_closer"
BRING_CLOSER_REF_POINT = "Fixed_point"
ROUNDING_VALUE_FIX = 0.1  -- used in BRING_CLOSER_REF_POINT
REWARD_PREDICTION_CRITERION= 'Prediction Reward'
ALL_PRIORS = {REP, CAUS,PROP,TEMP,BRING_CLOSER_REWARD, BRING_CLOSER_REF_POINT, REWARD_PREDICTION_CRITERION}
--DEFAULTS BEING APPLIED (SET THEM IN HYPERPARAMS.LUA)
PRIORS_CONFIGS_TO_APPLY ={{PROP, TEMP, CAUS, REP}}
MODEL_APPROACH = 'RoboticPriors'
SAVE_MODEL_T7_FILE = true --NECESSARY STEP TO RUN FULL EVALUATION PIPELINE (REQUIRED FILE BY imagesAndReprToTxt.lua)
USING_BUTTONS_RELATIVE_POSITION = false

-- ====================================================
---- needed for non cuda mode?
-- cutorch = require 'cutorch'
-- cudnn = require 'cudnn'
-- cunn = require 'cunn'

if USE_CUDA then
    require 'cunn'
    require 'cutorch'
    require 'cudnn'  --If trouble, installing, follow step 6 in https://github.com/jcjohnson/neural-style/blob/master/INSTALL.md
    -- and https://github.com/soumith/cudnn.torch  --TODO: set to true when speed issues rise
    -- cudnn.benchmark = true -- uses the inbuilt cudnn auto-tuner to find the fastest convolution algorithms.
    --                -- If this is set to false, uses some in-built heuristics that might not always be fastest.
    -- cudnn.fastest = true -- this is like the :fastest() mode for the Convolution modules,
                 -- simply picks the fastest convolution algorithm, rather than tuning for workspace size
    tnt = require 'torchnet'
    vision = require 'torchnet-vision'  -- Install via https://github.com/Cadene/torchnet-vision
end

--torch.manualSeed(100)
--=====================================
--DATA AND LOG FOLDER NAME etc..
--====================================
PRELOAD_FOLDER = 'preload_folder/'
lfs.mkdir(PRELOAD_FOLDER)

LOG_FOLDER = 'Log/'
MODEL_PATH = LOG_FOLDER

--STRING_MEAN_AND_STD_FILE = PRELOAD_FOLDER..'meanStdImages_'..DATA_FOLDER..'.t7'
LEARNED_REPRESENTATIONS_FILE = "saveImagesAndRepr.txt"
LAST_MODEL_FILE = 'lastModel.txt'
GLOBAL_SCORE_LOG_FILE = 'globalScoreLog.csv'
MODELS_CONFIG_LOG_FILE  = 'modelsConfigLog.csv'

RELOAD_MODEL = false

--===========================================================
-- VISUALIZATION TOOL
-- if you want to visualize images, use 'qlua' instead of 'th'
--===========================================================
VISUALIZE_IMAGES_TAKEN = false -- true for visualizing images taken in each prior
VISUALIZE_CAUS_IMAGE = false
VISUALIZE_IMAGE_CROP = false
VISUALIZE_MEAN_STD = false
VISUALIZE_AE = false

IM_CHANNEL = 3 --image channels (RGB)
ACTION_AMPLITUDE = 0.01
--================================================
-- dataFolder specific constants : filename, dim_in, indexes in state file etc...
--================================================
CLAMP_CAUSALITY = false

MIN_TABLE = {-10000,-10000} -- for x,y
MAX_TABLE = {10000,10000} -- for x,y

DIMENSION_IN = 2
DIMENSION_OUT= 3  -- STATES_DIMENSION (to be learned, configurable as cmd line param as STATES_DIMENSION,for grid search)
STATES_DIMENSION = -1

REWARD_INDEX = 1  --3 reward values: -1, 0, 10
INDEX_TABLE = {1,2} --column index for coordinate in state file (respectively x,y)

DEFAULT_PRECISION = 0.05

FILENAME_FOR_ACTION = "recorded_robot_action.txt" --not used at all, we use state file, and compute the action with it (contains dx, dy)
FILENAME_FOR_STATE = "recorded_robot_state.txt"
FILENAME_FOR_REWARD = "recorded_robot_reward.txt"
FILENAME_FOR_BUTTON_POSITION = 'recorded_button1_position.txt'  -- content example: # x y z   # 0.599993419271 0.29998631216 -0.160117283495

-- WARNING : If you change the folder (top, pano, front)
-- do rm preload_folder/* because the images won't be good
SUB_DIR_IMAGE = 'recorded_camera_top'
AVG_FRAMES_PER_RECORD = 90

--===============================================
FILE_PATTERN_TO_EXCLUDE = 'deltas'
CAN_HOLD_ALL_SEQ_IN_RAM = true
-- ====================================================
--DATASET DEPENDENT settings to be set below
STRING_MEAN_AND_STD_FILE =''
NAME_SAVE= ''
SAVED_MODEL_PATH = ''
--MODEL_ARCHITECTURE_FILE =''
WINDOW = nil--image.display(image.lena())
LOGGING_ACTIONS = false
IS_INCEPTION = false
IS_RESNET = false

DIFFERENT_FORMAT = IS_INCEPTION or IS_RESNET
MEAN_MODEL = torch.ones(3):double()*0.5
STD_MODEL = torch.ones(3):double()*0.5
MEAN_MODEL = torch.DoubleTensor({ 0.485, 0.456, 0.406 })
STD_MODEL = torch.DoubleTensor({ 0.229, 0.224, 0.225 })
IM_LENGTH = 200
IM_HEIGHT = 200

function addLeadingZero(number)
    -- Returns a string with a leading zero of the number if the number has only one digit (for model logging and sorting purposes)
    if number >= 0 and number <= 9 then  return "0" .. number else return tostring(number)    end
end

---------------------------------------------------------------------------------------
-- Function :	priorsToString(params)
--======================================================
--we add the first 2 letters of each prior for logging the priors used in the name and folder of the model
---------------------------------------------------------------------------------------
function priorsToString(tableOfPriors)
    str = '_'
    for index, priors in pairs(tableOfPriors) do
        for i=1,#priors do
            str = str..string.sub(priors[i], 1,3)
        end
    end
    return str
end
---------------------------------------------------------------------------------------
--======================================================
-- Function :	set_hyperparams(params)
--======================================================
-- TODO shall it be different (and saevd into CONFIG.TXT file (TODO) for each dataset depending on the variance of the input state space?
--If so, What is a good proxy  parameter to set it?
-- Input ():  modelApproach string, 2nd param adds model approach to model name
-- Output ():
---------------------------------------------------------------------------------------
function set_hyperparams(params, modelApproach, createNewModelFolder)
    --overriding the defaults:
    USE_CUDA = params.use_cuda      --print ('Boolean param: ') -- type is boolean
    USE_CONTINUOUS = params.use_continuous
    MAX_COS_DIST_AMONG_ACTIONS_THRESHOLD = params.mcd
    CONTINUOUS_ACTION_SIGMA = params.sigma
    DATA_FOLDER = params.data_folder  --print('[Log: Setting command line dataset to '..params.data_folder..']') type is a str
    STATES_DIMENSION = params.states_dimension
    MODEL_APPROACH = modelApproach  --if non empty (RoboticsPriors), can be inverse, forward model or ICM (TODO)
    set_cuda_hyperparams(USE_CUDA)
    set_dataset_specific_hyperparams(DATA_FOLDER, modelApproach, createNewModelFolder)

    save_config_to_file(CONFIG_DICT, CONFIG_JSON_FILE)
end

function set_cuda_hyperparams(USE_CUDA)
    --===========================================================
    -- CUDA CONSTANTS
    --===========================================================
    -- if USE_CUDA then
    --     require 'cunn'
    --     require 'cutorch'
    --     require 'cudnn'  --If trouble, installing, follow step 6 in https://github.com/jcjohnson/neural-style/blob/master/INSTALL.md
    --     -- and https://github.com/soumith/cudnn.torch
    --     cudnn.benchmark = true -- uses the inbuilt cudnn auto-tuner to find the fastest convolution algorithms.
    --                    -- If this is set to false, uses some in-built heuristics that might not always be fastest.
    --     cudnn.fastest = true -- this is like the :fastest() mode for the Convolution modules,
    --                  -- simply picks the fastest convolution algorithm, rather than tuning for workspace size
    --     tnt = require 'torchnet'
    --     vision = require 'torchnet-vision'  -- Install via https://github.com/Cadene/torchnet-vision
    -- end
    if USE_CUDA and USE_SECOND_GPU then
       cutorch.setDevice(2)
    end
end

function set_dataset_specific_hyperparams(DATA_FOLDER, modelApproach, createNewModelFolder)
    STRING_MEAN_AND_STD_FILE = PRELOAD_FOLDER..'meanStdImages_'..DATA_FOLDER..'.t7'
    -- print(MODEL_ARCHITECTURE_FILE) --./models/minimalNetModel      -- print(MODEL_ARCHITECTURE_FILE:match("(.+)/(.+)")) -- returns  ./models	minimalNetModel
    _, architecture_name = MODEL_ARCHITECTURE_FILE:match("(.+)/(.+)") --architecture_name, _ = split(architecture_name, ".")

    if DATA_FOLDER == SIMPLEDATA3D then
       DEFAULT_PRECISION = 0.05 -- for 'arrondit' function
       CLAMP_CAUSALITY = true  --TODO: make false when continuous works

       MIN_TABLE = {0.42,-0.2,-10} -- for x,y,z doesn't really matter in fact
       MAX_TABLE = {0.8,0.7,10} -- for x,y,z doesn't really matter in fact

       REWARD_INDICE = 2
       INDEX_TABLE = {2,3,4} --column indice for coordinate in state file (respectively x,y,z)

       FILENAME_FOR_REWARD = "is_pressed"
       FILENAME_FOR_ACTION = "endpoint_action"
       FILENAME_FOR_STATE = "endpoint_state"

       SUB_DIR_IMAGE = 'recorded_cameras_head_camera_2_image_compressed'

       MIN_TABLE = {0.42,-0.1,-10} -- for x,y,z doesn't really matter in fact
       MAX_TABLE = {0.75,0.6,10} -- for x,y,z doesn't really matter in fact

       DIMENSION_IN = 3
       if STATES_DIMENSION == -1 then  -- we use default dimension per dataset
          DIMENSION_OUT = 3
          STATES_DIMENSION = DIMENSION_OUT
       else
          DIMENSION_OUT = STATES_DIMENSION
       end

       REWARD_INDEX = 2 --2 reward va_robot_limb_left_endpoint_state.txt"--endpoint_state"

       SUB_DIR_IMAGE = 'recorded_cameras_head_camera_2_image_compressed'
       AVG_FRAMES_PER_RECORD = 100

    elseif DATA_FOLDER == MOBILE_ROBOT then
        print('Setting hyperparams for MOBILE_ROBOT (our baseline reproducing Jonchowscki)')
       --NOTE: DEFAULT PARAMETERS FOR OUR BASELINE DATABASE SET AT THE BEGINNING OF THE FILE (NEED TO BE DECLARED AS CONSTANTS
        CLAMP_CAUSALITY = false

        if STATES_DIMENSION == -1 then  -- we use default dimension per dataset
            DIMENSION_OUT = 2 --100 is a bit better, but we keep it default 2 for now
            STATES_DIMENSION = DIMENSION_OUT
        else
            DIMENSION_OUT = STATES_DIMENSION
        end
        -- MIN_TABLE = {-10000,-10000} -- for x,y
        -- MAX_TABLE = {10000,10000} -- for x,y

        -- DIMENSION_IN = 2
        -- DIMENSION_OUT = 2  --worked just as well as 4 output dimensions
        -- REWARD_INDEX = 1  --3 reward values: -1, 0, 10
        -- INDEX_TABLE = {1,2} --column index for coordinate in state file (respectively x,y)

        -- DEFAULT_PRECISION = 0.1
        -- FILENAME_FOR_ACTION = "recorded_robot_action.txt" --not used at all, we use state file, and compute the action with it (contains dx, dy)
        -- FILENAME_FOR_STATE = "recorded_robot_state.txt"
        -- FILENAME_FOR_REWARD = "recorded_robot_reward.txt"

        -- SUB_DIR_IMAGE = 'recorded_camera_top'
        AVG_FRAMES_PER_RECORD = 90

        -- -- Middle of field
        FIXED_POS = {1.54133736021, 1.71509412704}

        ROUNDING_VALUE_FIX = 0.1

    elseif DATA_FOLDER == BABBLING then
      -- Leni's real Baxter data on  ISIR dataserver. It is named "data_archive_sim_1".
      --(real Baxter Pushing Objects).  If data is not converted into action, state
      -- and reward files with images in subfolder, run first the conversion tool from
      -- yml format to rgb based data in https://github.com/LeniLeGoff/DB_action_discretization
      --For the version 1 of the dataset, rewards are very sparse and not always there is 2 values for the reward (required to apply Causality prior)
      DEFAULT_PRECISION = 0.1
      CLAMP_CAUSALITY = false
      MIN_TABLE = {-10000, -10000, -10000} -- for x,y,z
      MAX_TABLE = {10000, 10000, 10000} -- for x,y, z
      --
      DIMENSION_IN = 3
      if STATES_DIMENSION == -1 then  -- we use default dimension per dataset
          DIMENSION_OUT = 3
          STATES_DIMENSION = DIMENSION_OUT
      else
          DIMENSION_OUT = STATES_DIMENSION
      end

      REWARD_INDEX = 2 -- column (2 reward values: 0, 1 in this dataset)
      INDEX_TABLE = {2,3,4} --column indexes for coordinate in state file (respectively x,y)
      --
      FILENAME_FOR_REWARD = "reward_pushing_object.txt"  -- 1 if the object being pushed actually moved
      FILENAME_FOR_STATE = "state_pushing_object.txt" --computed while training based on action
      FILENAME_FOR_ACTION_DELTAS = "state_pushing_object_deltas.txt"
      FILENAME_FOR_ACTION = FILENAME_FOR_ACTION_DELTAS --""action_pushing_object.txt"

      SUB_DIR_IMAGE = 'baxter_pushing_objects'
      AVG_FRAMES_PER_RECORD = 60
      -- Causality needs at least 2 different values of reward and in sparse dataset such as babbling_1, this does not occur always
      --PRIORS_TO_APPLY ={{"Rep","Prop","Temp"}}
      PRIORS_CONFIGS_TO_APPLY ={{TEMP}}--, works best than 3 priors for babbling so far  {"Prop","Temp"}, {"Prop","Rep"},  {"Temp","Rep"}, {"Prop","Temp","Rep"}}  --TODO report 1 vs 2 vs 3 priors, add all prioris when Babbling contains +1 reward value
      --print('WARNING: Causality prior, at least, will be ignored for dataset because of too sparse rewards (<2 value types). TODO: convert to 3 reward values'..BABBLING?

    elseif DATA_FOLDER == PUSHING_BUTTON_AUGMENTED then
      CLAMP_CAUSALITY = false --TODO: make false when continuous works

      MIN_TABLE = {0.42,-0.2,-10} -- for x,y,z
      MAX_TABLE = {0.8,0.7,10} -- for x,y,z

      DIMENSION_IN = 3
      if STATES_DIMENSION == -1 then  -- we use default dimension per dataset
          DIMENSION_OUT = 3
          STATES_DIMENSION = DIMENSION_OUT
      else
          DIMENSION_OUT = STATES_DIMENSION
      end

      REWARD_INDEX = 2 --2 reward values: -0, 1 ?
      INDEX_TABLE = {2,3,4} --column index for coordinates in state file, respectively (x,y,z)

      DEFAULT_PRECISION = 0.05 -- for 'arrondit' function
      FILENAME_FOR_REWARD = "recorded_button1_is_pressed.txt"--"is_pressed"
      FILENAME_FOR_ACTION = "recorded_robot_limb_left_endpoint_action.txt"--endpoint_action"  -- Never written, always computed on the fly
      FILENAME_FOR_STATE = "recorded_robot_limb_left_endpoint_state.txt"--endpoint_state"

      SUB_DIR_IMAGE = 'recorded_cameras_head_camera_2_image_compressed'
      AVG_FRAMES_PER_RECORD = 100

    elseif DATA_FOLDER == STATIC_BUTTON_SIMPLEST then
        CLAMP_CAUSALITY = false --TODO: make false when continuous works
        -- A point where the robot wants the state to be very similar. Like a reference point for the robot
        FIXED_POS = {0.607, 0.017, -0.143} --for fixed point prior
        ROUNDING_VALUE_FIX = 0.04

        MIN_TABLE = {0.42,-0.2,-10} -- for x,y,z
        MAX_TABLE = {0.8,0.7,10} -- for x,y,z

        DIMENSION_IN = 3
        if STATES_DIMENSION == -1 then  -- we use default dimension per dataset
            DIMENSION_OUT = 3
            STATES_DIMENSION = DIMENSION_OUT
        else
            DIMENSION_OUT = STATES_DIMENSION
        end

        REWARD_INDEX = 2 --2 reward values: -0, 1 ?
        INDEX_TABLE = {2,3,4} --column index for coordinates in state file, respectively (x,y,z)

        DEFAULT_PRECISION = 0.05 -- for 'arrondit' function
        FILENAME_FOR_REWARD = "recorded_button1_is_pressed.txt"
        FILENAME_FOR_ACTION = "recorded_robot_limb_left_endpoint_action.txt" -- Never written, always computed on the fly
        FILENAME_FOR_STATE = "recorded_robot_limb_left_endpoint_state.txt"

        SUB_DIR_IMAGE = 'recorded_cameras_head_camera_2_image_compressed'
        AVG_FRAMES_PER_RECORD = 90  --HINT: reduce for fast full epoch testing in CPU mode

    elseif DATA_FOLDER == COMPLEX_DATA then
        CLAMP_CAUSALITY = false --TODO: make false when continuous works
        AVG_FRAMES_PER_RECORD = 200

        -- A point where the robot wants the state to be very similar.
        --Like a reference point for the robot

        -- just above the button
        --FIXED_POS = {0.587, -0.036, -0.143}
        FIXED_POS = { 0.598, 0.300, -0.143}  --for fixed point prior
        ROUNDING_VALUE_FIX = 0.04

        -- Above and further
        -- FIXED_POS = {0.639, 0.286, 0.136}
        -- ROUNDING_VALUE_FIX = 0.04

        MIN_TABLE = {0.42,-0.1,-0.11} -- for x,y,z
        MAX_TABLE = {0.75,0.60,0.35} -- for x,y,z

        DIMENSION_IN = 3
        if STATES_DIMENSION == -1 then  -- we use default dimension per dataset
            DIMENSION_OUT = 3
            STATES_DIMENSION = DIMENSION_OUT
        else
            DIMENSION_OUT = STATES_DIMENSION
        end

        REWARD_INDEX = 2 -- Which column in the reward file indicates the value of reward ?
        INDEX_TABLE = {2,3,4} --column index for coordinates in state file, respectively (x,y,z)

        DEFAULT_PRECISION = 0.05 -- for 'arrondit' function
        -- During data generation the amplitude of actions is set randomly in the interval of (0.03, 0.07).
        FILENAME_FOR_REWARD = "recorded_button1_is_pressed.txt"
        FILENAME_FOR_ACTION = "recorded_robot_limb_left_endpoint_action.txt" -- Never written, always computed on the fly
        FILENAME_FOR_STATE = "recorded_robot_limb_left_endpoint_state.txt"

        SUB_DIR_IMAGE = 'recorded_cameras_head_camera_2_image_compressed'

        -- BEST WORKING PARAMETERS FOR CONTINUOUS ACTIONS in this dataset so far: 52,modelY2017_D03_M08_H09M40S59_colorful75_resnet_cont_MCD0_3_S0_3_ProTemCauRep,0.126241133861,colorful75,./models/resnet,0.3,0.3:
        MAX_COS_DIST_AMONG_ACTIONS_THRESHOLD = 0.01
        CONTINUOUS_ACTION_SIGMA = 0.9

    elseif DATA_FOLDER == COLORFUL or DATA_FOLDER == COLORFUL75 then
        -- IMPORTANT: NOTE THAT BOTH THESE DATASETS HAVE CUSTOM TEST SETS THAT SHOULD BE USED, it is called sequence number record_150
        -- because it contains all different colors in domain randomization for a more fair assessment of the KNN_MSE
        CLAMP_CAUSALITY = false --TODO: make false when continuous works
        --Colorful starting pos is 0.6 0.3 0.1             NO starting point for complex and static
        FIXED_POS  = {0.6, 0.30, 0.10} -- starting point for every sequence in fixed point prior
        -- FIXED_POS = {0.587, -0.036, -0.143} --because some times position varies

        -- A point where the robot wants the state to be very similar. Like a reference point for the robot

        MIN_TABLE = {0.42,-0.1,-0.11} -- for x,y,z
        MAX_TABLE = {0.75,0.60,0.35} -- for x,y,z

        DIMENSION_IN = 3
        if STATES_DIMENSION == -1 then  -- we use default dimension per dataset
            DIMENSION_OUT = 3
            STATES_DIMENSION = DIMENSION_OUT
        else
            DIMENSION_OUT = STATES_DIMENSION
        end

        REWARD_INDEX = 2 -- Which column in the reward file indicates the value of reward ?
        INDEX_TABLE = {2,3,4} --column index for coordinates in state file, respectively (x,y,z)

        DEFAULT_PRECISION = 0.05 -- for 'arrondit' function
        FILENAME_FOR_REWARD = "recorded_button1_is_pressed.txt"
        FILENAME_FOR_ACTION = "recorded_robot_limb_left_endpoint_action.txt" -- Never written, always computed on the fly
        FILENAME_FOR_STATE = "recorded_robot_limb_left_endpoint_state.txt"

        SUB_DIR_IMAGE = 'recorded_cameras_head_camera_2_image_compressed'
        AVG_FRAMES_PER_RECORD = 250  --HINT: reduce for fast full epoch testing in CPU mode
        NB_EPOCHS = 5 --otherwise, see hyperparams for default value. colorful75 converges in losses fast, as it has more images, around epoch 3-5 and therefore 5-10 epocs are enough, while for the rest of smaller #seqs (~50), the nr of epochs is 50.

        -- BEST WORKING PARAMETERS FOR CONTINUOUS ACTIONS in this dataset so far: 52,modelY2017_D03_M08_H09M40S59_colorful75_resnet_cont_MCD0_3_S0_3_ProTemCauRep,0.126241133861,colorful75,./models/resnet,0.3,0.3:
        -- MAX_COS_DIST_AMONG_ACTIONS_THRESHOLD = 0.3
        -- CONTINUOUS_ACTION_SIGMA = 0.3
    elseif DATA_FOLDER == NONSTATIC_BUTTON then  -- FOR NOW, A COPY OF 3D_STATIC_DATASET TODO: MODIFY ACCORDINGLY WITH NEW SIMULATOR OF ANTONIN
      USING_BUTTONS_RELATIVE_POSITION = true
      CLAMP_CAUSALITY = false --TODO: make false when continuous works
      -- A point where the robot wants the state to be very similar. Like a reference point for the robot
      FIXED_POS = {0.607, 0.017, -0.143} --for fixed point prior
      ROUNDING_VALUE_FIX = 0.04

      MIN_TABLE = {0.42,-0.2,-10} -- for x,y,z
      MAX_TABLE = {0.8,0.7,10} -- for x,y,z

      DIMENSION_IN = 3
      if STATES_DIMENSION == -1 then  -- we use default dimension per dataset
          DIMENSION_OUT = 3
          STATES_DIMENSION = DIMENSION_OUT
      else
          DIMENSION_OUT = STATES_DIMENSION
      end

      REWARD_INDEX = 2 --2 reward values: -0, 1 ?
      INDEX_TABLE = {2,3,4} --column index for coordinates in state file, respectively (x,y,z)

      DEFAULT_PRECISION = 0.05 -- for 'arrondit' function
      FILENAME_FOR_REWARD = "recorded_button1_is_pressed.txt"
      FILENAME_FOR_ACTION = "recorded_robot_limb_left_endpoint_action.txt" -- Never written, always computed on the fly
      FILENAME_FOR_STATE = "recorded_robot_limb_left_endpoint_state.txt"

      SUB_DIR_IMAGE = 'recorded_cameras_head_camera_2_image_compressed'
      AVG_FRAMES_PER_RECORD = 90  --HINT: reduce for fast full epoch testing in CPU mode

    else
      print("No supported data folder provided, please add either of the data folders defined in hyperparams: "..BABBLING..", "..MOBILE_ROBOT.." "..SIMPLEDATA3D..' or others in const.lua' )
      os.exit()
    end

    if VISUALIZE_IMAGES_TAKEN or VISUALIZE_CAUS_IMAGE or VISUALIZE_IMAGE_CROP or VISUALIZE_MEAN_STD or VISUALIZE_AE then
       --Creepy, but need a placeholder, to prevent many window to pop
       WINDOW = image.display(image.lena())
    end

    LOGGING_ACTIONS = false

    if string.find(MODEL_ARCHITECTURE_FILE, 'inception') then
        IS_INCEPTION = true
    end
    if string.find(MODEL_ARCHITECTURE_FILE, 'resnet') then
        -- since the model require images to be a 3x299x299, and normalize differently, we need to adapt
        IS_RESNET = true
    end

    if string.find(MODEL_ARCHITECTURE_FILE, 'autoencoder_conv') then
       IS_RESNET = true -- AUTO_ENCODER USES RESNET AT THE MOMENT (encoding part)
    end

    if string.find(MODEL_ARCHITECTURE_FILE, 'minimalNetModel') then --TODO replace by constants
        error([[minimalNetModel should only be used in learn_autoencoder.lua, not script.lua]])
    end
    -- if IS_RESNET and DATA_FOLDER == STATIC_BUTTON_SIMPLEST then  --TODO FIx and remove this check (Mat was able to run this, it should be
    --     error([[STATIC_BUTTON_SIMPLEST= staticButtonSimplest dataset is not yet supported by ResNet model architecture, we are working on it? Try for now topUniqueSimplerWOTanh model]])
    -- end  --mobileData can on the other hand be run with and vithout resnet
    DIFFERENT_FORMAT = IS_INCEPTION or IS_RESNET

    if IS_INCEPTION then
       IM_LENGTH = 299
       IM_HEIGHT = 299
       MEAN_MODEL = torch.ones(3):double()*0.5
       STD_MODEL = torch.ones(3):double()*0.5
    elseif IS_RESNET then
       IM_LENGTH = 224
       IM_HEIGHT = 224
       MEAN_MODEL = torch.DoubleTensor({ 0.485, 0.456, 0.406 })
       STD_MODEL = torch.DoubleTensor({ 0.229, 0.224, 0.225 })
    else
       IM_LENGTH = 200
       IM_HEIGHT = 200
    end

    -- EXTRA PRIORS:
    if APPLY_BRING_CLOSER_REWARD then  -- TODO implement
       table.insert(PRIORS_CONFIGS_TO_APPLY[1], BRING_CLOSER_REWARD)
    end
    if APPLY_BRING_CLOSER_REF_POINT then
       table.insert(PRIORS_CONFIGS_TO_APPLY[1], BRING_CLOSER_REF_POINT)
    end
    if APPLY_REWARD_PREDICTION_CRITERION then  -- TODO implement
       table.insert(PRIORS_CONFIGS_TO_APPLY[1], REWARD_PREDICTION_CRITERION)
    end
    if RUN_FORWARD_MODEL then
        PRIORS_CONFIGS_TO_APPLY = {{FORWARD_MODEL}}
    end
    -- L1Smooth and cosDistance and max margin: compare with homemade MSDCriterion and replace if similar in the good practice of using native code
    --TODO PRIORS_CONFIGS_TO_APPLY.add('CosDist','L1SmoothDist','MaxMargin')


    -- DEFAULT_PRECISION for all CONTINUOUS ACTIONS:
    if USE_CONTINUOUS then  --otherwise, it is not used
        DEFAULT_PRECISION = 0.01
    end
    ------------------ Predictive priors settings---------
    ----------------------------------------------------------
    if ACTIVATE_PREDICTIVE_PRIORS then
        USE_CONTINUOUS = false -- TODO extend ICM module to continuous actions
        LR = 0.001 -- as in ICM pathak17  --0.003 in Shelhammer17?
        SGD_METHOD = 'adam'
        HIDDEN_LAYERS = 100 --neurons in Model learning DDPG (ML-DDPG)
        --ICM settings:
        BETA = 0.2
        LAMBDA = 0.1
        DIMENSION_OUT = 288
    end

    -- SAVING MODEL CONFIG
    if createNewModelFolder then
        --create new model filename to be uniquely identified
        now = os.date("*t")
        if USE_CONTINUOUS then
            DAY = 'Y'..now.year..'_M'..addLeadingZero(now.month)..'_D'..addLeadingZero(now.day)..'_H'..addLeadingZero(now.hour)..'M'..addLeadingZero(now.min)..'S'..addLeadingZero(now.sec)..'_'..DATA_FOLDER..'_'..architecture_name..'_cont'..'_MCD'..MAX_COS_DIST_AMONG_ACTIONS_THRESHOLD..'_S'..CONTINUOUS_ACTION_SIGMA..priorsToString(PRIORS_CONFIGS_TO_APPLY)..'_ST_DIM'..STATES_DIMENSION
            DAY = DAY:gsub("%.", "_")  -- replace decimal points by '_' for folder naming
        else
            DAY = 'Y'..now.year..'_M'..addLeadingZero(now.month)..'_D'..addLeadingZero(now.day)..'_H'..addLeadingZero(now.hour)..'M'..addLeadingZero(now.min)..'S'..addLeadingZero(now.sec)..'_'..DATA_FOLDER..'_'..architecture_name..priorsToString(PRIORS_CONFIGS_TO_APPLY)..'_ST_DIM'..STATES_DIMENSION
        end
        if modelApproach then --to add an extra keyword  to the model name
            NAME_SAVE= modelApproach..'model'..DAY
        else
            NAME_SAVE= 'model'..DAY
        end
        SAVED_MODEL_PATH = LOG_FOLDER..NAME_SAVE
        print ('The model will be saved in '..SAVED_MODEL_PATH)
    end
end

function print_hyperparameters(print_continuous_actions_config, extra_string_to_print)
    extra_string_to_print = extra_string_to_print or ''
    print(extra_string_to_print)
    print("============ Experiment: DATA_FOLDER USED =========\n",
                        DATA_FOLDER,
												" (LOG_FOLDER ", LOG_FOLDER,
                        ")\nUSE_CUDA ",USE_CUDA,", USE_CONTINUOUS ACTIONS: ",USE_CONTINUOUS, " MODEL: ",MODEL_ARCHITECTURE_FILE,". PRIORS_CONFIGS_TO_APPLY", PRIORS_CONFIGS_TO_APPLY)
    print('APPLY: EXTRAPOLATE_ACTION, EXTRAPOLATE_ACTION_CAUS, APPLY_BRING_CLOSER_REWARD, APPLY_BRING_CLOSER_REF_POINT, APPLY_REWARD_PREDICTION_CRITERION: ')
    print(EXTRAPOLATE_ACTION,EXTRAPOLATE_ACTION_CAUS,APPLY_BRING_CLOSER_REWARD,APPLY_BRING_CLOSER_REF_POINT,APPLY_REWARD_PREDICTION_CRITERION)
    if print_continuous_actions_config then--USE_CONTINUOUS and not using_precomputed_model then  --otherwise, it is not used
        --if we are using a precomputed model stored in a file, the command line default parameters are not effective and thus we should not print them, as they will be contradicting the ones being applied on the precomputed model that is going to be preloaded
        --Keep separated ifs to avoid conflicts with default parameters
        if USE_CONTINUOUS then
            print ('MAX_COS_DIST_AMONG_ACTIONS_THRESHOLD: ',MAX_COS_DIST_AMONG_ACTIONS_THRESHOLD,' CONTINUOUS_ACTION_SIGMA: ', CONTINUOUS_ACTION_SIGMA)
        end
    end
    print("\n================================")
end

function save_config_to_file(config_dict, filename)
    --    Saves config into json file for only one file to include important constans
    --to be read by whole learning pipeline of lua and python scripts
    CONFIG_DICT['DATA_FOLDER']= DATA_FOLDER
    -- if STATES_DIMENSION == -1 then  -- we use default dimension per dataset
    --   STATES_DIMENSION = DIMENSION_OUT
    -- end
    CONFIG_DICT['STATES_DIMENSION']= DIMENSION_OUT
    CONFIG_DICT['PRIORS_CONFIGS_TO_APPLY']=  PRIORS_CONFIGS_TO_APPLY
    CONFIG_DICT['MODEL_ARCHITECTURE_FILE']= MODEL_ARCHITECTURE_FILE
    CONFIG_DICT['MODEL_APPROACH']= MODEL_APPROACH
    CONFIG_DICT['FIFTH_PRIOR_FIXED_POINT']= FIXED_POS
    CONFIG_DICT['USING_BUTTONS_RELATIVE_POSITION']= USING_BUTTONS_RELATIVE_POSITION
    --local path = system.pathForFile( filename, system.DocumentsDirectory)  -- how to require system? 'lfs' and 'system' do not work.   local lfs = require "lfs";
    local file = io.open(CONFIG_JSON_FILE, "w")     -- "rb")
    if file then
        local contents = json.encode(CONFIG_DICT)
        file:write( contents )
        io.close( file )
        return true
    else
        print ('Could not save config to file ',CONFIG_DICT)
        return false
    end
end

function read_config(filename)
    -- load the data from json file into a dictionary
    local myTable = {}
    local file = io.open( filename, "r" )

    if file then
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        myTable = json.decode(contents)
        io.close( file )
        print('Read config: ', myTable)
        return myTable
    end
    return nil
end

----------------- Tests

function json_test()
  --Install json2lua luarocks install --server=http://rocks.moonscript.org/manifests/amrhassan --local json4Lua
  --json = require("json")
  --   Returns a string representing value encoded in JSON.
  table = { 1, 2, 3, { x = 10 } }
  string = json.encode(table) -- Returns '[1,2,3,{"x":10}]'
  --Returns a value representing the decoded JSON string.
  --decoded = json.decode('[1,2,3,{"x":10}]')  --gives qlua: /home/seurin/.luarocks/share/lua/5.2/json.lua:232: attempt to call global 'loadstring' (a nil value)
  save_config_to_file(string, CONFIG_JSON_FILE)
  loaded = read_config(CONFIG_JSON_FILE)
  print(loaded)
end

--json_test()    --/home/seurin/torch/install/share/lua/5.2/torch/CmdLine.lua:104: attempt to call field 'insert' (a nil value)
--stack traceback:   /home/seurin/torch/install/share/lua/5.2/torch/CmdLine.lua:104: in function 'option'   script.lua:252: in main chunk



--Ref. Point position for the 5th Ref. point prior
--(A point where the robot wants the state to be very similar. Like a reference point for the robot)

-- _____________________________   MORE CLARIFICATIONS ON THE FIXED PRIOR:
-- Button’s position:
-- {0.587, 0.300, -0.13} (Y,X,Z?) in ComplexData and Colorful75  (can vary, sometimes you get: 0.63 0.29 -0.14)
-- Colorful starting pos is 0.6 0.3 0.1         	NO starting point for complex and static
-- According to the current status of the code, I run using starting position all experiments for colorful while for all other datasets (complex and static button) we have by default and have run experiments using fixed point close to the button.
--
-- {0.58,  -0.03, -0.13} (X,Y,Z) in StaticButtonSimplest (more or less, you can check in recorded_robot_limb_left_endpoint_state.txt, it can vary a little bit (sometimes you get 0.64 -0.04 -0.14))
--
--
-- ---
-- STATIC_BUTTON_SIMPLEST:        (ROUNDING_VALUE_FIX = 0.04)  Button’s position is: (0.58, -0.03, -0.13)
--         FIXED_POS = {0.607, 0.017, -0.143} :  Not the button, i was testing other location  BUT VERY CLOSE TO THE BUTTON!
-- COMPLEX_DATA:   (ROUNDING_VALUE_FIX = 0.04,  Button’s position: (0.587, 0.3, -0.13))
--         -- just above the button:
--         FIXED_POS = { 0.598, 0.300, -0.143}   The position is above the button, again, it was just for testing purpose, trying different ref point position
--         -- Above and further:
--         -- FIXED_POS = {0.639, 0.286, 0.136}  -- Is this the position of the arm in the beginning of each sequence? No, this is a random test position
--  COLORFUL or COLORFUL75 (ROUNDING_VALUE_FIX = 0.01,  Button’s position: (0.587, 0.3, -0.13))
--         FIXED_POS  = {0.6, 0.30, 0.10} -- starting point for every sequence in fixed point prior -- Is this the position of the arm in the beginning of each sequence? If not, Why is so close to the button position and what was the position of the initial arm at the beginning of each sequence? Same for the next line:   THIS is the starting point for every colorful sequence (if you look at every recorded_robot_limb_left_endpoint_state.txt, it start with this) If you look at images, it’s not close to the button, it’s above, yes, that why the first 2 coordinate are close, but the last one is very different (-0.14 on the button, 0.10 for starting point)
--         -- FIXED_POS = {0.587, -0.036, -0.143}  This is the position of the button
--
