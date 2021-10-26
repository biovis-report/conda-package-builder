# Conda Package Buider

## How to build the conda package?
1. Python package on pypi.org
   
  ```bash
  conda-build.sh -m pypi -p click
  ```

2. R package on cran-project.org

  ```bash
  conda-build.sh -m cran -p ggplot2
  ```

3. Local package with conda.recipe

   ```bash
   # e.g. You have a package biovis-reportr in ~/Documents/Code/BioVisReport/
   conda-build.sh -m local -p ~/Documents/Code/BioVisReport/biovis-reportr/conda.recipe
   ```

## How to upload your packages to anaconda.org

```bash
bash upload.sh -c <CONDA_PACKAGE_DIRECTORY>
```