# Import Keras utilities
from keras.models import load_model
import keras.losses

# Import data utilities
# data visualization
from scipy.io import loadmat
import matplotlib.pyplot as plt
import numpy as np
import sklearn

# Import sys utilities
import sys

base_path =  '../dataset_18650pf/'

testing_dataset_paths = [
    "TEST 0degC_HWFET_Pan18650PF.mat",    
    "TEST 25degC_HWFTa_Pan18650P.mat",
    "TEST n10degC_US06_Pan18650PF.mat",
    "TEST 0degC_US06_Pan18650PF.mat",
    "TEST 25degC_HWFTb_Pan18650PF.mat",
    "TEST n20degC_HWFET_Pan18650PF.mat",
    "TEST 10degC_HWFET_Pan18650PF.mat",
    "TEST 25degC_US06_Pan18650PF.mat",
    "TEST n20degC_US06_Pan18650PF.mat",
    "TEST 10degC_US06_Pan18650PF.mat",
    "TEST OCV Test_C20_25dCOCV Test_C20_25dC"
    ]

def custom_loss_function(y_true, y_pred):
    e = y_pred - y_true 
    return tf.keras.backend.square(tf.keras.backend.max(e)) + \
        tf.keras.backend.mean(tf.keras.backend.square(e))

def max_soc(y_true, y_pred):
  e = y_pred - y_true
  return tf.keras.backend.square(tf.keras.backend.max(e))

keras.losses.custom_loss = custom_loss_function

# Load model specified in argv
model =  load_model(sys.argv[1], \
        custom_objects={'custom_loss_function': custom_loss_function, \
        'max_soc': max_soc})

# Summarize model
model.summary()

for i in range(len(testing_dataset_paths)):
    evaluation_data = loadmat(base_path + testing_dataset_paths[i])
    x_eval = np.concatenate((evaluation_data['voltage'],
    evaluation_data['avg_voltage'], evaluation_data['current'], \
        evaluation_data['avg_current'], evaluation_data['temp']), \
        axis = 1)
    y_eval = evaluation_data['soc']
    y_pred = model.predict(x_eval)
    plt.figure()
    #fig, axs = plt.subplots(4)
    plt.title('Evaluating model over ' + testing_dataset_paths[i])
    plt.plot(y_eval, label='True')
    plt.plot(y_pred, label='Predicted')
    plt.legend()
    plt.show()
    mse = sklearn.metrics.mean_squared_error(y_eval, y_pred)
    rmse = math.sqrt(mse)
    print(rmse)
    print(mse)


