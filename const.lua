require 'lfs'

-- Constants file

-- All constants should be located here for now, in CAPS_LOCK
-- Ex : NB_EPOCHS = 10
-- Disclamer there still plenty of constants everywhere
-- Because it wasn't done like this before, so if you still 
-- find global variable, that's normal. You can change it
-- and put it here.

DATA_FOLDER = 'simpleData3D'

PRELOAD_FOLDER = 'preload_folder/'
lfs.mkdir(PRELOAD_FOLDER)

-- Create actions that weren't done by the robot
-- by sampling randomly states (begin point and end point)
-- Cannot be applied in every scenario !!!!
EXTRAPOLATE_ACTION = false

-- if you want to visualize images, use 'qlua' instead of 'th'
VISUALIZE_IMAGES_TAKEN = false

LR=0.001
DIMENSION=3

BATCH_SIZE = 3
NB_EPOCHS=100

IM_LENGTH = 200
IM_HEIGHT = 200

DATA_AUGMENTATION = 0.01

USE_CUDA = true
USE_SECOND_GPU = true

if USE_CUDA and USE_SECOND_GPU then
   cutorch.setDevice(2) 
end



