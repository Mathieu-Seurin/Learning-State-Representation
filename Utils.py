#!/usr/bin/python
# coding: utf-8
import matplotlib.pyplot as plt
from matplotlib import colors
from matplotlib.colors import ListedColormap
from matplotlib.colors import LinearSegmentedColormap
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D
import sys
import numpy as np
import os, os.path
import matplotlib
import seaborn as sns

"""
Documentation for colorblind-supported plots: #http://seaborn.pydata.org/introduction.html
"""

SKIP_RENDERING = True  # Make True when running remotely via ssh for the batch/grid_search programs to save the plots and KNN figures folder
#DATASETS AVAILABLE:  NOTE: when adding a new dataset, add also to ALL_DATASETS for stats and logging consistency purposes
BABBLING = 'babbling'
MOBILE_ROBOT = 'mobileRobot'
SIMPLEDATA3D = 'simpleData3D'
PUSHING_BUTTON_AUGMENTED = 'pushingButton3DAugmented'
STATIC_BUTTON_SIMPLEST = 'staticButtonSimplest'
COMPLEX_DATA = 'complexData'
COLORFUL = 'colorful'  # 150 data recording sequences
COLORFUL75 = 'colorful75' # a smaller version half size of colorful
ALL_DATASETS = [BABBLING, MOBILE_ROBOT, SIMPLEDATA3D, PUSHING_BUTTON_AUGMENTED, STATIC_BUTTON_SIMPLEST,COMPLEX_DATA, COLORFUL, COLORFUL75]

# 2 options of plotting:
LEARNED_REPRESENTATIONS_FILE = "saveImagesAndRepr.txt"
GLOBAL_SCORE_LOG_FILE = 'globalScoreLog.csv'
MODELS_CONFIG_LOG_FILE  = 'modelsConfigLog.csv'
ALL_STATE_FILE = 'allStatesGT.txt'
LAST_MODEL_FILE = 'lastModel.txt'
ALL_STATS_FILE ='allStats.csv'
CONFIG = 'config.json' # not used yet, TODO
PATH_TO_LINEAR_MODEL = 'disentanglementLinearModels/'

def library_versions_tests():
    if not matplotlib.__version__.startswith('2.'):
        print "Using a too old matplotlib version (can be critical for properly plotting reward colours, otherwise the colors are difficult to see), to update, you need to do it via Anaconda: "
        print "Min version required is 2.0.0. Current version: ", matplotlib.__version__
        print "Option 1) (Preferred)\n - pip install --upgrade matplotlib (In general, prefer pip install --user (WITHOUT SUDO) to anaconda"
        print "2) To install anaconda (WARNING: can make sklearn PCA not work by installing a second version of numpy): \n -wget https://repo.continuum.io/archive/Anaconda2-4.4.0-Linux-x86_64.sh  \n -bash Anaconda2-4.4.0-Linux-x86_64.sh  \n -Restart terminal \n -conda update matplotlib"
        sys.exit(-1)

    numpy_versions_installed = np.__path__
    #print "numpy_versions_installed: ", numpy_versions_installed
    if len(numpy_versions_installed)>1:
        print "Probably you have installed numpy with and without Anaconda, so there is a conflict because two numpy versions can be used."
        print "Remove non-Anaconda numpy:\n 1) pip uninstall numpy \n and if needed, install 2.1) pip install --user numpy  \n "
        print "2.2) If 1 does not work: last version in: \n -https://anaconda.org/anaconda/numpy"

def get_data_folder_from_model_name(model_name):
    if BABBLING in model_name:
        return BABBLING
    elif MOBILE_ROBOT in model_name:
        return MOBILE_ROBOT
    elif SIMPLEDATA3D in model_name:
        return SIMPLEDATA3D
    elif PUSHING_BUTTON_AUGMENTED in model_name:
        return PUSHING_BUTTON_AUGMENTED
    elif STATIC_BUTTON_SIMPLEST in model_name:
        return STATIC_BUTTON_SIMPLEST
    elif COMPLEX_DATA in model_name:
        return COMPLEX_DATA
    elif COLORFUL75 in model_name:  # VERY IMPORTANT THE ORDER! TO NOT PROCESS THE WRONG SUPER LARGE DATASET WHEN RESOURCES NOT AVAILABLE!
        return COLORFUL75
    elif COLORFUL in model_name:
        return COLORFUL
    else:
        sys.exit("get_data_folder_from_model_name: Unsupported dataset!")

