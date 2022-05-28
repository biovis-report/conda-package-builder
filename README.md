<h2 align="center">Conda Builder</h2>
<p align="center">package/upload files to anaconda</p>

<p align="center">Jingcheng Yang [yjcyxky@163.com]</p>

<p align="center">
<img src="https://github.com/biovis-report/conda-package-builder/workflows/.github/workflows/test.yml/badge.svg" alt="Build Status">
<img src="https://img.shields.io/github/license/biovis-report/conda-package-builder.svg" alt="License">
</p>

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