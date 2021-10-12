<!--
 * @Description: LoRSCA user handbook
 * @Author: Wang Hejie
 * @Date: 2021-10-11 10:03:38
 * @LastEditTime: 2021-10-12 11:15:37
 * @LastEditors: Wang Hejie
-->
# Introduction
LoRSCA is a software that evaluates existing self-correction algorithms for PacBio long reads.
Output `eleven` evaluation metrics related to error corrected reads and `eight` evaluation metrics related to assembly.
The assembly steps are integrated. The error corrected reads are assembled by [Miniasm](https://github.com/lh3/miniasm).

# Installation
We have tested MECAT2 on CentOS release 7.3 and on Ubuntu 18.04.

- Step 1: Install dependency tool [Miniasm](https://github.com/lh3/miniasm). (*We strongly recommend using Anaconda to create a new virtual environment and install it automatically.*)
```shell
$ conda create -n miniasm minimap2 miniasm
```

- Step 2: Install dependency tool [BLASR](https://github.com/PacificBiosciences/blasr). (*We strongly recommend using Anaconda to create a new virtual environment and install it automatically.*)
```shell
$ conda create -n blasr blasr
```

- Step 3: Install dependency tool [QUAST](https://github.com/ablab/quast).
  - The PDF drawing feature of Quast requires a pre-installation of Matplotlib.
`$ sudo apt-get update && sudo apt-get install -y pkg-config libfreetype6-dev libpng-dev python-matplotlib`
  - Download the latest version from the [GitHub release page](https://github.com/ablab/quast/releases).
  - QUAST automatically compiles all its sub-parts when needed (on the first use). Thus, installation is not required. However, if you want to precompile everything and add `quast.py` to your PATH (*recommended*), you may choose either:
`$ ./setup.py install`
  - The default installation location is /`usr/local/bin/` for the executable scripts, and `/usr/local/lib/` for the python modules and auxiliary files.

- Step 4: Clone the LoRSCA repository locally.

# Quick Start
Use LoRSCA to quickly evaluate the error correction quality of the third-generation sequencing data.

In addition to the corrected reads file, the original reads file and the reference genome files need to be provided. The required input files are as follows: 
- corrected reads file, `.fasta`
- original reads file, `.fasta`
- reference genome `.fna` file
- reference genome `.gff` file