"""
Use this function if rewards need to be visualized, use plot_3D otherwise
"""
def plotStates(mode, rewards, toplot, plot_path, axes_labels = ['State Dimension 1','State Dimension 2','State Dimension 3'], title='Learned Representations-Rewards Distribution\n', dataset=''):
    # Plots states either learned or the ground truth
    # Useful documentation: https://matplotlib.org/examples/mplot3d/scatter3d_demo.html
    # Against colourblindness: https://chrisalbon.com/python/seaborn_color_palettes.html
    # TODO: add vertical color bar for representing reward values  https://matplotlib.org/examples/api/colorbar_only.html
    reward_values = set(rewards)
    rewards_cardinal = len(reward_values)
    rewards = map(float, rewards)
    print'plotStates ',mode,' for rewards cardinal: ',rewards_cardinal,' (', reward_values,')'
    cmap = colors.ListedColormap(['gray', 'blue', 'red'])     # print "cmap: ",type(cmap)

    # custom Red Gray Blue colormap
    colours = [(0.3,0.3,0.3), (0.0,0.0,1.0), (1,0,0)]
    n_bins = 100
    cmap_name = 'rgrayb'
    cm = LinearSegmentedColormap.from_list(cmap_name, colours, n_bins)

    colorblind_palette = sns.color_palette("colorblind", rewards_cardinal)  # 3 is the number of different colours to use
    #print(type(colorblind_palette))
    #cubehelix_pal_cmap = sns.cubehelix_palette(as_cmap=True)
    #print(type(cubehelix_pal_cmap))

    #sns.palplot(sns.color_palette("colorblind", 10))
    # sns.color_palette()
    #sns.set_palette('colorblind')

    colorblind_cmap  = ListedColormap(colorblind_palette)
    colormap = cmap
    bounds=[-1,0,9,15]
    norm = colors.BoundaryNorm(bounds, colormap.N)
    # TODO: for some reason, no matther if I use cmap=cmap or make cmap=colorblind_palette work, it prints just 2 colors too similar for a colorblind person

    fig = plt.figure()
    if mode =='2D':
        ax = fig.add_subplot(111)
        # colors_markers = [('r', 'o', -10, 0.5), ('b', '^', 0.5, 10)]
        # for c, m, zlow, zhigh in colors_markers:
        #     ax.scatter(toplot[:,0], toplot[:,1], c=c, marker=m)
        cax = ax.scatter(toplot[:,0], toplot[:,1], c=rewards, cmap=cmap, norm=norm, marker=".")#,fillstyle=None)
    elif mode == '3D':
        ax = fig.add_subplot(111, projection='3d')
        # for c, m, zlow, zhigh in colors_markers:
        #     ax.scatter(toplot[:,0], toplot[:,1], toplot[:,2], c=c, marker=m)
        cax = ax.scatter(toplot[:,0], toplot[:,1], toplot[:,2], c=rewards, cmap=cm, marker=".")#,fillstyle=None)
        ax.set_zlabel(axes_labels[2])
    else:
        sys.exit("only mode '2D' and '3D' plot supported")

    ax.set_xlabel(axes_labels[0])
    ax.set_ylabel(axes_labels[1])
    if 'GroundTruth' in plot_path:
        ax.set_title(title.replace('Learned Representations','Ground Truth')+dataset)
    else:
        ax.set_title(title+dataset)

    # adding color bar
    cbar = fig.colorbar(cax, ticks=[-1, 0, 1])
    cbar.ax.set_yticklabels(['-1', '0', '1'])  # vertically oriented colorbar
    plt.savefig(plot_path)
    #plt.colorbar()  #TODO WHY IT DOES NOT SHOW AND SHOWS A PALETTE INSTEAD?
    if not SKIP_RENDERING:  # IMPORTANT TO SAVE BEFORE SHOWING SO THAT IMAGES DO NOT BECOME BLANK!
        plt.show()
    print('\nSaved plot to '+plot_path)


