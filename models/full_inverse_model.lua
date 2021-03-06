-- require 'nn'
-- require 'nngraph'

--require 'cudnn'
--require 'cunn'
--require 'cutorch'

---INVERSE MODEL: : Given state_t and state_t+1, predict the action (needed to reach that state).
--  This is common problem in planning and navigation where we have the goal we want
-- to reach and we need to find the actions that take us there.


--TODO: difference with INVERSE RL? see https://stats.stackexchange.com/questions/189067/how-to-make-a-reward-function-in-reinforcement-learning
--TODO: reward prediction model (ICM where given a_t, s_t and s_t+1, we predict reward t),
-- see pred_bonus in https://github.com/pathak22/noreward-rl/blob/master/src/model.py
---TODO Augment with full ICM using  Intrinsic reward signal is computed as the difference between the next state and the estimated next state, pondered by a η/2 (η > 0)  scaling factor
--inverse RL or "apprenticeship learning", which generates a reward function that would reproduce observed behaviours.
--  Finding the best reward function to reproduce a set of observations can also be
-- implemented by MLE, bayesian, or information theoretic methods.  finding the reward function is the hardest part of the problem, it is intimately tied up with how you specify the state space. For example in a time-dependent problem, the distance to the goal often makes a poor reward function (e.g. in the mountain car problem).
--Such situations can be solved by using higher dimensional state spaces (hidden states or memory traces), or by hierarchical RL.

--  test_nn_graph.lua is an example of how nngraph should be done. Also a note:
--  never use updateOutput and updateGradInput, Only use forward and backward.
--  Basically, forward calls updateOutput + other stuff to retain the gradients etc.
--  And backward calls updateGradInput + other stuff to retain gradients etc. In conclusion,
--  it's better to call forward/backward because some models are doing more than just calling updateOutput etc.
-- SEE DOCUMENTATION IN https://github.com/torch/nn/blob/master/doc/module.md

--Model inspired from ICM:
-- The intrinsic curiosity module consists of the forward and the inverse
-- model. The inverse model first maps the input state
-- (st) into a feature vector φ(st) using a series of four convolution
-- layers, each with 32 filters, kernel size 3x3, stride
-- of 2 and padding of 1. ELU non-linearity is used after
-- each convolution layer. The dimensionality of φ(st) (i.e.
-- the output of the fourth convolution layer) is 288. For the
-- inverse model, φ(st) and φ(st+1) are concatenated into a
-- single feature vector and passed as inputs into a fully connected
-- layer of 256 units followed by an output fully connected
-- layer with 4 units to predict one of the four possible
-- actions. The forward model is constructed by concatenating
-- φ(st) with at and passing it into a sequence of two fully
-- connected layers with 256 and 288 units respectively. The
-- value of β is 0.2, and λ is 0.1. The Equation (7) is minimized
-- with learning rate of 1e − 3.

--
-- --TODO use softmax instead of reLu as in https://arxiv.org/pdf/1612.07307.pdf inverse models? and add reward prediction and sum of losses

--FROM ICM:
--NUM_HIDDEN_UNITS = 5 --TODO: what is ideal size? see ICM inverse model and forward model of loss is its own reward.
FC_UNITS_LAYER1 = 256
FC_UNITS_LAYER2 = 4
--TODO add ELU after each conv layer  and  four convolution layers, each with
NB_FILTERS = 32
KERNEL_SIZE = 3 --3x3
STRIDE = 2
PADDING = 1

local M = {}

