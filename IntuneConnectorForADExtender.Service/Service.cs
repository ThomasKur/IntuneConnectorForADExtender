using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using IntuneConnectorForADExtender.Core;

namespace IntuneConnectorForADExtender.Service
{
    public partial class Service : ServiceBase
    {
        private Core.BusinessLogic bl;
        public Service()
        {
            InitializeComponent();
            var settings = Properties.Settings.Default;
            bl = new Core.BusinessLogic(settings.PSScript, settings.EventIdToMonitor, settings.LogName, settings.LogSource);
        }

        protected override void OnStart(string[] args)
        {
            bl.StartMonitor();
        }

        protected override void OnStop()
        {
            bl.StopMonitor();
        }
    }
}
