# 8086ML

This repository contains implementations of basic machine learning algorithms written entirely in Assembly language. These implementations aim to demonstrate fundamental concepts of machine learning in a highly constrained programming environment.

## Decision Tree 

**Method Used:**
The Decision Tree code predicts whether it will rain based on the temperature and humidity inputs. It uses simple rules (greater than or less than a certain value) to decide the outcome.

**Code Explanation:**
- **Input**: Temperature and Humidity
- **Process**: Checks if the temperature is above or below 70 degrees. Based on that, it further checks humidity levels to predict rain.
- **Output**: Predicts "It will rain" or "It will not rain."

## k-Nearest Neighbors (k-NN) 

**Method Used:**
k-NN is used here to predict prices based on area. The algorithm looks at 'k' closest data points (based on distance) to predict the price.

**Code Explanation:**
- **Input**: Area of a property.
- **Process**: Calculates distances between input area and known data points, selects the nearest ones, and uses their average prices for prediction.
- **Output**: Predicts a price based on the area.Due to memory constrains it divides the price by 1000. 

## Linear Regression

**Method Used:**
Linear Regression is implemented to estimate prices based on area. It finds a line (mathematically) that best fits the data points.

**Code Explanation:**
- **Input**: Area of a property.
- **Process**: Computes a line that best describes the relationship between area and price by minimizing the distance between the line and the data points.
- **Output**: Gives an estimated price for a given area.

## Logistic Regression 

**Method Used:**
Logistic Regression is used to classify images as belonging to one of two classes. This model uses a simplified step function as an activation instead of the typical sigmoid function.

**Code Explanation:**
- **Input**: Pixel values of a 4x4 image.
- **Process**: Each pixel is multiplied by a corresponding weight and summed up, including a bias. A step function checks if the result is above or below zero to classify the image.
- **Output**: Classifies the image into class 0 or class 1.

---

> "...are you mad? ~William Shakespeare"

Feel free to explore the code, suggest improvements, or fork the repository!!
