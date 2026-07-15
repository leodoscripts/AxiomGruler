#!/bin/bash

cat << 'EOF' > temp_injector.ps1
try {
    [System.Threading.Thread]::CurrentThread.SetApartmentState([System.Threading.ApartmentState]::STA)
} catch {}

try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop

    $Kernel32Signature = @"
    using System;
    using System.Runtime.InteropServices;

    public class Kernel32 {
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr OpenProcess(uint processAccess, bool bInheritHandle, int processId);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out IntPtr lpNumberOfBytesWritten);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);

        [DllImport("kernel32.dll", CharSet = CharSet.Ansi, ExactSpelling = true, SetLastError = true)]
        public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern IntPtr GetModuleHandle(string lpModuleName);
        
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool CloseHandle(IntPtr hObject);
    }
"@
    Add-Type -TypeDefinition $Kernel32Signature -ErrorAction Stop

    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "Axiom Injector"
    $Form.Size = New-Object System.Drawing.Size(400,220)
    $Form.StartPosition = "CenterScreen"
    $Form.FormBorderStyle = "FixedDialog"
    $Form.MaximizeBox = $false

    $ProcLabel = New-Object System.Windows.Forms.Label
    $ProcLabel.Location = New-Object System.Drawing.Point(20,20)
    $ProcLabel.Size = New-Object System.Drawing.Size(350,20)
    $ProcLabel.Text = "Target Process: Minecraft.Windows.exe"
    $Form.Controls.Add($ProcLabel)

    $TextBox = New-Object System.Windows.Forms.TextBox
    $TextBox.Location = New-Object System.Drawing.Point(20,50)
    $TextBox.Size = New-Object System.Drawing.Size(260,20)
    $TextBox.ReadOnly = $true
    $Form.Controls.Add($TextBox)

    $BrowseButton = New-Object System.Windows.Forms.Button
    $BrowseButton.Location = New-Object System.Drawing.Point(290,48)
    $BrowseButton.Size = New-Object System.Drawing.Size(75,23)
    $BrowseButton.Text = "Browse..."
    $BrowseButton.Add_Click({
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $FileBrowser.Filter = "DLL Files (*.dll)|*.dll"
        if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $TextBox.Text = $FileBrowser.FileName
        }
    })
    $Form.Controls.Add($BrowseButton)

    $StatusLabel = New-Object System.Windows.Forms.Label
    $StatusLabel.Location = New-Object System.Drawing.Point(20,90)
    $StatusLabel.Size = New-Object System.Drawing.Size(350,20)
    $StatusLabel.Text = "Status: Idle"
    $Form.Controls.Add($StatusLabel)

    $InjectButton = New-Object System.Windows.Forms.Button
    $InjectButton.Location = New-Object System.Drawing.Point(20,120)
    $InjectButton.Size = New-Object System.Drawing.Size(345,35)
    $InjectButton.Text = "INJECT"
    $InjectButton.Add_Click({
        $DllPath = $TextBox.Text
        if ([string]::IsNullOrEmpty($DllPath)) {
            $StatusLabel.Text = "Status: Select a DLL first."
            return
        }

        $TargetProcess = Get-Process -Name "Minecraft.Windows" -ErrorAction SilentlyContinue
        if (-not $TargetProcess) {
            $StatusLabel.Text = "Status: Minecraft.Windows.exe not found."
            return
        }

        $ProcessId = $TargetProcess.Id
        $StatusLabel.Text = "Status: Injecting into PID $ProcessId..."
        $StatusLabel.Refresh()

        $PROCESS_VM_WRITE = 0x0020
        $PROCESS_VM_OPERATION = 0x0008
        $PROCESS_CREATE_THREAD = 0x0002
        $PROCESS_QUERY_INFORMATION = 0x0400
        $Access = $PROCESS_VM_WRITE -bor $PROCESS_VM_OPERATION -bor $PROCESS_CREATE_THREAD -bor $PROCESS_QUERY_INFORMATION
        
        $hProcess = [Kernel32]::OpenProcess($Access, $false, $ProcessId)
        if ($hProcess -eq [IntPtr]::Zero) {
            $StatusLabel.Text = "Status: Failed to open process."
            return
        }

        $MEM_COMMIT = 0x1000
        $MEM_RESERVE = 0x2000
        $PAGE_READWRITE = 0x04
        
        $LenRaw = $DllPath.Length + 1
        $PathLength = [Convert]::ToUInt32($LenRaw)
        
        $pRemoteMemory = [Kernel32]::VirtualAllocEx($hProcess, [IntPtr]::Zero, $PathLength, $MEM_COMMIT -bor $MEM_RESERVE, $PAGE_READWRITE)
        if ($pRemoteMemory -eq [IntPtr]::Zero) {
            $StatusLabel.Text = "Status: Failed to allocate memory."
            [Kernel32]::CloseHandle($hProcess) | Out-Null
            return
        }

        $Bytes = [System.Text.Encoding]::ASCII.GetBytes($DllPath + "`0")
        $Written = [IntPtr]::Zero
        $WriteSuccess = [Kernel32]::WriteProcessMemory($hProcess, $pRemoteMemory, $Bytes, [uint32]$Bytes.Length, [ref]$Written)
        if (-not $WriteSuccess) {
            $StatusLabel.Text = "Status: Failed to write memory."
            [Kernel32]::CloseHandle($hProcess) | Out-Null
            return
        }

        $hKernel32 = [Kernel32]::GetModuleHandle("kernel32.dll")
        $pLoadLibrary = [Kernel32]::GetProcAddress($hKernel32, "LoadLibraryA")
        if ($pLoadLibrary -eq [IntPtr]::Zero) {
            $StatusLabel.Text = "Status: Failed to get LoadLibraryA address."
            [Kernel32]::CloseHandle($hProcess) | Out-Null
            return
        }

        $hThread = [Kernel32]::CreateRemoteThread($hProcess, [IntPtr]::Zero, 0, $pLoadLibrary, $pRemoteMemory, 0, [IntPtr]::Zero)
        if ($hThread -eq [IntPtr]::Zero) {
            $StatusLabel.Text = "Status: Failed to execute thread injection."
            [Kernel32]::CloseHandle($hProcess) | Out-Null
        } else {
            $StatusLabel.Text = "Status: Injection successful! Closing GUI..."
            $StatusLabel.Refresh()
            [Kernel32]::CloseHandle($hThread) | Out-Null
            [Kernel32]::CloseHandle($hProcess) | Out-Null
            
            # Brief pause to display status message, then close UI and release all resources
            Start-Sleep -Milliseconds 800
            $Form.Close()
        }
    })
    $Form.Controls.Add($InjectButton)

    [System.Windows.Forms.Application]::Run($Form)
} catch {
    Write-Error $_
    Write-Host "Press enter to exit..."
    [void][Console]::ReadLine()
}
EOF

powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File temp_injector.ps1
rm temp_injector.ps1