--================ DATASETS AVAILABLE =====================
--=================================================

BABBLING = 'babbling'
MOBILE_ROBOT = 'mobileRobot'
SIMPLEDATA3D = 'simpleData3D'
PUSHING_BUTTON_AUGMENTED = 'pushingButton3DAugmented'

--DATA_FOLDER = MOBILE_ROBOT
DATA_FOLDER = PUSHING_BUTTON_AUGMENTED
--DATA_FOLDER = BABBLING

print("============ DATA USED =========\n",
                    DATA_FOLDER,
      "\n================================")

--================ MODEL USED =====================
--=================================================
INCEPTIONV4 = './models/inceptionFineTunning.lua'

RESNET = './models/resnet.lua'
RESNET_VERSION = 18 --34 or 50 maybe
FROZEN_LAYER = 3 --learning_rate=0 for those layer, meaning : number of layer who don't learn at all

BASE_TIMNET = './models/topUniqueSimplerWOTanh'

--MODEL_ARCHITECTURE_FILE = INCEPTIONV4 --Too big
--MODEL_ARCHITECTURE_FILE = BASE_TIMNET
MODEL_ARCHITECTURE_FILE = RESNET

print("Model :",MODEL_ARCHITECTURE_FILE)


--======================================================
--Continuous actions SETTINGS
--======================================================
USE_CONTINUOUS = false --A switch between discrete and continuous actions (translates into calling getRandomBatchFromSeparateListContinuous instead of getRandomBatchFromSeparateList
ACTION_AMPLITUDE = 0.01
-- The following parameter eliminates the need of finding close enough actions for assessing all priors except for the temporal.one.
-- If the actions are too far away, they will make the gradient 0 and will not be considered for the update rule
GAUSSIAN_SIGMA = 0.3 -- 0.1 for mobileData plots all concentrated.

--==================================================
-- Hyperparams : Learning rate, batchsize, USE_CUDA etc...
--==================================================

-- Create actions that weren't done by the robot
-- by sampling randomly states (begin point and end point)
-- Cannot be applied in every scenario !!!!
EXTRAPOLATE_ACTION = false

LR=0.0001
LR_DECAY = 1e-6

SGD_METHOD = 'adam' -- Can be adam or adagrad
BATCH_SIZE = 5
NB_EPOCHS=10

DATA_AUGMENTATION = 0.01
NORMALIZE_IMAGE = true

COEF_TEMP=1
COEF_PROP=1
COEF_REP=1
COEF_CAUS=1
DIMENSION_OUT=2


if DATA_FOLDER ~= BABBLING then
    PRIORS_TO_APPLY ={{"Prop","Temp","Caus","Rep"}}
else
    -- Causality needs at least 2 different values of reward and in sparse dataset such as babbling_1, this does not occur always
    PRIORS_TO_APPLY ={{"Rep","Prop","Temp"}}
    print('WARNING: Causality prior will be ignored for dataset '..BABBLING)
end