"""
Use this function if rewards DO NOT need to be visualized, use plotStates otherwise
"""
def plot_3D(x =[1,2,3,4,5,6,7,8,9,10], y =[5,6,2,3,13,4,1,2,4,8], z =[2,3,3,3,5,7,9,11,9,10], axes_labels = ['U','V','W'], title='Learned representations-rewards distribution\n', dataset=''):

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')

    ax.scatter(x, y, z, c='r', marker='o')  # 'r' : red

    ax.set_xlabel(axes_labels[0])
    ax.set_ylabel(axes_labels[1])
    ax.set_zlabel(axes_labels[2])
    ax.set_title(title+dataset)


def file2dict(file): # DO SAME FUNCTIONS IN LUA and call at the end of set_hyperparams() method SKIP_VISUALIZATIOn, USE_CUDA and all the other params to used them in the subprocess subroutine.
    d = {}
    with open(file) as f:
        for line in f:
            if line[0]!='#':
               key_and_values = line.split()
               key, values = key_and_values[0], key_and_values[1:]
               d[key] = map(float, values)
    return d

def parse_true_state_file(dataset):
    true_states = {}
    all_states_file = ALL_STATE_FILE.replace('.txt', ('_'+dataset+'.txt'))
    file_state = open(all_states_file, "r")

    for line in file_state:
        if line[0]!='#':
            words = line.split()
            true_states[words[0]] = np.array(map(float,words[1:]))
    print "parse_true_state_file: ",all_states_file," returned #true_states: ",len(true_states)
    if len(true_states) == 0:
        sys.exit('parse_true_state_file could not find any states file!')
    return true_states

def parse_repr_file(learned_representations_file):

    images=[]
    representations=[]

    #reading data
    file_representation = open(learned_representations_file, "r")
    for line in file_representation:
        if line[0]!='#':
            words = line.split()
            images.append(words[0])
            representations.append(words[1:])
    print "parse_repr_file: ",learned_representations_file," returned #representations: ",len(representations)
    if len(images) == 0:
        sys.exit('parse_repr_file could not find any images !')
    if len(representations) == 0:
        sys.exit('parse_repr_file could not find any representations file!: ',learned_representations_file)
    return images, representations


def get_test_set_for_data_folder(data_folder):
    # Returns a dictionary (notice, with unique keys) of test images
    # TODO : extend for other datasets for comparison, e.g. babbling
    if data_folder == STATIC_BUTTON_SIMPLEST:
        return IMG_TEST_SET
    elif data_folder == COMPLEX_DATA:
        return COMPLEX_TEST_SET
    elif data_folder == COLORFUL75:
        return COLORFUL75_TEST_SET
    elif data_folder == COLORFUL:
        return COLORFUL_TEST_SET
    elif data_folder == MOBILE_ROBOT:
        return ROBOT_TEST_SET
    else:
        sys.exit('get_list_of_test_imgs_for_dataset: Dataset has not a defined test set: {}'.format(data_folder))


