

#--------------------------------------------------------#
# CNN - Cats and Dogs
# Thomas Brown
#
# Data is from the dogs vs. cats dataset on kaggle
# https://www.kaggle.com/c/dogs-vs-cats/data
#--------------------------------------------------------#

import os
import matplotlib.pyplot as plt
from keras import layers
from keras import models
from keras.preprocessing.image import ImageDataGenerator
from keras import optimizers




# Set up the working directory
wd = 'D:\Data\deep_learning_catdog'
os.chdir(wd)

# Data structure has a seperate folder for the training,
# validation and test data

os.listdir(wd)

# Within set of data, we have a seperate folder for the dog and cat pictures
traindir = os.path.join(wd, 'train')
print(os.listdir(traindir))

valdir = os.path.join(wd, 'validation')
print(os.listdir(valdir))

testdir = os.path.join(wd, 'test')
print(os.listdir(testdir))


# Set up references to the individual folders containing the images
train_cats = os.path.join(traindir, 'cats')
train_dogs = os.path.join(traindir, 'dogs')
valid_cats = os.path.join(valdir, 'cats')
valid_dogs = os.path.join(valdir, 'dogs')
test_cats = os.path.join(testdir, 'cats')
test_dogs =os.path.join(testdir, 'dogs')


# To check the number of images in each set of data
print('n training cat images:', len(os.listdir(train_cats)))
print('n validation cat images:', len(os.listdir(valid_cats)))
print('n test cat images:', len(os.listdir(test_cats)))
print('n training dog images:', len(os.listdir(train_dogs)))
print('n validation dog images:', len(os.listdir(valid_dogs)))
print('n test dog images:', len(os.listdir(test_dogs)))


#--------------------------------#
# Data Preprocessing
#--------------------------------#


# Set up some data augmentation
train_datagen = ImageDataGenerator(
        rescale = 1./255,
        rotation_range = 45,
        width_shift_range = 0.2,
        height_shift_range = 0.2,
        shear_range = 0.2,
        zoom_range = 0.2,
        horizontal_flip = True)

test_datagen = ImageDataGenerator(rescale=1./255)


# Set up the data generators

train_generator = train_datagen.flow_from_directory(
        traindir,
        target_size = (150, 150),
        batch_size = 20,
        class_mode = 'binary')

validation_generator = test_datagen.flow_from_directory(
        valdir,
        target_size = (150, 150),
        batch_size = 20,
        class_mode = 'binary')


# Construct the CNN

model = models.Sequential()
model.add(layers.Conv2D(20, (3, 3), activation = 'relu',
                        input_shape = (150, 150, 3)))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(64, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(128, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(128, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(256, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Flatten())
model.add(layers.Dropout(0.5))
model.add(layers.Dense(512, activation = 'relu'))
model.add(layers.Dense(1, activation = 'sigmoid'))


# Summary of the model
model.summary()

# Compile the model
model.compile(loss = 'binary_crossentropy',
              optimizer = optimizers.RMSprop(lr=1e-4),
              metrics = ['acc'])


# Fit the model using the batch generators

cnn_model = model.fit_generator(
        train_generator,
        steps_per_epoch = 100,
        epochs = 100,
        validation_data=validation_generator,
        validation_steps = 50)


# Plot the results


acc = cnn_model.history['acc']
val_acc = cnn_model.history['val_acc']
loss = cnn_model.history['loss']
val_loss = cnn_model.history['val_loss']

epochs = range(1, len(acc) + 1)


plt.plot(epochs, acc, 'b.', label = 'Training Accuracy')
plt.plot(epochs, val_acc, 'b', label = 'Validation Accuracy')
plt.title('Training and Validation Accuracy')
plt.legend()

plt.figure()

plt.plot(epochs, loss, 'b.', label = 'Training Loss')
plt.plot(epochs, val_loss, 'b', label = 'Validation Loss')
plt.title('Training and Validation Loss')
plt.legend()

plt.show()



model.save('cats_vs_dogs_model.h5')
