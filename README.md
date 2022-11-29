# TextbookSimulations
Examples and problems accompanying Daniel Kirschen's Power Systems Textbook

## Purpose
This repository contains Jupyter notebooks that allow for interactive exploration into 
selected examples and problems included in Daniel Kirschen's Power Systems textbook. These 
notebooks use Los Alamos National Laboratory's 
[PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl) package for power systems 
simulation and computation. This repository also contains sample data to accompany the 
selected examples and problems included in the textbook.

## Installation Guide
To use the Jupyter notebooks included in this repository, the following steps must be 
followed:

1. **Install Python.** Jupyter notebooks are based in Python, meaning that Python must be 
installed. If your operating system is MacOS or Linux, the system Python should be 
sufficient. If you do not have Python installed, the latest version of Python 3 can be 
installed [here](https://www.python.org/downloads/). Make sure that Python is added to your 
PATH.

    **NOTE:** With Python 3.11.0 being released very recently, wheels are not available for 
    all of the libraries needed to set up the Jupyter notebook interface. Therefore, for 
    new installations, we recommend installing the latest version of Python 3.10. For 
    existing installations, we anticipate other minor versions of Python 3 to be sufficient 
    for operating this workflow.

2. **Install Jupyter notebooks.** Open command line or terminal and run the following:

    ```sh
    python -m pip install --upgrade pip
    python -m pip install notebook
    ```

    The Jupyter notebook interface will now be able to be opened in your browser by running 
    the following in command line or terminal:
    
    ```sh
    jupyter notebook
    ```

3. **Install Julia.** To be compatible with `PowerSystems.jl`, the installed version of 
Julia must be at least version 1.6 or greater. Julia can be installed for different 
operating systems [here](https://julialang.org/downloads/). Make sure that Julia is added 
to your PATH.

4. **Install the IJulia package.** The `IJulia` package is required to ensure that the 
Julia kernel is accessible in Jupyter notebooks. To install the `IJulia` package, open the 
Julia REPL, which is installed when Julia is installed, type `]` to open the Julia REPL's 
package manager mode, and run the following:

    ```julia
    add IJulia
    ```

5. **Clone this repository locally.** Using Git through the command line or terminal, clone 
the repository as follows:

    ```sh
    git clone https://github.com/Power-Systems-Textbook/TextbookSimulations.git
    ```
    
    If you do not have Git installed on your machine, you can install it by following 
    instructions [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). 
    Alternatively, a .zip file of the repository can be downloaded 
    [here](https://github.com/Power-Systems-Textbook/TextbookSimulations).

6. **Activate and instantiate the project environment.** Using the Julia REPL, navigate to 
the local directory in which this repository is downloaded. Type `]` to open the Julia 
REPL's pacakge manager mode, and run the following to ensure the necessary packages for the 
project environment are installed:

    ```
    activate .
    instantiate
    ```

## Using Example and Problem Notebooks
After following the Installation Guide described above, the notebooks included in this 
repository will be able to be opened. To do so, first open the Jupyter notebook interface 
running the following the command line or terminal:

```sh
jupyter notebook
```

Within the Jupyter notebook interface, which should open in your browser, navigate to the 
particular folder within this repository to find the desired notebook.
