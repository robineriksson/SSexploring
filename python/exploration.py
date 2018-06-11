# Robin Eriksson 2018
# import csv
import pandas as pd
import matplotlib.pyplot as plt
from tsfresh import extract_features


# load the data
def getData(destination):
    df = pd.read_csv(destination, skiprows=0, usecols=[1, 2, 4, 6],
                     delimiter=",")
    return(df)


# plot data
def plotData(data):
    plt.plot(data[:, 0], data[:, 1])
    plt.plot(data[:, 0], data[:, 2])
    plt.plot(data[:, 0], data[:, 3])
    plt.show()
    return()


filename = "/home/rober323/Gits/SSexploring/DATA/genData.csv"
dat = getData(filename)

SS = extract_features(dat,
                      column_id="obs.sample")
