# Changes-of-mind in the absence of new post-decision evidence
This repository hosts the code behind the [PLoS Computational Biology paper](https://doi.org/10.1371/journal.pcbi.1007149) which investigates the mechanism behind changes-of-mind in perceptual decisions in situations where no additional evidence is available after the initial decision. 

## Data collection
The data collection code requires 32-bit versions of Python 2.7, [PsychoPy 1.84.1](https://github.com/psychopy/psychopy/releases/tag/1.84.1), [PyGaze](https://github.com/esdalmaijer/PyGaze/tree/python27), [pyglet 1.2.4](http://pyglet.org/) (available from PyPI: `pip install pyglet==1.2.4`).

## Data analysis
The main results of this work are presented in the [notebook reproducing all figures from the paper](https://github.com/nidstigator/com_fixed_duration/blob/master/data_analysis/paper_figures.ipynb). The notebook needs to be pointed to the data, which can be downloaded from [OSF](https://osf.io/y385t/). You can either download the processed data, or download the raw data and run the preprocessing scripts on it (`0_fix_session_no.py`, `1_csv_merge.py`, `2_save_processed_data.py`).

Additional analyses of the data are summarized in three notebooks:

- [basic psychometrics](https://github.com/nidstigator/com_fixed_duration/blob/master/data_analysis/psychometrics.ipynb)
- [response times](https://github.com/nidstigator/com_fixed_duration/blob/master/data_analysis/response_times.ipynb)
- [statistical analysis](https://github.com/nidstigator/com_fixed_duration/blob/master/data_analysis/r_stats.ipynb)

To run the analysis code, you'd need Python 3.5+; the most convenient way of getting it is to install the latest version of [Anaconda](https://www.anaconda.com/download/), which also includes all the dependencies:
- Jupyter Notebook 1.0.0+
- NumPy 1.12.1+
- SciPy 0.19.1+
- pandas 0.20.1+
- matplotlib 2.0.2+
- seaborn 0.7.1+

You also need [R](https://www.r-project.org/) and [IRKernel](https://irkernel.github.io/) in order to run the stats notebook. 

## Model simulations
The modelling results are summarised in:

- [basic model fit](https://github.com/nidstigator/com_fixed_duration/blob/master/data_analysis/model_exp_sidebyside.ipynb)
- [modelling results](https://github.com/nidstigator/com_fixed_duration/blob/master/data_analysis/modelling_results.ipynb)
- [eDDM basic simulation](https://github.com/nidstigator/com_fixed_duration/blob/master/data_analysis/eDDM.ipynb)

You need Matlab 2017+ in order to run the model simulations. Those simulation files might be ported to python at some stage.

If you're not familiar with Jupyter Notebooks, here is a good [starting guide](http://jupyter-notebook-beginner-guide.readthedocs.io/en/latest/index.html)

