#!/bin/bash

th rmLast.lua
th learn_autoencoder.lua
th imagesAndReprToTxt.lua
python generateNNImages.py 10 25
python plotStates.py
path=`cat lastModel.txt | grep Log`
nautilus $path
