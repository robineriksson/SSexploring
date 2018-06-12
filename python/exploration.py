# Robin Eriksson 2018
# import csv
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from tsfresh import extract_features
from tsfresh.utilities.dataframe_functions import impute


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


# plot SS
def plotSS(s0, s1, s2):
    n = s0.shape[0]
    plt.plot(range(0, n), s0)
    plt.plot(range(0, n), s1)
    plt.plot(range(0, n), s2)
    plt.legend(["s0", "s1", "s2"])
    plt.show()
    return()


# plot distance
def plotdist(d1, d2):
    n = d1.shape[0]
    plt.plot(range(0, n), d1)
    plt.plot(range(0, n), d2)
    plt.legend(["d1", "d2"])
    plt.show()
    return()


# clean SS
def cleanSS(SS):
    impute(SS)
    s0 = np.array(SS.loc["obs.sample", :])
    s1 = np.array(SS.loc["sim1.sample", :])
    s2 = np.array(SS.loc["sim2.sample", :])
    # remove zero elements
    nonzero = np.isnan(s0/s0)
    return(s0[~nonzero], s1[~nonzero], s2[~nonzero])


# normalize SS
def normalSS(s0, s1, s2):
    n0 = s0/s0
    n1 = s1/s0
    n2 = s2/s0
    return(n0, n1, n2)


# eucl distance
def distSS(n0, n1, n2):
    d1 = np.sqrt(n0-n1)**2
    d2 = np.sqrt(n0-n2)**2
    return(d1, d2)


# specify filename
filename = "/home/rober323/Gits/SSexploring/DATA/genData.csv"

# load data
fulldat = getData(filename)

# melt the data frame
dat = pd.melt(fulldat, id_vars="time")

SS = extract_features(dat,
                      column_id="variable",
                      column_value="value")
s0, s1, s2 = cleanSS(SS)
n0, n1, n2 = normalSS(s0, s1, s2)

d1, d2 = distSS(n0, n1, n2)
plotdist(d1, d2)
