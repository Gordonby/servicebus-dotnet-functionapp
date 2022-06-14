using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace Company.Function
{
    
    public static class ServiceBusTrigger
    {

        //The notation %someText% in the trigger attribute indicates that it should be resolved from AppSettings. ServiceBusQueueName should be used in your local.settings.json or in your App Settings Configuration in Azure.
        [FunctionName("ReceiveServiceBusMessage")]
        public static void Run([ServiceBusTrigger("%ServiceBusQueueName%",
        Connection = "ServiceBusConnection")]string myQueueItem, ILogger log)
        {
            log.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
        }
    }
}
