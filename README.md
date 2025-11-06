# Genesa Windows Maintenance Tool v6.0

<div align="center">

**A powerful GUI-based Windows maintenance tool with progress tracking, statistics, and comprehensive system cleanup**

[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?style=flat-square&logo=windows)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=flat-square&logo=powershell)](https://docs.microsoft.com/powershell)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

</div>

---

## 📋 Table of Contents / Daftar Isi

- [English Version](#english-version)
  - [Overview](#overview)
  - [Problem Statement](#problem-statement)
  - [Solution](#solution)
  - [Features](#features)
  - [Advantages](#advantages)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Maintenance Tasks](#maintenance-tasks)
  - [Troubleshooting](#troubleshooting)
  
- [Versi Bahasa Indonesia](#versi-bahasa-indonesia)
  - [Gambaran Umum](#gambaran-umum)
  - [Masalah yang Dihadapi](#masalah-yang-dihadapi)
  - [Solusi](#solusi-1)
  - [Fitur](#fitur)
  - [Kelebihan](#kelebihan)
  - [Persyaratan](#persyaratan)
  - [Instalasi](#instalasi)
  - [Cara Penggunaan](#cara-penggunaan)
  - [Tugas Maintenance](#tugas-maintenance)
  - [Pemecahan Masalah](#pemecahan-masalah)

---

# English Version

## Overview

Genesa Windows Maintenance Tool is a comprehensive GUI-based tool designed to automate and streamline Windows system maintenance tasks. Built with PowerShell and Windows Forms, it provides an intuitive interface for performing various system cleanup, optimization, and maintenance operations.

## Problem Statement

Windows systems require regular maintenance to ensure optimal performance, but:

- **Manual maintenance is time-consuming**: Performing multiple maintenance tasks manually takes significant time and effort
- **Complex command-line tools**: Built-in Windows tools like DISM, SFC, and Disk Cleanup require command-line knowledge
- **No centralized interface**: Multiple tools scattered across different locations
- **Lack of progress visibility**: No clear indication of progress or completion status
- **No statistics tracking**: Users can't see how much space was freed or which tasks succeeded/failed
- **No cancellation support**: Once started, long-running tasks can't be easily cancelled

## Solution

This utility provides a **single, unified GUI application** that:

- ✅ Consolidates all maintenance tasks in one place
- ✅ Provides real-time progress tracking and status updates
- ✅ Calculates and displays space freed statistics
- ✅ Supports task cancellation
- ✅ Includes comprehensive error handling and logging
- ✅ Offers selectable tasks (run only what you need)
- ✅ Works with workgroup environments (no domain required)

## Features

### 🎯 Core Features

1. **Graphical User Interface (GUI)**
   - Clean, modern interface built with Windows Forms
   - Intuitive checkbox selection for tasks
   - Real-time progress bar and status updates
   - Scrollable log window with timestamped entries

2. **Progress Tracking**
   - Visual progress bar showing completion percentage
   - Detailed status messages for each operation
   - Sub-progress tracking for multi-step tasks (e.g., drive optimization)

3. **Statistics & Reporting**
   - Real-time calculation of disk space freed
   - Automatic MB/GB formatting
   - Success/failure count summary
   - Detailed operation results stored in memory

4. **Task Management**
   - Select All / Deselect All buttons for quick selection
   - Individual task selection via checkboxes
   - Tasks can be run independently or in combination

5. **Cancellation Support**
   - Cancel button to stop ongoing operations
   - Graceful cancellation (completes current task before stopping)
   - Confirmation dialog when exiting during maintenance

6. **Error Handling & Logging**
   - Comprehensive error catching and reporting
   - Detailed log files with timestamps and log levels
   - Color-coded log messages (info, warning, error)
   - Log files saved to `C:\MaintenanceLogs\`

### 🛠️ Maintenance Tasks

1. **Clean Temporary Files**
   - Cleans Windows Temp folder
   - Cleans user Temp folders
   - Calculates and reports space freed

2. **Disk Cleanup**
   - Runs Windows built-in Disk Cleanup utility
   - Uses predefined cleanup profile (sagerun:99)
   - Supports cancellation

3. **Optimize Drives**
   - Defragments and optimizes all fixed drives
   - Per-drive progress tracking
   - Handles multiple drives automatically

4. **System File Check (SFC/DISM)**
   - Runs System File Checker (SFC /scannow)
   - Runs DISM health check (/Online /Cleanup-Image /RestoreHealth)
   - Reports exit codes for verification

5. **Windows Updates**
   - Checks for available updates (requires PSWindowsUpdate module)
   - Installs updates automatically
   - Falls back to Windows Update Settings if module not available

6. **Clear Windows Update Cache**
   - Stops Windows Update services
   - Clears download cache
   - Restarts services automatically
   - Calculates space freed

7. **Browser Cache Cleanup**
   - Cleans Chrome cache
   - Cleans Edge cache
   - Cleans Firefox cache (all profiles)
   - Reports space freed per browser

8. **Delete Old Logs**
   - Removes log files older than 30 days
   - Operates on maintenance log directory
   - Reports file count and space freed

## Advantages

### 🚀 Why Choose This Tool?

1. **User-Friendly Interface**
   - No command-line knowledge required
   - Visual feedback for all operations
   - Easy task selection and execution

2. **Comprehensive Coverage**
   - All major maintenance tasks in one tool
   - Covers system files, temp files, browser cache, and more

3. **Transparency & Control**
   - See exactly what's happening
   - Know how much space is being freed
   - Control which tasks run

4. **Reliability**
   - Robust error handling
   - Detailed logging for troubleshooting
   - Graceful failure handling

5. **Flexibility**
   - Run individual tasks or combinations
   - Cancel operations anytime
   - Select specific maintenance needs

6. **Workgroup Compatible**
   - Works in workgroup environments
   - No domain controller required
   - Suitable for home and small business use

## Requirements

- **Operating System**: Windows 10 or Windows 11
- **PowerShell**: Version 5.1 or higher (included with Windows)
- **Permissions**: Administrator privileges required
- **Optional**: PSWindowsUpdate module (for automatic Windows Updates)

## Installation

### Method 1: Direct Download

1. Download or clone this repository
2. Extract files to a folder (e.g., `C:\Scripts\windows-maintenance\`)
3. Ensure both files are in the same directory:
   - `system_maintenance_gui.ps1`
   - `run.bat`

### Method 2: Git Clone

```bash
git clone <repository-url>
cd windows-maintenance
```

### Verify Installation

The directory should contain:
```
windows-maintenance/
├── system_maintenance_gui.ps1
├── run.bat
└── README.md
```

## Usage

### Quick Start

1. **Right-click** `run.bat` and select **"Run as administrator"**
   
   OR
   
   **Double-click** `run.bat` (UAC prompt will appear)

2. Click **"Yes"** on the UAC (User Account Control) prompt

3. The GUI window will open

4. **Select** the maintenance tasks you want to run (checkboxes)

5. Click **"Run Selected Tasks"**

6. Wait for completion and review the summary

### Detailed Steps

1. **Launch the Application**
   - Run `run.bat` as Administrator
   - The GUI window appears with 8 maintenance task checkboxes

2. **Select Tasks**
   - Use checkboxes to select desired tasks
   - Use **"Select All"** to select all tasks
   - Use **"Deselect All"** to clear selection

3. **Execute Maintenance**
   - Click **"Run Selected Tasks"**
   - Progress bar shows overall progress
   - Status label shows current operation
   - Statistics label shows space freed in real-time
   - Log window shows detailed operation logs

4. **Monitor Progress**
   - Watch the progress bar fill up
   - Read status messages for current operation
   - Check log window for detailed information
   - Use **"Cancel"** button if needed (appears during execution)

5. **Review Results**
   - Summary dialog shows:
     - Tasks completed count
     - Tasks failed count (if any)
     - Total space freed
     - Log file location
   - Check log file for detailed information

### Command Line Alternative

If you prefer command-line execution:

```powershell
# Run as Administrator PowerShell
powershell.exe -ExecutionPolicy Bypass -File ".\system_maintenance_gui.ps1"
```

## Maintenance Tasks

### Task Details

| Task | Description | Estimated Time | Space Impact |
|------|-------------|----------------|--------------|
| Clean Temp Files | Removes temporary files from Windows and user temp folders | 1-5 minutes | Varies (usually 100MB-5GB) |
| Disk Cleanup | Runs Windows Disk Cleanup utility | 5-15 minutes | Varies |
| Optimize Drives | Defragments and optimizes all fixed drives | 10-60 minutes | 0 MB (optimization only) |
| SFC/DISM | System file integrity check and repair | 10-30 minutes | 0 MB (repair only) |
| Windows Updates | Checks and installs Windows updates | 5-30 minutes | Varies (downloads) |
| Clear Update Cache | Removes Windows Update download cache | 1-3 minutes | 100MB-5GB |
| Browser Cache | Cleans Chrome, Edge, and Firefox caches | 1-3 minutes | 50MB-2GB |
| Delete Old Logs | Removes logs older than 30 days | <1 minute | 10MB-500MB |

### Recommended Usage

**Weekly Maintenance:**
- ✓ Clean Temp Files
- ✓ Browser Cache Cleanup
- ✓ Delete Old Logs

**Monthly Maintenance:**
- ✓ All weekly tasks +
- ✓ Disk Cleanup
- ✓ Clear Update Cache

**Quarterly Maintenance:**
- ✓ All monthly tasks +
- ✓ Optimize Drives
- ✓ SFC/DISM
- ✓ Windows Updates

## Troubleshooting

### Common Issues

#### Issue: "Please run this script as Administrator"
**Solution**: Right-click `run.bat` and select "Run as administrator"

#### Issue: Script doesn't start or shows errors
**Solution**: 
1. Check PowerShell execution policy: `Get-ExecutionPolicy`
2. Verify you're running as Administrator
3. Check Windows Event Viewer for detailed errors

#### Issue: Some tasks fail
**Solution**:
1. Check log file in `C:\MaintenanceLogs\`
2. Ensure you have sufficient disk space
3. Close other applications that might lock files
4. Try running individual tasks instead of all at once

#### Issue: Disk Cleanup doesn't work
**Solution**:
- Ensure Disk Cleanup is not already running
- Check if you have sufficient permissions
- Try running it manually first: `cleanmgr /sagerun:99`

#### Issue: Browser cache cleanup doesn't free space
**Solution**:
- Close all browser windows before running
- Some browsers may not be installed (check log for details)
- Firefox profiles may vary in location

#### Issue: Windows Updates don't install automatically
**Solution**:
- Install PSWindowsUpdate module: `Install-Module PSWindowsUpdate`
- Or use Windows Update Settings manually (will open automatically)

### Log Files

Log files are saved to: `C:\MaintenanceLogs\maintenance_YYYY-MM-DD_HH-mm-ss.txt`

Each log file contains:
- Timestamp of each operation
- Log level (INFO, ERROR, WARNING)
- Detailed operation messages
- Error messages and stack traces
- Summary statistics

### Getting Help

1. Check the log files for detailed error information
2. Review the GUI log window during execution
3. Ensure all requirements are met (Windows 10/11, Administrator rights)
4. Try running tasks individually to isolate issues

---

# Versi Bahasa Indonesia

## Gambaran Umum

Genesa Windows Maintenance Tool adalah tool berbasis GUI yang dirancang untuk mengotomasi dan merampingkan tugas maintenance sistem Windows. Dibangun dengan PowerShell dan Windows Forms, tool ini menyediakan antarmuka yang intuitif untuk melakukan berbagai operasi pembersihan, optimasi, dan maintenance sistem.

## Masalah yang Dihadapi

Sistem Windows memerlukan maintenance rutin untuk memastikan kinerja optimal, namun:

- **Maintenance manual memakan waktu**: Melakukan beberapa tugas maintenance secara manual membutuhkan waktu dan usaha yang signifikan
- **Tool command-line yang kompleks**: Tool Windows bawaan seperti DISM, SFC, dan Disk Cleanup memerlukan pengetahuan command-line
- **Tidak ada antarmuka terpusat**: Banyak tool tersebar di berbagai lokasi
- **Tidak ada visibilitas progress**: Tidak ada indikasi jelas tentang progress atau status penyelesaian
- **Tidak ada tracking statistik**: Pengguna tidak bisa melihat berapa banyak ruang yang dibebaskan atau tugas mana yang berhasil/gagal
- **Tidak ada dukungan pembatalan**: Setelah dimulai, tugas yang berjalan lama tidak bisa dibatalkan dengan mudah

## Solusi

Tool ini menyediakan **aplikasi GUI terpadu** yang:

- ✅ Mengkonsolidasikan semua tugas maintenance di satu tempat
- ✅ Menyediakan tracking progress dan pembaruan status real-time
- ✅ Menghitung dan menampilkan statistik ruang yang dibebaskan
- ✅ Mendukung pembatalan tugas
- ✅ Termasuk error handling dan logging yang komprehensif
- ✅ Menawarkan tugas yang dapat dipilih (jalankan hanya yang Anda butuhkan)
- ✅ Bekerja dengan lingkungan workgroup (tidak memerlukan domain)

## Fitur

### 🎯 Fitur Utama

1. **Antarmuka Pengguna Grafis (GUI)**
   - Antarmuka bersih dan modern yang dibangun dengan Windows Forms
   - Seleksi checkbox yang intuitif untuk tugas
   - Progress bar dan pembaruan status real-time
   - Jendela log yang dapat di-scroll dengan entri timestamp

2. **Tracking Progress**
   - Progress bar visual yang menunjukkan persentase penyelesaian
   - Pesan status detail untuk setiap operasi
   - Sub-progress tracking untuk tugas multi-langkah (misalnya, optimasi drive)

3. **Statistik & Reporting**
   - Perhitungan real-time ruang disk yang dibebaskan
   - Formatting MB/GB otomatis
   - Ringkasan jumlah sukses/gagal
   - Hasil operasi detail disimpan dalam memori

4. **Manajemen Tugas**
   - Tombol Select All / Deselect All untuk seleksi cepat
   - Seleksi tugas individual melalui checkbox
   - Tugas dapat dijalankan secara independen atau dalam kombinasi

5. **Dukungan Pembatalan**
   - Tombol Cancel untuk menghentikan operasi yang sedang berjalan
   - Pembatalan yang graceful (menyelesaikan tugas saat ini sebelum berhenti)
   - Dialog konfirmasi saat keluar selama maintenance

6. **Error Handling & Logging**
   - Penangkapan dan pelaporan error yang komprehensif
   - File log detail dengan timestamp dan level log
   - Pesan log dengan kode warna (info, warning, error)
   - File log disimpan ke `C:\MaintenanceLogs\`

### 🛠️ Tugas Maintenance

1. **Bersihkan File Temporary**
   - Membersihkan folder Windows Temp
   - Membersihkan folder Temp pengguna
   - Menghitung dan melaporkan ruang yang dibebaskan

2. **Pembersihan Disk**
   - Menjalankan utility Disk Cleanup bawaan Windows
   - Menggunakan profil pembersihan yang telah ditentukan (sagerun:99)
   - Mendukung pembatalan

3. **Optimasi Drive**
   - Defragmentasi dan optimasi semua drive tetap
   - Tracking progress per-drive
   - Menangani beberapa drive secara otomatis

4. **Pemeriksaan File Sistem (SFC/DISM)**
   - Menjalankan System File Checker (SFC /scannow)
   - Menjalankan pemeriksaan kesehatan DISM (/Online /Cleanup-Image /RestoreHealth)
   - Melaporkan exit code untuk verifikasi

5. **Windows Updates**
   - Memeriksa update yang tersedia (memerlukan modul PSWindowsUpdate)
   - Menginstal update secara otomatis
   - Fallback ke Windows Update Settings jika modul tidak tersedia

6. **Bersihkan Cache Windows Update**
   - Menghentikan layanan Windows Update
   - Membersihkan cache download
   - Me-restart layanan secara otomatis
   - Menghitung ruang yang dibebaskan

7. **Pembersihan Cache Browser**
   - Membersihkan cache Chrome
   - Membersihkan cache Edge
   - Membersihkan cache Firefox (semua profil)
   - Melaporkan ruang yang dibebaskan per browser

8. **Hapus Log Lama**
   - Menghapus file log yang lebih lama dari 30 hari
   - Beroperasi pada direktori log maintenance
   - Melaporkan jumlah file dan ruang yang dibebaskan

## Kelebihan

### 🚀 Mengapa Memilih Tool Ini?

1. **Antarmuka yang Ramah Pengguna**
   - Tidak memerlukan pengetahuan command-line
   - Umpan balik visual untuk semua operasi
   - Seleksi dan eksekusi tugas yang mudah

2. **Cakupan Komprehensif**
   - Semua tugas maintenance utama dalam satu tool
   - Mencakup file sistem, file temp, cache browser, dan lainnya

3. **Transparansi & Kontrol**
   - Lihat persis apa yang terjadi
   - Ketahui berapa banyak ruang yang dibebaskan
   - Kontrol tugas mana yang dijalankan

4. **Keandalan**
   - Error handling yang kuat
   - Logging detail untuk troubleshooting
   - Penanganan kegagalan yang graceful

5. **Fleksibilitas**
   - Jalankan tugas individual atau kombinasi
   - Batalkan operasi kapan saja
   - Pilih kebutuhan maintenance spesifik

6. **Kompatibel dengan Workgroup**
   - Bekerja di lingkungan workgroup
   - Tidak memerlukan domain controller
   - Cocok untuk penggunaan rumah dan bisnis kecil

## Persyaratan

- **Sistem Operasi**: Windows 10 atau Windows 11
- **PowerShell**: Versi 5.1 atau lebih tinggi (termasuk dengan Windows)
- **Izin**: Memerlukan hak istimewa Administrator
- **Opsional**: Modul PSWindowsUpdate (untuk Windows Updates otomatis)

## Instalasi

### Metode 1: Download Langsung

1. Download atau clone repository ini
2. Ekstrak file ke folder (misalnya, `C:\Scripts\windows-maintenance\`)
3. Pastikan kedua file berada di direktori yang sama:
   - `system_maintenance_gui.ps1`
   - `run.bat`

### Metode 2: Git Clone

```bash
git clone <repository-url>
cd windows-maintenance
```

### Verifikasi Instalasi

Direktori harus berisi:
```
windows-maintenance/
├── system_maintenance_gui.ps1
├── run.bat
└── README.md
```

## Cara Penggunaan

### Mulai Cepat

1. **Klik kanan** `run.bat` dan pilih **"Run as administrator"**
   
   ATAU
   
   **Double-click** `run.bat` (prompt UAC akan muncul)

2. Klik **"Yes"** pada prompt UAC (User Account Control)

3. Jendela GUI akan terbuka

4. **Pilih** tugas maintenance yang ingin Anda jalankan (checkbox)

5. Klik **"Run Selected Tasks"**

6. Tunggu hingga selesai dan tinjau ringkasan

### Langkah Detail

1. **Menjalankan Aplikasi**
   - Jalankan `run.bat` sebagai Administrator
   - Jendela GUI muncul dengan 8 checkbox tugas maintenance

2. **Memilih Tugas**
   - Gunakan checkbox untuk memilih tugas yang diinginkan
   - Gunakan **"Select All"** untuk memilih semua tugas
   - Gunakan **"Deselect All"** untuk membersihkan pilihan

3. **Menjalankan Maintenance**
   - Klik **"Run Selected Tasks"**
   - Progress bar menunjukkan progress keseluruhan
   - Label status menunjukkan operasi saat ini
   - Label statistik menunjukkan ruang yang dibebaskan secara real-time
   - Jendela log menunjukkan log operasi detail

4. **Memantau Progress**
   - Perhatikan progress bar terisi
   - Baca pesan status untuk operasi saat ini
   - Periksa jendela log untuk informasi detail
   - Gunakan tombol **"Cancel"** jika diperlukan (muncul selama eksekusi)

5. **Meninjau Hasil**
   - Dialog ringkasan menunjukkan:
     - Jumlah tugas yang diselesaikan
     - Jumlah tugas yang gagal (jika ada)
     - Total ruang yang dibebaskan
     - Lokasi file log
   - Periksa file log untuk informasi detail

### Alternatif Command Line

Jika Anda lebih suka eksekusi command-line:

```powershell
# Jalankan sebagai Administrator PowerShell
powershell.exe -ExecutionPolicy Bypass -File ".\system_maintenance_gui.ps1"
```

## Tugas Maintenance

### Detail Tugas

| Tugas | Deskripsi | Perkiraan Waktu | Dampak Ruang |
|-------|-----------|-----------------|--------------|
| Bersihkan File Temp | Menghapus file temporary dari folder Windows dan user temp | 1-5 menit | Bervariasi (biasanya 100MB-5GB) |
| Pembersihan Disk | Menjalankan utility Disk Cleanup Windows | 5-15 menit | Bervariasi |
| Optimasi Drive | Defragmentasi dan optimasi semua drive tetap | 10-60 menit | 0 MB (hanya optimasi) |
| SFC/DISM | Pemeriksaan dan perbaikan integritas file sistem | 10-30 menit | 0 MB (hanya perbaikan) |
| Windows Updates | Memeriksa dan menginstal update Windows | 5-30 menit | Bervariasi (downloads) |
| Bersihkan Cache Update | Menghapus cache download Windows Update | 1-3 menit | 100MB-5GB |
| Cache Browser | Membersihkan cache Chrome, Edge, dan Firefox | 1-3 menit | 50MB-2GB |
| Hapus Log Lama | Menghapus log yang lebih lama dari 30 hari | <1 menit | 10MB-500MB |

### Penggunaan yang Direkomendasikan

**Maintenance Mingguan:**
- ✓ Bersihkan File Temp
- ✓ Pembersihan Cache Browser
- ✓ Hapus Log Lama

**Maintenance Bulanan:**
- ✓ Semua tugas mingguan +
- ✓ Pembersihan Disk
- ✓ Bersihkan Cache Update

**Maintenance Triwulanan:**
- ✓ Semua tugas bulanan +
- ✓ Optimasi Drive
- ✓ SFC/DISM
- ✓ Windows Updates

## Pemecahan Masalah

### Masalah Umum

#### Masalah: "Please run this script as Administrator"
**Solusi**: Klik kanan `run.bat` dan pilih "Run as administrator"

#### Masalah: Script tidak dimulai atau menampilkan error
**Solusi**: 
1. Periksa execution policy PowerShell: `Get-ExecutionPolicy`
2. Verifikasi Anda menjalankan sebagai Administrator
3. Periksa Windows Event Viewer untuk error detail

#### Masalah: Beberapa tugas gagal
**Solusi**:
1. Periksa file log di `C:\MaintenanceLogs\`
2. Pastikan Anda memiliki ruang disk yang cukup
3. Tutup aplikasi lain yang mungkin mengunci file
4. Coba jalankan tugas individual alih-alih semua sekaligus

#### Masalah: Disk Cleanup tidak berfungsi
**Solusi**:
- Pastikan Disk Cleanup tidak sedang berjalan
- Periksa apakah Anda memiliki izin yang cukup
- Coba jalankan secara manual terlebih dahulu: `cleanmgr /sagerun:99`

#### Masalah: Pembersihan cache browser tidak membebaskan ruang
**Solusi**:
- Tutup semua jendela browser sebelum menjalankan
- Beberapa browser mungkin tidak terpasang (periksa log untuk detail)
- Profil Firefox mungkin bervariasi lokasinya

#### Masalah: Windows Updates tidak terinstal secara otomatis
**Solusi**:
- Instal modul PSWindowsUpdate: `Install-Module PSWindowsUpdate`
- Atau gunakan Windows Update Settings secara manual (akan terbuka otomatis)

### File Log

File log disimpan ke: `C:\MaintenanceLogs\maintenance_YYYY-MM-DD_HH-mm-ss.txt`

Setiap file log berisi:
- Timestamp setiap operasi
- Level log (INFO, ERROR, WARNING)
- Pesan operasi detail
- Pesan error dan stack trace
- Statistik ringkasan

### Mendapatkan Bantuan

1. Periksa file log untuk informasi error detail
2. Tinjau jendela log GUI selama eksekusi
3. Pastikan semua persyaratan terpenuhi (Windows 10/11, hak Administrator)
4. Coba jalankan tugas secara individual untuk mengisolasi masalah

---

## 📝 Changelog

### Version 6.0 (Current)
- ✨ Enhanced error handling and logging
- ✨ Added cancellation support
- ✨ Implemented statistics tracking (space freed)
- ✨ Improved progress tracking with sub-progress
- ✨ Added Select All/Deselect All buttons
- ✨ Enhanced GUI layout and UX
- ✨ Added detailed operation validation
- ✨ Improved task functions with better error handling
- ✨ Added space calculation for all cleanup operations

### Version 5.0
- Initial GUI version with basic progress tracking
- Basic maintenance functions
- Simple logging

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👤 Author

**Badia Tarigan - Genesa DevOps Team**

---

## 🙏 Acknowledgments

- Built with PowerShell and Windows Forms
- Uses Windows built-in maintenance tools
- Inspired by the need for user-friendly system maintenance solutions

---

<div align="center">

**⭐ If you find this project useful, please consider giving it a star! ⭐**

Made with ❤️ for Windows users in Indonesia and around of the world

</div>