# 50 lines, 49 images (1 repeated by error) IMAGES TEST SET HANDPICKED TO SHOW VISUAL VARIABILITY
IMG_TEST_SET = {
'staticButtonSimplest/record_000/recorded_cameras_head_camera_2_image_compressed/frame00000.jpg',
'staticButtonSimplest/record_000/recorded_cameras_head_camera_2_image_compressed/frame00012.jpg',
'staticButtonSimplest/record_000/recorded_cameras_head_camera_2_image_compressed/frame00015.jpg',
'staticButtonSimplest/record_000/recorded_cameras_head_camera_2_image_compressed/frame00042.jpg',
'staticButtonSimplest/record_000/recorded_cameras_head_camera_2_image_compressed/frame00039.jpg',
'staticButtonSimplest/record_000/recorded_cameras_head_camera_2_image_compressed/frame00065.jpg',
'staticButtonSimplest/record_000/recorded_cameras_head_camera_2_image_compressed/frame00048.jpg',
'staticButtonSimplest/record_000/recorded_cameras_head_camera_2_image_compressed/frame00080.jpg',
'staticButtonSimplest/record_000/recorded_cameras_head_camera_2_image_compressed/frame00004.jpg',
'staticButtonSimplest/record_000/recorded_cameras_head_camera_2_image_compressed/frame00078.jpg',

'staticButtonSimplest/record_008/recorded_cameras_head_camera_2_image_compressed/frame00056.jpg',
'staticButtonSimplest/record_008/recorded_cameras_head_camera_2_image_compressed/frame00047.jpg',
'staticButtonSimplest/record_008/recorded_cameras_head_camera_2_image_compressed/frame00033.jpg',
'staticButtonSimplest/record_008/recorded_cameras_head_camera_2_image_compressed/frame00005.jpg',
'staticButtonSimplest/record_008/recorded_cameras_head_camera_2_image_compressed/frame00026.jpg',
'staticButtonSimplest/record_008/recorded_cameras_head_camera_2_image_compressed/frame00056.jpg',

'staticButtonSimplest/record_011/recorded_cameras_head_camera_2_image_compressed/frame00003.jpg',
'staticButtonSimplest/record_011/recorded_cameras_head_camera_2_image_compressed/frame00056.jpg',
'staticButtonSimplest/record_011/recorded_cameras_head_camera_2_image_compressed/frame00063.jpg',
'staticButtonSimplest/record_011/recorded_cameras_head_camera_2_image_compressed/frame00035.jpg',
'staticButtonSimplest/record_011/recorded_cameras_head_camera_2_image_compressed/frame00015.jpg',

'staticButtonSimplest/record_019/recorded_cameras_head_camera_2_image_compressed/frame00009.jpg',
'staticButtonSimplest/record_019/recorded_cameras_head_camera_2_image_compressed/frame00074.jpg',
'staticButtonSimplest/record_019/recorded_cameras_head_camera_2_image_compressed/frame00049.jpg',

'staticButtonSimplest/record_022/recorded_cameras_head_camera_2_image_compressed/frame00039.jpg',
'staticButtonSimplest/record_022/recorded_cameras_head_camera_2_image_compressed/frame00085.jpg',
'staticButtonSimplest/record_022/recorded_cameras_head_camera_2_image_compressed/frame00000.jpg',

'staticButtonSimplest/record_031/recorded_cameras_head_camera_2_image_compressed/frame00000.jpg',
'staticButtonSimplest/record_031/recorded_cameras_head_camera_2_image_compressed/frame00007.jpg',
'staticButtonSimplest/record_031/recorded_cameras_head_camera_2_image_compressed/frame00070.jpg',

'staticButtonSimplest/record_036/recorded_cameras_head_camera_2_image_compressed/frame00085.jpg',
'staticButtonSimplest/record_036/recorded_cameras_head_camera_2_image_compressed/frame00023.jpg',
'staticButtonSimplest/record_036/recorded_cameras_head_camera_2_image_compressed/frame00036.jpg',

'staticButtonSimplest/record_037/recorded_cameras_head_camera_2_image_compressed/frame00053.jpg',
'staticButtonSimplest/record_037/recorded_cameras_head_camera_2_image_compressed/frame00083.jpg',
'staticButtonSimplest/record_037/recorded_cameras_head_camera_2_image_compressed/frame00032.jpg',

'staticButtonSimplest/record_040/recorded_cameras_head_camera_2_image_compressed/frame00045.jpg',
'staticButtonSimplest/record_040/recorded_cameras_head_camera_2_image_compressed/frame00003.jpg',
'staticButtonSimplest/record_040/recorded_cameras_head_camera_2_image_compressed/frame00080.jpg',

'staticButtonSimplest/record_048/recorded_cameras_head_camera_2_image_compressed/frame00034.jpg',
'staticButtonSimplest/record_048/recorded_cameras_head_camera_2_image_compressed/frame00059.jpg',
'staticButtonSimplest/record_048/recorded_cameras_head_camera_2_image_compressed/frame00089.jpg',
'staticButtonSimplest/record_048/recorded_cameras_head_camera_2_image_compressed/frame00030.jpg',

'staticButtonSimplest/record_050/recorded_cameras_head_camera_2_image_compressed/frame00064.jpg',
'staticButtonSimplest/record_050/recorded_cameras_head_camera_2_image_compressed/frame00019.jpg',
'staticButtonSimplest/record_050/recorded_cameras_head_camera_2_image_compressed/frame00008.jpg',

'staticButtonSimplest/record_052/recorded_cameras_head_camera_2_image_compressed/frame00000.jpg',
'staticButtonSimplest/record_052/recorded_cameras_head_camera_2_image_compressed/frame00008.jpg',
'staticButtonSimplest/record_052/recorded_cameras_head_camera_2_image_compressed/frame00068.jpg',
'staticButtonSimplest/record_052/recorded_cameras_head_camera_2_image_compressed/frame00025.jpg'}
#print(len(IMG_TEST_SET))

