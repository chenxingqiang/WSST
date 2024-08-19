# Getting Started with WSST

Welcome to the Wireless Security Simulation Toolkit (WSST)! This guide will walk you through the basics of setting up and using WSST for simulating and analyzing Pilot Spoofing Attacks (PSA) in massive MIMO systems.

## Prerequisites

Before getting started, ensure that you have the following:

- MATLAB installed on your system (version R2021a or later recommended)
- Basic knowledge of MATLAB programming

## Installation

To install WSST, follow these steps:

1. Clone the WSST repository from GitHub or download the source code as a ZIP file.
2. Extract the contents of the ZIP file to a directory of your choice.
3. Open MATLAB and navigate to the WSST directory.
4. Run the `setup.m` script to automatically add the necessary paths to your MATLAB environment.

Alternatively, you can manually add the WSST directory and its subdirectories to your MATLAB path using the following command:

```matlab
addpath(genpath('/path/to/wsst'));
```

## Basic Usage

To get started with WSST, follow these steps:

1. Open MATLAB and navigate to the `examples` directory within the WSST directory.
2. Open the `basicSimulation.m` script in the MATLAB editor.
3. Review the script and modify the simulation parameters as needed (e.g., number of antennas, number of users, pilot sequence length).
4. Run the script by clicking the "Run" button or pressing F5.
5. The script will perform the following steps:
   - Generate a dataset for the specified simulation parameters.
   - Train neural network models for PSA detection.
   - Perform PSA detection using various methods.
   - Visualize the results, including detection accuracy and error rates.
6. Review the generated plots and analyze the simulation results.

Feel free to experiment with different simulation parameters and explore the various functions and scripts provided in the WSST toolkit.

## Documentation

For detailed information on the WSST toolkit, including API references and advanced usage examples, refer to the following documentation:

- [API Reference](api/): Detailed documentation of the functions and modules available in WSST.
- [Examples](examples/): Sample scripts demonstrating various use cases and advanced features of WSST.

## Support and Feedback

If you encounter any issues, have questions, or would like to provide feedback, please feel free to:

- Open an issue on the GitHub repository: [https://github.com/your-repo/wsst/issues](https://github.com/your-repo/wsst/issues)
- Contact the maintainers via email: [your-email@example.com](mailto:your-email@example.com)

We appreciate your feedback and contributions to making WSST better!

## License

WSST is released under the [MIT License](../LICENSE). Feel free to use, modify, and distribute the toolkit in accordance with the terms of the license.

Happy simulating and analyzing wireless security with WSST!