function saveNetworkGraph(gmodule, title, show)
    --see also https://github.com/fmassa/optimize-net
    -- gmod is what we send to forward and backward pass
    -- gmod is what we send to forward and backward pass
    if not show then
        graph.dot(gmodule.fg, title ) --'Forward Graph')
    else --show and save          --filename = '../modelGraphs/fwdGraph'..title --Using / in path gives segmentation fault error!?
        print('saving network graph in main project dir: '..title)
        --if not file_exists(filename) then
        graph.dot(gmodule.fg, title, title)--, filename) --TODO fix: gives Graphviz Segmentation fault (core dumped)
    end
    --graph.dot(gmodule.bg, 'Backward Graph')
    -- param, grad = net:getParameters() --returns all weights and the gradients of the network in two 2D vector
    -- print('params: ',param, 'grad: ',grad)
    -- plot_loss()
end

function getModel(dimension_state_out, dimension_action)
    --TODO see parameter sharing http://kbullaughey.github.io/lstm-play/rnn/
    --Input:  Img_t, Img_t+1, Action_t, Action_t+1
    -- Output:
   print('getModel with hidden units '..NUM_HIDDEN_UNITS)
   local img_t = nn.Identity()()
   local img_t1 = nn.Identity()()

   state_t = nn.ReLU()(nn.Linear(DIMENSION_IN, dimension_state_out)(img_t))
   state_t1 = nn.ReLU()(nn.Linear(DIMENSION_IN, dimension_state_out)(img_t1)) --TODO How to make these two share params as they are not gModels to be cloned?
   --savedModel = model.modules[1]:clone('weight','bias','running_mean','running_std') --or  savedModel = model:clone('weight','bias','running_mean','running_std')

   -- Inverse model:
   state_and_next_state = nn.JoinTable(2)({state_t, state_t1})
   action_prediction = nn.Linear(NUM_HIDDEN_UNITS, dimension_action)(nn.Linear(DIMENSION_IN *2, NUM_HIDDEN_UNITS)(state_and_next_state))

   --state_prediction = nn.Linear(512, dimension_out)
   g = nn.gModule({img_t, img_t1}, {action_prediction})
   --TODO try g = nn.gModule({img_t, img_t1}, {action_prediction, reward}) -- and example from https://github.com/eladhoffer/ImageNet-Training/blob/master/Models/GoogLeNet_BN_Original.lua
   local g = require('weight-init')(g, 'xavier')local NLL = nn.ClassNLLCriterion()
   --local mse_crit = nn.MSECriterion()
   --local mse_crit2 = nn.MSECriterion()
   --local loss = nn.ParallelCriterion(true):add(mse_crit):add(mse_crit2)  -- return {model = model, loss = loss}
   saveNetworkGraph(g,'FullInverseModel', true)
   return g   --return {model = model, loss = loss}
end