# 50 unique images 
COMPLEX_TEST_SET = {
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00030.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00003.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00021.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00025.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00014.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00027.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00034.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00016.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00001.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00026.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00015.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00011.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00047.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00020.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00012.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00029.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00045.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00049.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00039.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00038.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00032.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00028.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00037.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00005.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00004.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00040.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00017.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00008.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00006.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00031.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00035.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00042.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00000.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00036.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00002.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00044.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00018.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00041.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00013.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00033.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00048.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00009.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00024.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00010.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00022.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00043.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00007.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00023.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00019.jpg',
'complexData/record_025/recorded_cameras_head_camera_2_image_compressed/frame00046.jpg'
}
#print(len(COMPLEX_TEST_SET))


# 56 Images
ROBOT_TEST_SET = {
'mobileRobot/record_005/recorded_camera_top/frame00001.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00002.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00003.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00004.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00005.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00006.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00007.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00008.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00009.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00010.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00011.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00012.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00013.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00014.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00015.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00016.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00017.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00018.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00019.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00020.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00021.jpg',
'mobileRobot/record_005/recorded_camera_top/frame00022.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00048.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00049.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00050.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00051.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00052.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00053.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00054.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00055.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00056.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00057.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00058.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00059.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00060.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00061.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00062.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00063.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00064.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00065.jpg',
'mobileRobot/record_000/recorded_camera_top/frame00066.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00010.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00011.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00012.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00013.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00014.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00015.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00016.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00017.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00018.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00019.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00020.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00021.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00022.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00023.jpg',
'mobileRobot/record_004/recorded_camera_top/frame00024.jpg'
}

# 50 Images: NOTE: IMPORTANT: RECORD_150 is a special one created with multi colors domain randomization WITHIN the same sequence (other sequences are not)
# in order to have a varied dataset in the test set.
COLORFUL_TEST_SET = {   
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00030.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00003.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00021.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00025.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00014.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00027.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00034.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00016.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00001.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00026.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00015.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00011.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00047.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00020.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00012.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00029.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00045.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00049.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00039.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00038.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00032.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00028.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00037.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00005.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00004.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00040.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00017.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00008.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00006.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00031.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00035.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00042.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00000.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00036.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00002.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00044.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00018.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00041.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00013.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00033.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00048.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00009.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00024.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00010.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00022.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00043.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00007.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00023.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00019.jpg',
'colorful/record_150/recorded_cameras_head_camera_2_image_compressed/frame00046.jpg'
}

COLORFUL75_TEST_SET = {   
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00030.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00003.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00021.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00025.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00014.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00027.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00034.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00016.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00001.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00026.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00015.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00011.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00047.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00020.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00012.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00029.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00045.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00049.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00039.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00038.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00032.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00028.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00037.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00005.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00004.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00040.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00017.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00008.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00006.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00031.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00035.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00042.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00000.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00036.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00002.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00044.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00018.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00041.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00013.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00033.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00048.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00009.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00024.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00010.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00022.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00043.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00007.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00023.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00019.jpg',
'colorful75/record_150/recorded_cameras_head_camera_2_image_compressed/frame00046.jpg'
}
#library_versions_tests()

