using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace Company.Function
{
    public class TimerAddMessageToQueue
    {
        //The notation %text% in the ServiceBus attribute indicates that it should be resolved from AppSettings. 
        //ServiceBusQueueName should be used in your local.settings.json or in your App Settings Configuration in Azure.
        [FunctionName("TimerAddMessageToQueue")]
        [return: ServiceBus("%ServiceBusQueueName%", Connection = "ServiceBusConnection")]
        public static string ServiceBusOutput([TimerTrigger("0 */1 * * * *")]TimerInfo myTimer, ILogger log)
        {
            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
            return $"This is a new message sent at {DateTime.Now}";
        }
    }
}
