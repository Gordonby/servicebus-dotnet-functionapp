using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace Company.Function
{
    public class TriggerFromMessageOnQueue
    {
        //The notation %text% in the ServiceBusTrigger attribute indicates that it should be resolved from AppSettings. 
        //ServiceBusQueueName should be used in your local.settings.json or in your App Settings Configuration in Azure.
        [FunctionName("TriggerFromMessageOnQueue")]
        public static void Run([ServiceBusTrigger("%ServiceBusQueueName%",
        Connection = "ServiceBusConnection")]string myQueueItem, ILogger log)
        {
            log.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
        }
    }
}
