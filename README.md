# Repository host the paper for comparing the *CRS* and *Plum* using simulations: 

***"A simulation study to compare 210Pb dating data analyses"***

url: [https://arxiv.org/abs/2012.06819](https://arxiv.org/abs/2012.06819)


This repository contains the R code and data used in the simulation study described in the paper ***"A simulation study to compare 210Pb dating data analyses"***

The goal of this project is to compare classical and Bayesian lead-210 dating techniques (CRS and Plum), assess their accuracy, precision, and coverage under various simulated sedimentation and sampling scenarios, and evaluate an expert-informed correction to the classical CRS method.


Authors:

**Marco A. Aquino-López** -Corresponding author-

Centro de Investigacio ́n en Matemáticas (CIMAT), Jalisco s/n, Valenciana, 36023 Guanajuato, GT, Mexico. email: aquino@cimat.mx

**Nicole K Sanderson**

GEOTOP Research Centre, Université du Québec à Montréal, Montréal, Québec, H2X 3Y7, Canada. 

**Maarten Blaauw**

Queen's University Belfast, Belfast, BT7-1NN, UK.

**Joan-Albert Sanchez-Cabeza**

Unidad Académica de Mazatlán, Instituto de Ciencias del Mar y Limnología, Universidad Nacional Autónoma de Mexico,82040 Mazatlán, México
			
**Ana Carolina Ruiz-Fernandez**

Unidad Académica de Mazatlán, Instituto de Ciencias del Mar y Limnología, Universidad Nacional Autónoma de Mexico,82040 Mazatlán, México

**J Andrés Christen**

Centro de Investigación en Matemáticas (CIMAT), Jalisco s/n, Valenciana, 36023 Guanajuato, GT, Mexico. 


---

## 📁 Directory Structure

```
Code/
├── Data/               # Contains simulated core data and constants
├── Old_code/           # Legacy or experimental code
├── Plum_runs/          # Output folders from running Plum
├── TEHUAI-plot.R       # Plotting script for the Tehuantepec core
├── Sampling_function.R # Main function for sampling and method execution
├── Sampling.R          # Script to run sampling and save results
├── Plot_by_info.R      # Generates plots by % of data used
├── E_CRS_errors.R      # Expert CRS correction script
├── E_CRS.txt           # Output from expert CRS runs
├── CRS_function.R      # Classical CRS method implementation
├── CRS_error.txt       # Output from classical CRS
├── constants.csv       # Constants used for expert CRS
├── C_CRS_errors.R      # Likely runs classical CRS (assumed)
├── By_depths_plot.R    # Plotting script for depth-based analysis
```

---

## 🔧 Description of Key Files

### Data and Constants
- **Data/**: Folder containing raw and preprocessed data used in simulations.
- **constants.csv**: Contains constants and variables for the expert CRS correction.

### Core Simulation and Execution
- **Sampling_function.R**: Function that samples from the cores (from `Data/`) and sets up folders and input files in `Plum_runs/`. It also runs the Plum and CRS methods.
- **Sampling.R**: Executes `Sampling_function.R` and saves the output to `Plum_errors_sd.txt`.

### Plotting Scripts
- **TEHUAI-plot.R**: Generates plots for the core from Tehuantepec.
- **Plot_by_info.R**: Produces figures showing how information percentage affects precision, accuracy, and coverage.
- **By_depths_plot.R**: Plots results by depth level.

### CRS Implementations
- **CRS_function.R**: Contains the classical CRS algorithm.
- **CRS_error.txt**: Output file storing results from the classical CRS model.
- **E_CRS_errors.R**: Script for applying expert-informed corrections to CRS.
- **E_CRS.txt**: Output from the expert CRS runs.

---




## 📬 Contact

For questions or collaborations, please contact Dr. Aquino-Lopez at aquino@cimat.mx.




























