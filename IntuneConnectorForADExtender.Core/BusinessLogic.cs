using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management.Automation;

namespace IntuneConnectorForADExtender.Core
{
    public partial class BusinessLogic
    {
        private int EventId = 0;
        private int ExecutionId = 0;
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private EventLog OdjLog = null;
        private EntryWrittenEventHandler OdjEventHandler = null;
        private string PsScript = null;
        public BusinessLogic(String psScript, int eventId, string logName,string logSource)
        {
            EventId = eventId;
            OdjLog = new EventLog(logName, ".", logSource);
            EntryWrittenEventHandler eventHandler = new EntryWrittenEventHandler(EventLog_OnEntryWritten);
            OdjLog.EnableRaisingEvents = true;
            log.Info("Starting Service");
            log.Info("PsScript: " + psScript);
            log.Info("EventId: "+eventId);
            log.Info("LogName: " + logName);
            log.Info("LogSource: " + logSource);
            //Validate Script File existance 
            PsScript = Path.GetFullPath(psScript);
            if (!File.Exists(PsScript))
            {
                log.Error("Specified PsScript file('"+ PsScript + "') does not exist.");
                //throw new Exception("Specified PsScript file does not exist.");
            }
            
        }
        public void StartMonitor()
        {
            log.Info("Starting Eventhandler");
            OdjLog.EntryWritten += new EntryWrittenEventHandler(EventLog_OnEntryWritten);
        }
        public void StopMonitor()
        {
            log.Info("Stopping Eventhandler");
            OdjLog.EntryWritten += OdjEventHandler;
        }

        
        private void EventLog_OnEntryWritten(object source, EntryWrittenEventArgs e)
        {
            try
            {
                if (e.Entry.EventID == EventId)
                {
                    
                    if (File.Exists(PsScript))
                    {
                        Task.Factory.StartNew(() => ExecuteAsynchronously(ExecutionId, e.Entry.Message));
                        ExecutionId += 1;
                    }
                    else
                    {
                        log.Warn("PSScript(" + PsScript + ") does not exist. Process not started.");
                    }
                    
                }
                else
                {
                    log.Debug("not in filter --> EventId " + e.Entry.EventID +" != " + EventId);
                }
            }
            catch (Exception ex)
            {
                log.Error("Failed to process event " + JsonConvert.SerializeObject(e.Entry), ex);
            }
    }
    }
}
