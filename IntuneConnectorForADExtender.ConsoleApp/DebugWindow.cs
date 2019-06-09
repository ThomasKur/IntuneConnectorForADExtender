using log4net;
using log4net.Appender;
using log4net.Repository.Hierarchy;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntuneConnectorForADExtender.ConsoleApp
{
    public partial class DebugWindow : Form
    {
        Core.BusinessLogic bl = null;
        public DebugWindow()
        {
            InitializeComponent();
            var settings = Properties.Settings.Default;
            bl = new Core.BusinessLogic(settings.PSScript, settings.EventIdToMonitor, settings.LogName, settings.LogSource);
        }

        private void btnStart_Click(object sender, EventArgs e)
        {
            bl.StartMonitor();
            btnStart.Enabled = false;
            btnStop.Enabled = true;
        }

        private void btnStop_Click(object sender, EventArgs e)
        {
            bl.StopMonitor();
            btnStart.Enabled = true;
            btnStop.Enabled = false;
        }

        private void btnOpenLogfile_Click(object sender, EventArgs e)
        {
            var rootAppender = ((Hierarchy)LogManager.GetRepository())
                                         .Root.Appenders.OfType<FileAppender>()
                                         .FirstOrDefault();

            string filename = rootAppender != null ? rootAppender.File : string.Empty;
            System.Diagnostics.Process.Start(filename);
        }
    }
}
