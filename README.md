# C# Function Application with Azure Service Bus

[![Open in Remote - Containers](https://img.shields.io/static/v1?label=Remote%20-%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/Gordonby/azd-template-servicebus-dotnet-functionapp)

This template includes everything you need to build, deploy, and monitor an Azure solution that both adds messages to and reacts to messages on an Azure Service Bus queue using Azure Function Apps and the native bindings for Service Bus. It includes application code, tools, and pipelines that serve as a foundation from which you can build upon and customize when creating your own solutions.

Let's jump in and get the apps up and running in Azure. When you are finished, you will have a fully functional Service Bus queue with accompanying Function apps deployed on Azure. In later steps, you'll see how to setup a pipeline and monitor the application.

### Prerequisites

The following prerequisites are required to use this application.  Please ensure that you have them all installed locally.

- [Azure Developer CLI](https://aka.ms/azure-dev/install)
  - Windows:
    ```powershell
    powershell -c "Set-ExecutionPolicy Bypass Process -Force; irm 'https://aka.ms/install-azd.ps1' | iex"
    ```
  - Linux/MacOS:
    ```
    curl -fsSL https://aka.ms/install-azd.sh | bash 
    ```
- [Azure CLI (2.37.0+)](https://docs.microsoft.com/cli/azure/install-azure-cli)
- VSCode
- Functions Runtime
- [Git (2.36.1+)](https://git-scm.com/)

### Quickstart

The fastest way for you to get this application up and running on Azure is to use the `azd up` command. This single command will create and configure all necessary Azure resources - including access policies and roles for your account and service-to-service communication with Managed Identities. 

1. Open a terminal, create a new empty folder, and change into it.
1. Run the following command to initialize the project, provision Azure resources, and deploy the application code.

```bash
azd up -t servicebus-dotnet-functionapp
```

You will be prompted for the following information:

- `Environment Name`: This will be used as a prefix for all your Azure resources, make sure it is globally unique and under 15 characters.
- `Azure Location`: The Azure location where your resources will be deployed.
- `Azure Subscription`: The Azure Subscription where your resources will be deployed.

> NOTE: This may take a while to complete as it executes three commands: `azd init` (initializes environment), `azd provision` (provisions Azure resources), and `azd deploy` (deploys application code). You will see a progress indicator as it provisions and deploys your application.

When `azd up` is complete it will output the following URLs:

- Azure Portal link to view resources
- ToDo Web application frontend
- ToDo API application

!["azd up output"](assets/urls.png)

Click the web application URL to launch the ToDo app. Create a new collection and add some items. This will create monitoring activity in the application that you will be able to see later when you run `azd monitor`.

> :warning: **Cleanup**
>
> Please be aware that with the `azd up` command Azure resources have been created. You can clean up these resources by deleting the resource group that was created, or by running the `azd down` command.

### Application Architecture

This application utilizes the following Azure resources:

- Service Bus
- App Insights
- Azure Functions

Here's a high level architecture diagram that illustrates these components. Notice that these are all contained within a single [resource group](https://docs.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal), that will be created for you when you create the resources.


> This template provisions resources to an Azure subscription that you will select upon provisioning them. Please refer to the [Pricing calculator for Microsoft Azure](https://azure.microsoft.com/pricing/calculator/) and, if needed, update the included Azure resource definitions found in `infra/main.bicep` to suit your needs.

### Application Code

The repo is structured to follow the [Azure Developer CLI](https://aka.ms/azure-dev/overview) conventions including:

- **Source Code**: All application source code is located in the `src` folder.
- **Infrastructure as Code**: All application "infrastructure as code" files are located in the `infra` folder.
- **Azure Developer Configuration**: An `azure.yaml` file located in the root that ties the application source code to the Azure services defined in your "infrastructure as code" files.
- **GitHub Actions**: A sample GitHub action file is located in the `.github/workflows` folder.
- **VS Code Configuration**: All VS Code configuration to run and debug the application is located in the `.vscode` folder.

### Azure Subscription

This template will create infrastructure and deploy code to Azure. If you don't have an Azure Subscription, you can sign up for a [free account here](https://azure.microsoft.com/free/). 

### Azure Developer CLI - VS Code Extension

The Azure Developer CLI experience includes an Azure Developer CLI VS Code Extension that mirrors all of the CLI commands into context menu and command palette options. If you are a VS Code user, then we highly recommend installing this extension for the best experience.

1. Download the extension from https://aka.ms/azure-dev/vsix
1. In VS Code:
    - Open "Extensions" (Ctrl+Shift+X)
    - Click the ... menu at top of Extensions sidebar
    - Click "Install from VSIX"
    - Select location of downloaded file

### Next Steps

At this point, you have a complete application deployed on Azure. But there is much more that the Azure Developer CLI can do. These next steps will introduce you to additional commands that will make creating applications on Azure much easier. Using the Azure Developer CLI, you can setup your pipelines, monitor your application, test and debug locally.

#### Set up a pipeline using `azd pipeline`

This template includes a GitHub Actions pipeline configuration file that will deploy your application whenever code is pushed to the main branch. You can find that pipeline file here: `.github/workflows`.

Setting up this pipeline requires you to give GitHub permission to deploy to Azure on your behalf, which is done via a Service Principal stored in a GitHub secret named `AZURE_CREDENTIALS`. The `azd pipeline config` command will automatically create a service principal for you. The command also helps to create a private GitHub repository and pushes code to the newly created repo. 

Before you call the `azd pipeline config` command, you'll need to install the following:
- [GitHub CLI (2.3+)](https://github.com/cli/cli)

Run the following command to set up a GitHub Action:

```bash
azd pipeline config
```

#### Monitor the application using `azd monitor`

To help with monitoring applications, the Azure Dev CLI provides a `monitor` command to help you get to the various Application Insights dashboards.

- Run the following command to open the "Overview" dashboard:

  ```bash
  azd monitor --overview
  ```

- Live Metrics Dashboard

  Run the following command to open the "Live Metrics" dashboard:

  ```bash
  azd monitor --live
  ```

- Logs Dashboard

  Run the following command to open the "Logs" dashboard:

  ```bash
  azd monitor --logs
  ```

#### Run and Debug Locally

The easiest way to run and debug is to leverage the Azure Developer CLI Visual Studio Code Extension. Refer to this [walkthrough](https://aka.ms/azure-dev/vscode) for more details. 


#### Clean up resources

When you are done, you can delete all the Azure resources created with this template by running the following command:

```bash
azd down
```

### Additional azd commands

The Azure Developer CLI includes many other commands to help with your Azure development experience. You can view these commands at the terminal by running `azd help`. You can also view the full list of commands on our [Azure Developer CLI command](https://aka.ms/azure-dev/ref) page.

## Troubleshooting/Known issues

Sometimes, things go awry. If you happen to run into issues, then please review our ["Known Issues"](https://aka.ms/azure-dev/knownissues) page for help. If you continue to have issues, then please file an issue in our main [Azure Dev](https://aka.ms/azure-dev/issues) repository.

## Security

### Roles

This template creates a [managed identity](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview) for your app inside your Azure Active Directory tenant, and it is used to authenticate your app with Azure and other services that support Azure AD authentication like Key Vault via access policies. You will see principalId referenced in the infrastructure as code files, that refers to the id of the currently logged in Azure CLI user, which will be granted access policies and permissions to run the application locally. To view your managed identity in the Azure Portal, follow these [steps](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/how-to-view-managed-identity-service-principal-portal).

## Reporting Issues and Feedback

If you have any feature requests, issues, or areas for improvement, please [file an issue](https://aka.ms/azure-dev/issues). To keep up-to-date, ask questions, or share suggestions, join our [GitHub Discussions](https://aka.ms/azure-dev/discussions). You may also contact us via AzDevTeam@microsoft.com.
