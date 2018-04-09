import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.patches as mpatches
from decimal import Decimal

###################################

#set precision for displaying float-point values in the notebook
pd.options.display.float_format = '{:,.3f}'.format

#set figure dpi to 100 to get reasonably sized figures displayed in the notebook
plt.rc('figure', dpi=100)

#set savefig dpi to 300 to get high-quality images to insert in the paper
plt.rc('savefig', dpi=300)

#set to 'pdf' or 'eps' for vector figures or to 'png'
plt.rc('savefig', format='png')

#set font sizes for figures throughout
plt.rc('xtick', labelsize=18)
plt.rc('ytick', labelsize=18)
plt.rc('axes', labelsize=20)
plt.rc('legend', fontsize=18)


###################################


def plot_figure_1():
    fig1b = pd.read_csv('../../figures_output/Fig1_b.txt', sep=',')
    fig1c = pd.read_csv('../../figures_output/Fig1_c.txt', sep=',')
    fig1d1 = pd.read_csv('../../figures_output/Fig1_d1.txt', sep=',')
    fig1d2 = pd.read_csv('../../figures_output/Fig1_d2.txt', sep=',')
    print('test')

plot_figure_1()

