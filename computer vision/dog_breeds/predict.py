#-------------------------------#
# Dog Breed Identification
# Individual Image Predictions
#-------------------------------#

# Module Imports
from fastai.vision import *
defaults.device = torch.device('cpu')

# Constants
MODEL_PATH = '/Users/thomas/Dropbox (Personal)/Data Science/Projects/computer vision/dog_breeds'
IMAGE_FILE = '/Users/thomas/Desktop/img1.jpg'

# Load the required files
img = open_image(IMAGE_FILE)
learn = load_learner(MODEL_PATH)

# Make predictions
pred_class, pred_idx, outputs = learn.predict(img)
print(pred_class)
