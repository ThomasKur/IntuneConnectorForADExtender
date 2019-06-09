using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntuneConnectorForADExtender.ConsoleApp
{
    class Program
    {

        static void Main(string[] args)
        {
            Console.WriteLine("Starting Intune Connector for AD Extender troubleshooting console!");
            Application.Run(new DebugWindow());

            

        }
    }
}
