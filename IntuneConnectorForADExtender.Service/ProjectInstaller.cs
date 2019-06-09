using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;
using System.Linq;
using System.ServiceProcess;
using System.Threading.Tasks;

namespace IntuneConnectorForADExtender.Service
{
    [RunInstaller(true)]
    public partial class ProjectInstaller : System.Configuration.Install.Installer
    {
        public ProjectInstaller()
        {
            InitializeComponent();
           
        }


        private void serviceInstaller1_AfterInstall(object sender, InstallEventArgs e)
        {
            // Auto Start the Service Once Installation is Finished.
            var controller = new ServiceController("IntuneConnectorForADExtender");
            controller.Start();
        }

        private void serviceInstaller1_BeforeUninstall(object sender, InstallEventArgs e)
        {
            var controller = new ServiceController("IntuneConnectorForADExtender");
            controller.Stop();
        }
    }
}
