# EC2 AUTOMATION

## Overview

This Terraform project automates the provisioning of EC2 instances. It provides a blueprint for creating and managing infrastructure on AWS using Terraform.

## Project Structure

- `.devcontainer`: Configuration files for Visual Studio Code development container.
- `blueprint`: Placeholder directory for your Terraform configurations.
- `env/dev`: Environment-specific configurations (e.g., variables, state) for the development environment.
- `modules`: Custom Terraform modules that can be reused across different parts of the infrastructure.
- `.gitignore`: Git ignore file to exclude certain files and directories from version control.
- `.terraform.lock.hcl`: Lock file containing information about module dependencies.
- `Makefile`: Makefile with targets for Terraform initialization, planning, and applying changes.
- `main.tf`: Main Terraform configuration file.

## Getting Started

1. Clone this repository:

    ```bash
    git clone https://github.com/hasanashik/EC2_AUTOMATION.git
    cd EC2_AUTOMATION
    ```

2. Initialize Terraform:

    ```bash
    make tf_init
    ```

3. Plan the Terraform changes:

    ```bash
    make tf_plan
    ```

4. Apply the Terraform changes:

    ```bash
    make tf_apply
    ```

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests. Please follow the [Contribution Guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the [MIT License](LICENSE).
