# Changes-of-mind model and experiment
Data analysis code for RDK experiment with eye- and hand-tracking, alongside a neural circuit model

Currently, the experimental analysis is summarized in three Jupyter notebooks:

- [basic psychometrics](https://github.com/nidstigator/eyehand_model/blob/master/plotting_code/notebooks/psychometrics.ipynb)
- [initiation times](https://github.com/nidstigator/eyehand_model/blob/master/plotting_code/notebooks/initiation_times.ipynb)
- [hand-eye lag analysis](https://github.com/nidstigator/eyehand_model/blob/master/plotting_code/notebooks/eye_hand_lags.ipynb)
- [statistical model] (https://github.com/nidstigator/eyehand_model/blob/master/plotting_code/notebooks/r_stats.ipynb)

The modelling results are summarised in:

- [basic model fit] (https://github.com/nidstigator/eyehand_model/blob/master/plotting_code/notebooks/model_exp_sidebyside.ipynb)


These notebooks are in active development, and more notebooks with more advanced analyses are on the way

## Prerequisites
To run the code, you'd need Python 3.5+; the most convenient way of getting it is to install the latest version of [Anaconda](https://www.anaconda.com/download/), which also includes all the dependencies:
- Jupyter Notebook 1.0.0+
- NumPy 1.12.1+
- SciPy 0.19.1+
- pandas 0.20.1+
- matplotlib 2.0.2+
- seaborn 0.7.1+

You also need R and IRKernel in order to run the stats notebook. 

Finally, you need Matlab 2017+ in order to run the model simulations. Those simulation files might be ported to python at some stage.


________________________________________________
As the project is in active development, it is best to regulary update these packages to the recent versions. This is easily done in Anaconda by one-liner 

> conda update --all

With minor modifications this project can be run under Python 2.7 (however, we recommend to use Python 3, as Python 2 is going to be [discontinued in the near future](https://pythonclock.org/))

If you're not familiar with Jupyter Notebooks, here is a good [starting guide](http://jupyter-notebook-beginner-guide.readthedocs.io/en/latest/index.html)

