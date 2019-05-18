#-------------------------------#
# Dog Breed Identification
# Individual Image Predictions
#-------------------------------#

# Module Imports
from fastai.vision import *
defaults.device = torch.device('cpu')

# Constants
MODEL_PATH = ''
IMAGE_FILE = 'path/'black'/'00000021.jpg''

# Load the required files
img = open_image(IMAGE_FILE)
learn = load_learner(MODEL_PATH)

# Make predictions
pred_class,pred_idx,outputs = learn.predict(img)
print(pred_class)
