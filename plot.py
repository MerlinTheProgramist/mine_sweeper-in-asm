#!/usr/bin/env python3
import matplotlib.pyplot as plt
import numpy as np
import sys

if(len(sys.argv) < 2):
    raise Exception("Wrong parameter length")

with open(sys.argv[1], "r") as file:
    print(f"reading values from {sys.argv[0]}")
    values = []

    for x, line in enumerate(file):
        print(line)
        values.append(int(line.strip()))

    values = np.array(values)
    fig, ax = plt.subplots(1, 2)
    ax[0].plot(values)
    ax[1].hist(values, bins=len(values)-1)
    plt.show()


