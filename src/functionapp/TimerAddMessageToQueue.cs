using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace Company.Function
{
    public class TimerAddMessageToQueue
    {
        [FunctionName("TimerAddMessageToQueue")]
        [return: ServiceBus("%ServiceBusQueueName%", Connection = "ServiceBusConnection")]
        public static string ServiceBusOutput([TimerTrigger("0 */1 * * * *")]TimerInfo myTimer, ILogger log)
        {
            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
            return $"This is a new message sent at {DateTime.Now}";
        }
    }
}
