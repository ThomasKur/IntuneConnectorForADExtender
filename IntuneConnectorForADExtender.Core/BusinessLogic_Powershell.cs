using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace IntuneConnectorForADExtender.Core
{
    public partial class BusinessLogic
    {
        /// <summary>
        /// Sample execution scenario 2: Asynchronous
        /// </summary>
        /// <remarks>
        /// Executes a PowerShell script asynchronously with script output and event handling.
        /// </remarks>
        public void ExecuteAsynchronously(int id, string eventData)
        {
            using (PowerShell PowerShellInstance = PowerShell.Create())
            {
                log.Info("[" + id + "] Starting execution for '"+eventData+ "'.");

                // Prepare Command
                Command eventCommand = new Command(PsScript);
                CommandParameter eventParam = new CommandParameter("EventData",eventData);
                eventCommand.Parameters.Add(eventParam);

                // this script has a sleep in it to simulate a long running script
                PowerShellInstance.Commands.AddCommand(eventCommand);

                // prepare a new collection to store output stream objects
                PSDataCollection<PSObject> outputCollection = new PSDataCollection<PSObject>();

                // the streams (Error, Debug, Progress, etc) are available on the PowerShell instance.
                // we can review them during or after execution.
                // we can also be notified when a new item is written to the stream (like this):
                PowerShellInstance.Streams.Error.DataAdded += (sender, e) => Error_DataAdded(sender, e, id); 


                // begin invoke execution on the pipeline
                // use this overload to specify an output stream buffer
                IAsyncResult result = PowerShellInstance.BeginInvoke<PSObject, PSObject>(null, outputCollection);

                // do something else until execution has completed.
                // this could be sleep/wait, or perhaps some other work
                while (result.IsCompleted == false)
                {
                    log.Debug("["+id+"] Waiting for PS pipeline to finish...");
                    Thread.Sleep(1000);
                }

                log.Info("[" + id + "] Execution has stopped. The pipeline state: " + PowerShellInstance.InvocationStateInfo.State);
                if (PowerShellInstance.InvocationStateInfo.State == PSInvocationState.Failed) {
                    log.Error("[" + id + "] " + PowerShellInstance.InvocationStateInfo.Reason.Message);
                }
                foreach (PSObject outputItem in outputCollection)
                {
                   log.Debug(outputItem.BaseObject.ToString());
                }
            }
        }

        /// <summary>
        /// Event handler for when Data is added to the Error stream.
        /// </summary>
        /// <param name="sender">Contains the complete PSDataCollection of all error output items.</param>
        /// <param name="e">Contains the index ID of the added collection item and the ID of the PowerShell instance this event belongs to.</param>
        void Error_DataAdded(object sender, DataAddedEventArgs e, int id)
        {
            
            // do something when an error is written to the error stream
            log.Error("[" + id + "] Error during execution", ((PSDataCollection<ErrorRecord>)sender)[0].Exception);
        }

    }
}
