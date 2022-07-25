# C# Function Application with Azure Service Bus

[![Open in Remote - Containers](https://img.shields.io/static/v1?label=Remote%20-%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/Gordonby/azd-template-servicebus-dotnet-functionapp)

This template includes everything you need to build, deploy, and monitor an Azure solution that both adds messages to and reacts to messages on an Azure Service Bus queue using Azure Function Apps and the native bindings for Service Bus. It includes application code, that serve as a foundation from which you can build upon and customize when creating your own solution.

Let's jump in and get the apps up and running in Azure. When you are finished, you will have a fully functional Service Bus queue with accompanying Function apps deployed on Azure.

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

### Architecture

```mermaid
graph TB
    subgraph Function Apps
    timer(Timer Trigger)
    sbTrigger
    
    end

    subgraph ServiceBus
    sb(Queue)
    timer-->|Every minute, write message|sb
    sb-->|On message add|sbTrigger(Queue Trigger)
    sbTrigger-->ai
    end

    subgraph Logging
    ai(App Insights)
    la(Log Analytics workspace)
    ai-->la   
    timer-->ai
    end

```

### Quickstart

The fastest way for you to get this application up and running on Azure is to use the `azd up` command. This single command will create and configure all necessary Azure resources.

1. Clone this sample

```bash
git clone https://github.com/Gordonby/servicebus-dotnet-functionapp.git
cd servicebus-dotnet-functionapp
```

2. Run the following command to initialize the project, provision Azure resources, and deploy the application code.

```bash
azd up
```

You will be prompted for the following information:

- `Environment Name`: This will be used as a prefix for all your Azure resources, make sure it is globally unique and under 15 characters.
- `Azure Location`: The Azure location where your resources will be deployed.
- `Azure Subscription`: The Azure Subscription where your resources will be deployed.
