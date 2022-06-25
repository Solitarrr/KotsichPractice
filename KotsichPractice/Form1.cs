using MaterialSkin.Controls;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Diagnostics;

namespace KotsichPractice
{
    public partial class Form1 : MaterialForm
    {
        readonly MaterialSkin.MaterialSkinManager materialSkinManager;
        public static String file_exe = Environment.GetFolderPath(Environment.SpecialFolder.InternetCache) + "\\ArduinoCodePractice.ino";
        public static String file2_exe = Environment.GetFolderPath(Environment.SpecialFolder.InternetCache) + "\\ProcessingCodePractice.pde";
        public static String file3_exe = Environment.GetFolderPath(Environment.SpecialFolder.InternetCache) + "\\PLX_DAQ.xls";
        public Form1()
        {
            InitializeComponent();
            materialSkinManager = MaterialSkin.MaterialSkinManager.Instance;
            materialSkinManager.EnforceBackcolorOnAllComponents = true;
            materialSkinManager.AddFormToManage(this);
            materialSkinManager.Theme = MaterialSkin.MaterialSkinManager.Themes.LIGHT;
            materialSkinManager.ColorScheme = new MaterialSkin.ColorScheme(MaterialSkin.Primary.Indigo500, MaterialSkin.Primary.Indigo700, MaterialSkin.Primary.Indigo100, MaterialSkin.Accent.Pink200, MaterialSkin.TextShade.WHITE);
            MaximizeBox = false;

        }

        private void materialLabel1_Click(object sender, EventArgs e)
        {

        }

        private void materialLabel2_Click(object sender, EventArgs e)
        {

        }

        private void tabPage1_Click(object sender, EventArgs e)
        {

        }

        private void materialButton1_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Process.Start("https://github.com/Solitarrr/KotsichPractice/tree/master");
        }

        private void materialButton2_Click(object sender, EventArgs e)
        {
            FileStream fs = new FileStream(file_exe, FileMode.Create);
            fs.Write(Properties.Resources.ArduinoCodePractice, 0, Properties.Resources.ArduinoCodePractice.Length);
            fs.Close();
            System.Diagnostics.Process.Start(file_exe);
        }

        private void materialButton3_Click(object sender, EventArgs e)
        {
            FileStream fs = new FileStream(file2_exe, FileMode.Create);
            fs.Write(Properties.Resources.ProcessingCodePractice, 0, Properties.Resources.ProcessingCodePractice.Length);
            fs.Close();
            System.Diagnostics.Process.Start(file2_exe);
        }

        private void materialButton4_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            if (openFileDialog1.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                string FilePath = openFileDialog1.FileName;
                Process.Start(FilePath);
            }
        }

        private void materialButton5_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Process.Start("https://www.tinkercad.com/things/9kK56aoCDLc?sharecode=EnIYgLRdEbR-k2v-Y98Zf5-2OuDiHo5eDEhO1v6m9e0");
        }

        private void materialButton6_Click(object sender, EventArgs e)
        {
            if (pictureBox1.Visible == true)
            {
                pictureBox2.Visible = true;
                pictureBox1.Visible = false;
            }
            else if (pictureBox2.Visible == true)
            {
                pictureBox1.Visible = true;
                pictureBox2.Visible = false;
            }
        }

        private void materialButton7_Click(object sender, EventArgs e)
        {
            FileStream fs = new FileStream(file3_exe, FileMode.Create);
            fs.Write(Properties.Resources.PLX_DAQ, 0, Properties.Resources.PLX_DAQ.Length);
            fs.Close();
            System.Diagnostics.Process.Start(file3_exe);
        }

        private void materialButton8_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Process.Start("https://www.arduino.cc/en/software");
            System.Diagnostics.Process.Start("https://processing.org/download");
            System.Diagnostics.Process.Start("https://www.parallax.com/download/?search=PLX#");
        }
    }
}