function train_model(model_graph)
    --https://github.com/torch/nn/blob/master/doc/criterion.md#nn.CrossEntropyCriterion
    --Basically, you don't put any activation unit at the end of you network
    -- this criterion calculate the logsoftmax and the classification loss
    -- WHAT SHOULD BE THE CRITERION LOSS FUNCTION IN AN INVERSE MODEL? If we had discrete actions, as in ICM, a soft-max distribution accross all possible actions (amounts to MLE of theta under a multinomial distribution)
    local crit = nn.MSECriterion()--local mse_crit = nn.MSECriterion() -- TODO try SmoothL1Criterion(): Creates a criterion that can be thought of as a smooth version of the AbsCriterion. It uses a squared term if the absolute element-wise error falls below 1. It is less sensitive to outliers than the MSECriterion and in some cases prevents exploding gradients (e.g. see "Fast R-CNN" paper by Ross Girshick).
    -- local mse_crit2 = nn.MSECriterion()
    -- --local crit = nn.ParallelCriterion(true):add(mse_crit):add(mse_crit2) --Criterion is a weighted sum of other Criterion. Criterions are added using the method: If repeatTarget=true, the target is repeatedly presented to each criterion (with a different input).
    batch_img_t = torch.randn(BATCH_SIZE, DIMENSION_IN) --Returns a Tensor filled with random numbers from a normal distribution with zero mean and variance of one.
    batch_img_t1 = torch.randn(BATCH_SIZE, DIMENSION_IN)

    batch_action = torch.randn(BATCH_SIZE, DIMENSION_ACTION) -- print(batch_state_t1)--[torch.DoubleTensor of size 2x2]

    model_graph:zeroGradParameters() -- zero the internal gradient buffers of the network
    -- Takes an input object, and computes the corresponding output of the module.
    -- In general input and output are Tensors. However, some special sub-classes like table layers might expect something else.
    -- After a forward(), the returned output state variable should have been updated to the new value.
    local output_action_var = model_graph:forward({batch_img_t, batch_img_t1})
    print('output action var ')
    print(output_action_var)

    local loss1 = crit:forward(output_action_var, batch_action)
    print('loss for MSE criterion : '..loss1)--.." "..loss2)

    local grad1 = crit:backward(output_action_var, batch_action)
    print('gradients for criterion : ')
    print(grad1)
    --print(grad2)

    --[gradInput] backward(input, gradOutput) Performs a backpropagation step through the module, with respect to the
    -- given input. In general this method makes the assumption forward(input) has been called before, with the same
    --input. This is necessary for optimization reasons. If you do not respect this rule, backward() will compute
    --incorrect gradients.
    --In general input and gradOutput and gradInput are Tensors. However, some special sub-classes like table layers might expect something else. Please, refer to each module specification for further information.
    --A backpropagation step consist in computing two kind of gradients at input given gradOutput (gradients with respect to the output of the module). This function simply performs this task using two function calls:
    -- A function call to updateGradInput(input, gradOutput).
    -- A function call to accGradParameters(input,gradOutput,scale).
    res = model_graph:backward({batch_state_t, batch_state_t1}, grad1)
    print('result from backward pass:  ')
    print(res)
    print(res[1])
    print(res[2])
end

--
-- function file_exists(name)
--    --tests whether the file can be opened for reading
--    local f=io.open(name,"r")
--    if f~=nil then io.close(f) return true else return false end
-- end
--
-- local function patch(nn_module)
--    if nn_module.modules then
--       for i =1,#nn_module.modules do
--          patch(nn_module.modules[i])
--       end
--    else
--       nn_module.accGradParameters = function(self,inp, out) end  -- this is freezing FROZEN_LAYER
--    end
-- end
--
-- function getResNetModel(dimension_out)
--
--    local whole_net, pretrain_net
--
--    whole_net = nn.Sequential()
--
--    local model = "resnet-"..RESNET_VERSION..".t7"
--    local model_full_path = "./models/"..model
--
--    if file_exists(model_full_path) then
--       pretrain_net = torch.load(model_full_path)
--    else
--       print(model_full_path)
--       error([[------------------The above model was required but it doesn't exist,
--       download it here :\n https://github.com/facebook/fb.resnet.torch/tree/master/pretrained \nAnd put it in models/ as resnet-VERSION.t7
--       Ex : resnet-18.t7 -------------------]])
--    end
--
--    if RESNET_VERSION == 18 or RESNET_VERSION == 34 then
--       pretrain_net.modules[11] = nil --nn.Linear(512 -> 1000)
--       --pretrain_net.modules[10] is a View(512)
--
--    else
--       error("Version of resnet not known or not available")
--    end
--
--    -- Block backpropagation, i.e Freeze FROZEN_LAYER layers (defined in hyperparams.lua)
--    for i=1,FROZEN_LAYER do
--       nn_module = pretrain_net:get(i)
--       patch(nn_module)  -- Freezes
--    end
--
--    whole_net:add(pretrain_net)
--    whole_net:add(nn.Linear(512, dimension_out))
--
--    whole_net:evaluate()
--
--    return whole_net
-- end


-- local g = getFullInverseModel(DIMENSION_OUT, DIMENSION_ACTION)
-- train_model(g)

M.getModel = getModel(DIMENSION_OUT, DIMENSION_ACTION)
return M
